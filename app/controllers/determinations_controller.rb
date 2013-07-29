class DeterminationsController < ApplicationController
  def eval
    app = Application.new(request.raw_post)

    render :xml => app.result
  end
end
