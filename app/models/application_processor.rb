module ApplicationProcessor
  include ApplicationComponents
  include ApplicationValidator

  class RelationshipError < StandardError
  end

  def compute_values!
    compute_relationships!

    for person in @people
      validate_relationships! person
      validate_physical_households person, @physical_households
    end
    validate_tax_returns @people, @tax_returns

    build_medicaid_households!
  end

  def process_rules!
    rulesets = [
      MAGI::Residency,
      MAGI::ParentCaretakerRelative,
      MAGI::ParentCaretakerRelativeSpouse,
      MAGI::Pregnant,
      MAGI::Child,
      MAGI::AdultGroup,
      MAGI::OptionalTargetedLowIncomeChildren,
      MAGI::TargetedLowIncomeChildren,
      MAGI::ReferralType,
      MAGI::Income,
      MAGI::Immigration,
      MAGI::PreliminaryMedicaid,
      MAGI::PreliminaryCHIP,
      MAGI::FormerFosterCare,
      MAGI::IncomeOverride,
      MAGI::OptionalUnbornChild,
      MAGI::PublicEmployeesBenefits,
      MAGI::CHIPWaitingPeriod,
      MAGI::CHIPEligibility,
      MAGI::DependentChildCovered,
      MAGI::MedicaidEligibility,
      MAGI::EmergencyMedicaid,
      MAGI::RefugeeAssistance
    ].map{|ruleset_class| ruleset_class.new()}

    for ruleset in rulesets
      for applicant in @applicants
        context = to_context(ruleset, applicant)
        ruleset.run(context)
        from_context!(applicant, context)
      end
    end
  end

  private

  def is_minor?(person)
    person.person_attributes["Applicant Age"] < @config["Child Age Threshold"] || 
    (@config["Option Householding Minor Student"] == "Y" &&
     person.person_attributes["Student Indicator"] == "Y" && 
     person.person_attributes["Applicant Age"] < @config["Student Age Threshold"])
  end

  def live_together?(person1, person2)
    @physical_households.any?{|hh| hh.people.include?(person1) && hh.people.include?(person2)}
  end

  def from_context!(applicant, context)
    applicant.outputs.merge!(context.output)
  end

  def to_context(ruleset, applicant)
    input = applicant.applicant_attributes.merge(applicant.person_attributes).merge(applicant.outputs)
    input.merge!({
      "State" => @state,
      "Application Year" => @application_year,
      "Person ID" => applicant.person_id,
      "Applicant List" => @applicants,
      "Person List" => @people,
      "Applicant Relationships" => applicant.relationships,
      "Medicaid Household" => applicant.medicaid_household,
      "Calculated Income" => applicant.medicaid_household.income,
      "Physical Household" => @physical_households.find{|hh| hh.people.include?(applicant)},
      "Tax Returns" => @tax_returns
    }).slice(*(ruleset.class.inputs.keys))
    config = @config.slice(*(ruleset.class.configs.keys))
    RuleContext.new(config, input, @determination_date)
  end

  def compute_relationships!
    for person in @people
      for rel in person.relationships
        inverse_relationship = rel.person.relationships.find{|rel| rel.person == person}
        if inverse_relationship
          unless inverse_relationship.relationship_type == ApplicationVariables::RELATIONSHIP_INVERSE[rel.relationship_type]
            raise "Inconsistent relationships between #{person.person_id} and #{rel.person.person_id}"
          end
        else
          rel.person.relationships << Relationship.new(person, ApplicationVariables::RELATIONSHIP_INVERSE[rel.relationship_type], {})
        end
      end
    end
  end

  def build_medicaid_households!
    for person in @people
      person.medicaid_household = determine_household(person)
    end
  end

  def determine_household(person)
    filed_tax_return = @tax_returns.find{|tr| tr.filers.include?(person)}
    dependent_tax_return = @tax_returns.find{|tr| tr.dependents.include?(person)}
    parents = person.get_relationships(:parent)
    parents_stepparents = parents + person.get_relationships(:stepparent)

    # If person files a return and no one claims person as dependent, household consists
    # of filers and dependents on tax return (435.603.f1)
    if filed_tax_return && !dependent_tax_return && 
      person.person_attributes["Claimed as Dependent by Person Not on Application"] != 'Y'

      med_household_members = filed_tax_return.filers + filed_tax_return.dependents
    # If spouse claims person as a dependent, household is spouse's household (435.603.f2)
    elsif dependent_tax_return && 
      dependent_tax_return.filers.any?{|filer| filer == person.get_relationship(:spouse)}

      med_household_members = determine_household(person.get_relationship(:spouse)).people
    # If parent/stepparent(s) claims person as a dependent, household is household of 
    # parent/stepparent(s) claiming person (435.603.f2)
    elsif dependent_tax_return && 
      dependent_tax_return.filers.any?{|filer| parents_stepparents.include?(filer)} &&
      # except if the person is a minor (as defined by 435.603.f3.iv) and 
      # either the person's parents live together and do not file jointly (435.603.f2.ii)
      # or the claiming parent does not live with the claimed person (435.603.f2.iii)
      !(
        is_minor?(person) &&
        (
          parents.any?{|parent| live_together?(person, parent) && !(dependent_tax_return.filers.include?(parent))} ||
          parents.any?{|parent| !(live_together?(person, parent)) && dependent_tax_return.filers.include?(parent)}
        )
      )

      filers = dependent_tax_return.filers.select{|filer| parents_stepparents.include?(filer)}
      med_household_members = filers.map{|filer| determine_household(filer).people}.reduce(:+)
    # In all other cases, the household is person's children who are minors and,
    # if person is a minor, person's siblings who are minors and the person's parents (435.603.f3)
    else
      med_household_members = person.get_relationships(:child) + person.get_relationships(:stepchild)
      med_household_members.select!{|member| is_minor?(member)}
      if is_minor?(person)
        med_household_members += person.get_relationships(:sibling).select{|sib| is_minor?(sib)} + parents_stepparents
      end
      med_household_members.select!{|member| live_together?(person, member)}
    end

    # If person lives with a spouse, add the spouse (435.603.f4)
    spouse = person.get_relationship(:spouse)
    if spouse && 
      (live_together?(person, spouse) || (filed_tax_return && filed_tax_return.filers.include?(spouse)))
      med_household_members << spouse
    end
    
    # Then add the person and dedupe
    med_household_members << person
    med_household_members.uniq!

    income_people = count_income_people(med_household_members)
    income = calculate_household_income(med_household_members, income_people)
    household_size = calculate_household_size(person, med_household_members)

    return MedicaidHousehold.new(nil, med_household_members, income_people, income, household_size)
  end

  def count_income_people(people)
    income_people = []
    for person in people
      dependent_tax_return = @tax_returns.find{|tr| tr.dependents.include?(person)}
      parents_stepparents = person.get_relationships(:parent) + person.get_relationships(:stepparent)

      # Your income is NOT counted if you are claimed as a tax dependent
      # on some tax return or if you are a minor and you have a parent/stepparent 
      # Your income IS counted (overriding the above) if you are 
      # required to file taxes.
      if !dependent_tax_return &&
         !(is_minor?(person) &&
           parents_stepparents.any?{|parent| people.include?(parent)}) ||
         person.person_attributes["Required to File Taxes"] == 'Y'
        income_people << person
      end
    end
    return income_people
  end

  def calculate_household_size(person, med_household_members)
    if person.person_attributes["Applicant Pregnant Indicator"] == 'Y'
      persons_unborn_children = person.person_attributes["Number of Children Expected"]
    else
      persons_unborn_children = 0
    end

    # If option 01, count the number of children expected for each pregnanct woman
    if @config["Count Unborn Children for Household"] == "01"
      return med_household_members.count +
        med_household_members.inject(0){|sum, p| sum +
          (p.person_attributes["Applicant Pregnant Indicator"] == 'Y' ? 
            p.person_attributes["Number of Children Expected"] : 0)
        }
    # If option 02, count 1 extra for each pregnant woman
    # But always count unborn children in the pregnant woman's household
    elsif @config["Count Unborn Children for Household"] == "02"
      return med_household_members.count +
        med_household_members.count{|p| p.person_attributes["Applicant Pregnant Indicator"] == 'Y'} +
        (persons_unborn_children == 0 ? 0 : persons_unborn_children - 1)
    # If option 03, don't count unborn children
    # But always count unborn children in the pregnant woman's household
    elsif @config["Count Unborn Children for Household"] == "03"
      return med_household_members.count + persons_unborn_children
    else
      raise "Invalid or missing state configuration Count Unborn Children for Household"
    end
  end

  def calculate_household_income(people, income_people)
    income_people.select{|p| p.income}.map{|p|
      p.income[:incomes].inject(0){|sum, (name, amt)| sum + amt} - 
      p.income[:deductions].inject(0){|sum, (name, amt)| sum + amt}
    }.sum
  end
end
