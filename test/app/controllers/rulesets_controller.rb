class RulesetsController < ApplicationController
  rescue_from RuleContext::MissingVariableError, :with => :missing_variable_error

  def eval
    @context = RuleContext.new(params[:config], params[:inputs], Date.today)
    render json: ruleset.run(@context).output
  end

  protected
    def ruleset
      @ruleset ||= params[:id].camelize.constantize.new
    end

    def missing_variable_error(error)
      render :json => {:error => error.message}, :status => 422
    end 
end
