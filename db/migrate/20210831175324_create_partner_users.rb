class CreatePartnerUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :partner_users do |t|
      t.belongs_to :partner
      t.belongs_to :user
      t.timestamps
    end
  end
end
