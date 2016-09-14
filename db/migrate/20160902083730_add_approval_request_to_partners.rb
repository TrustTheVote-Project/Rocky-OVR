class AddApprovalRequestToPartners < ActiveRecord::Migration
  def change
    add_column :partners, :branding_update_request, :text
  end
end
