class Application
  def initialize(raw_application)
    @raw_application = raw_application
    @xml_application = Nokogiri::XML(raw_application)
  end

  def validate

  end

  def result
    #@xml_application
    #get_value('/exch:AccountTransferRequest/hix-ee:InsuranceApplication/hix-ee:InsuranceApplicant').first
    c = to_rules_context
    {
      'config' => c.config,
      'input' => c.input
    }
  end

  def to_rules_context
    build_context
  end

  def from_rules_context
    
  end

  def get_value(xpath)
    @xml_application.xpath(xpath)
  end

  def set_value(xpath, value)

  end

  private

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
      
      for app_var, app_var_info in applicant_variables
        app_raw_field = app.at_xpath(app_var_info[:xpath])
        if app_raw_field
          app_data[app_var] = app_var_info[app_raw_field.value]
        elsif app_var_info[:required]
          raise "Input xml missing variable #{app_var} for applicant #{app_id}"
        elsif app_var_info[:missing_val]
          app_data[app_var] = app_var_info[:missing_val]
        else
          raise "Missing default value for variable #{app_var}"
        end
      end
      input["Applicants"] << app_data
    end

    RuleContext.new(config, input)
  end

  def applicant_variables
    @applicant_values ||= {
      "Medicaid Residency Status Indicator" => {
        :xpath => "/hix-ee:MedicaidMAGIEligibility/hix-ee:MedicaidMAGIResidencyEligibilityBasis/hix-ee:StatusIndicator",
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
        :xpath => "/hix-ee:MedicaidMAGIEligibility/hix-ee:MedicaidMAGICitizenOrImmigrantEligibilityBasis/hix-ee:StatusIndicator",
        :required => false,
        :values => {
          'Y' => 'Y',
          'true' => 'Y',
          'N' => 'N',
          'false' => 'N'
        },
        :missing_val => 'N'
      }
    }
  end
end
