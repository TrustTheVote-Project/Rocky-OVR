class CreateStateRegistrantsVaRegistrants < ActiveRecord::Migration
  def change
    create_table :state_registrants_va_registrants do |t|
      t.boolean :confirm_voter_record_update
      t.boolean  "confirm_us_citizen"
      t.string   "ssn"
      t.boolean  "confirm_no_ssn"
      t.string   "dln"
      t.boolean  "confirm_no_dln"
      t.date     "date_of_birth"

      t.string    "dln"
      

      t.string   "name_title"
      t.string   "first_name"
      t.string   "middle_name"
      t.boolean  :confirm_no_middle_name
      t.string   "last_name"
      t.string   "name_suffix"
      
      t.boolean  "change_of_name"
      t.string   "previous_first_name"
      t.string   "previous_last_name"
      t.string   "previous_middle_name"
      t.string   "previous_name_suffix"
      
      
      t.string   "registration_address_1"
      t.string   "registration_address_2"
      t.string   "registration_city"
      t.string   "registration_zip_code"
      t.string   "registration_locality"

      t.string   "email"
      t.string   "phone"
      t.boolean  "opt_in_email"
      t.boolean  "opt_in_sms"

      t.boolean  :convicted_of_felony
      t.boolean  :right_to_vote_restored
      
      t.boolean  "is_military"
      t.boolean :is_law_enforcement
      t.boolean :is_court_protected
      t.boolean :is_confidentiality_program
      t.boolean :is_being_stalked
      
      t.boolean :no_usps_address
      t.string   "mailing_address_1"
      t.string   "mailing_address_2"
      t.string   "mailing_city"
      t.string   "mailing_state"
      t.string   "mailing_zip_code"
      t.string   "mailing_address_locality"

      t.boolean  :registered_in_other_state
      t.string   :other_registration_state_abbrev

      t.boolean  :interested_in_being_poll_worker

      t.datetime :submitted_at

      t.boolean :confirm_voter_fraud_warning
      t.boolean :confirm_affirm_privacy_notice

      t.boolean  "confirm_will_be_18"
      
      
      #t.string   "party"
      #t.string   "other_party"
      #t.boolean  "change_of_party"
      #t.string   "race"

      t.string   "registrant_id"
      t.string   "locale"
      t.string   "status"
      t.boolean  "va_check_complete"
      t.string   "va_check_voter_id"
      t.boolean  "va_check_is_registered_voter"
      t.boolean  "va_check_has_dmv_signature"
      t.boolean  "va_check_error"
      t.text     "va_check_response"
      t.boolean  "va_submission_complete"
      t.string   "va_transaction_id"
      t.text     "va_submission_error"
      
      
      t.timestamps
    end
  end
end
