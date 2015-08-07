class HomeController < ActionController::Base
  def index
    gon.restrictStates = ENV["RESTRICT_STATES"] == "true"
    gon.accessToken = ENV["ACCESS_TOKENS"] ? ENV["ACCESS_TOKENS"].split(';').first : "none"

    states_from_api = HTTParty.get('http://mitc-configs.herokuapp.com/states/active').parsed_response.map {|x| x['state_cd'] } if Rails.env.production? 
    gon.enabledStates = if states_from_api
    	states_from_api
    elsif ENV['ENABLED_STATES']
    	ENV['ENABLED_STATES']
    else
    	[]
    end

    respond_to do |format|
      format.html
    end 
  end
end
