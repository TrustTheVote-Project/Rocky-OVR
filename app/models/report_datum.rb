class ReportDatum < ActiveRecord::Base
  belongs_to :report
  
  serialize :h_value, Hash
  
end
