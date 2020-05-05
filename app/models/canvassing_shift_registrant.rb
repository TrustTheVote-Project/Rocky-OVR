class CanvassingShiftRegistrant < ActiveRecord::Base
  belongs_to :registrant, primary_key: :uid
  belongs_to :canvassing_shift, primary_key: :shift_external_id, foreign_key: :shift_external_id
  
  validates_presence_of :registrant_id
  validates_presence_of :shift_external_id
  
end
