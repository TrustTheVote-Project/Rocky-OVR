class CreateStateRegistrantsMnRegistrants < ActiveRecord::Migration
  def change
    create_table :state_registrants_mn_registrants do |t|
      t.string   "email"
      t.string   "registrant_id"
      t.string   "locale"
      t.string   "status"

      t.boolean  "confirm_eligibility"

      t.string   "name_title"
      t.string   "first_name"
      t.string   "middle_name"
      t.string   "last_name"
      t.string   "name_suffix"

      t.date     "date_of_birth"

      t.string   "phone"
      t.string   "phone_type"

      t.boolean  "opt_in_email"
      t.boolean  "opt_in_sms"
      t.boolean  "volunteer", default: false
      t.boolean  "partner_opt_in_sms"
      t.boolean  "partner_opt_in_email"
      t.boolean  "partner_volunteer"

      t.string   "dln"
      t.string   "ssn4"
      t.boolean  "confirm_no_dln"
      t.boolean  "confirm_no_dl_or_ssn"

      t.string   "signature_method"
      t.text     "voter_signature_image"
      t.string   "sms_number_for_continue_on_device"
      t.string   "email_address_for_continue_on_device"

      t.string   "home_address"
      t.string   "home_unit"
      t.string   "home_city"
      t.string   "home_zip_code",                      limit: 10
    
      t.boolean  "has_mailing_address"
      t.string   "mailing_address"
      t.string   "mailing_city"
      t.string   "mailing_unit"
      t.string   "mailing_state_id"
      t.string   "mailing_zip_code"
      t.boolean  "change_of_address"
      t.string   "prev_address"
      t.string   "prev_unit"
      t.string   "prev_city"
      t.integer  "prev_state_id"
      t.string   "prev_zip_code"

      t.string   "original_survey_question_1"
      t.string   "original_survey_question_2"
      t.string   "survey_answer_1"
      t.string   "survey_answer_2"

      t.boolean  "confirm_declaration"


      # t.boolean  "change_of_name"
      # t.string   "previous_first_name",                  limit: 255
      # t.string   "previous_last_name",                   limit: 255
      # t.string   "previous_middle_name",                 limit: 255





      # t.string   "party",                                limit: 255
      # t.string   "other_party",                          limit: 255
      # t.boolean  "change_of_party"
      # t.string   "race",                                 limit: 255


      # t.boolean  "has_assistant"
      # t.string   "assistant_name",                       limit: 255
      # t.string   "assistant_address",                    limit: 255
      # t.string   "assistant_phone",                      limit: 255

      t.timestamps null: false
    end
  end
end
