class CreateStateRegistrantsPaRegistrants < ActiveRecord::Migration
  def change
    create_table :state_registrants_pa_registrants do |t|
      t.string :email
      
      t.boolean :confirm_us_citizen
      t.boolean :confirm_will_be_18
      t.date :date_of_birth
      t.string :name_title
      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.string :name_suffix
      
      t.boolean :change_of_name
      t.string :previous_first_name
      t.string :previous_last_name
      t.string :previous_suffix
      
      t.string :registration_address_1
      t.string :registration_address_2
      t.string :registration_unit_type
      t.string :registration_unit_number
      t.string :registration_city
      t.string :registration_zip_code
      t.string :registration_county
      
      t.boolean :has_mailing_address
      t.string :mailing_address
      t.string :mailing_city
      t.string :mailing_state
      t.string :mailing_zip_code
      
      t.boolean :change_of_address
      t.string :previous_address
      t.string :previous_city
      t.string :previous_state
      t.string :previous_zip_code
      t.string :previous_county
      
      t.boolean :opt_in_email
      t.boolean :opt_in_sms
      
      t.string :phone
      
      t.string :party
      t.string :other_party
      t.boolean :change_of_party
      t.string :race
      
      t.string :penndot_number
      t.string :ssn4
      t.boolean :confirm_no_dl_or_ssn
      t.string :voter_signature_image
      
      t.boolean :has_assistant
      t.string :assistant_name
      t.string :assistant_address
      t.string :assistant_phone
      t.boolean :confirm_assistant_declaration
      
      t.boolean :confirm_declaration
      
      t.timestamps
    end
  end
end
