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
    state = @request['TransferHeader']['TransferActivity']['RecipientTransferActivityStateCode']

    config = MedicaidEligibilityApi::Application.options[:config][state] || MedicaidEligibilityApi::Application.options[:config][:default]
    input = {
      "State" => state
    }      

    RuleContext.new(config, input)
  end
end
