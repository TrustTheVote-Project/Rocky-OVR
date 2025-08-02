class AddCountiesToAddresses < ActiveRecord::Migration[4.2]
  def change
    add_column :registrants, :home_county, :string
    add_column :registrants, :prev_county, :string
    add_column :registrants, :mailing_county, :string
  end
end
