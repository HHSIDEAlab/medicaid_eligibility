class RulesetsController < ApplicationController
  rescue_from RuleContext::MissingVariableError, with: :missing_variable_error

  def eval
    @context = RuleContext.new(params[:config], params[:inputs], Date.today)
    render json: ruleset.run(@context).output
  end

  protected

  def ruleset
    @ruleset ||= load_ruleset(params[:id])
  end

  def missing_variable_error(error)
    render json: { error: error.message }, status: 422
  end

  private

  def load_ruleset(ruleset)
    MAGI.const_get(ruleset.gsub(/magi\//i, '').camelize).new
  end
end
