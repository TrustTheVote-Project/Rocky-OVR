class CatalistLookupsRegistrant < ActiveRecord::Base
  belongs_to :registrant, primary_key: :uid, foreign_key: :registrant_uid
  belongs_to :catalist_lookup


end
