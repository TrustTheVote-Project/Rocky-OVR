class AddStateRegistrantWaRegistrants < ActiveRecord::Migration[5.2]
  def change
    create_table :state_registrants_wa_registrants do |t|


      t.string	"first_name"
      t.string	"middle_name"
      t.string	"last_name"
      t.string	"name_suffix"
      t.date	"date_of_birth"




      t.boolean	"is_resident"
      t.boolean	"is_citizen"

      t.string	"prev_first_name"
      t.string	"prev_middle_name"
      t.string	"prev_last_name"

      t.string	"prev_name_suffix"

      t.string	"residence_unit_number"
      t.string	"residence_unit_type"
      t.string	"residence_address"
      t.string	"residence_city"
      t.string	"residence_state"
      t.string	"residence_zip"
      t.string	"res_county_code"

      t.string	"mailing_unit_number"
      t.string	"mailing_unit_type"
      t.string	"mailing_address"
      t.string	"mailing_city"
      t.string	"mailing_state"
      t.string	"mailing_zip"
      t.string	"mail_county_code"

      t.string	"prev_residence_unit_number"
      t.string	"prev_residence_unit_type"
      t.string	"prev_residence_address"
      t.string	"prev_residence_city"
      t.string	"prev_residence_state"
      t.string	"prev_residence_zip"
      t.string	"prev_res_county_code"


      t.boolean	"address_change"
      t.date	    "res_address_change_made_date"
  
      t.string	"prev_mailing_unit_type"
      t.string	"prev_mailing_unit_number"
      t.string	"prev_mailing_address"
      t.string	"prev_mailing_city"
      t.string	"prev_mailing_state"
      t.string	"prev_mailing_zip"
      t.string	"prev_mail_county_code"

      t.date	    "mail_address_change_made_date"


      t.boolean	"is_homeless"
      t.boolean	"military_flag"
      t.string	"gender"

        #t.string	"customer_id"
      t.string	"driver_license"
      t.date	    "issue_date"

      t.string	"dle"
      t.string	"old_dln"
      t.boolean	"enhanced_dln"

      t.string	"ssn4"

      t.text	    "signature"


      t.date	    "registration_date"









      t.string	"transaction_id"

      #adding

      t.string   "registrant_id"
      t.string   "locale"
      t.string   "status"
  
      #t.boolean  "wa_check_complete"
      #t.string   "wa_check_voter_id" #might not be applicable

      #t.boolean  "wa_check_is_registered_voter"
      #t.boolean  "wa_check_has_dmv_signature"
      #t.boolean  "wa_check_error"  #do we have checks?
      #t.text     "wa_check_response" #do we have checks?
      
      t.text     "wa_submission_error"
      t.boolean  "wa_submission_complete"
      t.string   "wa_transaction_id"

  
      
      t.string    "email"
      t.string    "phone"
      t.string    "phone_type"
      t.boolean    "opt_in_email"
      t.boolean    "opt_in_sms"

      t.boolean    "has_dln"
      t.boolean    "has_ssn"
      

      t.boolean   "has_previous_address"
      t.boolean   "has_previous_mailing_address"
      t.boolean   "has_previous_name"
  
      t.boolean   "has_mailing_address"
      t.boolean   "partner_opt_in_email"
      t.boolean   "partner_opt_in_sms"
      t.boolean   "partner_volunteer"

      t.string "return_token"
      t.boolean "wa_check_complete"
      
      t.timestamps
    end
  end

end
