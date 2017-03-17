class Application
  include ApplicationComponents
  include ApplicationParser
  include ApplicationProcessor
  include ApplicationResponder
  include ActiveModel::Conversion
  extend  ActiveModel::Naming

  def persisted?
    false
  end

  attr_reader :error
  attr_reader :state, :people, :tax_returns

  def initialize(raw_application, content_type)
    @determination_date = Date.today
    @error = nil

    begin
      if content_type == 'application/json'
        @json_application = JSON.parse(raw_application)
        read_json!
      elsif content_type == 'application/xml'
        raise 'XML not supported'
      elsif content_type
        raise "Invalid content type #{content_type}"
      else
        raise "Missing content type"
      end
      read_configs!
      compute_values!
      process_rules!
    rescue Exception => e
      Rails.logger.error e
      Rails.logger.error e.backtrace.join("\n")
      @error = e
    end
  end

  private

  def return_application?
    true
  end
end
