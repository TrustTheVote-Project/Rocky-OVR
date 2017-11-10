class StateRegistrants::PARegistrant < ActiveRecord::Base
  UNITS = {APT: "APARTMENT",
    BSM: "BASEMENT",
    BOX: "BOX #",
    BLD: "BUILDING",
    DEP: "DEPARTMENT",
    FL: "FLOOR",
    FRN: "FRONT",
    HNG: "HANGER",
    LBB: "LOBBY",
    LOT: "LOT",
    LOW: "LOWER",
    OFC: "OFFICE",
    PH: "PENTHOUSE",
    PIE: "PIER",
    POL: "POLL",
    REA: "REAR",
    RM: "ROOM",
    SID: "SIDE",
    SLI: "SLIP",
    SPC: "SPACE",
    STO: "STOP",
    STE: "SUITE",
    TRL: "TRAILER",
    UNI: "UNIT",
    UPP: "UPPER",
    CBN: "CABIN",
    HUB: "HUB",
    SMC: "STUDENT MAILING CENTER",
    TH: "TOWNHOUSE"
  }
  
  COUNTIES =%w(ADAMS ALLEGHENY ARMSTRONG BEAVER BEDFORD BERKS BLAIR BRADFORD BUCKS BUTLER CAMBRIA CAMERON CARBON CENTRE CHESTER CLARION CLEARFIELD CLINTON COLUMBIA CRAWFORD CUMBERLAND DAUPHIN DELAWARE ELK ERIE FAYETTE FOREST FRANKLIN FULTON GREENE HUNTINGDON INDIANA JEFFERSON JUNIATA LACKAWANNA LANCASTER LAWRENCE LEBANON LEHIGH LUZERNE LYCOMING MCKEAN MERCER MIFFLIN MONROE MONTGOMERY MONTOUR NORTHAMPTON NORTHUMBERLAND PERRY PHILADELPHIA PIKE POTTER SCHUYLKILL SNYDER SOMERSET SULLIVAN SUSQUEHANNA TIOGA UNION VENANGO WARREN WASHINGTON WAYNE WESTMORELAND WYOMING YORK)
  
  include RegistrantMethods
  
  validates_with PARegistrantValidator
  

  delegate :use_state_flow?, :skip_state_flow?, to: :registrant
  delegate :titles, :suffixes, :races, :state_parties, :partner, :partner_id, :state_registrar_address, :rtv_and_partner_name, :home_state_email_instructions, :email_address_to_send_from,  :finish_iframe_url, to: :registrant
  delegate :is_fake?, :requires_race?, :requires_party?, :require_age_confirmation?, :require_id?, :en_localization, :to => :registrant
    
    
  before_create :set_default_opt_ins
    
  def self.from_registrant(reg)
    sr = self.find_by_registrant_id(reg.uid) || self.new
    sr.registrant_id = reg.uid
    sr.status ||= :step_2
    sr.set_from_original_registrant
    sr
  end
  
  def name_title_key
    key_for_attribute(:name_title, 'titles')
  end
  def english_name_title
    english_attribute_value(name_title_key, 'titles')
  end
  def name_suffix_key
    key_for_attribute(:name_suffix, 'titles')
  end
  def english_name_suffix
    english_attribute_value(name_suffix_key, 'titles')
  end
  
  
  attr_accessor :new_locale
  def check_locale_change
    if !self.new_locale.blank? && self.new_locale != self.locale
      selected_name_title_key = name_title_key
      selected_name_suf_key = name_suffix_key
      selected_race_key = race_key
      party_idx = state_parties.index(self.party)
      self.locale = self.new_locale
      self.registrant.locale = self.locale #So state_parties returns the correct new list
       
      self.name_title=I18n.t("txt.registration.titles.#{selected_name_title_key}", locale: self.locale) if selected_name_title_key
      self.name_suffix=I18n.t("txt.registration.suffixes.#{selected_name_suf_key}", locale: self.locale) if selected_name_suf_key
      self.race = I18n.t("txt.registration.races.#{selected_race_key}", locale: self.locale) if selected_race_key
      self.party = state_parties[party_idx] if !party_idx.nil?
      self.save(validate: false)
      self.update_original_registrant
    end
  end
  
  def registrant
    @registrant ||= Registrant.find_by_uid(self.registrant_id)
  end
  
  def complete?
    status = step_list.last && valid? && confirm_declaration?
  end
  
  def cleanup!
    self.update_attribute(:ssn4, '')
    self.update_attribute(:penndot_number, '')
  end
  
  def uid
    self.registrant_id
  end
  def to_param
    self.registrant_id
  end
  
  def set_default_opt_ins
    self.opt_in_email = true
    self.opt_in_sms = true
  end
  
  def num_steps
    4
  end
  def current_step
    if status =~ /step_(\d)/
      $1
    else
      num_steps
    end
  end
  
  def is_fake
    false
  end
  
  def short_form?
    true
  end
  def use_short_form?
    true
  end
  
  def home_state
    registration_zip_code.blank? ? GeoState['PA'] : GeoState.for_zip_code(registration_zip_code.strip)
  end
  
  def home_state_abbrev
    home_state.abbreviation
    #"PA"
  end
  def home_state_name
    #"Pennsylvania"
    home_state.name
  end
  
  STEPS=%w(step_1 step_2 step_3 step_4 complete)
  def step_list
    STEPS
  end
  
  def advance!
    self.status = next_step
    self.save!
  end
  
  def aasm_current_state
    status
  end
  
  def async_submit_to_online_reg_url
    self.pa_submission_complete = false
    self.save
    self.delay.submit_to_online_reg_url
  end
 
  def bool_to_int(v)
    v ? "1" : "0"
  end
  
  def parse_gender
    male_titles = RockyConf.enabled_locales.collect { |loc|
     I18n.backend.send(:lookup, loc, "txt.registration.titles.#{Registrant::TITLE_KEYS[0]}") 
    }.flatten.uniq
    return 'M' if male_titles.include?(self.name_title)
    return 'F' if !self.name_title.blank?
    return ''
  end
  
  def parse_race
    VRToPA::RACE_RULES[english_race.to_s.downcase.strip] || ""
  end
  

  def parse_party
    @parsed_party ||= begin
      v = VRToPA::PARTIES_NAMES[english_party_name.to_s.downcase.strip]
      v ? {politicalparty: v, otherpoliticalparty: ""} : {politicalparty: "OTH", otherpoliticalparty: other_party}
    end
  end
  
  def is_new_registration
    empty_prev_reg = !change_of_address?
    empty_prev_name = !change_of_name?
    prev_state = previous_state
    prev_state_outside_pa = !empty_prev_reg && prev_state.is_a?(String) && prev_state != "PA"
    return (empty_prev_reg && empty_prev_name) || prev_state_outside_pa
  end
  
  
  def to_pa_data
    result = {}
    result['batch'] = "0"
    result['FirstName'] = self.first_name
    result['MiddleName'] = self.middle_name
    result['LastName'] = self.last_name
    result['TitleSuffix'] = self.name_suffix

    result['united-states-citizen'] = bool_to_int(self.confirm_us_citizen)
    result['eighteen-on-election-day'] = bool_to_int(self.confirm_will_be_18)

    result['isnewregistration'] = bool_to_int(is_new_registration)
    result['name-update'] = bool_to_int(self.change_of_name?)
    result['address-update'] = bool_to_int(self.change_of_address?)
    result['ispartychange'] = bool_to_int(self.change_of_party?)
    result['isfederalvoter'] = ""

    # YYYY-MM-DD is expected
    result['DateOfBirth'] = VRToPA.format_date(self.date_of_birth.to_s)
    result['Gender'] = parse_gender
    result['Ethnicity'] = parse_race
    
    result['Phone'] = ''
    if !self.phone.blank?
      begin
        result['Phone'] = PhoneFormatter.process(value)
      rescue
      end
    end
    result['Email'] = email
    result['streetaddress'] = registration_address_1
    result['streetaddress2'] = registration_address_2
    result['unittype'] = registration_unit_type
    result['unitnumber'] = registration_unit_number

    result['city'] = registration_city

    result['zipcode'] = registration_zip_code
    result['donthavePermtOrResAddress'] = ''
    result['county'] = registration_county

    if has_mailing_address?
      result['mailingaddress'] = mailing_address
      result['mailingcity'] = mailing_city
      result['mailingstate'] = mailing_state
      result['mailingzipcode'] = mailing_zip_code
    else
      result['mailingaddress'] = ''
      result['mailingcity'] = ''
      result['mailingstate'] = ''
      result['mailingzipcode'] = ''
    end

    result['signatureimage'] = ""
    result['continueAppSubmit'] = "1"
    result['donthavebothDLandSSN'] = bool_to_int(confirm_no_dl_or_ssn?)
    result['ssn4'] = ""
    result['drivers-license'] = ""
    unless confirm_no_dl_or_ssn?
      if confirm_no_penndot_number?
        result['ssn4'] = ssn4.to_s.gsub(/[^\d]/,'')
      else
        result['drivers-license'] = penndot_number.to_s.gsub(/[^\d]/,'')
      end
    end
    

    result['politicalparty'] = parse_party[:politicalparty]
    result['otherpoliticalparty'] = parse_party[:otherpoliticalparty]
    result['needhelptovote'] = ""
    result['typeofassistance'] = ""

    result['preferredlanguage'] = self.locale

    result['voterregnumber'] = ""

    if !is_new_registration
      result['previousreglastname'] = previous_last_name
      result['previousregfirstname'] = previous_first_name
      result['previousregmiddlename'] = previous_middle_name
    end
    if !is_new_registration
      result['previousregaddress'] = previous_address
      result['previousregcity'] = previous_city
      result['previousregstate'] = previous_state
      result['previousregzip'] = previous_zip_code
      result['previousregcounty'] = previous_county
    end
    
    
    result['previousregyear'] = ""
    result['declaration1'] = bool_to_int(confirm_declaration)
    
    result['assistedpersonname'] = assistant_name
    result['assistedpersonAddress'] = assistant_address
    result['assistedpersonphone'] = assistant_phone
    result['assistancedeclaration2'] = confirm_assistant_declaration
    result['ispollworker'] = ""
    result['bilingualinterpreter'] = ""
    result['pollworkerspeaklang'] = ""
    result['secondEmail'] = ""

    result
  end
  
  def submit_to_online_reg_url
    begin
      result = PARegistrationRequest.send_request(self.to_pa_data)
      self.pa_submission_complete = true
      self.save
      if result[:error].present?
        self.pa_submission_error = [result[:error].to_s]
        self.registrant.skip_state_flow!
        self.save!
        # No retries for this flow
        Rails.logger.warn("PA Registration Error for StateRegistrants::PARegistrant id: #{self.id} params:\n#{self.to_pa_data}\n\nErrors:\n#{self.pa_submission_error}")
        AdminMailer.pa_registration_error(self, self.pa_submission_error).deliver
      elsif result[:id].blank? || result[:id]==0
          self.pa_submission_error = ["PA returned response with no errors and no transaction ID"]
          #complete it, but go on to PDF generation?
          self.pa_transaction_id = nil
          self.registrant.skip_state_flow!
          self.save!
          Rails.logger.warn("PA Registration Error for StateRegistrants::PARegistrant id: #{self.id} params:\n#{self.to_pa_data}\n\nErrors:\n#{self.pa_submission_error}")
          AdminMailer.pa_registration_error(self, self.pa_submission_error).deliver
      else
        self.pa_transaction_id = result[:id]
        self.save!
        self.update_original_registrant
        self.registrant.complete_registration_with_state!
        deliver_confirmation_email
      end
    rescue
      self.pa_transaction_id = nil
      # TODO - make sure original record knows we're skipping PA OVR
      self.registrant.skip_state_flow!
    end
  ensure
    self.cleanup!
    self.update_attribute(:pa_submission_complete, true)
  end
  
  def submitted?
    pa_submission_complete?
  end
  
  # TODO do we allow no-collect-email for PA?
  def send_emails?
    !self.email.blank?
  end
  
  def deliver_confirmation_email
    if send_emails?
      # TODO, depending on partner customizations, just use main Notifier class - or refactor to StateRegistrantNotifier for all states
      PANotifier.pa_confirmation(self).deliver
    end
  end
  
  
  def mappings
    {
      "email" => "email_address",
      "confirm_us_citizen"  => "us_citizen",
      "confirm_will_be_18"  => "will_be_18_by_election",
      "date_of_birth" => "date_of_birth",
      "name_title"  => "name_title",
      "first_name"  => "first_name",
      "middle_name" => "middle_name",
      "last_name" => "last_name",
      "name_suffix" => "name_suffix",
      "change_of_name"  => "change_of_name",
      "previous_first_name" => "prev_first_name",
      "previous_last_name"  => "prev_last_name",
      "previous_middle_name" => "prev_middle_name",
      "registration_city" => "home_city",
      "registration_zip_code" => "home_zip_code",
      "has_mailing_address" => "has_mailing_address",      
      "mailing_address" => "mailing_address",
      "mailing_city"  => "mailing_city",
      "mailing_zip_code"  => "mailing_zip_code",
      "change_of_address" => "change_of_address",
      "previous_address"  => "prev_address",
      "previous_city" => "prev_city",
      "previous_zip_code" => "prev_zip_code",
      "opt_in_email"  => "opt_in_email",
      "opt_in_sms"  => "opt_in_sms",
      "phone" => "phone",
      "party" => "party",
      "race"  => "race",
      "locale"  => "locale"
    }
  end
  
  def rase=(val)
    raise val.to_s
  end
  
  def set_from_original_registrant
    r = self.registrant
    mappings.each do |k,v|
      val = r.send(v)
      self.send("#{k}=", val)
    end
    address_info = r.home_address.to_s.split(',')
    if address_info.size > 1
      self.registration_address_2 = address_info.pop.strip
    end
    self.registration_address_1 = address_info.join(',')
    
    unit_info =r.home_unit.to_s.split(' ')
    if unit_info.size > 1
      self.registration_unit_type = unit_info.shift
    end
    self.registration_unit_number = unit_info.join(' ')
    self.has_mailing_address = r.has_mailing_address?
    self.save(validate: false)
  end
  
  def attributes=(*args)
    super(*args)
    update_original_registrant
  end
  
  def update_original_registrant
    r = self.registrant
    mappings.each do |k,v|
      val = self.send(k)
      r.send("#{v}=", val)
    end
    r.home_address = [self.registration_address_1.blank? ? nil : self.registration_address_1, self.registration_address_2.blank? ? nil : self.registration_address_2].compact.join(", ")
    r.home_unit = [self.registration_unit_type.blank? ? nil : self.registration_unit_type, self.registration_unit_number.blank? ? nil : self.registration_unit_number].compact.join(" ")
    r.save(validate: false)
  end
end
