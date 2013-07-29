class Application
  def initialize(raw_application)
    @raw_application = Nokogiri::XML(raw_application)
  end

  def validate

  end

  def result
    @raw_application
  end

  def to_rules_context

  end

  def from_rules_context

  end

  def get_value(xpath)

  end

  def set_value(xpath, value)

  end
end
