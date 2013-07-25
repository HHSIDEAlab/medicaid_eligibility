class DeterminationsController < ApplicationController
  def eval
    render :xml => {}, :root => 'Response' 
  end
end
