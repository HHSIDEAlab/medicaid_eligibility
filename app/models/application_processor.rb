module ApplicationProcessor
  include ApplicationComponents

  def compute_values!
    # relationship validator
    compute_relationships!
    validate_tax_returns
    build_medicaid_households!
    calculate_household_size!
    calculate_household_income!
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
      MAGI::DenyCHIPIncarcerated,
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
    person.person_attributes["Applicant Age"] < @config["Child Age Threshold"] || (person.person_attributes["Student Indicator"] == "Y" && person.person_attributes["Applicant Age"] < @config["Student Age Threshold"])
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
      "Applicant ID" => applicant.applicant_id,
      "Person ID" => applicant.person_id,
      "Applicant List" => @applicants,
      "Person List" => @people,
      "Applicant Relationships" => applicant.relationships,
      "Medicaid Household" => @medicaid_households.find{|mh| mh.people.include?(applicant)},
      "Calculated Income" => @medicaid_households.find{|mh| mh.people.include?(applicant)}.income,
      "Physical Household" => @physical_households.find{|hh| hh.people.include?(applicant)},
      "Tax Returns" => @tax_returns
    }).slice(*(ruleset.class.inputs.keys))
    config = @config.slice(*(ruleset.class.configs.keys))
    RuleContext.new(config, input, @determination_date)
  end

  def validate_tax_returns
    for person in @people
      if @tax_returns.select{|tr| tr.filers.include?(person)}.count > 1
        raise "Invalid tax returns: #{person.person_id} is a filer on two returns"
      end
      if @tax_returns.select{|tr| tr.dependents.include?(person)}.count > 1
        raise "Invalid tax returns: #{person.person_id} is a dependent on two returns"
      end
    end
    if @tax_returns.any?{|tr| tr.filers.count > 2}
      raise "Invalid tax returns: Tax return has more than two filers"
    elsif @tax_returns.any?{|tr| tr.filers.count == 2 && tr.filers[0].get_relationship(:spouse) != tr.filers[1]}
      raise "Invalid tax returns: Tax return has joint filers who are not married"
    end
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
    @medicaid_households = []
    
    for person in @people
      filed_tax_return = @tax_returns.find{|tr| tr.filers.include?(person)}
      dependent_tax_return = @tax_returns.find{|tr| tr.dependents.include?(person)}
      parents = person.get_relationships(:parent)
      parents_stepparents = parents + person.get_relationships(:stepparent)

      # If person files a return and no one claims person as dependent, add tax
      # return people (435.603.f1)
      if filed_tax_return && !dependent_tax_return && 
        person.person_attributes["Claimed as Dependent by Person Not on Application"] != 'Y'
        med_household_members = filed_tax_return.filers + filed_tax_return.dependents
      # If spouse claims person as a dependent, include spouse (435.603.f2)
      elsif dependent_tax_return && 
        dependent_tax_return.filers.any?{|filer| filer == person.get_relationship(:spouse)}
        med_household_members = dependent_tax_return.filers
      # If parent claims person as a dependent and person lives with parent, include 
      # filers, unless person is a minor and lives with another parent (not 
      # stepparent) not on the tax return (435.603.f2) or person is a minor claimed
      # by a parent (not stepparent) they don't live with (435.603.f2) -- the set of 
      # parent claimers must be equal to the set of parents lived with
      elsif dependent_tax_return && 
        dependent_tax_return.filers.any?{|filer| parents_stepparents.include?(filer)} && 
        !(is_minor?(person) &&
          (Set.new(parents.select{|parent| live_together?(person, parent)}) != Set.new(parents.select{|parent| dependent_tax_return.filers.include?(parent)})))
        med_household_members = dependent_tax_return.filers
      # In all other cases, the household is person's children who are minors and,
      # if person is a minor, person's siblings (435.603.f3)
      elsif
        med_household_members = person.get_relationships(:child) + person.get_relationships(:stepchild)
        if is_minor?(person)
          med_household_members += person.get_relationships(:sibling).select{|sib| is_minor?(sib)}
        end
        med_household_members.select!{|member| live_together?(person, member)}
      end

      # If person lives with a spouse, add the spouse (435.603.f4)
      spouse = person.get_relationship(:spouse)
      if spouse && 
        (live_together?(person, spouse) || (filed_tax_return && filed_tax_return.filers.include?(spouse)))
        med_household_members << spouse
      end
      
      # Then dedupe and remove the person
      med_household_members.uniq!
      med_household_members.delete(person)
      
      # Your income is NOT counted if you are claimed as a tax dependent
      # on some tax return or if you are a minor and you have a parent 
      # in the medicaid household (in which case parents is not empty). 
      # Your income IS counted (overriding the above) if you are 
      # required to file taxes.
      income_counted = !dependent_tax_return && !(is_minor?(person) && parents_stepparents.any?{|parent| med_household_members.include?(parent)}) || person.person_attributes["Required to File Taxes"] == 'Y'

      med_households = @medicaid_households.select{|mh| med_household_members.any?{|mhm| mh.people.include?(mhm)}}

      # Place someone into the correct medicaid household, merging 
      # households if necessary
      if med_households.empty?
        med_household = MedicaidHousehold.new(nil, [])
        @medicaid_households << med_household
      elsif med_households.length == 1
        med_household = med_households.first
      else
        while med_households.length > 1
          last_med_household = med_households.pop
          @medicaid_households.delete(last_med_household)
          med_households.first.people += last_med_household.people
          med_households.first.income_people += last_med_household.income_people
        end
        med_household = med_households.first
      end
      
      med_household.people << person
      if income_counted
        med_household.income_people << person
      end
    end    
  end

  def calculate_household_size!
    for household in @medicaid_households
      if @config["Count Unborn Children for Household"] == "01"
        household.household_size = household.people.count + household.people.inject(0){|sum, p| sum + (p.person_attributes["Applicant Pregnant Indicator"] == 'Y' ? p.person_attributes["Number of Children Expected"] : 0)}
      elsif @config["Count Unborn Children for Household"] == "02"
        household.household_size = household.people.count + household.people.count{|p| p.person_attributes["Applicant Pregnant Indicator"] == 'Y'}
      elsif @config["Count Unborn Children for Household"] == "03"
        household.household_size = household.people.count
      else
        raise "Invalid or missing state configuration Count Unborn Children for Household"
      end  
    end
  end

  def calculate_household_income!
    for household in @medicaid_households
      non_tax_return_people = []
      tax_returns = []
      for person in household.income_people
        tax_return = @tax_returns.find{|tr| tr.filers.include?(person)}
        if tax_return && tax_return.income
          tax_returns << tax_return
        elsif person.income
          non_tax_return_people << person
        end
      end
      incomes = (tax_returns.uniq + non_tax_return_people).map{|obj| 
        obj.income[:primary_income] + 
        obj.income[:other_income].inject(0){|sum, (name, amt)| sum + amt} - 
        obj.income[:deductions].inject(0){|sum, (name, amt)| sum + amt}
      }
      household.income = incomes.sum
    end
  end
end
