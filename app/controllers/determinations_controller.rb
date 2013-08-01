class DeterminationsController < ApplicationController
  def eval
    app = Application.new(request.raw_post, params[:return_application])

    render :xml => app.result
  end
end
