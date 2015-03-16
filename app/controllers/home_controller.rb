class HomeController < ApplicationController
  include ActionController::MimeResponds

  def index
    @show_splash_notice = ENV["SHOW_SPLASH_NOTICE"] == "true"
    @restrict_states = ENV["RESTRICT_STATES"] == "true"
    @access_token = ENV["ACCESS_TOKENS"] ? ENV["ACCESS_TOKENS"].split(';').first : "none"

    respond_to do |format|
      format.html
    end 
  end

end
