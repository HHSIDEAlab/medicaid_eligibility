class DeterminationsController < ApplicationController
  def eval
    return_format = request.accept
    content_type = request.content_type
    if(params.has_key?(:json_request)) 
       return_format = 'application/json'
       print "test"
       app = Application.new(params[:json_request], 'application/json', params[:return_application])
    else
       app = Application.new(request.raw_post , request.content_type, params[:return_application])
    end
    
    if return_format == 'application/xml'
      render :xml => app.result(:xml)
    elsif return_format == 'application/json'
      render :json => JSON.pretty_generate(app.result(:json))
    else
      render 'Specify a return format'
    end
  end

  def json_form_post
    request.accept = 'application/json'
    eval
  end

end
