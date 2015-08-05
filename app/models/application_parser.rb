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
      unless person_id.is_a?(Integer) && person_id >= 1 #&& person_id <= 100
        #raise "Person ID #{person_id} is invalid -- Person ID should be a number between 1 and 100"
        raise "Person ID #{person_id} is invalid -- Person ID should be a number"
      end
      person_attributes = {}
      applicant_id = json_person["Applicant ID"]
      applicant_attributes = {}
      is_applicant = json_person["Is Applicant"] == 'Y'
      
      for input in ApplicationVariables::PERSON_INPUTS
        if [:relationship, :special].include? input[:group] || (!(is_applicant) && input[:group] == :applicant)
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
      elsif json_person["Applicant Age"] >= 90
        raise "MITC cannot accept ages >= 90. Please resubmit with 'Applicant Age >= 90' set to 'Y'"
      else
        person_attributes["Applicant Age"] = json_person["Applicant Age"].to_i
      end

      # get income
      income = get_json_income(json_person["Income"], :personal)

      if is_applicant
        person = Applicant.new(person_id, person_attributes, applicant_id, applicant_attributes, income)
        @applicants << person
      else
        person = Person.new(person_id, person_attributes, income)
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

      income = get_json_income(json_return["Income"], :tax_return)

      @tax_returns << TaxReturn.new(filers, dependents, income)
    end

    # get physical households
    @physical_households = []
    for json_household in @json_application["Physical Households"]
      @physical_households << Household.new(json_household["Household ID"], json_household["People"].map{|jp| @people.find{|p| p.person_id == jp["Person ID"]}})
    end
  end

  def read_xml!
    @state = get_node("/exch:AccountTransferRequest/ext:TransferHeader/ext:TransferActivity/ext:RecipientTransferActivityStateCode").inner_text
    @people = []
    @applicants = []
    
    xml_people = get_nodes "/exch:AccountTransferRequest/hix-core:Person"
    
    for xml_person in xml_people
      person_id = xml_person.attribute('id').value
      person_attributes = {}

      xml_app = get_nodes("/exch:AccountTransferRequest/hix-ee:InsuranceApplication/hix-ee:InsuranceApplicant").find{
        |x_app| x_app.at_xpath("hix-core:RoleOfPersonReference").attribute('ref').value == person_id
      }
      if xml_app
        applicant_id = xml_app.attribute('id').value
        applicant_attributes = {}
      end
      
      for input in ApplicationVariables::PERSON_INPUTS
        if input[:xpath] == :unimplemented
          raise "Variable #{input[:name]} has unimplemented xpath"
        end

        if input[:group] == :person
          node = xml_person.at_xpath(input[:xpath])
        elsif input[:group] == :applicant
          unless xml_app
            next
          end
          node = xml_app.at_xpath(input[:xpath])
        elsif input[:group] == :relationship
          next
        else
          raise "Variable #{input[:name]} has unimplemented xml group #{input[:group]}"
        end

        attr_value = get_xml_variable(node, input, person_attributes.merge(applicant_attributes))
        
        if input[:group] == :person
          person_attributes[input[:name]] = attr_value
        elsif input[:group] == :applicant
          applicant_attributes[input[:name]] = attr_value
        end
      end

      if xml_app
        person = Applicant.new(person_id, person_attributes, applicant_id, applicant_attributes)
        @applicants << person
      else
        person = Person.new(person_id, person_attributes)
      end
      @people << person
    end

    # get relationships
    for person in @people
      xml_person = get_nodes("/exch:AccountTransferRequest/hix-core:Person").find{
        |x_person| x_person.attribute('id').value == person.person_id
      }
      relationships = get_nodes("hix-core:PersonAugmentation/hix-core:PersonAssociation", xml_person)

      for relationship in relationships
        other_id = get_node("nc:PersonReference", relationship).attribute('ref').value
        
        other_person = @people.find{|p| p.person_id == other_id}
        relationship_type = ApplicationVariables::RELATIONSHIP_CODES[get_node("hix-core:FamilyRelationshipCode", relationship).inner_text]
        relationship_attributes = {}
        for input in ApplicationVariables::PERSON_INPUTS.select{|i| i[:group] == :relationship}
          node = get_node(input[:xpath], relationship)

          relationship_attributes[input[:name]] = get_xml_variable(node, input, person_attributes.merge(applicant_attributes))
        end

        person.relationships << Relationship.new(other_person, relationship_type, relationship_attributes)
      end
    end

    # get tax returns
    @tax_returns = []
    xml_tax_returns = get_nodes("/exch:AccountTransferRequest/hix-ee:TaxReturn")
    for xml_return in xml_tax_returns
      filers = []
      xml_filers = [
        get_node("hix-ee:TaxHousehold/hix-ee:PrimaryTaxFiler", xml_return),
        get_node("hix-ee:TaxHousehold/hix-ee:SpouseTaxFiler", xml_return)
      ]

      filers = xml_filers.select{|xf| xf}.map{|xf|
        @people.find{|p| p.person_id == get_node("hix-core:RoleOfPersonReference", xf).attribute('ref').value}
      }
      
      dependents = get_nodes("hix-ee:TaxHousehold/hix-ee:PrimaryTaxFiler/RoleOfPersonReference", xml_return).map{|node|
        @people.find{|p| p.person_id == node.attribute('ref').value}
      }

      @tax_returns << TaxReturn.new(filers, dependents)
    end

    # get physical households
    @physical_households = []
    xml_physical_households = get_nodes("/exch:AccountTransferRequest/ext:PhysicalHousehold")
    for xml_household in xml_physical_households
      person_references = get_nodes("hix-ee:HouseholdMemberReference", xml_household).map{|node| node.attribute('ref').value}

      @physical_households << Household.new(nil, person_references.map{|ref| @people.find{|p| p.person_id == ref}})
    end
  end

  private

  def get_json_variable(json_object, input, attributes)
    get_variable(json_object[input[:name]], input, attributes)
  end

  def get_json_income(json_income, income_type)
    income = {}
    income_calculation = ApplicationVariables::INCOME_INPUTS[income_type]
    if json_income && json_income[income_calculation[:primary_income]]
      income[:primary_income] = json_income[income_calculation[:primary_income]].to_i
      income[:other_income] = {}
      for other_income in income_calculation[:other_income]
        income[:other_income][other_income] = (json_income[other_income] || 0).to_i
      end
      income[:deductions] = {}
      for deduction in income_calculation[:deductions]
        income[:deductions][deduction] = (json_income[deduction] || 0).to_i
      end
    end
    
    if income.empty?
      nil
    else
      income
    end
  end

  def get_xml_variable(node, input, attributes)
    unless node
      get_variable(nil, input, attributes)
    end

    get_variable(node.inner_text, input, attributes)
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

  def get_node(xpath, start_node=@xml_application)
      start_node.at_xpath(xpath, XML_NAMESPACES)
    end

  def get_nodes(xpath, start_node=@xml_application)
    start_node.xpath(xpath, XML_NAMESPACES)
  end
end
