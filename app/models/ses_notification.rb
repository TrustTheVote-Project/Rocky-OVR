class SesNotification < ActiveRecord::Base
  serialize :request_params
  after_initialize do
    self.request_params ||= {}
  end
  
end
