class TrackingParam < ApplicationRecord
  belongs_to :query_param_trackable, polymorphic: true
end
