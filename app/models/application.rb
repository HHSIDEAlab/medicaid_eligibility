class Application
  class Person
    attr_reader :person_id, :person_attributes, :income
    attr_accessor :relationships

    def initialize(person_id, person_attributes, income)
      @person_id = person_id
      @person_attributes = person_attributes
      @relationships = []
      @income = income
    end
  end

  class Applicant < Person
    attr_reader :applicant_id, :applicant_attributes
    attr_accessor :outputs

    def initialize(person_id, person_attributes, applicant_id, applicant_attributes, income)
      super person_id, person_attributes, income
      @applicant_id = applicant_id
      @applicant_attributes = applicant_attributes
      @outputs = {}
    end
  end

  class Relationship
    attr_reader :person, :relationship, :relationship_attributes

    def initialize(person, relationship, relationship_attributes)
      @person = person
      @relationship = relationship
      @relationship_attributes = relationship_attributes
    end
  end

  class Household
    attr_accessor :people
    attr_reader :household_id

    def initialize(household_id, people)
      @household_id = household_id
      @people = people
    end
  end

  class MedicaidHousehold < Household
    attr_accessor :income_people

    def initialize(household_id, people)
      super
      @income_people = []
    end
  end

  class TaxReturn
    attr_reader :filers, :dependents

    def initialize(filers, dependents)
      @filers = filers
      @dependents = dependents
    end
  end

  #attr_reader :state, :applicants, :people, :physical_households, :tax_households, :medicaid_households, :tax_returns, :config

  XML_NAMESPACES = {
    "exch"     => "http://at.dsh.cms.gov/exchange/1.0",
    "s"        => "http://niem.gov/niem/structures/2.0", 
    "ext"      => "http://at.dsh.cms.gov/extension/1.0",
    "hix-core" => "http://hix.cms.gov/0.1/hix-core", 
    "hix-ee"   => "http://hix.cms.gov/0.1/hix-ee",
    "nc"       => "http://niem.gov/niem/niem-core/2.0", 
    "hix-pm"   => "http://hix.cms.gov/0.1/hix-pm",
    "scr"      => "http://niem.gov/niem/domains/screening/2.1"
  }

  def initialize(raw_application, content_type, return_application)
    @raw_application = raw_application
    @content_type = content_type    
    @determination_date = Date.today
    @return_application = return_application
  end

  def result(return_type)
    if @content_type == 'application/xml'
      @xml_application = Nokogiri::XML(@raw_application) do |config|
        config.default_xml.noblanks
      end
      read_xml!
    elsif @content_type == 'application/json'
      @json_application = JSON.parse(@raw_application)
      read_json!
    end
    read_configs!
    compute_values!

    process_rules!
    # to_hash
    if return_type == :xml
      to_xml
    elsif return_type == :json
      to_json
    end
  end

  private

  def validate
  end

  def get_node(xpath, start_node=@xml_application)
    start_node.at_xpath(xpath, XML_NAMESPACES)
  end

  def get_nodes(xpath, start_node=@xml_application)
    start_node.xpath(xpath, XML_NAMESPACES)
  end

  def find_or_create_node(node, xpath)
    xpath = xpath.gsub(/^\/+/,'')
    if xpath.empty?
      node
    elsif get_node(xpath, node)
      get_node(xpath, node)
    else
      xpath_list = xpath.split('/')
      next_node = get_node(xpath_list.first, node)
      if next_node
        find_or_create_node(next_node, xpath_list[1..-1].join('/'))
      else
        Nokogiri::XML::Builder.with(node) do |xml|
          xml.send(xpath_list.first)
        end

        find_or_create_node(get_node(xpath_list.first, node), xpath_list[1..-1].join('/'))
      end
    end
  end

  def return_application?
    @return_application
  end

  def read_configs!
    config = MedicaidEligibilityApi::Application.options[:state_config]
    if config[@state]
      @config = config[:default].merge(config[@state])
    else
      @config = config[:default]
    end
    @config.merge!(MedicaidEligibilityApi::Application.options[:system_config])
  end

  def read_xml!
    @people = []
    @applicants = []
    @state = get_node("/exch:AccountTransferRequest/ext:TransferHeader/ext:TransferActivity/ext:RecipientTransferActivityStateCode").inner_text
    
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
        relationship_code = ApplicationVariables::RELATIONSHIP_CODES[get_node("hix-core:FamilyRelationshipCode", relationship).inner_text]
        relationship_attributes = {}
        for input in ApplicationVariables::PERSON_INPUTS.select{|i| i[:group] == :relationship}
          node = get_node(input[:xpath], relationship)

          relationship_attributes[input[:name]] = get_xml_variable(node, input, person_attributes.merge(applicant_attributes))
        end

        person.relationships << Relationship.new(other_person, relationship_code, relationship_attributes)
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

  def get_xml_variable(node, input, attributes)
    unless node
      get_variable(nil, input, attributes)
    end

    get_variable(node.inner_text, input, attributes)
  end

  def to_xml
    Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
      xml.send("exch:AccountTransferRequest", Hash[XML_NAMESPACES.map{|k, v| ["xmlns:#{k}", v]}]) {
        xml.send("ext:TransferHeader") {
          xml.send("ext:TransferActivity") {
            xml.send("nc:ActivityIdentification") {
              # Need Identification ID
            }
            xml.send("nc:ActivityDate") {
              xml.send("nc:DateTime", Time.now.strftime("%Y-%m-%dT%H:%M:%S"))
            }
            xml.send("ext:TransferActivityReferralQuantity", @applicants.length)
            xml.send("ext:RecipientTransferActivityCode", "MedicaidCHIP")
            xml.send("ext:RecipientTransferActivityStateCode", @state)
          }
        }
        xml.send("hix_core:Sender") {
          # Need to figure out what to put here
        }
        xml.send("hix_core:Receiver") {
          # Need to figure out what to put here
        }
        xml.send("hix-ee:InsuranceApplication") {
          xml.send("hix-core:ApplicationCreation") {
            # Need to figure out what to put here
          }
          xml.send("hix-core:ApplicationSubmission") {
            # Need to figure out what to put here
          }
          # Do we want Application Identification?
          @applicants.each do |applicant|
            xml.send("hix-ee:InsuranceApplicant", {"s:id" => applicant.applicant_id}) {
              xml.send("hix-ee:MedicaidMAGIEligibility") {
                ApplicationVariables::DETERMINATIONS.select{|det| det[:eligibility] == :MAGI}.each do |determination|
                  det_name = determination[:name]
                  xml.send("hix-ee:MedicaidMAGI#{det_name.gsub(/ +/,'')}EligibilityBasis") {
                    build_determinations(xml, det_name, applicant)
                    if det_name == "Parent Caretaker Category"
                      xml.send("ChildrenEligibilityBasis") {
                        applicant.outputs["Children List"].each do |child|
                          xml.send("Child", {"s:ref" => child["Person ID"]}) {
                            ApplicationVariables::CHILD_OUTPUTS.each do |output|
                              xml.send(output[:name].gsub(/ +/,'')) {
                                xml.send("EligibilityBasisStatusIndicator", child["#{output[:name]} Indicator"])
                                xml.send("DateTime", child["#{output[:name]} Determination Date"])
                                xml.send("EligibilityBasisIneligibilityReasonText", child["#{output[:name]} Ineligibility Reason"])
                              }
                            end
                          }
                        end
                      }
                    end
                  }
                end
                ApplicationVariables::OUTPUTS.select{|o| o[:group] == :MAGI}.each do |output|
                  xml.send(output[:xpath], applicant.outputs[output[:name]])
                end
              }
              xml.send("hix-ee:CHIPEligibility") {
                ApplicationVariables::DETERMINATIONS.select{|det| det[:eligibility] == :CHIP}.each do |determination|
                  det_name = determination[:name]
                  xml.send("hix-ee:#{det_name.gsub(/ +/,'')}EligibilityBasis") {
                    build_determinations(xml, det_name, applicant)
                  }
                end
              }
              xml.send("hix-ee:MedicaidNonMAGIEligibility") {
                det_name = "Medicaid Non-MAGI Referral"
                xml.send("hix-ee:EligibilityIndicator", applicant.outputs["Applicant #{det_name} Indicator"])
                xml.send("hix-ee:EligibilityDetermination") {
                  xml.send("nc:ActivityDate") {
                    xml.send("nc:DateTime", applicant.outputs["#{det_name} Determination Date"].strftime("%Y-%m-%d"))
                  }
                }
                xml.send("hix-ee:EligibilityReasonText", applicant.outputs["#{det_name} Ineligibility Reason"])
              }
            }
          end
        }
        if return_application?
          @people.each do |person|
            xml.send("hix-core:Person", {"s:id" => person.person_id}) {

            }
          end
          @physical_households.each do |household|
            xml.send("ext:PhysicalHousehold") {
              household.people.each do |person|
                xml.send("hix-ee:HouseholdMemberReference", {"s:ref" => person.person_id})
              end
            }
          end
        end
      }
    end
  end

  def build_determinations(xml, det_name, applicant)
    xml.send("hix-ee:EligibilityBasisStatusIndicator", applicant.outputs["Applicant #{det_name} Indicator"])
    xml.send("hix-ee:EligibilityBasisDetermination") {
      xml.send("nc:ActivityDate") {
        xml.send("nc:DateTime", applicant.outputs["#{det_name} Determination Date"].strftime("%Y-%m-%d"))
      }
    }
    xml.send("hix-ee:EligibilityBasisIneligibilityReasonText", applicant.outputs["#{det_name} Ineligibility Reason"])
  end

  def build_xpath(xml, xpath)
    xpath = xpath.gsub(/^\/+/,'')
    unless xpath.empty?
      xpath_list = xpath.split('/')
      xml.send(xpath_list.first) {
        build_path(xml, xpath_list[1..-1].join('/'))
      }
    end
  end

  def read_json!
    @state = @json_application["State"]
    @people = []
    @applicants = []
    for json_person in @json_application["People"]
      person_id = json_person["Person ID"]
      person_attributes = {}
      applicant_id = json_person["Applicant ID"]
      applicant_attributes = {}
      is_applicant = json_person["Is Applicant"] == 'Y'
      
      for input in ApplicationVariables::PERSON_INPUTS
        if input[:group] == :relationship || (!(is_applicant) && input[:group] == :applicant)
          next
        elsif input[:group] == :person
          person_attributes[input[:name]] = get_json_variable(json_person, input, person_attributes.merge(applicant_attributes))
        elsif input[:group] == :applicant
          applicant_attributes[input[:name]] = get_json_variable(json_person, input, person_attributes.merge(applicant_attributes))
        else
          raise "Variable #{input[:name]} has unimplemented group #{input[:group]}"
        end
      end

      # get income
      json_income = json_person["Income"]
      income = {}
      for income_calculation in ApplicationVariables::INCOME_INPUTS
        if json_income[income_calculation[:primary_income]]
          income[:primary_income] = json_income[income_calculation[:primary_income]].to_i
          income[:other_income] = {}
          for other_income in income_calculation[:other_income]
            income[:other_income][other_income] = (json_income[other_income] || 0).to_i
          end
          income[:deductions] = {}
          for deduction in income_calculation[:deductions]
            income[:deductions][deduction] = (json_income[deduction] || 0).to_i
          end
          break
        end
      end
      if income.empty?
        raise "No income for person #{person_id}"
      end

      if is_applicant
        person = Applicant.new(person_id, person_attributes, applicant_id, applicant_attributes, income)
        @applicants << person
      else
        person = Person.new(person_id, person_attributes, income)
      end
      @people << person
    end

    # get relationships
    for person in @people
      json_person = @json_application["People"].find{|jp| jp["Person ID"] == person.person_id}
      relationships = json_person["Relationships"]

      for relationship in relationships
        other_id = relationship["Other ID"]
        
        other_person = @people.find{|p| p.person_id == other_id}
        relationship_code = ApplicationVariables::RELATIONSHIP_CODES[relationship["Relationship Code"]]
        relationship_attributes = {}
        for input in ApplicationVariables::PERSON_INPUTS.select{|i| i[:group] == :relationship}
          relationship_attributes[input[:name]] = get_json_variable(relationship, input, person_attributes.merge(applicant_attributes))
        end

        person.relationships << Relationship.new(other_person, relationship_code, relationship_attributes)
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

  def get_json_variable(json_object, input, attributes)
    get_variable(json_object[input[:name]], input, attributes)
  end

  def get_variable(value, input, attributes)
    if value.blank?
      if input[:required] || (input[:required_if] && attributes[input[:required_if]] == input[:required_if_value])
        raise "Input missing required variable #{input[:name]}"
      elsif input[:default]
        return input[:default]
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

  def to_json
    returned_json = {"Determination Date" => @determination_date, "Applicants" => []}
    for app in @applicants
      app_json = {}
      app_json["Person ID"] = app.person_id
      app_json["Determinations"] = {}

      app_json["Determinations"]["Applicant Parent Caretaker Category Indicator"] = app.outputs["Applicant Parent Caretaker Category Indicator"]
      ineligibility_reason = app.outputs["Parent Caretaker Category Ineligibility Reason"]
      if ineligibility_reason != 999
        app_json["Determinations"]["Parent Caretaker Category Ineligibility Reason"] = ineligibility_reason
      end
      app_json["Determinations"]["Qualified Children List"] = app.outputs["Qualified Children List"]

      for det in ApplicationVariables::DETERMINATIONS.select{|d| !(["Parent Caretaker Category", "Income"].include?(d[:name]))}
        app_json["Determinations"]["Applicant #{det[:name]} Indicator"] = app.outputs["Applicant #{det[:name]} Indicator"]
        ineligibility_reason = app.outputs["#{det[:name]} Ineligibility Reason"]
        if ineligibility_reason != 999
          app_json["Determinations"]["#{det[:name]} Ineligibility Reason"] = ineligibility_reason
        end
      end

      app_json["Determinations"]["Applicant Income Determination Indicator"] = app.outputs["Applicant Income Indicator"]
      ineligibility_reason = app.outputs["Income Determination Date"]
      if ineligibility_reason != 999
        app_json["Determinations"]["Income Determination Date"] = ineligibility_reason
      end
      for output in ["Category Used to Calculate Income", "Calculated Income"]#, "Percentage Used", "FPL * Percentage + 5%"]
        app_json["Determinations"][output] = app.outputs[output]
      end

      returned_json["Applicants"] << app_json
    end

    returned_json
    # @applicants.map{|a|
    #   {
    #     "Person ID" => a.person_id,
    #     "Determinations" => a.outputs
    #   }
    # }
  end

  def compute_values!
    build_medicaid_households!
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

      spouses = person.relationships.select{|r| r.relationship == :spouse && physical_household.people.include?(r.person)}.map{|r| r.person}

      if is_child?(person)
        siblings = person.relationships.select{|r| r.relationship == :sibling && physical_household.people.include?(r.person) && is_child(r.person)}.map{|r| r.person}
      else
        siblings = []
      end

      if is_child?(person)
        parents = person.relationships.select{|r| [:parent, :stepparent].include?(r.relationship) && physical_household.people.include?(r.person)}.map{|r| r.person}
      else
        parents = []
      end

      children = person.relationships.select{|r| [:child, :stepchild].include?(r.relationship) && physical_household.people.include?(r.person) && is_child?(r.person)}.map{|r| r.person}

      med_household_members = (tax_return_people + spouses + siblings + parents + children).uniq
      med_household_members.delete(person)
      
      income_counted = !((tax_return && tax_return.dependents.include?(person)) || parents.any?) || person.person_attributes["Required to File Taxes"] == 'Y'

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

  def is_child?(person)
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
      "Applicant Relationships" => applicant.relationships || [],
      "Medicaid Household" => @medicaid_households.find{|mh| mh.people.include?(applicant)},
      "Physical Household" => @physical_households.find{|hh| hh.people.include?(applicant)},
      "Tax Returns" => @tax_returns || []
    }).slice(*(ruleset.class.inputs.keys))
    config = @config.slice(*(ruleset.class.configs.keys))
    RuleContext.new(config, input, @determination_date)
  end

  def to_hash()
    {
      :config => @config,
      :applicants => @applicants.map{|a|
        {
          :id => a.applicant_id,
          :person_id => a.person_id,
          :attributes => a.applicant_attributes.merge(a.person_attributes),
          :income => {
            :primary_income => a.income[:primary_income],
            :other_income => a.income[:other_income],
            :deductions => a.income[:deductions]
          },
          :relationships => (a.relationships || []).map{|r|
            {
              :other_id => r.person.person_id,
              :relationship => r.relationship,
              :attributes => r.relationship_attributes
            }
          },
          :outputs => a.outputs
        }
      },
      :physical_households => @physical_households.map{|ph|
        ph.people.map{|p|
          {
            :person_id => p.person_id
          }
        }
      },
      :medicaid_households => @medicaid_households.map{|mh|
        mh.people.map{|p|
          {
            :person_id => p.person_id,
            :income_counted => mh.income_people.include?(p)
          }
        }
      },
      :tax_returns => @tax_returns.map{|tr|
        {
          :filers => tr.filers.map{|f|
            {
              :person_id => f.person_id
            }
          },
          :dependents => tr.dependents.map{|d|
            {
              :person_id => d.person_id
            }
          }
        }
      }
    }
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
end
