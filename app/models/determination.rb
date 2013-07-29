class Determination
  def initialize(request)
    @request = request
  end

  def result()
    input_context = build_context

    {
      :config => input_context.config,
      :input  => input_context.input
    }
  end

  private

  def build_context()
    context = RuleContext.new({},{})

    state = @request['TransferHeader']['TransferActivity']['RecipientTransferActivityStateCode']

    config = MedicaidEligibilityApi::Application.options[:config][state] || MedicaidEligibilityApi::Application.options[:config][:default]
    input = {
      "State"      => state,
      "Applicants" => []
    }

    @request['InsuranceApplication']['InsuranceApplicant'].each do |app|
      app_data = {}
      app_data["Applicant ID"] = app["s:id"]
      app_data["State"] = state

      if defined? app["MedicaidMAGIEligibility"]["MedicaidMAGIResidencyEligibilityBasis"]["StatusIndicator"]
        if app["MedicaidMAGIEligibility"]["MedicaidMAGIResidencyEligibilityBasis"]["StatusIndicator"]
          app_data["Medicaid Residency Status Indicator"] = 'Y'
        else
          app_data["Medicaid Residency Status Indicator"] = 'N'
        end
        # 'P' value?
      else
        # do something 
      end

      if defined? app["MedicaidMAGIEligibility"]["MedicaidMAGICitizenOrImmigrantEligibilityBasis"]["StatusIndicator"]
        if app["MedicaidMAGIEligibility"]["MedicaidMAGICitizenOrImmigrantEligibilityBasis"]["StatusIndicator"]
          app_data["Applicant Medicaid Citizen Or Immigrant Status Indicator"] = 'Y'
        else
          app_data["Applicant Medicaid Citizen Or Immigrant Status Indicator"] = 'N'
        end
        # 'D', 'E', 'H', 'I', 'P', 'T'?
      else
        # do something
      end

      input["Applicants"] << app_data
    end

    RuleContext.new(config, input)
  end
end
