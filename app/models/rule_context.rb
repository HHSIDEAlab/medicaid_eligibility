class RuleContext
  include ActiveModel::SerializerSupport
  extend ActiveModel::Naming

  attr_reader :config, :input, :output, :current_date

  class MissingVariableError < StandardError
  end

  def initialize(config, input, current_date)
    @config = config
    @input = input
    @output = {}
    @current_date = current_date
  end

  def o
    @output
  end

  def determination_y(determination)
    o["Applicant #{determination} Indicator"] = 'Y'
    o["#{determination} Determination Date"] = current_date
    o["#{determination} Ineligibility Reason"] = 999
  end

  def determination_n(determination, reason)
    o["Applicant #{determination} Indicator"] = 'N'
    o["#{determination} Determination Date"] = current_date
    o["#{determination} Ineligibility Reason"] = reason
  end

  def determination_na(determination)
    o["Applicant #{determination} Indicator"] = 'X'
    o["#{determination} Determination Date"] = current_date
    o["#{determination} Ineligibility Reason"] = 555
  end

  def c(name)
    @config[name] || (raise MissingVariableError, "missing config variable #{name}")
  end

  def v(name)
    unless @input.key? name
      raise MissingVariableError, "missing input variable #{name}"
    end
    @input[name]
  end
end
