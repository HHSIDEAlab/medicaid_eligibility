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
      self.rules << Rule.new(rule_name, blk)
    end

    def calculated(variable, &blk)
      self.calculateds << CalculatedVariable.new(variable, blk)
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
      self.assumptions << text
    end

    def special_instruction(text)
      self.special_instructions << text
    end

    def input(name, source, type, possible_values=nil, options={})
      # options may include the type of element for list inputs
      self.inputs[name] = {
        :name   => name,
        :source => source,
        :type   => type
      }

      if possible_values
        self.inputs[name][:possible_values] = possible_values
      end
    end

    def config(name, source, type, possible_values=nil, default=nil)
      self.configs[name] = {
        :name   => name,
        :source => source,
        :type   => type
      }
      
      if possible_values
        self.configs[name][:possible_values] = possible_values
      end
      if default
        self.configs[name][:default] = default
      end
    end

    def indicator(name, possible_values=nil)
      self.outputs[name] = {
        :name => name,
        :type => "Indicator"
      }

      if possible_values
        self.outputs[name][:possible_values] = possible_values
      end
    end

    def date(name)
      self.outputs[name] = {
        :name => name,
        :type => "Date"
      }
    end

    def code(name, possible_values=nil)
      self.outputs[name] = {
        :name => name,
        :type => "Code"
      }

      if possible_values
        self.outputs[name][:possible_values] = possible_values
      end
    end

    def determination(name, possible_values=nil, ineligibility_codes = nil)
      self.outputs[name] = {}
    end

    def output(name, type, possible_values=nil, options={})
      # options may include the type of element for list outputs
      self.outputs[name] = {
        :name => name,
        :type => type
      }

      if possible_values
        self.outputs[name][:possible_values] = possible_values
      end
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
