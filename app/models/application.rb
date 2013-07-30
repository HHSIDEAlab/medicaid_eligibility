class Application
  def initialize(raw_application)
    @raw_application = raw_application
    @xml_application = Nokogiri::XML(raw_application)
  end

  def validate

  end

  def result
    #@xml_application
    get_value('/exch:AccountTransferRequest/hix-ee:InsuranceApplication/hix-ee:InsuranceApplicant').first
  end

  def to_rules_context

  end

  def from_rules_context

  end

  def get_value(xpath)
    @xml_application.xpath(xpath)
  end

  def set_value(xpath, value)

  end
end
