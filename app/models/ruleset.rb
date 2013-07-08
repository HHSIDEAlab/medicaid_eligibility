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

    def outputs
      @outputs ||= {}
    end

    def rule(rule_name, &blk)
      self.rules << Rule.new(rule_name, blk)
    end

    def calculated(variable, &blk)
      self.calculateds << CalculatedVariable.new(variable, blk)
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

    def indicator(name, valid_inputs=nil)
      self.outputs[name] = nil
    end

    def date(name)
      self.outputs[name] = nil
    end

    def code(name, valid_inputs=nil)
      self.outputs[name] = nil
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
