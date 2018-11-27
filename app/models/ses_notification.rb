class SesNotification < ActiveRecord::Base
  serialize :request_params, Hash
  
end
