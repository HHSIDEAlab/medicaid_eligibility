module ApplicationParser
  include ApplicationComponents
  
  def read_configs!
    config = MedicaidEligibilityApi::Application.options[:state_config]
    if config[@state]
      @config = config[:default].merge(config[@state])
    else
      @config = config[:default]
    end
    @config.merge!(MedicaidEligibilityApi::Application.options[:system_config])
  end

  def read_json!
    @state = @json_application["State"]
    if @json_application["Application Year"]
      unless MedicaidEligibilityApi::Application.options[:state_config][:default][:FPL].keys.include?(@json_application["Application Year"].to_s)
        raise "Invalid application year"
      end
      @application_year = @json_application["Application Year"]
    elsif Date.today >= Date.new(Date.today.year, 4, 1)
      @application_year = Date.today.year
    else
      @application_year = Date.today.year - 1
    end
    @people = []
    @applicants = []
    for json_person in @json_application["People"]
      person_id = json_person["Person ID"]
      unless (Integer(person_id) >= 1 rescue false) #person_id.is_a?(Integer) && person_id >= 1 && person_id <= 100
        #raise "Person ID #{person_id} is invalid -- Person ID should be a number between 1 and 100"
        raise "Person ID #{person_id} is invalid -- Person ID should be a number"
      end
      person_attributes = {}
      applicant_id = json_person["Applicant ID"]
      applicant_attributes = {}
      is_applicant = json_person["Is Applicant"] == 'Y'
      
      for input in ApplicationVariables::PERSON_INPUTS
        if [:relationship, :special].include? input[:group]
          next
        elsif input[:group] == :person
          person_attributes[input[:name]] = get_json_variable(json_person, input, person_attributes.merge(applicant_attributes))
        elsif input[:group] == :applicant
          applicant_attributes[input[:name]] = get_json_variable(json_person, input, person_attributes.merge(applicant_attributes))
        else
          raise "Variable #{input[:name]} has unimplemented group #{input[:group]}"
        end
      end

      # get age
      if json_person["Applicant Age >= 90"] == "Y"
        person_attributes["Applicant Age"] = 90
      elsif json_person["Applicant Age"].nil? || !(json_person["Applicant Age"].instance_of? Fixnum)
        raise "Missing or invalid Applicant Age"
      # elsif json_person["Applicant Age"] >= 90
      #   raise "MITC cannot accept ages >= 90. Please resubmit with 'Applicant Age >= 90' set to 'Y'"
      else
        person_attributes["Applicant Age"] = json_person["Applicant Age"].to_i
      end

      # get income
      income = get_json_income(json_person["Income"])
      person = Person.new(person_id, person_attributes, income, applicant_id, applicant_attributes)
      if is_applicant
        @applicants << person
      end
      @people << person
    end

    unless @people.map{|p| p.person_id}.length == @people.map{|p| p.person_id}.uniq.length
      raise "Invalid Person IDs -- each person should have a unique Person ID"
    end

    # get relationships
    for person in @people
      json_person = @json_application["People"].find{|jp| jp["Person ID"] == person.person_id}
      relationships = json_person["Relationships"]

      for relationship in relationships
        other_id = relationship["Other ID"]
        
        other_person = @people.find{|p| p.person_id == other_id}
        relationship_type = ApplicationVariables::RELATIONSHIP_INVERSE[ApplicationVariables::RELATIONSHIP_CODES[relationship["Relationship Code"]]]
        relationship_attributes = {}
        for input in ApplicationVariables::PERSON_INPUTS.select{|i| i[:group] == :relationship}
          relationship_attributes[input[:name]] = get_json_variable(relationship, input, person_attributes.merge(applicant_attributes))
        end

        person.relationships << Relationship.new(other_person, relationship_type, relationship_attributes)
      end
    end

    # get tax returns
    @tax_returns = []
    for json_return in @json_application["Tax Returns"]
      filers = []
      json_filers = json_return["Filers"]

      filers = json_return["Filers"].map{|jf|
        @people.find{|p| p.person_id == jf["Person ID"]}
      }
      
      dependents = json_return["Dependents"].map{|jd|
        @people.find{|p| p.person_id == jd["Person ID"]}
      }

      @tax_returns << TaxReturn.new(filers, dependents)
    end

    # get physical households
    @physical_households = []
    for json_household in @json_application["Physical Households"]
      @physical_households << Household.new(json_household["Household ID"], json_household["People"].map{|jp| @people.find{|p| p.person_id == jp["Person ID"]}})
    end
  end

  private

  def get_json_variable(json_object, input, attributes)
    get_variable(json_object[input[:name]], input, attributes)
  end

  def get_json_income(json_income)
    income_fields = ApplicationVariables::INCOME_INPUTS
    income = {incomes: {}, deductions: {}}

    if json_income
      for income_field in income_fields[:incomes]
        income[:incomes][income_field] = get_json_income_field(json_income[income_field], income_field, :positive)
      end

      for income_field in income_fields[:gains_losses]
        income[:incomes][income_field] = get_json_income_field(json_income[income_field], income_field, :either)
      end

      for income_field in income_fields[:deductions]
        income[:deductions][income_field] = get_json_income_field(json_income[income_field], income_field, :positive)
      end
    end

    income
  end

  def get_json_income_field(amount, income_field, income_type)
    if income_type == :positive && amount.to_i < 0
      raise "Invalid income: #{income_field} cannot be negative"
    end

    amount.to_i
  end

  def get_variable(value, input, attributes)
    if value.blank?
      if input[:required] || (input[:required_if] && attributes[input[:required_if]] == input[:required_if_value])
        raise "Input missing required variable #{input[:name]}"
      elsif input[:default]
        if MedicaidEligibilityApi::Application.options[:system_config]["Allow Blank Booleans"] 
          return input[:default]
        else
          raise "Input missing variable #{input[:name]}"
        end
      else
        return nil
      end
    end

    if input[:type] == :integer
      value.to_i
    elsif input[:type] == :flag
      if input[:values].include? value
        value
      elsif ['true', true].include? value
        'Y'
      elsif ['false', false].include? value
        'N'
      else
        raise "Invalid value #{value} for variable #{input[:name]}"
      end 
    elsif input[:type] == :string
      value
    elsif input[:type] == :date
      Date.parse(value)
    else
      raise "Variable #{input[:name]} has unimplemented type #{input[:type]}"
    end
  end
end
