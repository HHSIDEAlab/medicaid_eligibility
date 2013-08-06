class Application
  class Person
    attr_reader :person_id, :person_attributes, :relationships

    def initialize(person_id, person_attributes)
      @person_id = person_id
      @person_attributes = person_attributes
    end
  end

  class Applicant < Person
    attr_reader :applicant_id, :applicant_attributes
    attr_accessor :outputs

    def initialize(person_id, person_attributes, applicant_id, applicant_attributes)
      @person_id = person_id
      @person_attributes = person_attributes
      @applicant_id = applicant_id
      @applicant_attributes = applicant_attributes
      @outputs = {}
    end
  end

  class Household
    attr_reader :household_id, :people
  end

  attr_reader :state, :applicants, :people, :physical_households, :tax_households, :medicaid_households, :config

  PERSON_INPUTS = [
    # {
    #   :name       => "Applicant Age",
    #   :type       => :integer,
    #   :xml_group  => :undefined,
    #   :xpath      => :undefined
    # },
    {
      :name       => "Applicant Attest Disabled",
      :type       => :flag,
      :values     => %w(Y N),
      :xml_group  => :applicant,
      :xpath      => "hix-ee:InsuranceApplicantBlindnessOrDisabilityIndicator"
    },
    {
      :name       => "Applicant Attest Long Term Care",
      :type       => :flag,
      :values     => %w(Y N),
      :xml_group  => :applicant,
      :xpath      => "hix-ee:InsuranceApplicantBlindnessOrDisabilityIndicator"
    },
    # {
    #   :name       => "Applicant Household Income",
    #   :type       => :integer,
    #   :xml_group  => :undefined,
    #   :xml_group  => :undefined
    # },
    {
      :name       => "Applicant Medicaid Citizen Or Immigrant Status Indicator",
      :type       => :flag,
      :values     => %w(Y N D E H I P T),
      :xml_group  => :applicant,
      :xpath      => "hix-ee:MedicaidMAGIEligibility/hix-ee:MedicaidMAGICitizenOrImmigrantEligibilityBasis/hix-ee:StatusIndicator"
    },
    {
      :name       => "Applicant Pregnant Indicator",
      :type       => :flag,
      :values     => %w(Y N),
      :xml_group  => :person,
      :xpath      => "hix-core:PersonAugmentation/hix-core:PersonPregnancyStatus/hix-core:StatusIndicator"
    },
    {
      :name       => "Medicare Entitlement Indicator",
      :type       => :flag,
      :values     => %w(Y N),
      :xml_group  => :applicant,
      :xpath      => "hix-ee:MedicaidNonMAGIEligibility/hix-ee:MedicaidNonMAGIMedicareEntitlementEligibilityBasis/hix-core:StatusIndicator"
    },
    {
      :name       => "Medicaid Residency Status Indicator",
      :type       => :flag,
      :values     => %w(Y N P),
      :xml_group  => :applicant,
      :xpath      => "hix-ee:MedicaidMAGIEligibility/hix-ee:MedicaidMAGIResidencyEligibilityBasis/hix-ee:StatusIndicator"
    },
    {
      :name       => "Person Disabled Indicator",
      :type       => :flag,
      :values     => %w(Y N),
      :xml_group  => :applicant,
      :xpath      => "hix-ee:MedicaidNonMAGIEligibility/hix-ee:MedicaidNonMAGIBlindnessOrDisabilityEligibilityBasis/hix-ee:EligibilityBasisStatusIndicator"
    }
  ]

  DETERMINATIONS = [
    {name: "Pregnancy Category", eligibility: :MAGI},
    {name: "Child Category", eligibility: :MAGI},
    {name: "Adult Group Category", eligibility: :MAGI},
    {name: "Adult Group XX Category", eligibility: :MAGI},
    {name: "Optional Targeted Low Income Child", eligibility: :MAGI},
    {name: "CHIP Targeted Low Income Child", eligibility: :CHIP},
    {name: "Income", eligibility: :MAGI},
    {
      name: "Medicaid Non-MAGI Referral",
      group: :other,
      indicator_xpath: "hix-ee:MedicaidNonMAGIEligibility/hix-ee:EligibilityIndicator",
      date_xpath: "hix-ee:MedicaidNonMAGIEligibility/hix-ee:EligibilityDetermination/nc:ActivityDate/nc:DateTime",
      reason_xpath: "hix-ee:MedicaidNonMAGIEligibility/hix-ee:EligibilityReasonText"
    }
  ]

  OUTPUTS = [
    {
      :name   => "Category Used to Calculate Income",
      :type   => :string,
      :xpath  => :undefined
    }
  ]

  def initialize(raw_application, return_application)
    @raw_application = raw_application
    @xml_application = Nokogiri::XML(raw_application) do |config|
      config.default_xml.noblanks
    end
    @return_application = return_application
  end

  def result
    #@determination_date = Date.today
    from_xml
    read_configs
    # {
    #   :state => @state, 
    #   :applicants => @applicants.map{|a| {:app_id => a.applicant_id, :app_attrs => a.applicant_attributes, :person_id => a.person_id, :person_attrs => a.person_attributes}}, 
    #   :people => @people.map{|p| {:person_id => p.person_id, :person_attrs => p.person_attributes}}, #:physical_households, :tax_households, :medicaid_households,
    #   :config => @config
    # }
    c = to_context(@applicants.first)
    {
      :config => c.config,
      :input => c.input
    }
    #context = build_context
    #output = process_rules(context)
    #update_xml!(output)
  end

  private

  def validate
  end

  def get_value(xpath, start_node=@xml_application)
    @xml_application.xpath(xpath, {
          "exch"     => "http://at.dsh.cms.gov/exchange/1.0",
          "s"        => "http://niem.gov/niem/structures/2.0", 
          "ext"      => "http://at.dsh.cms.gov/extension/1.0",
          "hix-core" => "http://hix.cms.gov/0.1/hix-core", 
          "hix-ee"   => "http://hix.cms.gov/0.1/hix-ee",
          "nc"       => "http://niem.gov/niem/niem-core/2.0", 
          "hix-pm"   => "http://hix.cms.gov/0.1/hix-pm",
          "scr"      => "http://niem.gov/niem/domains/screening/2.1"
     } )
  end

  def find_or_create_node(node, xpath)
    xpath.gsub!(/^\/+/,'')
    if xpath.empty?
      node
    elsif node.at_xpath(xpath)
      node.at_xpath(xpath)
    else
      xpath_list = xpath.split('/')
      next_node = node.at_xpath(xpath_list.first)
      if next_node
        find_or_create_node(next_node, xpath_list[1..-1].join('/'))
      else
        Nokogiri::XML::Builder.with(node) do |xml|
          xml.send(xpath_list.first)
        end

        find_or_create_node(node.at_xpath(xpath_list.first), xpath_list[1..-1].join('/'))
      end
    end
  end

  def return_application?
    @return_application
  end

  def read_configs
    config = MedicaidEligibilityApi::Application.options[:config]
    if config[@state]
      @config = config[:default].merge(config[@state])
    else
      @config = config[:default]
    end
  end

  def from_xml
    @people = []
    @applicants = []
    @state = get_value("/exch:AccountTransferRequest/ext:TransferHeader/ext:TransferActivity/ext:RecipientTransferActivityStateCode").inner_text
    
    xml_people = get_value "/exch:AccountTransferRequest/hix-core:Person"
    
    for xml_person in xml_people
      person_id = xml_person.attribute('id').value
      person_attributes = {}

      xml_app = get_value("/exch:AccountTransferRequest/hix-ee:InsuranceApplication/hix-ee:InsuranceApplicant").find{
        |x_app| x_app.at_xpath("hix-core:RoleOfPersonReference").attribute('ref').value == person_id
      }
      if xml_app
        applicant_id = xml_app.attribute('id').value
        applicant_attributes = {}
      end
      
      for input in PERSON_INPUTS
        if input[:xml_group] == :person
          node = xml_person.at_xpath(input[:xpath])
        elsif input[:xml_group] == :applicant
          unless xml_app
            next
          end
          node = xml_app.at_xpath(input[:xpath])
        else
          raise "Variable #{input[:name]} has unimplemented xml group #{input[:xml_group]}"
        end

        unless node
          next # for testing
          raise "Input xml missing variable #{input[:name]} for applicant #{applicant_id}"
        end

        if input[:type] == :integer
          attr_value = node.inner_text.to_i
        elsif input[:type] == :flag
          if input[:values].include? node.inner_text
            attr_value = node.inner_text
          elsif node.inner_text == 'true'
            attr_value = 'Y'
          elsif node.inner_text == 'false'
            attr_value = 'N'
          else
            raise "Invalid value #{node.inner_text} for variable #{input[:name]} for applicant #{applicant_id}"
          end 
        elsif input[:type] == :string
          attr_value = node.inner_text
        else
          raise "Variable #{input[:name]} has unimplemented type #{input[:type]}"
        end

        if input[:xml_group] == :person
          person_attributes[input[:name]] = attr_value
        elsif input[:xml_group] == :applicant
          applicant_attributes[input[:name]] = attr_value
        else
          raise "Variable #{input[:name]} has unimplemented xml group #{input[:xml_group]}"
        end
      end

      if xml_app
        person = Applicant.new(person_id, person_attributes, applicant_id, applicant_attributes)
        @applicants << person
      else
        person = Person.new(person_id, person_attributes)
      end
      @people << person

      # We need additional information passed to us, since we
      # don't have birthdates; this is just a quick fix for now
      # app_data["Applicant Post Partum Period Indicator"] = 'N'
      # app_data["Household"] = get_value("/exch:AccountTransferRequest/ext:PhysicalHousehold/hix-ee:HouseholdMemberReference").map{
      #   |p| p.attribute('ref').value
      # }
    end
  end

  def to_xml

  end

  def from_context(applicant, context)
    applicant.outputs.merge!(context.output)
  end

  def to_context(applicant)
    input = applicant.applicant_attributes.merge(applicant.person_attributes).merge(applicant.outputs)
    config = @config
    RuleContext.new(config, input)
  end

  def build_context
    state = get_value("/exch:AccountTransferRequest/ext:TransferHeader/ext:TransferActivity/ext:RecipientTransferActivityStateCode").inner_text
    
    config = MedicaidEligibilityApi::Application.options[:config][state] || MedicaidEligibilityApi::Application.options[:config][:default]
    input = {
      "State"      => state,
      "Applicants" => []
    }

    applicants = get_value "/exch:AccountTransferRequest/hix-ee:InsuranceApplication/hix-ee:InsuranceApplicant"
    
    for app in applicants
      app_data = {}
      app_id = app.attribute('id').value
      app_data['id'] = app_id

      person = get_value("/exch:AccountTransferRequest/hix-core:Person").find{
        |p| p.attribute('id').value == app.at_xpath("hix-core:RoleOfPersonReference").attribute('ref').value
      }
      
      for app_var, app_var_info in applicant_variables
        if app_var_info[:group] == :applicants
          node = app.at_xpath(app_var_info[:xpath])
        elsif app_var_info[:group] == :people
          node = person.at_xpath(app_var_info[:xpath])
        else
          raise "No group listed for variable #{app_var}"
        end

        if node
          if app_var_info[:values]
            app_data[app_var] = app_var_info[:values][node.inner_text]
          elsif app_var_info[:type] == :integer
            app_data[app_var] = node.inner_text.to_i
          else
            app_data[app_var] = node.inner_text
          end
        elsif app_var_info[:required]
          raise "Input xml missing required variable #{app_var} for applicant #{app_id}"
        elsif app_var_info[:missing_val]
          app_data[app_var] = app_var_info[:missing_val]
        else
          raise "Missing default value for variable #{app_var}"
        end
      end

      # We need additional information passed to us, since we
      # don't have birthdates; this is just a quick fix for now
      app_data["Applicant Post Partum Period Indicator"] = 'N'
      app_data["Household"] = get_value("/exch:AccountTransferRequest/ext:PhysicalHousehold/hix-ee:HouseholdMemberReference").map{
        |p| p.attribute('ref').value
      }

      input["Applicants"] << app_data
    end

    RuleContext.new(config, input)
  end

  def update_xml!(output)
    unless return_application?
      node = get_value("exch:AccountTransferRequest").first
      node.children.remove
      Nokogiri::XML::Builder.with(node) do |xml|
        xml.send("hix-ee:InsuranceApplication") {
          output["Applicants"].each do |applicant|
            xml.send("hix-ee:InsuranceApplicant",:id => applicant["id"])
          end
        }
      end
    end

    for applicant in output["Applicants"]
      xml_applicant = get_value("/exch:AccountTransferRequest/hix-ee:InsuranceApplication/hix-ee:InsuranceApplicant").find{
        |app| app.attribute("id").value == applicant["id"]
      }

      for output_var, output_value in applicant.except("id", "Category Used to Calculate Income")
        xpath = output_variables[output_var][:xpath]
        find_or_create_node(xml_applicant, xpath).content = output_value
      end
    end
    @xml_application
  end

  def process_rules(initial_context)
    final_output = {
      "Applicants" => []
    }

    for applicant in initial_context.input["Applicants"]
      applicant_context = RuleContext.new(initial_context.config, applicant)
      applicant_output = {
        "id" => applicant["id"]
      }
      for ruleset in ruleset_order
        ruleset.new().run(applicant_context)
        applicant_output.merge!(applicant_context.output)

        applicant_context = RuleContext.new(applicant_context.config, applicant_context.input.merge(applicant_context.output))
      end
      final_output["Applicants"] << applicant_output
    end

    final_output
  end

  def ruleset_order
    @ruleset_order ||= [
      Medicaidchip::Eligibility::Category::Pregnant,
      Medicaidchip::Eligibility::Category::Child,
      Medicaid::Eligibility::Category::Medicaid::AdultGroup,
      Medicaid::Eligibility::Category::OptionalTargetedLowIncomeChildren,
      Chip::Eligibility::Category::TargetedLowIncomeChildren,
      Medicaid::Eligibility::ReferralType,
      Medicaidchip::Eligibility::Income
    ]
  end

  def applicant_variables
    @applicant_variables ||= {
      "Medicaid Residency Status Indicator" => {
        :group => :applicants,
        :xpath => "hix-ee:MedicaidMAGIEligibility/hix-ee:MedicaidMAGIResidencyEligibilityBasis/hix-ee:StatusIndicator",
        :required => false,
        :values => {
          'Y' => 'Y',
          'true' => 'Y',
          'N' => 'N',
          'false' => 'N'
        },
        :missing_val => 'N'
      },
      "Applicant Medicaid Citizen Or Immigrant Status Indicator" => {
        :group => :applicants,
        :xpath => "hix-ee:MedicaidMAGIEligibility/hix-ee:MedicaidMAGICitizenOrImmigrantEligibilityBasis/hix-ee:StatusIndicator",
        :required => false,
        :values => {
          'Y' => 'Y',
          'true' => 'Y',
          'N' => 'N',
          'false' => 'N'
        },
        :missing_val => 'N'
      },
      "Applicant Pregnant Indicator" => {
        :group => :people,
        :xpath => "hix-core:PersonAugmentation/hix-core:PersonPregnancyStatus/hix-core:StatusIndicator",
        :required => false,
        :values => {
          'Y' => 'Y',
          'true' => 'Y',
          'N' => 'N',
          'false' => 'N'
        },
        :missing_val => 'N'
      },
      "Applicant Age" => {
        :group => :people,
        :xpath => "PersonAge",
        :required => true,
        :type => :integer
      },
      "Medicare Entitlement Indicator" => {
        :group => :applicants,
        :xpath => "hix-ee:MedicaidNonMAGIEligibility/hix-ee:MedicaidNonMAGIMedicareEntitlementEligibilityBasis/hix-core:StatusIndicator",
        :required => false,
        :values => {
          'Y' => 'Y',
          'true' => 'Y',
          'N' => 'N',
          'false' => 'N'
        },
        :missing_val => 'N'
      },
      "Applicant Attest Disabled" => {
        :group => :applicants,
        :xpath => "hix-ee:InsuranceApplicantBlindnessOrDisabilityIndicator",
        :required => false,
        :values => {
          'Y' => 'Y',
          'true' => 'Y',
          'N' => 'N',
          'false' => 'N'
        },
        :missing_val => 'N'
      },
      "Applicant Attest Long Term Care" => {
        :group => :applicants,
        :xpath => "hix-ee:InsuranceApplicantLongTermCareIndicator",
        :required => false,
        :values => {
          'Y' => 'Y',
          'true' => 'Y',
          'N' => 'N',
          'false' => 'N'
        },
        :missing_val => 'N'
      },
      "Person Disabled Indicator" => {
        :group => :applicants,
        :xpath => "hix-ee:MedicaidNonMAGIEligibility/hix-ee:MedicaidNonMAGIBlindnessOrDisabilityEligibilityBasis/hix-ee:EligibilityBasisStatusIndicator",
        :required => false,
        :values => {
          'Y' => 'Y',
          'true' => 'Y',
          'N' => 'N',
          'false' => 'N'
        },
        :missing_val => 'N'
      },
      "Applicant Household Income" => {
        :group => :people,
        :xpath => "hix-core:PersonAugmentation/hix-core:PersonIncome/hix-core:IncomeAmount",
        :required => true,
        :type => :integer
      }
    }
  end

  def output_variables
    @output_variables ||= generate_output_variables
  end

  def generate_output_variables
    outputs = [
      {name: "Pregnancy Category", eligibility: :MAGI},
      {name: "Child Category", eligibility: :MAGI},
      {name: "Adult Group Category", eligibility: :MAGI},
      {name: "Adult Group XX Category", eligibility: :MAGI},
      {name: "Optional Targeted Low Income Child", eligibility: :MAGI},
      {name: "CHIP Targeted Low Income Child", eligibility: :CHIP},
      {name: "Income", eligibility: :MAGI}
    ].reduce({}){|outputs, ruleset| outputs.merge(category_variable(ruleset[:name], ruleset[:eligibility]))}.merge({
      "Applicant Medicaid Non-MAGI Referral Indicator" => {
        :xpath => "hix-ee:MedicaidNonMAGIEligibility/hix-ee:EligibilityIndicator"
      },
      "Medicaid Non-MAGI Referral Determination Date" => {
        :xpath => "hix-ee:MedicaidNonMAGIEligibility/hix-ee:EligibilityDetermination/nc:ActivityDate/nc:DateTime"
      },
      "Medicaid Non-MAGI Referral Ineligibility Reason" => {
        :xpath => "hix-ee:MedicaidNonMAGIEligibility/hix-ee:EligibilityReasonText"
      },
      "Category Used to Calculate Income" => {
        :xpath => "hix-ee:MedicaidMAGIEligibility/hix-ee:MedicaidMAGIIncomeEligibilityBasis/CategoryUsed"
      }
    })
  end

  def category_variable(name, eligibility) 
    if eligibility == :MAGI
      prefix = "hix-ee:MedicaidMAGIEligibility/hix-ee:MedicaidMAGI"
    elsif eligibility == :CHIP
      prefix = "hix-ee:CHIPEligibility/hix-ee:"
    end
    {
      "Applicant #{name} Indicator" => {
        :xpath => "#{prefix}#{name.gsub(/ +/,'')}EligibilityBasis/hix-ee:EligibilityBasisStatusIndicator"
      },
      "#{name} Determination Date" => {
        :xpath => "#{prefix}#{name.gsub(/ +/,'')}EligibilityBasis/hix-ee:EligibilityBasisDetermination/nc:ActivityDate/nc:DateTime"
      },
      "#{name} Ineligibility Reason" => {
        :xpath => "#{prefix}#{name.gsub(/ +/,'')}EligibilityBasis/hix-ee:EligibilityBasisIneligibilityReasonText"
      }
    }
  end
end
