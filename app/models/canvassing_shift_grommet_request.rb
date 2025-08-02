class CanvassingShiftGrommetRequest < ActiveRecord::Base
  belongs_to :grommet_request, optional: true
  belongs_to :canvassing_shift, primary_key: :shift_external_id, foreign_key: :shift_external_id, optional: true
  
  validates_presence_of :grommet_request_id
  validates_presence_of :shift_external_id
  
end
