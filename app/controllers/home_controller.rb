class HomeController < ActionController::Base
  def index
    gon.restrictStates = ENV['RESTRICT_STATES'] == 'true'
    gon.accessToken = ENV['ACCESS_TOKENS'] ? ENV['ACCESS_TOKENS'].split(';').first : 'none'

    if ENV['CONFIG_API']
      response = HTTParty.get(ENV['CONFIG_API'])
      gon.enabledStates = JSON.parse(response.body).map { |st_config| st_config['state_cd'] }
    else
      gon.enabledStates = []
    end

    respond_to do |format|
      format.html
    end
  end
end
