class HomeController < ActionController::Base
  def index
    gon.restrictStates = ENV["RESTRICT_STATES"] == "true"
    gon.enabledStates = ENV["ENABLED_STATES"] ? ENV["ENABLED_STATES"].split(';') : []
    gon.accessToken = ENV["ACCESS_TOKENS"] ? ENV["ACCESS_TOKENS"].split(';').first : "none"

    respond_to do |format|
      format.html
    end 
  end
end
