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

  def initialize(raw_application, content_type)
    @determination_date = Date.today
    @error = nil

    begin
      if content_type == 'application/json'
        @json_application = JSON.parse(raw_application)
        read_json!
      elsif content_type == 'application/xml'
        @xml_application = Nokogiri::XML(raw_application) do |config|
          config.default_xml.noblanks
        end
        read_xml!
      elsif content_type
        raise "Invalid content type #{content_type}"
      else
        raise "Missing content type"
      end
      read_configs!
      compute_values!
      process_rules!
    rescue Exception => e
      Rails.logger.error e.message
      Rails.logger.error e.backtrace.join("\n")
      @error = e
    end
  end

  private

  def return_application?
    true
  end
end
