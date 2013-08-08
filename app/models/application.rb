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

  def initialize(raw_application, return_application)
    @raw_application = raw_application
    @xml_application = Nokogiri::XML(raw_application) do |config|
      config.default_xml.noblanks
    end
    @return_application = return_application
  end

  def result
    @determination_date = Date.today
    read_xml!
    read_configs!
    process_rules!
    # to_xml
    {
      :state => @state, 
      :applicants => 
        @applicants.map{|a| {
          :app_id => a.applicant_id, 
          :app_attrs => a.applicant_attributes, 
          :person_id => a.person_id, 
          :person_attrs => a.person_attributes, 
          :outputs => a.outputs
        }}, 
      :people => 
        @people.map{|p| {
          :person_id => p.person_id, 
          :person_attrs => p.person_attributes
        }}, 
      #:physical_households, :tax_households, :medicaid_households,
      :config => @config
    }
    # context = to_context(@applicants.first)
    # {
    #   :config => context.config,
    #   :input => context.input
    # }  
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
    xpath.gsub!(/^\/+/,'')
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
    config = MedicaidEligibilityApi::Application.options[:config]
    if config[@state]
      @config = config[:default].merge(config[@state])
    else
      @config = config[:default]
    end
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
      # app_data["Household"] = get_nodes("/exch:AccountTransferRequest/ext:PhysicalHousehold/hix-ee:HouseholdMemberReference").map{
      #   |p| p.attribute('ref').value
      # }
    end
  end

  def to_xml
    Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
      xml.send("exch:AccountTransferRequest", Hash[XML_NAMESPACES.map{|k, v| ["xmlns:#{k}", v]}]) {
        xml.send("ext:TransferHeader") {
        
        }
        xml.send("hix_core:Sender") {

        }
        xml.send("hix_core:Receiver") {

        }
        xml.send("hix-ee:InsuranceApplication") {
          xml.send("hix-core:ApplicationCreation") {

          }
          xml.send("hix-core:ApplicationSubmission") {

          }
          xml.send("hix-core:ApplicationIdentification") {

          }
          @applicants.each do |applicant|
            xml.send("hix-ee:InsuranceApplicant", {"s:id" => applicant.applicant_id}) {

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

  def from_context!(applicant, context)
    applicant.outputs.merge!(context.output)
  end

  def to_context(applicant)
    input = applicant.applicant_attributes.merge(applicant.person_attributes).merge(applicant.outputs)
    config = @config
    RuleContext.new(config, input)
  end

  def process_rules!
    magi_part_1 = [
      Medicaidchip::Eligibility::Category::Pregnant,
      Medicaidchip::Eligibility::Category::Child,
      Medicaid::Eligibility::Category::Medicaid::AdultGroup,
      Medicaid::Eligibility::Category::OptionalTargetedLowIncomeChildren,
      Chip::Eligibility::Category::TargetedLowIncomeChildren,
      Medicaid::Eligibility::ReferralType
    ].map{|ruleset_class| ruleset_class.new()}

    for applicant in @applicants
      for ruleset in magi_part_1
        context = to_context(applicant)
        ruleset.run(context)
        from_context(applicant, context)
      end
    end

    Medicaidchip::Eligibility::Income
  end

  def update_xml!(output)
    unless return_application?
      node = get_node "exch:AccountTransferRequest"
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
      xml_applicant = get_nodes("/exch:AccountTransferRequest/hix-ee:InsuranceApplication/hix-ee:InsuranceApplicant").find{
        |app| app.attribute("id").value == applicant["id"]
      }

      for output_var, output_value in applicant.except("id", "Category Used to Calculate Income")
        xpath = output_variables[output_var][:xpath]
        find_or_create_node(xml_applicant, xpath).content = output_value
      end
    end
    @xml_application
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
