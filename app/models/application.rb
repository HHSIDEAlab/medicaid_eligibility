class Application
  def initialize(raw_application)
    @raw_application = raw_application
    @xml_application = Nokogiri::XML(raw_application)
  end

  def validate

  end

  def result
    context = to_rules_context
    output = process_rules(context)

    {
      'config' => context.config,
      'input' => context.input,
      'output' => output
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
    
    for app, person in applicants
      app_data = {}
      app_id = app.attribute('id').value
      app_data['id'] = app_id

      person = get_value("/exch:AccountTransferRequest/hix-core:Person").find{
        |p| p.attribute('id').value == app.at_xpath("hix-core:RoleOfPersonReference").attribute('ref').value
      }
      
      for app_var, app_var_info in applicant_variables
        if app_var_info[:group] == :applicants
          app_raw_field = app.at_xpath(app_var_info[:xpath])
        elsif app_var_info[:group] == :people
          app_raw_field = person.at_xpath(app_var_info[:xpath])
        else
          raise "No group listed for variable #{app_var}"
        end

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

      # We need additional information passed to us, since we
      # don't have birthdates; this is just a quick fix for now
      app_data["Applicant Post Partum Period Indicator"] = 'N'

      input["Applicants"] << app_data
    end

    RuleContext.new(config, input)
  end

  def applicant_variables
    @applicant_values ||= {
      "Medicaid Residency Status Indicator" => {
        :group => :applicants,
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
        :group => :applicants,
        :xpath => "/hix-ee:MedicaidMAGIEligibility/hix-ee:MedicaidMAGICitizenOrImmigrantEligibilityBasis/hix-ee:StatusIndicator",
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
        :xpath => "/hix-core:PersonAugmentation/hix-core:PersonPregnancyStatus/hix-core:StatusIndicator",
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
      Medicaidchip::Eligibility::Category::Pregnant
    ]
  end
end
