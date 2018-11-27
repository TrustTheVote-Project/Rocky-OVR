class SesController < ApplicationController
  skip_before_filter :authenticate_everything
  
  def bounce
    SesNotification.create(request_params: params)
    render text: ''
  end
  
end