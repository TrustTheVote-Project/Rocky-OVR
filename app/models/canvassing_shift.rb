class CanvassingShift < ActiveRecord::Base
  has_many :canvassing_shift_registrations
  has_many :registrations, through: :canvassing_shift_registrations
  
  belongs_to :canvasser
  
end
