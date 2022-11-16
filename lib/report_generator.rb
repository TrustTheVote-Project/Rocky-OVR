class ReportGenerator
  
  #!/usr/bin/env bash
  # r.id, r.status, r.locale, r.partner_id, r.uid, r.reminders_left, r.date_of_birth, r.email_address, r.first_registration, r.home_zip_code, r.us_citizen, r.name_title, r.first_name, r.middle_name, r.last_name, r.name_suffix, r.home_address, r.home_unit, r.home_city, l.abbreviation, r.has_mailing_address, r.mailing_address, r.mailing_unit, r.mailing_city, r.mailing_state_id, r.mailing_zip_code, r.party, r.race, r.state_id_number, r.phone, r.phone_type, r.change_of_name, r.prev_name_title, r.prev_first_name, r.prev_middle_name, r.prev_last_name, r.prev_name_suffix, r.change_of_address, r.prev_address, r.prev_unit, r.prev_city, r.prev_state_id, r.prev_zip_code, r.opt_in_email, r.opt_in_sms, r.survey_answer_1, r.survey_answer_2, r.ineligible_non_participating_state, r.ineligible_age, r.ineligible_non_citizen, r.created_at, r.updated_at, r.abandoned, r.volunteer, r.tracking_source, r.finish_with_state, r.send_confirmation_reminder_emails, r.building_via_api_call 
  # from registrants r join geo_states l on (r.home_state_id = l.id) where date(r.created_at) = date_sub(curdate(), interval 1 day) 
  
  #!/usr/bin/env bash
  # r.id, r.status, r.locale, r.partner_id, r.uid, r.reminders_left, r.date_of_birth, r.email_address, r.first_registration, r.home_zip_code, r.us_citizen, r.name_title, r.first_name, r.middle_name, r.last_name, r.name_suffix, r.home_address, r.home_unit, r.home_city, l.abbreviation, r.has_mailing_address, r.mailing_address, r.mailing_unit, r.mailing_city, r.mailing_state_id, r.mailing_zip_code, r.party, r.race, r.state_id_number, r.phone, r.phone_type, r.change_of_name, r.prev_name_title, r.prev_first_name, r.prev_middle_name, r.prev_last_name, r.prev_name_suffix, r.change_of_address, r.prev_address, r.prev_unit, r.prev_city, r.prev_state_id, r.prev_zip_code, r.opt_in_email, r.opt_in_sms, r.survey_answer_1, r.survey_answer_2, r.ineligible_non_participating_state, r.ineligible_age, r.ineligible_non_citizen, r.created_at, r.updated_at, r.abandoned, r.volunteer, r.tracking_source, r.finish_with_state, r.send_confirmation_reminder_emails, r.building_via_api_call 
  # from registrants r join geo_states l on (r.home_state_id = l.id) where date(r.created_at) >= date_sub(curdate(), interval 6 hour)
  def self.registrant_fields
    %w(id status locale partner_id uid reminders_left date_of_birth email_address first_registration? home_zip_code us_citizen name_title first_name middle_name last_name name_suffix home_address home_unit home_city home_state_abbrev has_mailing_address mailing_address mailing_unit mailing_city mailing_state_id mailing_zip_code party race state_id_number phone phone_type change_of_name prev_name_title prev_first_name prev_middle_name prev_last_name prev_name_suffix change_of_address prev_address prev_unit prev_city prev_state_id prev_zip_code opt_in_email opt_in_sms survey_answer_1 survey_answer_2 ineligible_non_participating_state ineligible_age ineligible_non_citizen created_at updated_at abandoned volunteer tracking_source tracking_id open_tracking_id finish_with_state send_confirmation_reminder_emails building_via_api_call submitted_via_state_api? submitted_via_state_api_with_default_key?)
  end
  def self.registrant_fields_old
    %w(id status locale partner_id uid reminders_left date_of_birth email_address first_registration? home_zip_code us_citizen name_title first_name middle_name last_name name_suffix home_address home_unit home_city home_state_abbrev has_mailing_address mailing_address mailing_unit mailing_city mailing_state_id mailing_zip_code party race state_id_number phone phone_type change_of_name prev_name_title prev_first_name prev_middle_name prev_last_name prev_name_suffix change_of_address prev_address prev_unit prev_city prev_state_id prev_zip_code opt_in_email opt_in_sms survey_answer_1 survey_answer_2 ineligible_non_participating_state ineligible_age ineligible_non_citizen created_at updated_at abandoned volunteer tracking_source finish_with_state send_confirmation_reminder_emails building_via_api_call)
  end
  # p.id, p.username, p.email, p.name, p.organization, p.url, p.address, p.city, l.abbreviation, p.zip_code, p.phone, p.survey_question_1_en, p.survey_question_1_es, p.survey_question_2_en, p.survey_question_2_es, p.created_at, p.updated_at from partners p join geo_states l on (p.state_id = l.id)

  def self.abr_field_mapping(column_name, row)
    case column_name
    when "home_address"
      return [row["street_number"], row["street_name"], row["street_line2"]].join(" ")
    when "home_unit"
      return row["unit"]
    when "home_city"
      return row["city"]
    when "home_zip_code"
      return row["zip"]
    when "abbreviation"
      return row.home_state_abbrev
    when "abr_uid"
      return row["uid"]
    when "tool"
      return "abr"
    when "uid"
      return nil
    end
    begin
      if abr_fields.include?(column_name)
        return row.send(column_name)
      else
        return ""
      end
    rescue
      return ""
    end
  end

  def self.abr_fields
    [
      "id", # -> map to id
      "locale", # -> map to locale
      "partner_id", # -> map to partner_id
      "date_of_birth", # -> map to date_of_birth
      "email_address", # -> map to email_address
      "name_title", # -> map to name_title
      "first_name", # -> map to first_name
      "middle_name", # -> map to middle_name
      "last_name", # -> map to last_name
      "name_suffix", # -> map to name_suffix

      "street_number", # V (merge below)
      "street_name", # -> map to home_address (combine street number + street name + street_line2 please)
      "street_line2", # ^ (merge above)
      
      "unit", # -> map to home_unit
      "city", # -> map to home_city
      "home_state_abbrev", # -> map to abbreviation
      "zip", # -> map to home_zip_code
      "phone", # -> map to phone
      "phone_type", # -> map to phone_type
      "opt_in_email", # -> map to opt_in_email
      "opt_in_sms", # -> map to opt_in_sms
      "created_at", # -> map to created_at
      "updated_at", # -> map to udpated_at
      "volunteer", # -> map to volunteer (if available)
      "tracking_source", # -> map to tracking_source
      "tracking_id", # -> map to tracking_id
      "finish_with_state", # -> map to finish_with_state

      "uid", # -> (add new field to end of file called abr_uid)
      "current_step", # -> (add new field to end of file called current_step)
      "max_step", # -> (add new field to end of file called max_step)
      "pdf_ready", # -> (add new field to end of file called pdf_ready)
      "tool", # -> (add new field to end of file called tool and add default value 'abr')
    ]
  end

  def self.lookup_field_mapping(column_name, row)
    case column_name
    when "date_of_birth"
      return row["birthdate"]
    when "home_address"
      return row["address"]
    when "home_city"
      return row["city"]
    when "abbreviation"
      return row.state_abbrev
    when "home_zip_code"
      return row["zip"]
    when "home_state_abbrev"
      return row.state_abbrev
    when "email_address"
      return row["email"]
    when "uid"
      return row["registrant_uid"]
    when "lookup_uid"
      return row["uid"]
    when "abr_uid"
      return row.abr_uid
    when "first_name"
      return row.first
    when "last_name"
      return row.last
    when "middle_name"
      return row.middle
    when "tool"
      return "lookup"
    end
    begin
      if catalist_lookup_fields.include?(column_name)
        return row.send(column_name)
      else
        return ""
      end
    rescue
      return ""
    end
  end

  def self.catalist_lookup_fields
    [
      "id",
      "first", # -> map to first_name
      "middle", # -> map to middle_name
      "last", # -> map to last_name
      "suffix", # -> map to name_suffix
      "birthdate", # -> map to date_of_birth
      "address", #  -> map to home_address
      "city", #  -> map to home_city
      "state_abbrev", # -> map to abbreviation
      "zip", # -> map to home_zip_code
      "phone", # -> map to phone
      "email", # -> map to email_address
      "created_at", # -> map to created_at
      "updated_at", # -> map to updated_at
      "partner_id", # -> map to partner_id
      "tracking_source", # -> tracking_source
      "tracking_id", # -> map to tracking_id
      "phone_type", # -> map to phone_type
      "opt_in_email", # -> map to opt_in_email
      "opt_in_sms", # -> map to opt_in_sms
      "registrant_uid", # -> map to uid

      "gender", # -> (add new field to end of file called gender)
      "uid", # -> (add new field to end of file called lookup_uid)
      "abr_uid", # -> (add new field to end of file called abr_uid)
      "tool", # -> (add new field to end of file called tool and add default value 'lookup')
    ]
  end

  def self.bsc_field_mapping(column_name, row)
    case column_name
    when "email_address"
      return row["email"]
    when "home_zip_code"
      return row["zip"]
    when "ballot_status_check_uid"
      return row["uid"]
    when "tool"
      return "ballot_status_check"
    end
    begin
      if ballot_status_check_fields.include?(column_name)
        return row.send(column_name)
      else
        return ""
      end
    rescue
      return ""
    end
  end

  def self.ballot_status_check_fields
    [
      "id", # map to id
      "first_name", # map to first_name
      "last_name", # map to last_name
      "email", # map to email_address
      "zip", # map to home_zip_code
      "phone", # map to phone
      "partner_id", # map to partner_id
      "tracking_source", # tracking_source
      "tracking_id", # tracking_id
      "opt_in_email", # map to opt_in_email
      "opt_in_sms", # map to opt_in_sms
      "created_at", # map to created_at
      "updated_at", # map to updated_at

      "ballot_status_check_uid"
    ]
  end

  def self.alert_field_mapping(column_name, row)
    case column_name
    when "first_name"
      return row.first
    when "last_name"
      return row.last
    when "middle_name"
      return row.middle
    when "email_address"
      return row["email"]
    when "home_zip_code"
      return row["zip"]
    when "tool"
      return "alert_requests"
    when "home_address"
      return row["address"]
    when "home_unit"
      return row["address_2"]
    when "home_city"
      return row["city"]
    when "home_zip_code"
      return row["zip"]
    when "abbreviation"
      return row.state_abbrev
    when "alert_request_uid"
      return row["uid"]
    end
    begin
      if alert_request_fields.include?(column_name)
        return row.send(column_name)
      else
        return ""
      end
    rescue
      return ""
    end
  end

  def self.alert_request_fields
    ["id",
    "locale",
    "partner_id",
    "first",
    "middle",
    "last",
    "date_of_birth",
    "email",
    "phone",
    "phone_type",
    "address",
    "address_2",
    "city",
    "state_id",
    "zip",
    "opt_in_email",
    "opt_in_sms",
    "partner_opt_in_email",
    "partner_opt_in_sms",
    "javascript_disabled",
    "tracking_source",
    "tracking_id",
    "original_survey_question_1",
    "original_survey_question_2",
    "survey_answer_1",
    "survey_answer_2",
    "created_at",
    "updated_at",

    "alert_request_uid"]
  end


  def self.voteready_fields
    %w(id 
      locale 
      partner_id
      partner_name
      uid 
      date_of_birth_year
      date_of_birth_month
      date_of_birth_day
      name_title 
      first_name 
      middle_name 
      last_name 
      prev_name_title
      prev_first_name
      prev_middle_name
      prev_last_name
      prev_name_suffix
      name_suffix 
      home_address 
      home_unit 
      home_city 
      home_zip_code 
      home_state_abbrev 
      prev_address
      prev_unit
      prev_city
      prev_state_abbrev
      prev_zip_code
      mailing_address 
      mailing_unit 
      mailing_city
      mailing_state_abbrev
      mailing_zip_code
      party
      race
      email_address
      phone
      phone_type
      created_at
      updated_at      
    )
  end

  def self.partner_fields
    %w(id username email name organization url address city state_abbrev zip_code phone survey_question_1_en survey_question_1_es survey_question_2_en survey_question_2_es created_at updated_at active whitelabeled)
  end
  # p.id, p.username, p.email, p.name, p.organization, p.url, p.address, p.city, l.abbreviation, p.zip_code, p.phone, p.survey_question_1_en, p.survey_question_1_es, p.survey_question_2_en, p.survey_question_2_es, p.created_at, p.updated_at from partners p join geo_states l on (p.state_id = l.id);

  def self.generate_4
    t = DateTime.now
    self.generate_6hr_registrants(t)
    self.generate_partners(t, 4)
  end
  
  def self.generate_24
    t = DateTime.now
    self.generate_24hr_registrants(t)
    self.generate_partners(t, 24)
    self.generate_voteready_registrants
  end
  
  def self.generate_24hr_registrants(t)
    self.generate_registrants(t, 24)
  end
  
  def self.generate_4hr_registrants(t)
    self.generate_registrants(t, 4)
  end

  def self.generate_6hr_registrants(t)
    self.generate_registrants(t, 6)
  end
  
  def self.generate_partners(t, time_period)
    partners = Partner.includes(:state)
    csv_str = CsvFormatter.wrap do |csv|
      csv << headers = self.partner_fields.dup
      CsvFormatter.rename_array_item(headers, 'state_abbrev', 'abbreviation')

      partners.each do |p|
        p_attr = self.partner_fields.collect {|fname| p.send(fname) }
        csv << p_attr
      end
    end
    if time_period == 24
      self.save_csv_to_s3(csv_str, "partners.csv")
    else
      self.save_csv_to_s3(csv_str, "rtv_partners.csv")
    end
  end
  
  def self.generate_voteready_registrants(start_time = nil, end_time = nil)
    distribute_reads(failover: false) do
      t2 = end_time || Time.now.beginning_of_hour - 1.day
      t1 = start_time || t2 - 24.hours
      registrants = Registrant.where(status: "complete").where("created_at >= ? AND created_at < ?", t1, t2).includes(:home_state, :prev_state, :mailing_state, :partner)
      csv_str = CSV.generate do |csv|
        csv << self.voteready_fields + %w(alloy_person_id permanent_absentee registration_status registration_date submitted_registration_date registration_changed_date)
        registrants.find_each do |r|
          reg_attributes = self.voteready_fields.collect {|fname| r.send(fname) }
          csv << reg_attributes
        end
      end
      file_name = "voteready_registrants_#{t1.strftime("%Y_%m_%d_%H:%M")}-#{t2.strftime("%Y_%m_%d_%H:%M")}.csv"
      self.save_csv_to_s3(csv_str, file_name, voteready: true)
    end
  end

  def self.generate_registrants_old(t, time_span)
    distribute_reads(failover: false) do
      registrants = Registrant.where("created_at > ?", t-time_span.hours).includes(:home_state)
      # Also preload all PA and VA state registrants?
      pa_registrants = {}
      va_registrants = {}
      mi_registrants = {}
      mn_registrants = {}
      wa_registrants = {}
      StateRegistrants::PARegistrant.where("created_at > ?", t-time_span.hours).find_each {|sr| pa_registrants[sr.registrant_id] = sr}
      StateRegistrants::VARegistrant.where("created_at > ?", t-time_span.hours).find_each {|sr| va_registrants[sr.registrant_id] = sr}
      StateRegistrants::MIRegistrant.where("created_at > ?", t-time_span.hours).find_each {|sr| mi_registrants[sr.registrant_id] = sr}
      StateRegistrants::MNRegistrant.where("created_at > ?", t-time_span.hours).find_each {|sr| mn_registrants[sr.registrant_id] = sr}
      StateRegistrants::WARegistrant.where("created_at > ?", t-time_span.hours).find_each {|sr| wa_registrants[sr.registrant_id] = sr}
      csv_str = CsvFormatter.wrap do |csv|
        csv << headers = self.registrant_fields_old.dup
        CsvFormatter.rename_array_item(headers, 'home_state_abbrev', 'abbreviation')
        CsvFormatter.rename_array_item(headers, 'first_registration?', 'first_registration')        
        CsvFormatter.rename_array_item(headers, 'submitted_via_state_api?', 'submitted_via_state_api')
        CsvFormatter.rename_array_item(headers, 'submitted_via_state_api_with_default_key?', 'submitted_via_state_api_with_default_key')

        registrants.find_each do |r|
          # Set the @existing_state_registrant value
          if r.use_state_flow?
            sr  = nil
            case r.home_state_abbrev
            when "PA"
              sr = pa_registrants[r.uid] || nil
            when "VA"
              sr = va_registrants[r.uid] || nil
            when "MI"
              sr = mi_registrants[r.uid] || nil
            when "MN"
              sr = mn_registrants[r.uid] || nil
            when "WA"
              sr = wa_registrants[r.uid] || nil
            end
            r.instance_variable_set(:@existing_state_registrant, sr)
            r.instance_variable_set(:@existing_state_registrant_fetched, true)
          end
          reg_attributes = self.registrant_fields_old.collect {|fname| r.send(fname) }
          csv << reg_attributes
        end
      end
      file_name = self.file_name("registrants", t, time_span)
      self.save_csv_to_s3(csv_str, file_name)
    end
  end

  def self.generate_registrants(t, time_span)
    self.generate_registrants_old(t, time_span)
    # update the Abr method to not run after_initialize
    ENV['GENERATING_REPORTS'] = "true"
    distribute_reads(failover: false) do
      registrants = Registrant.where("created_at > ?", t-time_span.hours).includes(:home_state)
      abrs = Abr.where("created_at > ?", t-time_span.hours).includes(:home_state)
      lookups = CatalistLookup.where("created_at > ?", t-time_span.hours).includes(:state, :abr)
      bscs = BallotStatusCheck.where("created_at > ?", t-time_span.hours)
      alerts = AlertRequest.where("created_at > ?", t-time_span.hours).includes(:state)

      # Also preload all PA and VA state registrants?
      pa_registrants = {}
      va_registrants = {}
      mi_registrants = {}
      mn_registrants = {}
      wa_registrants = {}
      StateRegistrants::PARegistrant.where("created_at > ?", t-time_span.hours).find_each {|sr| pa_registrants[sr.registrant_id] = sr}
      StateRegistrants::VARegistrant.where("created_at > ?", t-time_span.hours).find_each {|sr| va_registrants[sr.registrant_id] = sr}
      StateRegistrants::MIRegistrant.where("created_at > ?", t-time_span.hours).find_each {|sr| mi_registrants[sr.registrant_id] = sr}
      StateRegistrants::MNRegistrant.where("created_at > ?", t-time_span.hours).find_each {|sr| mn_registrants[sr.registrant_id] = sr}
      StateRegistrants::WARegistrant.where("created_at > ?", t-time_span.hours).find_each {|sr| wa_registrants[sr.registrant_id] = sr}

      headers = self.registrant_fields.dup
      headers += [
        "abr_uid",
        "lookup_uid",
        "ballot_status_check_uid",
        "alert_request_uid",
        "current_step",
        "max_step",
        "pdf_ready",
        "gender",
        "tool"
      ]
      csv_str_regs = CsvFormatter.wrap do |csv|
        csv << headers
        CsvFormatter.rename_array_item(headers, 'home_state_abbrev', 'abbreviation')
        CsvFormatter.rename_array_item(headers, 'first_registration?', 'first_registration')
        CsvFormatter.rename_array_item(headers, 'submitted_via_state_api?', 'submitted_via_state_api')
        CsvFormatter.rename_array_item(headers, 'submitted_via_state_api_with_default_key?', 'submitted_via_state_api_with_default_key')

        registrants.find_each do |r|
          # Set the @existing_state_registrant value
          if r.use_state_flow?
            sr  = nil
            case r.home_state_abbrev
            when "PA"
              sr = pa_registrants[r.uid] || nil
            when "VA"
              sr = va_registrants[r.uid] || nil
            when "MI"
              sr = mi_registrants[r.uid] || nil
            when "MN"
              sr = mn_registrants[r.uid] || nil
            when "WA"
              sr = wa_registrants[r.uid] || nil
            end
            r.instance_variable_set(:@existing_state_registrant, sr)
            r.instance_variable_set(:@existing_state_registrant_fetched, true)
          end
          reg_attributes = self.registrant_fields.collect {|fname| r.send(fname) || ""}
          csv << reg_attributes + ["", "", "", "", "", "", "", "", "vr"]          
        end
      end
      csv_str_abrs = CsvFormatter.wrap do |csv|
        csv << headers
        CsvFormatter.rename_array_item(headers, 'home_state_abbrev', 'abbreviation')
        CsvFormatter.rename_array_item(headers, 'first_registration?', 'first_registration')
        CsvFormatter.rename_array_item(headers, 'submitted_via_state_api?', 'submitted_via_state_api')
        CsvFormatter.rename_array_item(headers, 'submitted_via_state_api_with_default_key?', 'submitted_via_state_api_with_default_key')
        abrs.find_each do |abr|
          abr_attributes = headers.collect {|fname| abr_field_mapping(fname, abr) || ""}
          csv << abr_attributes
        end
      end

      csv_str_lookups = CsvFormatter.wrap do |csv|
        csv << headers
        CsvFormatter.rename_array_item(headers, 'home_state_abbrev', 'abbreviation')
        CsvFormatter.rename_array_item(headers, 'first_registration?', 'first_registration')
        CsvFormatter.rename_array_item(headers, 'submitted_via_state_api?', 'submitted_via_state_api')
        CsvFormatter.rename_array_item(headers, 'submitted_via_state_api_with_default_key?', 'submitted_via_state_api_with_default_key')
        lookups.find_each do |lookup|
          lookup_attributes = headers.collect {|fname| lookup_field_mapping(fname, lookup) || ""}
          csv << lookup_attributes
        end
      end
      
      csv_str_bscs = CsvFormatter.wrap do |csv|
        csv << headers
        CsvFormatter.rename_array_item(headers, 'home_state_abbrev', 'abbreviation')
        CsvFormatter.rename_array_item(headers, 'first_registration?', 'first_registration')
        CsvFormatter.rename_array_item(headers, 'submitted_via_state_api?', 'submitted_via_state_api')
        CsvFormatter.rename_array_item(headers, 'submitted_via_state_api_with_default_key?', 'submitted_via_state_api_with_default_key')
        bscs.find_each do |bsc|
          bsc_attributes = headers.collect {|fname| bsc_field_mapping(fname, bsc) || ""}
          csv << bsc_attributes
        end
      end
      
      csv_str_alerts  = CsvFormatter.wrap do |csv|
        csv << headers
        alerts.find_each do |alert|
          alert_attributes = headers.collect {|fname| alert_field_mapping(fname, alert) || ""}
          csv << alert_attributes
        end
      end

      t = DateTime.now
      
      file_name = time_span == 24 ? "rocky-daily-registrants.csv" : "rocky-hourly-registrants.csv"
      file_name = "daily/#{t.strftime("%Y-%m-%d")}-rocky-daily-registrants.csv"
      self.save_csv_to_s3(csv_str_regs, file_name)
      
      file_name = time_span == 24 ? "rocky-daily-abrs.csv" : "rocky-hourly-abrs.csv"
      filename = "daily/#{t.strftime("%Y-%m-%d")}-rocky-daily-abrs.csv"
      self.save_csv_to_s3(csv_str_abrs, file_name)

      file_name = time_span == 24 ? "rocky-daily-lookups.csv" : "rocky-hourly-lookups.csv"
      file_name = "daily/#{t.strftime("%Y-%m-%d")}-rocky-daily-lookups.csv"
      self.save_csv_to_s3(csv_str_lookups, file_name)

      file_name = time_span == 24 ? "rocky-daily-ballot-status-checks.csv" : "rocky-hourly-ballot-status-checks.csv"
      filen_ame = "daily/#{t.strftime("%Y-%m-%d")}-rocky-daily-ballot-status-checks.csv"
      self.save_csv_to_s3(csv_str_bscs, file_name)

      file_name = time_span == 24 ? "rocky-daily-election-alerts.csv" : "rocky-hourly-election-alerts.csv"
      file_name = "daily/#{t.strftime("%Y-%m-%d")}-rocky-daily-election-alerts.csv"
      self.save_csv_to_s3(csv_str_alerts, file_name)
    end
    ENV['GENERATING_REPORTS'] = nil    
  end
  
  def self.file_name(base, time, time_period)
    if time_period == 24
      "registrants.csv"
    else
      "rtv_registrants.csv"
    end
    # d1 = time - time_period
    # d1_str = d1.strftime("%Y_%m_%d-%H:%M")
    # d2_str = time.strftime("%Y_%m_%d-%H:%M")
    # "#{base}_#{time_period}hr_#{d1_str}-#{d2_str}.csv"
  end
  
  def self.save_csv_to_s3(contents, file_name, voteready: false)
    connection = Fog::Storage.new({
      :provider                 => 'AWS',
      :aws_access_key_id        => voteready ? ENV['PDF_AWS_ACCESS_KEY_ID'] : ENV['AWS_ACCESS_KEY_ID'],
      :aws_secret_access_key    => voteready ? ENV['PDF_AWS_SECRET_ACCESS_KEY'] : ENV['AWS_SECRET_ACCESS_KEY'],
      :region                   => 'us-west-2'
    })
    bucket_name = voteready ? "rtv-to-voteready" : "rtv-reports-from-rocky"
    directory = connection.directories.get(bucket_name)
    file = directory.files.create(
      :key    => "#{Rails.env}/#{file_name}",
      :body   => contents,
      :content_type => "text/csv",
      :encryption => 'AES256', #Make sure its encrypted on their own hard drives
      :public => false
    )
  end
  
end
