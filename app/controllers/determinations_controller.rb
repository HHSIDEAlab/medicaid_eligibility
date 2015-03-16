class DeterminationsController < ApplicationController
  include ActionController::MimeResponds
  include ActionController::HttpAuthentication::Token::ControllerMethods

  before_filter :restrict_access

  @@access_tokens ||= ENV['ACCESS_TOKENS'].split(';')

  def eval
    @app = Application.new(request)

    respond_to do |format|
      format.xml { render xml: @app }
      format.json { render json: @app, status: (@app.error.nil? ? :ok : :unprocessable_entity) }
    end
  end

  private

  def restrict_access
    authenticate_or_request_with_http_token do |token, options|
      @@access_tokens.include? token
    end
  end
end
