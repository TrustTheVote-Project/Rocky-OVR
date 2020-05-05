class CanvassingShiftRegistration < ActiveRecord::Base
  belongs_to :registrant, primary_key: :uid
  belongs_to :canvassing_shift, primary_key: :shift_external_id, foreign_key: :shift_external_id
end
