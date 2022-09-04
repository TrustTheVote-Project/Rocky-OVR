class AddApprovalRequestToPartners < ActiveRecord::Migration[4.2]
  def change
    add_column :partners, :branding_update_request, :text
  end
end
