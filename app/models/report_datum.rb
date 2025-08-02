class ReportDatum < ActiveRecord::Base
  belongs_to :report, optional: true
  
  serialize :h_value
  after_initialize do
    self.h_value ||= {}
  end
  
end
