class HomeController < ApplicationController
  include ActionController::MimeResponds

  def index
    @show_splash_notice = ENV["SHOW_SPLASH_NOTICE"] == "true"

    respond_to do |format|
      format.html
    end 
  end

end
