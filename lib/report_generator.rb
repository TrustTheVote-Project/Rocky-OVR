class ReportGenerator
  
  #!/usr/bin/env bash
  # r.id, r.status, r.locale, r.partner_id, r.uid, r.reminders_left, r.date_of_birth, r.email_address, r.first_registration, r.home_zip_code, r.us_citizen, r.name_title, r.first_name, r.middle_name, r.last_name, r.name_suffix, r.home_address, r.home_unit, r.home_city, l.abbreviation, r.has_mailing_address, r.mailing_address, r.mailing_unit, r.mailing_city, r.mailing_state_id, r.mailing_zip_code, r.party, r.race, r.state_id_number, r.phone, r.phone_type, r.change_of_name, r.prev_name_title, r.prev_first_name, r.prev_middle_name, r.prev_last_name, r.prev_name_suffix, r.change_of_address, r.prev_address, r.prev_unit, r.prev_city, r.prev_state_id, r.prev_zip_code, r.opt_in_email, r.opt_in_sms, r.survey_answer_1, r.survey_answer_2, r.ineligible_non_participating_state, r.ineligible_age, r.ineligible_non_citizen, r.created_at, r.updated_at, r.abandoned, r.volunteer, r.tracking_source, r.finish_with_state, r.send_confirmation_reminder_emails, r.building_via_api_call 
  # from registrants r join geo_states l on (r.home_state_id = l.id) where date(r.created_at) = date_sub(curdate(), interval 1 day) 
  
  #!/usr/bin/env bash
  # r.id, r.status, r.locale, r.partner_id, r.uid, r.reminders_left, r.date_of_birth, r.email_address, r.first_registration, r.home_zip_code, r.us_citizen, r.name_title, r.first_name, r.middle_name, r.last_name, r.name_suffix, r.home_address, r.home_unit, r.home_city, l.abbreviation, r.has_mailing_address, r.mailing_address, r.mailing_unit, r.mailing_city, r.mailing_state_id, r.mailing_zip_code, r.party, r.race, r.state_id_number, r.phone, r.phone_type, r.change_of_name, r.prev_name_title, r.prev_first_name, r.prev_middle_name, r.prev_last_name, r.prev_name_suffix, r.change_of_address, r.prev_address, r.prev_unit, r.prev_city, r.prev_state_id, r.prev_zip_code, r.opt_in_email, r.opt_in_sms, r.survey_answer_1, r.survey_answer_2, r.ineligible_non_participating_state, r.ineligible_age, r.ineligible_non_citizen, r.created_at, r.updated_at, r.abandoned, r.volunteer, r.tracking_source, r.finish_with_state, r.send_confirmation_reminder_emails, r.building_via_api_call 
  # from registrants r join geo_states l on (r.home_state_id = l.id) where date(r.created_at) >= date_sub(curdate(), interval 6 hour)
  def self.registrant_fields
    %w(id status locale partner_id uid reminders_left date_of_birth email_address first_registration? home_zip_code us_citizen name_title first_name middle_name last_name name_suffix home_address home_unit home_city home_state_abbrev has_mailing_address mailing_address mailing_unit mailing_city mailing_state_id mailing_zip_code party race state_id_number phone phone_type change_of_name prev_name_title prev_first_name prev_middle_name prev_last_name prev_name_suffix change_of_address prev_address prev_unit prev_city prev_state_id prev_zip_code opt_in_email opt_in_sms survey_answer_1 survey_answer_2 ineligible_non_participating_state ineligible_age ineligible_non_citizen created_at updated_at abandoned volunteer tracking_source finish_with_state send_confirmation_reminder_emails building_via_api_call)
  end
  # p.id, p.username, p.email, p.name, p.organization, p.url, p.address, p.city, l.abbreviation, p.zip_code, p.phone, p.survey_question_1_en, p.survey_question_1_es, p.survey_question_2_en, p.survey_question_2_es, p.created_at, p.updated_at from partners p join geo_states l on (p.state_id = l.id)

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
    %w(id username email name organization url address city state_abbrev zip_code phone survey_question_1_en survey_question_1_es survey_question_2_en survey_question_2_es created_at updated_at)
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

  def self.generate_registrants(t, time_span)
    distribute_reads(failover: false) do
      registrants = Registrant.where("created_at > ?", t-time_span.hours).includes(:home_state)
      # Also preload all PA and VA state registrants?
      pa_registrants = {}
      va_registrants = {}
      mi_registrants = {}
      StateRegistrants::PARegistrant.where("created_at > ?", t-time_span.hours).find_each {|sr| pa_registrants[sr.registrant_id] = sr}
      StateRegistrants::VARegistrant.where("created_at > ?", t-time_span.hours).find_each {|sr| va_registrants[sr.registrant_id] = sr}
      StateRegistrants::MIRegistrant.where("created_at > ?", t-time_span.hours).find_each {|sr| mi_registrants[sr.registrant_id] = sr}
      csv_str = CsvFormatter.wrap do |csv|
        csv << headers = self.registrant_fields.dup
        CsvFormatter.rename_array_item(headers, 'home_state_abbrev', 'abbreviation')
        CsvFormatter.rename_array_item(headers, 'first_registration?', 'first_registration')

        registrants.find_each do |r|
          # Set the @existing_state_registrant value
          if r.use_state_flow?
            sr  = nil
            case r.home_state_abbrev
            when "PA"
              sr = pa_registrants[r.uid] || StateRegistrants::PARegistrant.new
            when "VA"
              sr = va_registrants[r.uid] || StateRegistrants::VARegistrant.new
            when "MI"
              sr = mi_registrants[r.uid] || StateRegistrants::MIRegistrant.new
            end
            r.instance_variable_set(:@existing_state_registrant, sr)
          end
          reg_attributes = self.registrant_fields.collect {|fname| r.send(fname) }
          csv << reg_attributes
        end
      end
      file_name = self.file_name("registrants", t, time_span)
      self.save_csv_to_s3(csv_str, file_name)
    end
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
      :aws_access_key_id        => ENV['PDF_AWS_ACCESS_KEY_ID'],
      :aws_secret_access_key    => ENV['PDF_AWS_SECRET_ACCESS_KEY'],
      :region                   => 'us-west-2'
    })
    bucket_name = voteready ? "rtv-to-voteready" : "rtv-reports"
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