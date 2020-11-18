class StateRegistrants::PARegistrant < StateRegistrants::Base
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
    TRLR: "TRAILER",
    UNI: "UNIT",
    UPP: "UPPER",
    CBN: "CABIN",
    HUB: "HUB",
    SMC: "STUDENT MAILING CENTER",
    TH: "TOWNHOUSE"
  }

  delegate :full_name, to: :registrant
  
  COUNTIES =%w(ADAMS ALLEGHENY ARMSTRONG BEAVER BEDFORD BERKS BLAIR BRADFORD BUCKS BUTLER CAMBRIA CAMERON CARBON CENTRE CHESTER CLARION CLEARFIELD CLINTON COLUMBIA CRAWFORD CUMBERLAND DAUPHIN DELAWARE ELK ERIE FAYETTE FOREST FRANKLIN FULTON GREENE HUNTINGDON INDIANA JEFFERSON JUNIATA LACKAWANNA LANCASTER LAWRENCE LEBANON LEHIGH LUZERNE LYCOMING MCKEAN MERCER MIFFLIN MONROE MONTGOMERY MONTOUR NORTHAMPTON NORTHUMBERLAND PERRY PHILADELPHIA PIKE POTTER SCHUYLKILL SNYDER SOMERSET SULLIVAN SUSQUEHANNA TIOGA UNION VENANGO WARREN WASHINGTON WAYNE WESTMORELAND WYOMING YORK)
  
  
  INVALID_PENNDOT= "VR_WAPI_InvalidOVRDL".freeze
  
  include RegistrantMethods
  include TwilioHelper
  
  validates_with PARegistrantValidator
  
  serialize :pa_submission_error, Array
  
  def check_valid_for_state_flow!
    if self.signature_method == VoterSignature::PRINT_METHOD
      self.skip_state_flow!
      self.registrant.state_id_number = self.ssn4
      if self.registrant.state_id_number.blank?
        self.registrant.state_id_number = "NONE"
      end
      self.registrant.save(validate: false)
    end
  end

  
  def complete?
    status == step_list.last && (valid? || submitted?) && confirm_declaration?
  end
  
  def cleanup!
    self.update_attribute(:ssn4, '')
    self.update_attribute(:penndot_number, '')
  end
  
  def num_steps
    4
  end

  def default_state_abbrev
    'PA'
  end
  
  def signature_step
    "step_3"
  end
  
  def steps
    %w(step_1 step_2 step_3 step_4 complete)
  end
  
  def email_address_for_continue_on_device
    self.read_attribute(:email_address_for_continue_on_device) || self.email
  end

  def sms_number_for_continue_on_device
    self.read_attribute(:sms_number_for_continue_on_device) || self.phone
  end
  
  def should_advance(params)
    if params.has_key?(:email_continue_on_device) || params.has_key?(:sms_continue_on_device)
      return false
    end
    return params[:skip_advance] != "true"    
  end
  
  include Rails.application.routes.url_helpers
  def default_url_options
    ActionMailer::Base.default_url_options
  end
  
  def signature_capture_url
    update_state_registrant_url(self.to_param, self.signature_step)
  end
  
  def custom_advance(controller, params)
    # Set flash message?
    # Actually send the message
    if params.has_key?(:email_continue_on_device)
      PANotifier.continue_on_device(self, signature_capture_url).deliver_now
      controller.flash[:success] = I18n.t('states.custom.pa.signature_capture.email_sent', email: self.email_address_for_continue_on_device)
    elsif params.has_key?(:sms_continue_on_device)
      if sms_number =~ /[ [:punct:]]*\d{3}[ [:punct:]]*\d{3}[ [:punct:]]*\d{4}\D*/
        begin
          twilio_client.messages.create(
            :from => "+1#{twilio_phone_number}",
            :to => sms_number,
            :body => I18n.t('states.custom.pa.signature_capture.sms_body', signature_capture_url: signature_capture_url)
          )
          controller.flash[:success] = I18n.t('states.custom.pa.signature_capture.sms_sent', phone: self.sms_number)
        rescue Twilio::REST::RequestError
          self.errors.add(:sms_number_for_continue_on_device, :format)
        end
      else
        #controller.flash[:warning] = I18n.t('states.custom.pa.signature_capture.sms_sent', phone: self.sms_number)
        self.errors.add(:sms_number_for_continue_on_device, :format)
      end
    end    
  end
  
  def sms_number
    self.sms_number_for_continue_on_device.to_s.gsub(/[^\d]/, '')
  end
  
  def async_submit_to_online_reg_url
    self.pa_submission_complete = false
    self.save
    self.delay.submit_to_online_reg_url
  end
 
  def bool_to_int(v)
    v ? "1" : "0"
  end
 
  def parse_suffix(suffix)
    suffix.to_s.gsub('.','')
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
  
  def state_parties
    sp = self.registrant.state_parties
    # no_party should be 2nd to last instead of last
    if sp.length > 1
      sp[-1], sp[-2] = sp[-2], sp[-1]
    end
    sp
  end
  
  def english_state_parties
    sp = self.registrant.english_state_parties
    # no_party should be 2nd to last instead of last
    if sp.length > 1
      sp[-1], sp[-2] = sp[-2], sp[-1]
    end
    sp
  end

  def has_other_party?
    return parse_party[:politicalparty] == "OTH" && !self.other_party.blank?
  end

  def parse_party
    parsed_party ||= begin
      v = VRToPA::PARTIES_NAMES[english_party_name.to_s.downcase.strip]
      v ? {politicalparty: v, otherpoliticalparty: ""} : {politicalparty: "OTH", otherpoliticalparty: other_party}
    end
  end
  
  # Override the actual data column here
  def first_registration?
    is_new_registration
  end
  
  def is_new_registration
    empty_prev_reg = !change_of_address?
    empty_prev_name = !change_of_name?
    no_party_change = !change_of_party?
    return (empty_prev_reg && empty_prev_name && no_party_change) || prev_state_outside_pa
  end
  
  def is_change_of_party
    return change_of_party? && !prev_state_outside_pa
  end
  
  def prev_state_outside_pa
    empty_prev_reg = !change_of_address?
    prev_state = previous_state
    return !empty_prev_reg && prev_state.is_a?(String) && prev_state != "PA"    
  end
  
  
  
  def to_pa_data
    result = {}
    result['batch'] = "0"
    result['FirstName'] = self.first_name
    result['MiddleName'] = self.middle_name
    result['LastName'] = self.last_name
    result['TitleSuffix'] = parse_suffix(self.name_suffix)

    result['united-states-citizen'] = bool_to_int(self.confirm_us_citizen)
    result['eighteen-on-election-day'] = bool_to_int(self.confirm_will_be_18)

    result['isnewregistration'] = bool_to_int(is_new_registration)
    result['isfederalvoter'] = ""

    # YYYY-MM-DD is expected
    result['DateOfBirth'] = VRToPA.format_date(self.date_of_birth.to_s)
    result['Gender'] = parse_gender
    result['Ethnicity'] = parse_race
    
    result['Phone'] = ''
    if !self.phone.blank?
      begin
        result['Phone'] = PhoneFormatter.process(self.phone)
      rescue
      end
    end
    result['Email'] = email
    result['streetaddress'] = registration_address_1
    result['streetaddress2'] = registration_address_2
    result['unittype'] = registration_unit_type
    result['unitnumber'] = registration_unit_number

    result['city'] = registration_city
    result['municipality'] = result['city']

    result['zipcode'] = registration_zip_code.to_s.gsub(/[^\d]/,'')[0...5]
    result['donthavePermtOrResAddress'] = ''
    result['county'] = registration_county

    if has_mailing_address?
      result['mailingaddress'] = mailing_address
      result['mailingcity'] = mailing_city
      result['mailingstate'] = mailing_state
      result['mailingzipcode'] = mailing_zip_code.to_s.gsub(/[^\d]/,'')[0...5]
    else
      result['mailingaddress'] = ''
      result['mailingcity'] = ''
      result['mailingstate'] = ''
      result['mailingzipcode'] = ''
    end

    result['signatureimage'] = self.class.resize_signature_url(voter_signature_image)
    
    result['continueAppSubmit'] = (confirm_no_penndot_number? || penndot_retries >= 2) ? "1" : "0"
    result['donthavebothDLandSSN'] = bool_to_int(confirm_no_dl_or_ssn? && confirm_no_penndot_number?)
    result['ssn4'] = confirm_no_dl_or_ssn? ? '' : ssn4.to_s.gsub(/[^\d]/,'')
    result['drivers-license'] = confirm_no_penndot_number? ? '' : penndot_number.to_s.gsub(/[^\d]/,'')
    

    result['politicalparty'] = parse_party[:politicalparty]
    result['otherpoliticalparty'] = parse_party[:otherpoliticalparty]
    result['needhelptovote'] = ""
    result['typeofassistance'] = ""

    result['preferredlanguage'] = self.locale

    result['voterregnumber'] = ""
    
    if !is_new_registration
      result['name-update'] = bool_to_int(self.change_of_name?)
      result['address-update'] = bool_to_int(self.change_of_address?)
      result['ispartychange'] = bool_to_int(is_change_of_party)
    else
      result['name-update'] = "0"
      result['address-update'] = "0"
      result['ispartychange'] = "0"
    end
    

    if !is_new_registration
      result['previousreglastname'] = previous_last_name
      result['previousregfirstname'] = previous_first_name
      result['previousregmiddlename'] = previous_middle_name
    else
      result['previousreglastname'] = nil
      result['previousregfirstname'] = nil
      result['previousregmiddlename'] = nil
    end
    if !is_new_registration
      result['previousregaddress'] = previous_address
      result['previousregcity'] = previous_city
      result['previousregstate'] = previous_state
      result['previousregzip'] = previous_zip_code.to_s.gsub(/[^\d]/,'')[0...5]
      result['previousregcounty'] = previous_county
    else
      result['previousregaddress'] = nil
      result['previousregcity'] = nil
      result['previousregstate'] = nil
      result['previousregzip'] = nil
      result['previousregcounty'] = nil
    end
    
    
    result['previousregyear'] = ""
    result['declaration1'] = bool_to_int(confirm_declaration)
    
    result['assistedpersonname'] = assistant_name
    result['assistedpersonAddress'] = assistant_address
    result['assistedpersonphone'] = ""
    if !self.assistant_phone.blank?
      begin
        result['assistedpersonphone'] = PhoneFormatter.process(self.assistant_phone)
      rescue
      end
    end
    
    
    result['assistancedeclaration2'] = confirm_assistant_declaration
    result['ispollworker'] = ""
    result['bilingualinterpreter'] = ""
    result['pollworkerspeaklang'] = ""
    result['secondEmail'] = ""

    result
  end
  
  def pdf_assistant_info
    [assistant_name, assistant_address, assistant_phone].collect do |ai|
      ai.blank? ? nil : ai
    end.compact.join(", ")
  end
  
  
  def pa_api_key
    self.partner ? self.partner.pa_api_key : nil
  end
  
  def state_api_error   
    pa_submission_error
  end
  
  def submit_to_online_reg_url
    RequestLogSession.make_call_with_logging(registrant: self, client_id: 'PARegistrationRequest::Rocky', censor: PACensor) do
      begin
        result = PARegistrationRequest.send_request(self.to_pa_data, self.pa_api_key, self.locale)
        self.pa_submission_complete = true
        self.pa_submission_error ||= []
        if result[:error].present?
          self.pa_submission_error.push("#{DateTime.now}: #{result[:error]}")
          RequestLogSession.request_log_instance.log_error(result[:error].to_s)
          if result[:error] == INVALID_PENNDOT && self.penndot_retries < 2
            self.retry_drivers_license
            RequestLogSession.request_log_instance.log_error(INVALID_PENNDOT)
            RequestLogSession.request_log_instance.log_error("Allowing user to retry.")
          else
            RequestLogSession.request_log_instance.log_error("Registrant switched to paper.")            
            self.registrant.skip_state_flow!
            self.save!
            # No retries for this flow
            Rails.logger.warn("PA Registration Error for StateRegistrants::PARegistrant id: #{self.id} params:\n#{self.to_pa_data}\n\nErrors:\n#{self.pa_submission_error}")
            AdminMailer.pa_registration_error(self, self.pa_submission_error, "Registrant Switched to paper").deliver_now
          end
        elsif result[:id].blank? || result[:id]==0
            self.pa_submission_error.push("#{DateTime.now}: PA returned response with no errors and no transaction ID")
            RequestLogSession.request_log_instance.log_error("PA returned response with no errors and no transaction ID. Registrant Switched to paper.")
            
            #complete it, but go on to PDF generation?
            self.pa_transaction_id = nil
            self.registrant.skip_state_flow!
            self.save(validate: false)
            Rails.logger.warn("PA Registration Error for StateRegistrants::PARegistrant id: #{self.id} params:\n#{self.to_pa_data}\n\nErrors:\n#{self.pa_submission_error}")
            AdminMailer.pa_registration_error(self, self.pa_submission_error).deliver_now
        else
          self.pa_transaction_id = result[:id]
          self.save!
          self.update_original_registrant
          self.registrant.complete_registration_with_state!
          deliver_confirmation_email
        end
      rescue Exception => e
        # Send notification
        RequestLogSession.request_log_instance.log_error(e)
        RequestLogSession.request_log_instance.log_error("Registrant Switched to paper.")
        self.pa_transaction_id = nil
        self.pa_submission_complete = true #need to mark as submitted in case we didn't get to that step before raising error
        self.registrant.skip_state_flow!
        begin
          AdminMailer.pa_registration_error(self, self.pa_submission_error, "Unhandled exception #{e.messsage}\n#{e.backtrace} - Registrant switched to paper").deliver_now
        rescue
        end
      end
    end
  ensure
    if self.pa_submission_complete
      self.cleanup!
      self.update_attribute(:pa_submission_complete, true)
    end
  end
  
  # NOTE: This "submitted?", "api_submission_error" and "state_transaction_id" methods must be implemented by all state registrants
  def submitted?
    pa_submission_complete?
  end
  
  def api_submission_error
    self.pa_submission_error.to_s
  end
  
  def state_transaction_id
    self.pa_transaction_id
  end

  # TODO do we allow no-collect-email for PA?
  def send_emails?
    !self.email.blank?
  end
  
  def deliver_confirmation_email
    if send_emails?
      # TODO, depending on partner customizations, just use main Notifier class - or refactor to StateRegistrantNotifier for all states
      PANotifier.pa_confirmation(self).deliver_now
    end
  end
  
  def retry_drivers_license
    self.pa_submission_complete = false
    self.penndot_retries += 1
    self.status = signature_step
    self.save(validate: false)
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
      "partner_opt_in_email"=>"partner_opt_in_email",
      "partner_opt_in_sms"=>"partner_opt_in_sms",
      "partner_volunteer"=>"partner_volunteer",
      "phone" => "phone",
      "party" => "party",
      "race"  => "race",
      "locale"  => "locale"
    }
  end
  
  
  def self.from_registrant(reg)
    # Swap out partner if no API-key is present
    original_partner_id = nil
    if !reg.partner.primary? && reg.partner.pa_api_key.blank?
      # Make it an RTV partner
      original_partner_id = reg.partner_id
      reg.partner = Partner.primary_partner
      reg.save(validate: false)
    end
    sr = super(reg)
    if original_partner_id
      sr.original_partner_id = original_partner_id
      sr.save(validate: false)
    end
    return sr
  end
  
  
  def set_from_original_registrant
    r = self.registrant
    mappings.each do |k,v|
      val = r.send(v)
      self.send("#{k}=", val)
    end
    self.confirm_no_penndot_number = r.has_state_license == false
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
    self.has_mailing_address = r.has_mailing_address? unless r.has_mailing_address.nil? 
    begin
      self.mailing_state = r.mailing_state.abbreviation
    rescue
    end
    self.save(validate: false)
  end
  
  def update_original_registrant
    r = self.registrant
    mappings.each do |k,v|
      val = self.send(k)
      r.send("#{v}=", val)
    end
    r.home_address = [self.registration_address_1.blank? ? nil : self.registration_address_1, self.registration_address_2.blank? ? nil : self.registration_address_2].compact.join(", ")
    r.home_unit = [self.registration_unit_type.blank? ? nil : self.registration_unit_type, self.registration_unit_number.blank? ? nil : self.registration_unit_number].compact.join(" ")
    r.has_ssn = !self.confirm_no_dl_or_ssn?
    r.has_state_license = !self.confirm_no_penndot_number?
    begin 
      r.mailing_state = GeoState[self.mailing_state]
    end
    r.save(validate: false)
  end
  
  def has_state_license?
    !self.confirm_no_penndot_number?
  end
  
  def has_ssn?
    !self.confirm_no_dl_or_ssn?
  end
  

  def self.resize_signature_url(sig_url)
    regexp = /\Adata:(.+);base64,(.+)\z/
    if sig_url =~ regexp
      type = $1
      data = $2
      return "data:#{type};base64,#{process_signature(data)[0]}"
    else
      return sig_url
    end
  # rescue
  #   return sig_url
  end
  
  SIG_WIDTH = 180
  SIG_HEIGHT = 60
  RESOLUTION =  100
  def self.process_signature(base64data, mods=[])
    image_blob = Base64.decode64(base64data)
    src = Tempfile.new('src')
    dst = Tempfile.new('dst')
    begin
      src.binmode
      src.write(image_blob)
      src.close
      wh = `identify -format "%wx%h" #{src.path}`
      if wh.to_s.strip !="#{SIG_WIDTH}x#{SIG_HEIGHT}"
        dst.close
        #  -background skyblue -extent 100x60
        cmd = "convert #{src.path} -background white -extent #{SIG_WIDTH}x#{SIG_HEIGHT} -density #{RESOLUTION} #{dst.path}"
        `#{cmd}`
        dst.open
        dst.binmode
        converted = dst.read
        converted64 = Base64.encode64(converted)
        mods << "Converted #{wh} image to #{SIG_WIDTH}x#{SIG_HEIGHT}"
        return converted64.gsub("\n",''), mods
      else
        return base64data, mods
      end
    ensure
       src.close
       src.unlink   # deletes the temp file
       dst.close
       dst.unlink   # deletes the temp file
    end
  end
  
  def has_penndot
    case self.confirm_no_penndot_number
      when true
        return false
      when false
       return true
      when nil
        return nil
    end
  end

  def has_penndot= (val)
    case val
      when true,1,"1"
        self.confirm_no_penndot_number=false
      when false,0,"0"
        self.confirm_no_penndot_number=true
      when nil
        self.confirm_no_penndot_number = nil
    end
  end
  
end
