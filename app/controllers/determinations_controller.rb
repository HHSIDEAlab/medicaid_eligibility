class DeterminationsController < ApplicationController
  def eval
    return_format = request.accept
    content_type = request.content_type
    app = Application.new(request.raw_post, request.content_type, params[:return_application])

    if return_format == 'application/xml'
      render :xml => app.result(:xml)
    elsif return_format == 'application/json'
      render :json => JSON.pretty_generate(app.result(:json))
    else
      render 'Specify a return format'
    end
  end
end
