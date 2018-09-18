# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180914110348) do

  create_table "admins", force: :cascade do |t|
    t.string   "username",           limit: 255
    t.string   "email",              limit: 255
    t.string   "crypted_password",   limit: 255
    t.string   "password_salt",      limit: 255
    t.string   "persistence_token",  limit: 255
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.integer  "failed_login_count"
    t.string   "perishable_token",   limit: 255
    t.integer  "login_count",                    default: 0, null: false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip",   limit: 255
    t.string   "last_login_ip",      limit: 255
  end

  add_index "admins", ["perishable_token"], name: "index_admins_on_perishable_token", unique: true
  add_index "admins", ["persistence_token"], name: "index_admins_on_persistence_token", unique: true

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",                    default: 0
    t.integer  "attempts",                    default: 0
    t.text     "handler",    limit: 16777215
    t.text     "last_error", limit: 16777215
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "queue",      limit: 255
  end

  create_table "email_templates", force: :cascade do |t|
    t.integer  "partner_id",             null: false
    t.string   "name",       limit: 255, null: false
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "subject",    limit: 255
  end

  add_index "email_templates", ["partner_id", "name"], name: "index_email_templates_on_partner_id_and_name", unique: true

  create_table "geo_states", force: :cascade do |t|
    t.string   "name",                    limit: 21
    t.string   "abbreviation",            limit: 2
    t.boolean  "requires_race"
    t.boolean  "requires_party"
    t.boolean  "participating"
    t.integer  "id_length_min"
    t.integer  "id_length_max"
    t.string   "registrar_address",       limit: 255
    t.string   "registrar_phone",         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "registrar_url",           limit: 255
    t.string   "online_registration_url", limit: 255
  end

  create_table "grommet_requests", force: :cascade do |t|
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.text     "request_params"
    t.string   "request_hash",    limit: 255
    t.text     "request_headers"
  end

  add_index "grommet_requests", ["request_hash"], name: "index_grommet_requests_on_request_hash"

  create_table "partners", force: :cascade do |t|
    t.string   "username",                           limit: 255,                 null: false
    t.string   "email",                              limit: 255,                 null: false
    t.string   "crypted_password",                   limit: 255,                 null: false
    t.string   "password_salt",                      limit: 255,                 null: false
    t.string   "persistence_token",                  limit: 255,                 null: false
    t.string   "perishable_token",                   limit: 255, default: "",    null: false
    t.string   "name",                               limit: 255
    t.string   "organization",                       limit: 255
    t.string   "url",                                limit: 255
    t.string   "address",                            limit: 255
    t.string   "city",                               limit: 255
    t.integer  "state_id"
    t.string   "zip_code",                           limit: 10
    t.string   "phone",                              limit: 255
    t.string   "survey_question_1_en",               limit: 255
    t.string   "survey_question_1_es",               limit: 255
    t.string   "survey_question_2_en",               limit: 255
    t.string   "survey_question_2_es",               limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "ask_for_volunteers",                             default: false
    t.string   "widget_image",                       limit: 255
    t.string   "logo_file_name",                     limit: 255
    t.string   "logo_content_type",                  limit: 255
    t.integer  "logo_file_size"
    t.boolean  "whitelabeled",                                   default: false
    t.boolean  "partner_ask_for_volunteers",                     default: false
    t.boolean  "rtv_email_opt_in",                               default: true
    t.boolean  "partner_email_opt_in",                           default: false
    t.boolean  "rtv_sms_opt_in",                                 default: true
    t.boolean  "partner_sms_opt_in",                             default: false
    t.string   "api_key",                            limit: 40,  default: ""
    t.string   "privacy_url",                        limit: 255
    t.string   "from_email",                         limit: 255
    t.string   "finish_iframe_url",                  limit: 255
    t.boolean  "csv_ready",                                      default: false
    t.string   "csv_file_name",                      limit: 255
    t.boolean  "is_government_partner",                          default: false
    t.integer  "government_partner_state_id"
    t.text     "government_partner_zip_codes"
    t.text     "survey_question_1"
    t.text     "survey_question_2"
    t.text     "external_tracking_snippet"
    t.string   "registration_instructions_url",      limit: 255
    t.text     "pixel_tracking_codes"
    t.datetime "from_email_verified_at"
    t.datetime "from_email_verification_checked_at"
    t.boolean  "enabled_for_grommet",                            default: false, null: false
    t.text     "branding_update_request"
    t.boolean  "active",                                         default: true,  null: false
    t.text     "external_conversion_snippet"
    t.text     "replace_system_css"
    t.string   "pa_api_key",                         limit: 255
    t.integer  "failed_login_count"
    t.integer  "login_count",                                    default: 0,     null: false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip",                   limit: 255
    t.string   "last_login_ip",                      limit: 255
    t.boolean  "grommet_csv_ready"
    t.string   "grommet_csv_file_name",              limit: 255
  end

  add_index "partners", ["email"], name: "index_partners_on_email"
  add_index "partners", ["perishable_token"], name: "index_partners_on_perishable_token"
  add_index "partners", ["persistence_token"], name: "index_partners_on_persistence_token"
  add_index "partners", ["username"], name: "index_partners_on_username"
  add_index "partners", ["whitelabeled"], name: "index_partners_on_whitelabeled"

  create_table "pdf_deliveries", force: :cascade do |t|
    t.integer  "registrant_id"
    t.integer  "delivery_attempts"
    t.boolean  "deliverd_to_printer"
    t.boolean  "pdf_ready"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  add_index "pdf_deliveries", ["registrant_id"], name: "index_pdf_deliveries_on_registrant_id"

  create_table "pdf_generations", force: :cascade do |t|
    t.integer  "registrant_id"
    t.boolean  "locked",        default: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "pdf_generations", ["locked"], name: "index_pdf_generations_on_locked"

  create_table "priority_pdf_generations", force: :cascade do |t|
    t.integer  "registrant_id"
    t.boolean  "locked",        default: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "priority_pdf_generations", ["locked"], name: "index_priority_pdf_generations_on_locked"

  create_table "registrant_statuses", force: :cascade do |t|
    t.integer  "registrant_id"
    t.string   "state_transaction_id",   limit: 255
    t.string   "state_status",           limit: 255
    t.string   "state_status_details",   limit: 255
    t.integer  "geo_state_id"
    t.datetime "state_application_date"
    t.text     "state_data"
    t.integer  "admin_id"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  add_index "registrant_statuses", ["state_transaction_id", "geo_state_id"], name: "registrant_statues_state_id_index"

  create_table "registrants", force: :cascade do |t|
    t.string   "status",                             limit: 255
    t.string   "locale",                             limit: 64
    t.integer  "partner_id"
    t.string   "uid",                                limit: 255
    t.integer  "reminders_left",                                 default: 0
    t.date     "date_of_birth"
    t.string   "email_address",                      limit: 255
    t.boolean  "first_registration"
    t.string   "home_zip_code",                      limit: 10
    t.boolean  "us_citizen"
    t.string   "name_title",                         limit: 255
    t.string   "first_name",                         limit: 255
    t.string   "middle_name",                        limit: 255
    t.string   "last_name",                          limit: 255
    t.string   "name_suffix",                        limit: 255
    t.string   "home_address",                       limit: 255
    t.string   "home_unit",                          limit: 255
    t.string   "home_city",                          limit: 255
    t.integer  "home_state_id"
    t.boolean  "has_mailing_address"
    t.string   "mailing_address",                    limit: 255
    t.string   "mailing_unit",                       limit: 255
    t.string   "mailing_city",                       limit: 255
    t.integer  "mailing_state_id"
    t.string   "mailing_zip_code",                   limit: 10
    t.string   "party",                              limit: 255
    t.string   "race",                               limit: 255
    t.string   "state_id_number",                    limit: 255
    t.string   "phone",                              limit: 255
    t.string   "phone_type",                         limit: 255
    t.boolean  "change_of_name"
    t.string   "prev_name_title",                    limit: 255
    t.string   "prev_first_name",                    limit: 255
    t.string   "prev_middle_name",                   limit: 255
    t.string   "prev_last_name",                     limit: 255
    t.string   "prev_name_suffix",                   limit: 255
    t.boolean  "change_of_address"
    t.string   "prev_address",                       limit: 255
    t.string   "prev_unit",                          limit: 255
    t.string   "prev_city",                          limit: 255
    t.integer  "prev_state_id"
    t.string   "prev_zip_code",                      limit: 10
    t.boolean  "opt_in_email",                                   default: false
    t.boolean  "opt_in_sms",                                     default: false
    t.string   "survey_answer_1",                    limit: 255
    t.string   "survey_answer_2",                    limit: 255
    t.boolean  "ineligible_non_participating_state"
    t.boolean  "ineligible_age"
    t.boolean  "ineligible_non_citizen"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "abandoned",                                      default: false, null: false
    t.boolean  "volunteer",                                      default: false
    t.string   "tracking_source",                    limit: 255
    t.boolean  "under_18_ok"
    t.boolean  "remind_when_18"
    t.integer  "age"
    t.string   "official_party_name",                limit: 255
    t.boolean  "pdf_ready"
    t.string   "barcode",                            limit: 12
    t.boolean  "partner_opt_in_email",                           default: false
    t.boolean  "partner_opt_in_sms",                             default: false
    t.boolean  "partner_volunteer",                              default: false
    t.boolean  "has_state_license"
    t.boolean  "using_state_online_registration",                default: false
    t.boolean  "javascript_disabled",                            default: false
    t.string   "tracking_id",                        limit: 255
    t.boolean  "finish_with_state",                              default: false
    t.string   "original_survey_question_1",         limit: 255
    t.string   "original_survey_question_2",         limit: 255
    t.boolean  "send_confirmation_reminder_emails",              default: false
    t.boolean  "building_via_api_call",                          default: false
    t.boolean  "short_form",                                     default: false
    t.string   "collect_email_address",              limit: 255
    t.boolean  "will_be_18_by_election"
    t.text     "state_ovr_data"
    t.integer  "remote_partner_id"
    t.string   "remote_uid",                         limit: 255
    t.string   "remote_pdf_path",                    limit: 255
    t.string   "custom_stop_reminders_url",          limit: 255
    t.boolean  "pdf_downloaded",                                 default: false
    t.datetime "pdf_downloaded_at"
    t.boolean  "final_reminder_delivered",                       default: false
    t.boolean  "is_fake",                                        default: false
    t.boolean  "has_ssn"
    t.string   "home_county",                        limit: 255
    t.string   "prev_county",                        limit: 255
    t.string   "mailing_county",                     limit: 255
    t.string   "open_tracking_id",                   limit: 255
  end

  add_index "registrants", ["abandoned", "status"], name: "registrant_stale"
  add_index "registrants", ["abandoned"], name: "index_registrants_on_abandoned"
  add_index "registrants", ["age"], name: "index_registrants_on_age"
  add_index "registrants", ["created_at"], name: "index_registrants_on_created_at"
  add_index "registrants", ["finish_with_state", "partner_id", "status", "created_at"], name: "index_registrants_for_stats"
  add_index "registrants", ["finish_with_state", "partner_id", "status", "home_state_id"], name: "index_registrants_by_state"
  add_index "registrants", ["finish_with_state", "partner_id", "status"], name: "index_registrants_for_started_count"
  add_index "registrants", ["home_state_id"], name: "index_registrants_on_home_state_id"
  add_index "registrants", ["name_title"], name: "index_registrants_on_name_title"
  add_index "registrants", ["official_party_name"], name: "index_registrants_on_official_party_name"
  add_index "registrants", ["partner_id", "status"], name: "index_registrants_by_partner_and_status"
  add_index "registrants", ["partner_id"], name: "index_registrants_on_partner_id"
  add_index "registrants", ["race"], name: "index_registrants_on_race"
  add_index "registrants", ["reminders_left", "updated_at"], name: "index_registrants_on_reminders_left_and_updated_at"
  add_index "registrants", ["remote_partner_id"], name: "index_registrants_on_remote_partner_id"
  add_index "registrants", ["remote_uid"], name: "index_registrants_on_remote_uid"
  add_index "registrants", ["status", "partner_id", "age"], name: "index_registrants_by_age"
  add_index "registrants", ["status", "partner_id", "name_title"], name: "index_registrants_by_gender"
  add_index "registrants", ["status", "partner_id", "official_party_name"], name: "index_registrants_by_party"
  add_index "registrants", ["status", "partner_id", "race"], name: "index_registrants_by_race"
  add_index "registrants", ["status"], name: "index_registrants_on_status"
  add_index "registrants", ["uid"], name: "index_registrants_on_uid"

  create_table "settings", force: :cascade do |t|
    t.string   "var",         limit: 255, null: false
    t.text     "value"
    t.integer  "target_id"
    t.string   "target_type", limit: 30
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "settings", ["target_type", "target_id", "var"], name: "index_settings_on_target_type_and_target_id_and_var", unique: true

  create_table "state_localizations", force: :cascade do |t|
    t.integer  "state_id"
    t.string   "locale",                    limit: 64
    t.string   "parties",                   limit: 1024
    t.string   "no_party",                  limit: 255
    t.string   "not_participating_tooltip", limit: 1024
    t.string   "race_tooltip",              limit: 1024
    t.string   "id_number_tooltip",         limit: 1024
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "party_tooltip",             limit: 1024
    t.string   "sub_18",                    limit: 1024
    t.string   "registration_deadline",     limit: 1024
    t.string   "pdf_instructions",          limit: 1024
    t.string   "email_instructions",        limit: 1024
    t.string   "pdf_other_instructions",    limit: 1024
  end

  add_index "state_localizations", ["state_id"], name: "index_state_localizations_on_state_id"

  create_table "state_registrants_pa_registrants", force: :cascade do |t|
    t.string   "email",                                limit: 255
    t.boolean  "confirm_us_citizen"
    t.boolean  "confirm_will_be_18"
    t.date     "date_of_birth"
    t.string   "name_title",                           limit: 255
    t.string   "first_name",                           limit: 255
    t.string   "middle_name",                          limit: 255
    t.string   "last_name",                            limit: 255
    t.string   "name_suffix",                          limit: 255
    t.boolean  "change_of_name"
    t.string   "previous_first_name",                  limit: 255
    t.string   "previous_last_name",                   limit: 255
    t.string   "registration_address_1",               limit: 255
    t.string   "registration_address_2",               limit: 255
    t.string   "registration_unit_type",               limit: 255
    t.string   "registration_unit_number",             limit: 255
    t.string   "registration_city",                    limit: 255
    t.string   "registration_zip_code",                limit: 255
    t.string   "registration_county",                  limit: 255
    t.boolean  "has_mailing_address"
    t.string   "mailing_address",                      limit: 255
    t.string   "mailing_city",                         limit: 255
    t.string   "mailing_state",                        limit: 255
    t.string   "mailing_zip_code",                     limit: 255
    t.boolean  "change_of_address"
    t.string   "previous_address",                     limit: 255
    t.string   "previous_city",                        limit: 255
    t.string   "previous_state",                       limit: 255
    t.string   "previous_zip_code",                    limit: 255
    t.string   "previous_county",                      limit: 255
    t.boolean  "opt_in_email"
    t.boolean  "opt_in_sms"
    t.string   "phone",                                limit: 255
    t.string   "party",                                limit: 255
    t.string   "other_party",                          limit: 255
    t.boolean  "change_of_party"
    t.string   "race",                                 limit: 255
    t.string   "penndot_number",                       limit: 255
    t.string   "ssn4",                                 limit: 255
    t.boolean  "confirm_no_dl_or_ssn"
    t.text     "voter_signature_image"
    t.boolean  "has_assistant"
    t.string   "assistant_name",                       limit: 255
    t.string   "assistant_address",                    limit: 255
    t.string   "assistant_phone",                      limit: 255
    t.boolean  "confirm_assistant_declaration"
    t.boolean  "confirm_declaration"
    t.datetime "created_at",                                                   null: false
    t.datetime "updated_at",                                                   null: false
    t.string   "registrant_id",                        limit: 255
    t.string   "locale",                               limit: 255
    t.string   "status",                               limit: 255
    t.boolean  "confirm_no_penndot_number"
    t.boolean  "pa_submission_complete"
    t.string   "pa_transaction_id",                    limit: 255
    t.text     "pa_submission_error"
    t.string   "previous_middle_name",                 limit: 255
    t.string   "phone_type",                           limit: 255
    t.string   "signature_method",                     limit: 255
    t.string   "sms_number_for_continue_on_device",    limit: 255
    t.string   "email_address_for_continue_on_device", limit: 255
    t.integer  "original_partner_id"
    t.boolean  "partner_opt_in_sms"
    t.boolean  "partner_opt_in_email"
    t.boolean  "partner_volunteer"
    t.integer  "penndot_retries",                                  default: 0
  end

  add_index "state_registrants_pa_registrants", ["original_partner_id"], name: "pa_registrants_original_partner_id"

  create_table "state_registrants_va_registrants", force: :cascade do |t|
    t.boolean  "confirm_voter_record_update"
    t.boolean  "confirm_us_citizen"
    t.string   "ssn",                             limit: 255
    t.boolean  "confirm_no_ssn"
    t.string   "dln",                             limit: 255
    t.boolean  "confirm_no_dln"
    t.date     "date_of_birth"
    t.string   "name_title",                      limit: 255
    t.string   "first_name",                      limit: 255
    t.string   "middle_name",                     limit: 255
    t.boolean  "confirm_no_middle_name"
    t.string   "last_name",                       limit: 255
    t.string   "name_suffix",                     limit: 255
    t.boolean  "change_of_name"
    t.string   "previous_first_name",             limit: 255
    t.string   "previous_last_name",              limit: 255
    t.string   "previous_middle_name",            limit: 255
    t.string   "previous_name_suffix",            limit: 255
    t.string   "registration_address_1",          limit: 255
    t.string   "registration_address_2",          limit: 255
    t.string   "registration_city",               limit: 255
    t.string   "registration_zip_code",           limit: 255
    t.string   "registration_locality",           limit: 255
    t.string   "email",                           limit: 255
    t.string   "phone",                           limit: 255
    t.boolean  "opt_in_email"
    t.boolean  "opt_in_sms"
    t.boolean  "convicted_of_felony"
    t.boolean  "right_to_vote_restored"
    t.boolean  "is_military"
    t.boolean  "is_law_enforcement"
    t.boolean  "is_court_protected"
    t.boolean  "is_confidentiality_program"
    t.boolean  "is_being_stalked"
    t.boolean  "no_usps_address"
    t.string   "mailing_address_1",               limit: 255
    t.string   "mailing_address_2",               limit: 255
    t.string   "mailing_city",                    limit: 255
    t.string   "mailing_state",                   limit: 255
    t.string   "mailing_zip_code",                limit: 255
    t.string   "mailing_address_locality",        limit: 255
    t.boolean  "registered_in_other_state"
    t.string   "other_registration_state_abbrev", limit: 255
    t.boolean  "interested_in_being_poll_worker"
    t.datetime "submitted_at"
    t.boolean  "confirm_voter_fraud_warning"
    t.boolean  "confirm_affirm_privacy_notice"
    t.boolean  "confirm_will_be_18"
    t.string   "registrant_id",                   limit: 255
    t.string   "locale",                          limit: 255
    t.string   "status",                          limit: 255
    t.boolean  "va_check_complete"
    t.string   "va_check_voter_id",               limit: 255
    t.boolean  "va_check_is_registered_voter"
    t.boolean  "va_check_has_dmv_signature"
    t.boolean  "va_check_error"
    t.text     "va_check_response"
    t.boolean  "va_submission_complete"
    t.string   "va_transaction_id",               limit: 255
    t.text     "va_submission_error"
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.boolean  "has_mailing_address"
    t.boolean  "confirm_register_to_vote"
    t.string   "phone_type",                      limit: 255
  end

  create_table "tracking_events", force: :cascade do |t|
    t.string   "tracking_event_name", limit: 255
    t.string   "source_tracking_id",  limit: 255
    t.string   "partner_tracking_id", limit: 255
    t.string   "open_tracking_id",    limit: 255
    t.text     "geo_location"
    t.text     "tracking_data"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  add_index "tracking_events", ["open_tracking_id"], name: "index_tracking_events_on_open_tracking_id"
  add_index "tracking_events", ["partner_tracking_id"], name: "index_tracking_events_on_partner_tracking_id"
  add_index "tracking_events", ["source_tracking_id"], name: "index_tracking_events_on_source_tracking_id"

  create_table "zip_code_county_addresses", force: :cascade do |t|
    t.integer  "geo_state_id"
    t.string   "zip",                 limit: 255
    t.string   "address",             limit: 255
    t.text     "county",              limit: 255
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.text     "cities"
    t.text     "unacceptable_cities"
    t.datetime "last_checked"
  end

  add_index "zip_code_county_addresses", ["geo_state_id"], name: "index_zip_code_county_addresses_on_geo_state_id"
  add_index "zip_code_county_addresses", ["zip"], name: "index_zip_code_county_addresses_on_zip"

end
