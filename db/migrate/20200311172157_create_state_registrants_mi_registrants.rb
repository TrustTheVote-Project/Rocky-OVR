class CreateStateRegistrantsMiRegistrants < ActiveRecord::Migration
  def change
    create_table :state_registrants_mi_registrants do |t|
      t.string  :registrant_id
      t.string  :locale
      t.string  :status
      

      t.string :email
      
      t.datetime :submitted_at

      t.boolean :updated_dln_recently
      t.boolean :requested_duplicate_dln_today

      t.boolean :confirm_us_citizen
      t.boolean :confirm_will_be_18
      
      t.boolean :is_30_day_resident
      t.boolean :registration_cancellation_authorized
      t.boolean :digital_signature_authorized
      
      t.string  :full_name
      t.string  :dln
      
      t.date :date_of_birth
      
      t.string :eye_color_code
      
      t.string :ssn4
      
      
      t.string :registration_address_number
      t.string :registration_address_street_name
      t.string :registration_address_street_type
      t.string :registration_unit_type
      t.string :registration_unit_number
      t.string :registration_city
      t.string :registration_zip_code
      t.string :registration_county
      
      t.boolean :has_mailing_address
      t.string :mailing_attention
      t.string :mailing_address_type
      t.string :mailing_box_id
      t.string :mailing_box_group_type
      
      t.string :mailing_box_group_id
      t.string :mailing_address_1
      t.string :mailing_address_2
      t.string :mailing_address_3
      t.string :mailing_city # Or military place name
      t.string :mailing_state
      t.string :mailing_country
      t.string :mailing_zip_code
      
      
      
      t.boolean :opt_in_email
      t.boolean :opt_in_sms
      
      t.boolean  :partner_opt_in_sms
      t.boolean  :partner_opt_in_email
      t.boolean  :partner_volunteer
      
      
      t.string :phone
      
      
      t.timestamps null: false
    end
    add_index "state_registrants_pa_registrants", ["registrant_id"], name: "pa_registrants_registrant_id"
    add_index "state_registrants_va_registrants", ["registrant_id"], name: "va_registrants_registrant_id"
    add_index "state_registrants_mi_registrants", ["registrant_id"], name: "mi_registrants_registrant_id"
  end
end
