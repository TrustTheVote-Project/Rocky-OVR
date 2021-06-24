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

ActiveRecord::Schema.define(version: 2020_12_24_191326) do

  create_table "ab_tests", force: :cascade do |t|
    t.integer "registrant_id"
    t.string "name"
    t.string "assignment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "assignment"], name: "index_ab_tests_on_name_and_assignment"
    t.index ["name"], name: "index_ab_tests_on_name"
    t.index ["registrant_id"], name: "index_ab_tests_on_registrant_id"
  end

  create_table "abr_email_deliveries", force: :cascade do |t|
    t.integer "abr_id"
    t.string "to_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["abr_id"], name: "index_abr_email_deliveries_on_abr_id"
    t.index ["to_email"], name: "index_abr_email_deliveries_on_to_email"
  end

  create_table "abr_state_values", force: :cascade do |t|
    t.integer "abr_id"
    t.string "attribute_name"
    t.string "string_value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["abr_id"], name: "index_abr_state_values_on_abr_id"
    t.index ["attribute_name"], name: "index_abr_state_values_on_attribute_name"
  end

  create_table "abrs", force: :cascade do |t|
    t.string "uid"
    t.integer "partner_id"
    t.string "first_name"
    t.string "middle_name"
    t.string "last_name"
    t.string "name_suffix"
    t.string "city"
    t.integer "home_state_id"
    t.string "zip"
    t.string "email"
    t.string "phone"
    t.date "date_of_birth"
    t.boolean "javascript_disabled", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "phone_type"
    t.boolean "opt_in_email"
    t.boolean "opt_in_sms"
    t.boolean "partner_opt_in_email"
    t.boolean "partner_opt_in_sms"
    t.string "votercheck"
    t.string "current_step"
    t.string "max_step"
    t.boolean "abandoned", default: false, null: false
    t.boolean "pdf_ready"
    t.boolean "pdf_downloaded"
    t.datetime "pdf_downloaded_at"
    t.string "street_number"
    t.string "street_name"
    t.string "street_line2"
    t.string "unit"
    t.boolean "finish_with_state", default: false
    t.boolean "final_reminder_delivered", default: false
    t.integer "reminders_left"
    t.boolean "dead_end", default: false
    t.string "tracking_source"
    t.string "tracking_id"
    t.string "registration_county"
    t.boolean "confirm_email_delivery"
    t.index ["abandoned", "dead_end", "current_step"], name: "index_abrs_for_abandonment"
    t.index ["abandoned"], name: "index_abrs_on_abandoned"
    t.index ["current_step"], name: "index_abrs_on_current_step"
    t.index ["dead_end"], name: "index_abrs_on_dead_end"
    t.index ["email"], name: "index_abrs_on_email"
    t.index ["home_state_id"], name: "index_abrs_on_home_state_id"
    t.index ["partner_id"], name: "index_abrs_on_partner_id"
    t.index ["uid"], name: "index_abrs_on_uid"
  end

  create_table "abrs_catalist_lookups", force: :cascade do |t|
    t.integer "abr_id"
    t.integer "catalist_lookup_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["abr_id", "catalist_lookup_id"], name: "abrs_catalist_join_index"
    t.index ["abr_id"], name: "index_abrs_catalist_lookups_on_abr_id"
    t.index ["catalist_lookup_id"], name: "index_abrs_catalist_lookups_on_catalist_lookup_id"
  end

  create_table "admins", force: :cascade do |t|
    t.string "username", limit: 255
    t.string "email", limit: 255
    t.string "crypted_password", limit: 255
    t.string "password_salt", limit: 255
    t.string "persistence_token", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "failed_login_count"
    t.string "perishable_token", limit: 255
    t.integer "login_count", default: 0, null: false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string "current_login_ip", limit: 255
    t.string "last_login_ip", limit: 255
    t.boolean "active", default: true, null: false
    t.index ["perishable_token"], name: "index_admins_on_perishable_token", unique: true
    t.index ["persistence_token"], name: "index_admins_on_persistence_token", unique: true
  end

  create_table "ballot_status_checks", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "zip"
    t.string "phone"
    t.integer "partner_id"
    t.string "tracking_source"
    t.string "tracking_id"
    t.string "uid"
    t.boolean "opt_in_email"
    t.boolean "opt_in_sms"
    t.boolean "partner_opt_in_email"
    t.boolean "partner_opt_in_sms"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["partner_id"], name: "bsc_partners"
    t.index ["uid"], name: "index_ballot_status_checks_on_uid"
  end

  create_table "blocks_form_dispositions", force: :cascade do |t|
    t.integer "grommet_request_id"
    t.string "registrant_id"
    t.string "blocks_form_id"
    t.boolean "final_state_submitted", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["blocks_form_id"], name: "index_blocks_form_dispositions_on_blocks_form_id"
    t.index ["grommet_request_id"], name: "index_blocks_form_dispositions_on_grommet_request_id"
    t.index ["registrant_id"], name: "index_blocks_form_dispositions_on_registrant_id"
  end

  create_table "blocks_locations", force: :cascade do |t|
    t.string "blocks_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["blocks_id"], name: "index_blocks_locations_on_blocks_id"
  end

  create_table "blocks_service_bulk_submissions", force: :cascade do |t|
    t.datetime "shift_start"
    t.datetime "shift_end"
    t.text "partners_submitted"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "canvassing_shift_grommet_requests", force: :cascade do |t|
    t.string "grommet_request_id"
    t.string "shift_external_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["grommet_request_id"], name: "index_canvassing_shift_grommet_requests_on_grommet_request_id"
    t.index ["shift_external_id"], name: "index_canvassing_shift_grommet_requests_on_shift_external_id"
  end

  create_table "canvassing_shift_registrants", force: :cascade do |t|
    t.string "registrant_id"
    t.string "shift_external_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["registrant_id"], name: "index_canvassing_shift_registrants_on_registrant_id"
    t.index ["shift_external_id"], name: "index_canvassing_shift_registrants_on_shift_external_id"
  end

  create_table "canvassing_shifts", force: :cascade do |t|
    t.integer "partner_id"
    t.string "shift_location"
    t.text "geo_location"
    t.string "shift_external_id"
    t.string "source_tracking_id"
    t.string "partner_tracking_id"
    t.string "open_tracking_id"
    t.string "device_id"
    t.datetime "clock_in_datetime"
    t.datetime "clock_out_datetime"
    t.integer "abandoned_registrations"
    t.integer "completed_registrations"
    t.string "canvasser_phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "submitted_to_blocks", default: false
    t.string "canvasser_first_name"
    t.string "canvasser_last_name"
    t.string "canvasser_email"
    t.string "shift_source"
    t.string "blocks_shift_id"
    t.boolean "complete"
    t.string "blocks_shift_location_name"
    t.string "blocks_turf_id"
    t.index ["canvasser_first_name", "canvasser_last_name"], name: "shift_canvasser_name_index"
    t.index ["partner_id"], name: "canvasser_index"
    t.index ["partner_id"], name: "index_canvassing_shifts_on_partner_id"
    t.index ["partner_tracking_id"], name: "index_canvassing_shifts_on_partner_tracking_id"
    t.index ["shift_external_id"], name: "index_canvassing_shifts_on_shift_external_id"
    t.index ["shift_location"], name: "index_canvassing_shifts_on_shift_location"
    t.index ["source_tracking_id"], name: "index_canvassing_shifts_on_source_tracking_id"
  end

  create_table "catalist_lookups", force: :cascade do |t|
    t.string "first"
    t.string "middle"
    t.string "last"
    t.string "suffix"
    t.string "gender"
    t.date "birthdate"
    t.string "address"
    t.string "city"
    t.integer "state_id"
    t.string "zip"
    t.string "county"
    t.string "phone"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "match"
    t.integer "partner_id"
    t.string "tracking_source"
    t.string "tracking_id"
    t.string "uid"
    t.string "phone_type"
    t.boolean "opt_in_email"
    t.boolean "opt_in_sms"
    t.boolean "partner_opt_in_email"
    t.boolean "partner_opt_in_sms"
    t.index ["email"], name: "index_catalist_lookups_on_email"
    t.index ["partner_id"], name: "index_catalist_lookups_on_partner_id"
    t.index ["state_id"], name: "index_catalist_lookups_on_state_id"
  end

  create_table "catalist_lookups_registrants", force: :cascade do |t|
    t.string "registrant_uid"
    t.integer "catalist_lookup_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["catalist_lookup_id"], name: "index_catalist_lookups_registrants_on_catalist_lookup_id"
    t.index ["registrant_uid", "catalist_lookup_id"], name: "registrants_catalist_join_index"
    t.index ["registrant_uid"], name: "index_catalist_lookups_registrants_on_registrant_uid"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0
    t.integer "attempts", default: 0
    t.text "handler", limit: 16777215
    t.text "last_error", limit: 16777215
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "queue", limit: 255
    t.string "cron"
  end

  create_table "email_addresses", force: :cascade do |t|
    t.string "email_address"
    t.boolean "blacklisted"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["blacklisted", "email_address"], name: "index_email_addresses_on_blacklisted_and_email_address"
    t.index ["blacklisted"], name: "index_email_addresses_on_blacklisted"
    t.index ["email_address"], name: "index_email_addresses_on_email_address"
  end

  create_table "email_domains", force: :cascade do |t|
    t.string "domain"
    t.boolean "blacklisted"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["blacklisted", "domain"], name: "index_email_domains_on_blacklisted_and_domain"
    t.index ["blacklisted"], name: "index_email_domains_on_blacklisted"
    t.index ["domain"], name: "index_email_domains_on_domain"
  end

  create_table "email_templates", force: :cascade do |t|
    t.integer "partner_id", null: false
    t.string "name", limit: 255, null: false
    t.text "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "subject", limit: 255
    t.index ["partner_id", "name"], name: "index_email_templates_on_partner_id_and_name", unique: true
  end

  create_table "geo_states", force: :cascade do |t|
    t.string "name", limit: 21
    t.string "abbreviation", limit: 2
    t.boolean "requires_race"
    t.boolean "requires_party"
    t.boolean "participating"
    t.integer "id_length_min"
    t.integer "id_length_max"
    t.string "registrar_address", limit: 255
    t.string "registrar_phone", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "registrar_url", limit: 255
    t.string "online_registration_url", limit: 255
    t.string "online_registration_system_name"
    t.string "registrar_abr_address"
    t.string "status_check_url"
    t.boolean "pdf_assistance_enabled"
    t.date "catalist_updated_at"
  end

  create_table "grommet_requests", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "request_params"
    t.string "request_hash", limit: 255
    t.text "request_headers"
    t.index ["request_hash"], name: "index_grommet_requests_on_request_hash"
  end

  create_table "partners", force: :cascade do |t|
    t.string "username", limit: 255, null: false
    t.string "email", limit: 255, null: false
    t.string "crypted_password", limit: 255, null: false
    t.string "password_salt", limit: 255, null: false
    t.string "persistence_token", limit: 255, null: false
    t.string "perishable_token", limit: 255, default: "", null: false
    t.string "name", limit: 255
    t.string "organization", limit: 255
    t.string "url", limit: 255
    t.string "address", limit: 255
    t.string "city", limit: 255
    t.integer "state_id"
    t.string "zip_code", limit: 10
    t.string "phone", limit: 255
    t.string "survey_question_1_en", limit: 255
    t.string "survey_question_1_es", limit: 255
    t.string "survey_question_2_en", limit: 255
    t.string "survey_question_2_es", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "ask_for_volunteers", default: false
    t.string "widget_image", limit: 255
    t.string "logo_file_name", limit: 255
    t.string "logo_content_type", limit: 255
    t.integer "logo_file_size"
    t.boolean "whitelabeled", default: false
    t.boolean "partner_ask_for_volunteers", default: false
    t.boolean "rtv_email_opt_in", default: true
    t.boolean "partner_email_opt_in", default: false
    t.boolean "rtv_sms_opt_in", default: true
    t.boolean "partner_sms_opt_in", default: false
    t.string "api_key", limit: 40, default: ""
    t.string "privacy_url", limit: 255
    t.string "from_email", limit: 255
    t.string "finish_iframe_url", limit: 255
    t.boolean "csv_ready", default: false
    t.string "csv_file_name", limit: 255
    t.boolean "is_government_partner", default: false
    t.integer "government_partner_state_id"
    t.text "government_partner_zip_codes"
    t.text "survey_question_1"
    t.text "survey_question_2"
    t.text "external_tracking_snippet"
    t.string "registration_instructions_url", limit: 255
    t.text "pixel_tracking_codes"
    t.datetime "from_email_verified_at"
    t.datetime "from_email_verification_checked_at"
    t.boolean "enabled_for_grommet", default: false, null: false
    t.text "branding_update_request"
    t.boolean "active", default: true, null: false
    t.text "external_conversion_snippet"
    t.text "replace_system_css"
    t.string "pa_api_key", limit: 255
    t.integer "failed_login_count"
    t.integer "login_count", default: 0, null: false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string "current_login_ip", limit: 255
    t.string "last_login_ip", limit: 255
    t.boolean "grommet_csv_ready"
    t.string "grommet_csv_file_name", limit: 255
    t.string "short_code"
    t.string "terms_url"
    t.boolean "enabled_for_catalist_api"
    t.text "states_enabled_for_pdf_assistance"
    t.index ["email"], name: "index_partners_on_email"
    t.index ["perishable_token"], name: "index_partners_on_perishable_token"
    t.index ["persistence_token"], name: "index_partners_on_persistence_token"
    t.index ["username"], name: "index_partners_on_username"
    t.index ["whitelabeled"], name: "index_partners_on_whitelabeled"
  end

  create_table "pdf_abr_generations", force: :cascade do |t|
    t.integer "abr_id"
    t.boolean "locked", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["locked"], name: "index_pdf_abr_generations_on_locked"
  end

  create_table "pdf_deliveries", force: :cascade do |t|
    t.integer "registrant_id"
    t.integer "delivery_attempts"
    t.boolean "deliverd_to_printer"
    t.boolean "pdf_ready"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["registrant_id"], name: "index_pdf_deliveries_on_registrant_id"
  end

  create_table "pdf_delivery_reports", force: :cascade do |t|
    t.date "date"
    t.integer "assistance_registrants"
    t.integer "direct_mail_registrants"
    t.string "status"
    t.text "last_error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["date"], name: "index_pdf_delivery_reports_on_date"
  end

  create_table "pdf_generations", force: :cascade do |t|
    t.integer "registrant_id"
    t.boolean "locked", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["locked"], name: "index_pdf_generations_on_locked"
  end

  create_table "priority_pdf_generations", force: :cascade do |t|
    t.integer "registrant_id"
    t.boolean "locked", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["locked"], name: "index_priority_pdf_generations_on_locked"
  end

  create_table "registrant_statuses", force: :cascade do |t|
    t.integer "registrant_id"
    t.string "state_transaction_id", limit: 255
    t.string "state_status", limit: 255
    t.string "state_status_details", limit: 255
    t.integer "geo_state_id"
    t.datetime "state_application_date"
    t.text "state_data"
    t.integer "admin_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["state_transaction_id", "geo_state_id"], name: "registrant_statues_state_id_index"
  end

  create_table "registrants", force: :cascade do |t|
    t.string "status", limit: 255
    t.string "locale", limit: 64
    t.integer "partner_id"
    t.string "uid", limit: 255
    t.integer "reminders_left", default: 0
    t.date "date_of_birth"
    t.string "email_address", limit: 255
    t.boolean "first_registration"
    t.string "home_zip_code", limit: 10
    t.boolean "us_citizen"
    t.string "name_title", limit: 255
    t.string "first_name", limit: 255
    t.string "middle_name", limit: 255
    t.string "last_name", limit: 255
    t.string "name_suffix", limit: 255
    t.string "home_address", limit: 255
    t.string "home_unit", limit: 255
    t.string "home_city", limit: 255
    t.integer "home_state_id"
    t.boolean "has_mailing_address"
    t.string "mailing_address", limit: 255
    t.string "mailing_unit", limit: 255
    t.string "mailing_city", limit: 255
    t.integer "mailing_state_id"
    t.string "mailing_zip_code", limit: 10
    t.string "party", limit: 255
    t.string "race", limit: 255
    t.string "state_id_number", limit: 255
    t.string "phone", limit: 255
    t.string "phone_type", limit: 255
    t.boolean "change_of_name"
    t.string "prev_name_title", limit: 255
    t.string "prev_first_name", limit: 255
    t.string "prev_middle_name", limit: 255
    t.string "prev_last_name", limit: 255
    t.string "prev_name_suffix", limit: 255
    t.boolean "change_of_address"
    t.string "prev_address", limit: 255
    t.string "prev_unit", limit: 255
    t.string "prev_city", limit: 255
    t.integer "prev_state_id"
    t.string "prev_zip_code", limit: 10
    t.boolean "opt_in_email", default: false
    t.boolean "opt_in_sms", default: false
    t.string "survey_answer_1", limit: 255
    t.string "survey_answer_2", limit: 255
    t.boolean "ineligible_non_participating_state"
    t.boolean "ineligible_age"
    t.boolean "ineligible_non_citizen"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "abandoned", default: false, null: false
    t.boolean "volunteer", default: false
    t.string "tracking_source", limit: 255
    t.boolean "under_18_ok"
    t.boolean "remind_when_18"
    t.integer "age"
    t.string "official_party_name", limit: 255
    t.boolean "pdf_ready"
    t.string "barcode", limit: 12
    t.boolean "partner_opt_in_email", default: false
    t.boolean "partner_opt_in_sms", default: false
    t.boolean "partner_volunteer", default: false
    t.boolean "has_state_license"
    t.boolean "using_state_online_registration", default: false
    t.boolean "javascript_disabled", default: false
    t.string "tracking_id", limit: 255
    t.boolean "finish_with_state", default: false
    t.string "original_survey_question_1", limit: 255
    t.string "original_survey_question_2", limit: 255
    t.boolean "send_confirmation_reminder_emails", default: false
    t.boolean "building_via_api_call", default: false
    t.boolean "short_form", default: false
    t.string "collect_email_address", limit: 255
    t.boolean "will_be_18_by_election"
    t.text "state_ovr_data"
    t.integer "remote_partner_id"
    t.string "remote_uid", limit: 255
    t.string "remote_pdf_path", limit: 255
    t.string "custom_stop_reminders_url", limit: 255
    t.boolean "pdf_downloaded", default: false
    t.datetime "pdf_downloaded_at"
    t.boolean "final_reminder_delivered", default: false
    t.boolean "is_fake", default: false
    t.boolean "has_ssn"
    t.string "home_county", limit: 255
    t.string "prev_county", limit: 255
    t.string "mailing_county", limit: 255
    t.string "open_tracking_id", limit: 255
    t.index ["abandoned", "status"], name: "registrant_stale"
    t.index ["abandoned"], name: "index_registrants_on_abandoned"
    t.index ["age"], name: "index_registrants_on_age"
    t.index ["created_at"], name: "index_registrants_on_created_at"
    t.index ["finish_with_state", "partner_id", "status", "created_at"], name: "index_registrants_for_stats"
    t.index ["finish_with_state", "partner_id", "status", "home_state_id"], name: "index_registrants_by_state"
    t.index ["finish_with_state", "partner_id", "status"], name: "index_registrants_for_started_count"
    t.index ["home_state_id"], name: "index_registrants_on_home_state_id"
    t.index ["name_title"], name: "index_registrants_on_name_title"
    t.index ["official_party_name"], name: "index_registrants_on_official_party_name"
    t.index ["partner_id", "status"], name: "index_registrants_by_partner_and_status"
    t.index ["partner_id"], name: "index_registrants_on_partner_id"
    t.index ["race"], name: "index_registrants_on_race"
    t.index ["reminders_left", "updated_at"], name: "index_registrants_on_reminders_left_and_updated_at"
    t.index ["remote_partner_id"], name: "index_registrants_on_remote_partner_id"
    t.index ["remote_uid"], name: "index_registrants_on_remote_uid"
    t.index ["status", "partner_id", "age"], name: "index_registrants_by_age"
    t.index ["status", "partner_id", "name_title"], name: "index_registrants_by_gender"
    t.index ["status", "partner_id", "official_party_name"], name: "index_registrants_by_party"
    t.index ["status", "partner_id", "race"], name: "index_registrants_by_race"
    t.index ["status"], name: "index_registrants_on_status"
    t.index ["uid"], name: "index_registrants_on_uid"
  end

  create_table "report_data", force: :cascade do |t|
    t.integer "report_id"
    t.string "key"
    t.string "s_value"
    t.integer "i_value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "h_value"
    t.index ["key"], name: "index_report_data_on_key"
    t.index ["report_id", "key"], name: "index_report_data_on_report_id_and_key"
    t.index ["report_id"], name: "index_report_data_on_report_id"
  end

  create_table "reports", force: :cascade do |t|
    t.datetime "start_date"
    t.datetime "end_date"
    t.string "report_type"
    t.integer "record_count"
    t.integer "current_index"
    t.integer "partner_id"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "filters"
    t.text "error"
  end

  create_table "request_logs", force: :cascade do |t|
    t.string "client_id"
    t.string "registrant_id"
    t.text "request_uri"
    t.text "request_body"
    t.text "request_headers"
    t.integer "response_code"
    t.text "response_body"
    t.text "error_messages"
    t.integer "network_duration_ms"
    t.integer "total_duration_ms"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "abr_id"
    t.index ["client_id"], name: "index_request_logs_on_client_id"
    t.index ["registrant_id"], name: "index_request_logs_on_registrant_id"
    t.index ["response_code"], name: "index_request_logs_on_response_code"
  end

  create_table "ses_notifications", force: :cascade do |t|
    t.text "request_params"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "settings", force: :cascade do |t|
    t.string "var", limit: 255, null: false
    t.text "value"
    t.integer "target_id"
    t.string "target_type", limit: 30
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["target_type", "target_id", "var"], name: "index_settings_on_target_type_and_target_id_and_var", unique: true
  end

  create_table "state_localizations", force: :cascade do |t|
    t.integer "state_id"
    t.string "locale", limit: 64
    t.string "parties", limit: 20480
    t.string "no_party", limit: 255
    t.string "not_participating_tooltip", limit: 20480
    t.string "race_tooltip", limit: 20480
    t.string "id_number_tooltip", limit: 20480
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "party_tooltip", limit: 20480
    t.string "sub_18", limit: 20480
    t.string "registration_deadline", limit: 20480
    t.string "pdf_instructions", limit: 20480
    t.string "email_instructions", limit: 20480
    t.string "pdf_other_instructions", limit: 20480
    t.index ["state_id"], name: "index_state_localizations_on_state_id"
  end

  create_table "state_registrants_mi_registrants", force: :cascade do |t|
    t.string "registrant_id"
    t.string "locale"
    t.string "status"
    t.string "email"
    t.datetime "submitted_at"
    t.boolean "updated_dln_recently"
    t.boolean "requested_duplicate_dln_today"
    t.boolean "confirm_us_citizen"
    t.boolean "confirm_will_be_18"
    t.boolean "is_30_day_resident"
    t.boolean "registration_cancellation_authorized"
    t.boolean "digital_signature_authorized"
    t.string "full_name"
    t.string "dln"
    t.date "date_of_birth"
    t.string "eye_color_code"
    t.string "ssn4"
    t.string "registration_address_number"
    t.string "registration_address_street_name"
    t.string "registration_address_street_type"
    t.string "registration_unit_number"
    t.string "registration_city"
    t.string "registration_zip_code"
    t.string "registration_county"
    t.boolean "has_mailing_address"
    t.string "mailing_address_type"
    t.string "mailing_address_1"
    t.string "mailing_address_2"
    t.string "mailing_address_3"
    t.string "mailing_address_unit_number"
    t.string "mailing_city"
    t.string "mailing_state"
    t.string "mailing_country"
    t.string "mailing_zip_code"
    t.boolean "opt_in_email"
    t.boolean "opt_in_sms"
    t.boolean "partner_opt_in_sms"
    t.boolean "partner_opt_in_email"
    t.boolean "partner_volunteer"
    t.string "phone"
    t.boolean "mi_submission_complete"
    t.integer "submission_attempts", default: 0
    t.string "mi_transaction_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "mi_api_voter_status_id"
    t.string "registration_address_post_directional"
    t.text "registration_address_matches"
    t.boolean "has_ssn", default: false
    t.boolean "has_state_license", default: false
    t.boolean "volunteer", default: false
    t.string "original_survey_question_1"
    t.string "original_survey_question_2"
    t.string "survey_answer_1"
    t.string "survey_answer_2"
    t.index ["registrant_id"], name: "mi_registrants_registrant_id"
  end

  create_table "state_registrants_pa_registrants", force: :cascade do |t|
    t.string "email", limit: 255
    t.boolean "confirm_us_citizen"
    t.boolean "confirm_will_be_18"
    t.date "date_of_birth"
    t.string "name_title", limit: 255
    t.string "first_name", limit: 255
    t.string "middle_name", limit: 255
    t.string "last_name", limit: 255
    t.string "name_suffix", limit: 255
    t.boolean "change_of_name"
    t.string "previous_first_name", limit: 255
    t.string "previous_last_name", limit: 255
    t.string "registration_address_1", limit: 255
    t.string "registration_address_2", limit: 255
    t.string "registration_unit_type", limit: 255
    t.string "registration_unit_number", limit: 255
    t.string "registration_city", limit: 255
    t.string "registration_zip_code", limit: 255
    t.string "registration_county", limit: 255
    t.boolean "has_mailing_address"
    t.string "mailing_address", limit: 255
    t.string "mailing_city", limit: 255
    t.string "mailing_state", limit: 255
    t.string "mailing_zip_code", limit: 255
    t.boolean "change_of_address"
    t.string "previous_address", limit: 255
    t.string "previous_city", limit: 255
    t.string "previous_state", limit: 255
    t.string "previous_zip_code", limit: 255
    t.string "previous_county", limit: 255
    t.boolean "opt_in_email"
    t.boolean "opt_in_sms"
    t.string "phone", limit: 255
    t.string "party", limit: 255
    t.string "other_party", limit: 255
    t.boolean "change_of_party"
    t.string "race", limit: 255
    t.string "penndot_number", limit: 255
    t.string "ssn4", limit: 255
    t.boolean "confirm_no_dl_or_ssn"
    t.text "voter_signature_image"
    t.boolean "has_assistant"
    t.string "assistant_name", limit: 255
    t.string "assistant_address", limit: 255
    t.string "assistant_phone", limit: 255
    t.boolean "confirm_assistant_declaration"
    t.boolean "confirm_declaration"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "registrant_id", limit: 255
    t.string "locale", limit: 255
    t.string "status", limit: 255
    t.boolean "confirm_no_penndot_number"
    t.boolean "pa_submission_complete"
    t.string "pa_transaction_id", limit: 255
    t.text "pa_submission_error"
    t.string "previous_middle_name", limit: 255
    t.string "phone_type", limit: 255
    t.string "signature_method", limit: 255
    t.string "sms_number_for_continue_on_device", limit: 255
    t.string "email_address_for_continue_on_device", limit: 255
    t.integer "original_partner_id"
    t.boolean "partner_opt_in_sms"
    t.boolean "partner_opt_in_email"
    t.boolean "partner_volunteer"
    t.integer "penndot_retries", default: 0
    t.boolean "volunteer", default: false
    t.string "original_survey_question_1"
    t.string "original_survey_question_2"
    t.string "survey_answer_1"
    t.string "survey_answer_2"
    t.index ["original_partner_id"], name: "pa_registrants_original_partner_id"
    t.index ["registrant_id"], name: "pa_registrants_registrant_id"
  end

  create_table "state_registrants_va_registrants", force: :cascade do |t|
    t.boolean "confirm_voter_record_update"
    t.boolean "confirm_us_citizen"
    t.string "ssn", limit: 255
    t.boolean "confirm_no_ssn"
    t.string "dln", limit: 255
    t.boolean "confirm_no_dln"
    t.date "date_of_birth"
    t.string "name_title", limit: 255
    t.string "first_name", limit: 255
    t.string "middle_name", limit: 255
    t.boolean "confirm_no_middle_name"
    t.string "last_name", limit: 255
    t.string "name_suffix", limit: 255
    t.boolean "change_of_name"
    t.string "previous_first_name", limit: 255
    t.string "previous_last_name", limit: 255
    t.string "previous_middle_name", limit: 255
    t.string "previous_name_suffix", limit: 255
    t.string "registration_address_1", limit: 255
    t.string "registration_address_2", limit: 255
    t.string "registration_city", limit: 255
    t.string "registration_zip_code", limit: 255
    t.string "registration_locality", limit: 255
    t.string "email", limit: 255
    t.string "phone", limit: 255
    t.boolean "opt_in_email"
    t.boolean "opt_in_sms"
    t.boolean "convicted_of_felony"
    t.boolean "right_to_vote_restored"
    t.boolean "is_military"
    t.boolean "is_law_enforcement"
    t.boolean "is_court_protected"
    t.boolean "is_confidentiality_program"
    t.boolean "is_being_stalked"
    t.boolean "no_usps_address"
    t.string "mailing_address_1", limit: 255
    t.string "mailing_address_2", limit: 255
    t.string "mailing_city", limit: 255
    t.string "mailing_state", limit: 255
    t.string "mailing_zip_code", limit: 255
    t.string "mailing_address_locality", limit: 255
    t.boolean "registered_in_other_state"
    t.string "other_registration_state_abbrev", limit: 255
    t.boolean "interested_in_being_poll_worker"
    t.datetime "submitted_at"
    t.boolean "confirm_voter_fraud_warning"
    t.boolean "confirm_affirm_privacy_notice"
    t.boolean "confirm_will_be_18"
    t.string "registrant_id", limit: 255
    t.string "locale", limit: 255
    t.string "status", limit: 255
    t.boolean "va_check_complete"
    t.string "va_check_voter_id", limit: 255
    t.boolean "va_check_is_registered_voter"
    t.boolean "va_check_has_dmv_signature"
    t.boolean "va_check_error"
    t.text "va_check_response"
    t.boolean "va_submission_complete"
    t.string "va_transaction_id", limit: 255
    t.text "va_submission_error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "has_mailing_address"
    t.boolean "confirm_register_to_vote"
    t.string "phone_type", limit: 255
    t.boolean "partner_opt_in_sms"
    t.boolean "partner_opt_in_email"
    t.boolean "partner_volunteer"
    t.boolean "volunteer", default: false
    t.string "original_survey_question_1"
    t.string "original_survey_question_2"
    t.string "survey_answer_1"
    t.string "survey_answer_2"
    t.index ["registrant_id"], name: "va_registrants_registrant_id"
  end

  create_table "tracking_events", force: :cascade do |t|
    t.string "tracking_event_name", limit: 255
    t.string "source_tracking_id", limit: 255
    t.string "partner_tracking_id", limit: 255
    t.string "open_tracking_id", limit: 255
    t.text "geo_location"
    t.text "tracking_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["open_tracking_id"], name: "index_tracking_events_on_open_tracking_id"
    t.index ["partner_tracking_id"], name: "index_tracking_events_on_partner_tracking_id"
    t.index ["source_tracking_id"], name: "index_tracking_events_on_source_tracking_id"
  end

  create_table "voter_signatures", force: :cascade do |t|
    t.string "registrant_id"
    t.text "voter_signature_image"
    t.string "signature_method"
    t.string "sms_number_for_continue_on_device"
    t.string "email_address_for_continue_on_device"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "abr_id"
    t.index ["registrant_id"], name: "index_voter_signatures_on_registrant_id"
  end

  create_table "zip_code_county_addresses", force: :cascade do |t|
    t.integer "geo_state_id"
    t.string "zip", limit: 255
    t.string "address", limit: 255
    t.text "county", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "cities"
    t.text "unacceptable_cities"
    t.datetime "last_checked"
    t.string "vr_address_to"
    t.string "vr_street1"
    t.string "vr_street2"
    t.string "vr_city"
    t.string "vr_state"
    t.string "vr_zip"
    t.string "req_address_to"
    t.string "req_street1"
    t.string "req_street2"
    t.string "req_city"
    t.string "req_state"
    t.string "req_zip"
    t.string "vr_contact_email"
    t.string "vr_contact_phone"
    t.string "req_contact_email"
    t.string "req_contact_phone"
    t.string "vr_contact_office_name"
    t.string "vr_contact_title"
    t.string "vr_contact_first_name"
    t.string "vr_contact_last_name"
    t.string "vr_contact_suffix"
    t.string "vr_website"
    t.string "req_contact_office_name"
    t.string "req_contact_title"
    t.string "req_contact_first_name"
    t.string "req_contact_last_name"
    t.string "req_contact_suffix"
    t.string "req_website"
    t.string "vr_main_phone"
    t.string "vr_main_email"
    t.string "req_main_phone"
    t.string "req_main_email"
    t.index ["geo_state_id"], name: "index_zip_code_county_addresses_on_geo_state_id"
    t.index ["zip"], name: "index_zip_code_county_addresses_on_zip"
  end

end
