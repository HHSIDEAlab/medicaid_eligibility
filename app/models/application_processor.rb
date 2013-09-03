module ApplicationProcessor
  include ApplicationComponents
  
  def compute_values!
    # relationship validator/filler
    build_medicaid_households!
  end

  def process_rules!
    rulesets = [
      MAGI::ParentCaretakerRelative,
      MAGI::ParentCaretakerRelativeSpouse,
      MAGI::Pregnant,
      MAGI::Child,
      MAGI::AdultGroup,
      MAGI::OptionalTargetedLowIncomeChildren,
      MAGI::TargetedLowIncomeChildren,
      MAGI::ReferralType,
      MAGI::Income
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

  def from_context!(applicant, context)
    applicant.outputs.merge!(context.output)
  end

  def to_context(ruleset, applicant)
    input = applicant.applicant_attributes.merge(applicant.person_attributes).merge(applicant.outputs)
    input.merge!({
      "Applicant ID" => applicant.applicant_id,
      "Person ID" => applicant.person_id,
      "Applicant List" => @applicants,
      "Person List" => @people,
      "Applicant Relationships" => applicant.relationships,
      "Medicaid Household" => @medicaid_households.find{|mh| mh.people.include?(applicant)},
      "Physical Household" => @physical_households.find{|hh| hh.people.include?(applicant)},
      "Tax Returns" => @tax_returns
    }).slice(*(ruleset.class.inputs.keys))
    config = @config.slice(*(ruleset.class.configs.keys))
    RuleContext.new(config, input, @determination_date)
  end

  def build_medicaid_households!
    @medicaid_households = []
    
    for person in @people
      physical_household = @physical_households.find{|ph| ph.people.include? person}

      tax_return = @tax_returns.find{|tr| tr.filers.include?(person) || tr.dependents.include?(person)}
      if tax_return
        tax_return_people = tax_return.filers + tax_return.dependents
      else
        tax_return_people = []
      end

      spouses = person.relationships.select{|r| r.relationship_type == :spouse && physical_household.people.include?(r.person)}.map{|r| r.person}

      if is_minor?(person)
        siblings = person.relationships.select{|r| r.relationship_type == :sibling && physical_household.people.include?(r.person) && is_minor?(r.person)}.map{|r| r.person}
      else
        siblings = []
      end

      if is_minor?(person)
        parents = person.relationships.select{|r| [:parent, :stepparent].include?(r.relationship_type) && physical_household.people.include?(r.person)}.map{|r| r.person}
      else
        parents = []
      end

      children = person.relationships.select{|r| [:child, :stepchild].include?(r.relationship_type) && physical_household.people.include?(r.person) && is_minor?(r.person)}.map{|r| r.person}

      med_household_members = (tax_return_people + spouses + siblings + parents + children).uniq
      med_household_members.delete(person)
      
      # Your income is NOT counted if you are claimed as a tax dependent
      # on some tax return or if you are a minor and you have a parent 
      # in the medicaid household (in which case parents is not empty). 
      # Your income IS counted (overriding the above) if you are 
      # required to file taxes.
      income_counted = !(tax_return && tax_return.dependents.include?(person)) && parents.empty? || person.person_attributes["Required to File Taxes"] == 'Y'

      med_households = @medicaid_households.select{|mh| med_household_members.any?{|mhm| mh.people.include?(mhm)}}

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
end
