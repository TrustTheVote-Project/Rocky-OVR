class CreatePdfDeliveryReports < ActiveRecord::Migration
  def change
    create_table :pdf_delivery_reports do |t|
      t.date :date, index: true
      t.integer :assistance_registrants
      t.integer :direct_mail_registrants
      t.string :status
      t.text :last_error
      t.timestamps null: false
    end
  end
end
