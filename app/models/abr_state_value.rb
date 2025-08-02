class AbrStateValue < ActiveRecord::Base
  belongs_to :abr, optional: true
end
