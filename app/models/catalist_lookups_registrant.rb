class CatalistLookupsRegistrant < ActiveRecord::Base
  belongs_to :registrant, primary_key: :uid, foreign_key: :registrant_uid, optional: true
  belongs_to :catalist_lookup, optional: true


end
