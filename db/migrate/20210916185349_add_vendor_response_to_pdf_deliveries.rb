class AddVendorResponseToPdfDeliveries < ActiveRecord::Migration[5.2]
  def change
    add_column :pdf_deliveries, :api_vendor_id, :string
    add_column :pdf_deliveries, :api_vendor_response, :text
  end
end
