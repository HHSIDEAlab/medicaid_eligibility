class Ruleset
  class Rule
    def initialize(name, blk)
      @name = name
      @blk = blk
    end

    def run(context)
      context.instance_eval &@blk
    end
  end

  class CalculatedVariable
    def initialize(name, blk)
      @name = name
      @blk = blk
    end

    def run(context)
      context.input[@name] = context.instance_eval(&@blk)
    end
  end

  class << self
    def rules
      @rules ||= []
    end

    def calculateds
      @calculateds ||= []
    end

    def inputs
      @inputs ||= {}
    end

    def configs
      @configs ||= {}
    end

    def outputs
      @outputs ||= {}
    end

    def assumptions
      @assumptions ||= []
    end

    def special_instructions
      @special_instructions ||= []
    end

    def rule(rule_name, &blk)
      rules << Rule.new(rule_name, blk)
    end

    def calculated(variable, &blk)
      calculateds << CalculatedVariable.new(variable, blk)
    end

    def name(text)
      @name = text
    end

    def mandatory(text)
      @mandatory = text
    end

    def references(text)
      @references = text
    end

    def applies_to(text)
      @applies_to = text
    end

    def purpose(text)
      @purpose = text
    end

    def description(text)
      @description = text
    end

    def assumption(text)
      assumptions << text
    end

    def special_instruction(text)
      special_instructions << text
    end

    def input(name, source, type, possible_values = nil, _options = {})
      # options may include the type of element for list inputs
      inputs[name] = {
        name: name,
        source: source,
        type: type
      }

      inputs[name][:possible_values] = possible_values if possible_values
    end

    def config(name, source, type, possible_values = nil, default = nil)
      configs[name] = {
        name: name,
        source: source,
        type: type
      }

      configs[name][:possible_values] = possible_values if possible_values
      configs[name][:default] = default if default
    end

    def indicator(name, possible_values = nil)
      outputs[name] = {
        name: name,
        type: 'Indicator'
      }

      outputs[name][:possible_values] = possible_values if possible_values
    end

    def date(name)
      outputs[name] = {
        name: name,
        type: 'Date'
      }
    end

    def code(name, possible_values = nil)
      outputs[name] = {
        name: name,
        type: 'Code'
      }

      outputs[name][:possible_values] = possible_values if possible_values
    end

    def determination(name, _possible_values = nil, _ineligibility_codes = nil)
      outputs[name] = {}
    end

    def output(name, type, possible_values = nil, _options = {})
      # options may include the type of element for list outputs
      outputs[name] = {
        name: name,
        type: type
      }

      outputs[name][:possible_values] = possible_values if possible_values
    end
  end

  def run(context)
    self.class.calculateds.each do |cvar|
      cvar.run(context)
    end

    self.class.rules.each do |rule|
      rule.run(context)
    end

    context
  end
end
