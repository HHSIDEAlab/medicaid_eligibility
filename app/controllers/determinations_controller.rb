class DeterminationsController < ApplicationController
  include ActionController::MimeResponds
  include ActionController::HttpAuthentication::Token::ControllerMethods

  before_filter :restrict_access

  @@access_tokens ||= ENV['ACCESS_TOKENS'] ? ENV['ACCESS_TOKENS'].split(';') : []

  def eval
    @app = Application.new(request.raw_post, request.content_type)

    respond_to do |format|
      format.xml { render xml: @app, status: (@app.error.nil? ? :ok : :unprocessable_entity) }
      format.json { render json: @app, status: (@app.error.nil? ? :ok : :unprocessable_entity) }
    end
  end

  private

  def restrict_access
    if ENV['REQUIRE_ACCESS_TOKEN'] == 'true'
      authenticate_or_request_with_http_token do |token, _options|
        @@access_tokens.include? token
      end
    end
  end
end
