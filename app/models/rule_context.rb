class RuleContext
  attr_reader :config, :input, :output

  class MissingVariableError < StandardError
  end

  def initialize(config, input)
    @config = config
    @input = input
    @output = {}
  end

  def current_date
    Date.today
  end

  def o
    @output
  end

  def c(name)
    @config[name] || (raise MissingVariableError, "missing config variable #{name}")
  end

  def v(name)
    @input[name] || (raise MissingVariableError, "missing input variable #{name}")
  end
end
