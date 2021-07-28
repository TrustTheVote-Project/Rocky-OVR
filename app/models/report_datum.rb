class ReportDatum < ActiveRecord::Base
  belongs_to :report, optional: true
  
  serialize :h_value, Hash
  
end
