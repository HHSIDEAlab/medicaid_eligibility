class DeterminationsController < ApplicationController
  def eval
    determination = Determination.new(params['AccountTransferRequest'])

    render :xml => determination.result, :root => 'Response' 
  end
end
