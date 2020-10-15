class StateRegistrants::VARegistrant < StateRegistrants::Base
  
  validates_with VARegistrantValidator
  
  # mailing address if military (or spouse/dependent), if overseas, if not serviced by USPS or homeless, if providing PO box for privacy
  # Locality Codes
  # https://publicapi.elections.virginia.gov/V1/Locality/All 
  def self.localities
    [{"Code" => "001", "Name" => "ACCOMACK COUNTY"},
     {"Code" => "003", "Name" => "ALBEMARLE COUNTY"},
     {"Code" => "510", "Name" => "ALEXANDRIA CITY"},
     {"Code" => "005", "Name" => "ALLEGHANY COUNTY"},
     {"Code" => "007", "Name" => "AMELIA COUNTY"},
     {"Code" => "009", "Name" => "AMHERST COUNTY"},
     {"Code" => "011", "Name" => "APPOMATTOX COUNTY"},
     {"Code" => "013", "Name" => "ARLINGTON COUNTY"},
     {"Code" => "015", "Name" => "AUGUSTA COUNTY"},
     {"Code" => "017", "Name" => "BATH COUNTY"},
     {"Code" => "019", "Name" => "BEDFORD COUNTY"},
     {"Code" => "021", "Name" => "BLAND COUNTY"},
     {"Code" => "023", "Name" => "BOTETOURT COUNTY"},
     {"Code" => "520", "Name" => "BRISTOL CITY"},
     {"Code" => "025", "Name" => "BRUNSWICK COUNTY"},
     {"Code" => "027", "Name" => "BUCHANAN COUNTY"},
     {"Code" => "029", "Name" => "BUCKINGHAM COUNTY"},
     {"Code" => "530", "Name" => "BUENA VISTA CITY"},
     {"Code" => "031", "Name" => "CAMPBELL COUNTY"},
     {"Code" => "033", "Name" => "CAROLINE COUNTY"},
     {"Code" => "035", "Name" => "CARROLL COUNTY"},
     {"Code" => "036", "Name" => "CHARLES CITY COUNTY"},
     {"Code" => "037", "Name" => "CHARLOTTE COUNTY"},
     {"Code" => "540", "Name" => "CHARLOTTESVILLE CITY"},
     {"Code" => "550", "Name" => "CHESAPEAKE CITY"},
     {"Code" => "041", "Name" => "CHESTERFIELD COUNTY"},
     {"Code" => "043", "Name" => "CLARKE COUNTY"},
     {"Code" => "570", "Name" => "COLONIAL HEIGHTS CITY"},
     {"Code" => "580", "Name" => "COVINGTON CITY"},
     {"Code" => "045", "Name" => "CRAIG COUNTY"},
     {"Code" => "047", "Name" => "CULPEPER COUNTY"},
     {"Code" => "049", "Name" => "CUMBERLAND COUNTY"},
     {"Code" => "590", "Name" => "DANVILLE CITY"},
     {"Code" => "051", "Name" => "DICKENSON COUNTY"},
     {"Code" => "053", "Name" => "DINWIDDIE COUNTY"},
     {"Code" => "595", "Name" => "EMPORIA CITY"},
     {"Code" => "057", "Name" => "ESSEX COUNTY"},
     {"Code" => "600", "Name" => "FAIRFAX CITY"},
     {"Code" => "059", "Name" => "FAIRFAX COUNTY"},
     {"Code" => "610", "Name" => "FALLS CHURCH CITY"},
     {"Code" => "061", "Name" => "FAUQUIER COUNTY"},
     {"Code" => "063", "Name" => "FLOYD COUNTY"},
     {"Code" => "065", "Name" => "FLUVANNA COUNTY"},
     {"Code" => "620", "Name" => "FRANKLIN CITY"},
     {"Code" => "067", "Name" => "FRANKLIN COUNTY"},
     {"Code" => "069", "Name" => "FREDERICK COUNTY"},
     {"Code" => "630", "Name" => "FREDERICKSBURG CITY"},
     {"Code" => "640", "Name" => "GALAX CITY"},
     {"Code" => "071", "Name" => "GILES COUNTY"},
     {"Code" => "073", "Name" => "GLOUCESTER COUNTY"},
     {"Code" => "075", "Name" => "GOOCHLAND COUNTY"},
     {"Code" => "077", "Name" => "GRAYSON COUNTY"},
     {"Code" => "079", "Name" => "GREENE COUNTY"},
     {"Code" => "081", "Name" => "GREENSVILLE COUNTY"},
     {"Code" => "083", "Name" => "HALIFAX COUNTY"},
     {"Code" => "650", "Name" => "HAMPTON CITY"},
     {"Code" => "085", "Name" => "HANOVER COUNTY"},
     {"Code" => "660", "Name" => "HARRISONBURG CITY"},
     {"Code" => "087", "Name" => "HENRICO COUNTY"},
     {"Code" => "089", "Name" => "HENRY COUNTY"},
     {"Code" => "091", "Name" => "HIGHLAND COUNTY"},
     {"Code" => "670", "Name" => "HOPEWELL CITY"},
     {"Code" => "093", "Name" => "ISLE OF WIGHT COUNTY"},
     {"Code" => "095", "Name" => "JAMES CITY COUNTY"},
     {"Code" => "097", "Name" => "KING & QUEEN COUNTY"},
     {"Code" => "099", "Name" => "KING GEORGE COUNTY"},
     {"Code" => "101", "Name" => "KING WILLIAM COUNTY"},
     {"Code" => "103", "Name" => "LANCASTER COUNTY"},
     {"Code" => "105", "Name" => "LEE COUNTY"},
     {"Code" => "678", "Name" => "LEXINGTON CITY"},
     {"Code" => "107", "Name" => "LOUDOUN COUNTY"},
     {"Code" => "109", "Name" => "LOUISA COUNTY"},
     {"Code" => "111", "Name" => "LUNENBURG COUNTY"},
     {"Code" => "680", "Name" => "LYNCHBURG CITY"},
     {"Code" => "113", "Name" => "MADISON COUNTY"},
     {"Code" => "683", "Name" => "MANASSAS CITY"},
     {"Code" => "685", "Name" => "MANASSAS PARK CITY"},
     {"Code" => "690", "Name" => "MARTINSVILLE CITY"},
     {"Code" => "115", "Name" => "MATHEWS COUNTY"},
     {"Code" => "117", "Name" => "MECKLENBURG COUNTY"},
     {"Code" => "119", "Name" => "MIDDLESEX COUNTY"},
     {"Code" => "121", "Name" => "MONTGOMERY COUNTY"},
     {"Code" => "125", "Name" => "NELSON COUNTY"},
     {"Code" => "127", "Name" => "NEW KENT COUNTY"},
     {"Code" => "700", "Name" => "NEWPORT NEWS CITY"},
     {"Code" => "710", "Name" => "NORFOLK CITY"},
     {"Code" => "131", "Name" => "NORTHAMPTON COUNTY"},
     {"Code" => "133", "Name" => "NORTHUMBERLAND COUNTY"},
     {"Code" => "720", "Name" => "NORTON CITY"},
     {"Code" => "135", "Name" => "NOTTOWAY COUNTY"},
     {"Code" => "137", "Name" => "ORANGE COUNTY"},
     {"Code" => "139", "Name" => "PAGE COUNTY"},
     {"Code" => "141", "Name" => "PATRICK COUNTY"},
     {"Code" => "730", "Name" => "PETERSBURG CITY"},
     {"Code" => "143", "Name" => "PITTSYLVANIA COUNTY"},
     {"Code" => "735", "Name" => "POQUOSON CITY"},
     {"Code" => "740", "Name" => "PORTSMOUTH CITY"},
     {"Code" => "145", "Name" => "POWHATAN COUNTY"},
     {"Code" => "147", "Name" => "PRINCE EDWARD COUNTY"},
     {"Code" => "149", "Name" => "PRINCE GEORGE COUNTY"},
     {"Code" => "153", "Name" => "PRINCE WILLIAM COUNTY"},
     {"Code" => "155", "Name" => "PULASKI COUNTY"},
     {"Code" => "750", "Name" => "RADFORD CITY"},
     {"Code" => "157", "Name" => "RAPPAHANNOCK COUNTY"},
     {"Code" => "760", "Name" => "RICHMOND CITY"},
     {"Code" => "159", "Name" => "RICHMOND COUNTY"},
     {"Code" => "770", "Name" => "ROANOKE CITY"},
     {"Code" => "161", "Name" => "ROANOKE COUNTY"},
     {"Code" => "163", "Name" => "ROCKBRIDGE COUNTY"},
     {"Code" => "165", "Name" => "ROCKINGHAM COUNTY"},
     {"Code" => "167", "Name" => "RUSSELL COUNTY"},
     {"Code" => "775", "Name" => "SALEM CITY"},
     {"Code" => "169", "Name" => "SCOTT COUNTY"},
     {"Code" => "171", "Name" => "SHENANDOAH COUNTY"},
     {"Code" => "173", "Name" => "SMYTH COUNTY"},
     {"Code" => "175", "Name" => "SOUTHAMPTON COUNTY"},
     {"Code" => "177", "Name" => "SPOTSYLVANIA COUNTY"},
     {"Code" => "179", "Name" => "STAFFORD COUNTY"},
     {"Code" => "790", "Name" => "STAUNTON CITY"},
     {"Code" => "800", "Name" => "SUFFOLK CITY"},
     {"Code" => "181", "Name" => "SURRY COUNTY"},
     {"Code" => "183", "Name" => "SUSSEX COUNTY"},
     {"Code" => "185", "Name" => "TAZEWELL COUNTY"},
     {"Code" => "810", "Name" => "VIRGINIA BEACH CITY"},
     {"Code" => "187", "Name" => "WARREN COUNTY"},
     {"Code" => "191", "Name" => "WASHINGTON COUNTY"},
     {"Code" => "820", "Name" => "WAYNESBORO CITY"},
     {"Code" => "193", "Name" => "WESTMORELAND COUNTY"},
     {"Code" => "830", "Name" => "WILLIAMSBURG CITY"},
     {"Code" => "840", "Name" => "WINCHESTER CITY"},
     {"Code" => "195", "Name" => "WISE COUNTY"},
     {"Code" => "197", "Name" => "WYTHE COUNTY"},
     {"Code" => "199", "Name" => "YORK COUNTY"}]
  end
  
  serialize :va_submission_error, Array
  
  def requires_mailing_address?
    is_protected? || is_military? || no_usps_address?
  end
  
  def is_protected?
    is_court_protected? || is_law_enforcement? || is_confidentiality_program? || is_being_stalked?
  end
  
  def ssn_digits
    self.ssn.to_s.gsub(/[^\d]/, '')
  end
  
  def private_ssn
    "* * *  -  * *  -  #{self.ssn_digits.last(4)}"
  end
  
  def dln_digits
    self.dln.to_s.gsub(/[^\da-zA-Z]/, '')
  end
  
  def gender
    male_titles = RockyConf.enabled_locales.collect { |loc|
     I18n.backend.send(:lookup, loc, "txt.registration.titles.#{Registrant::TITLE_KEYS[0]}") 
    }.flatten.uniq
    return 'M' if male_titles.include?(self.name_title)
    return 'F' if !self.name_title.blank?
    return ''   
  end
  
  def complete?
    status == step_list.last && valid? && confirm_affirm_privacy_notice? && confirm_voter_fraud_warning?
  end
  
  def submitted?
    va_submission_complete? || (va_check_complete? && va_check_error?)
  end
  
  def state_transaction_id
    va_transaction_id
  end
  
  def cleanup!
    # TODO make sure we don't keep SSN
    self.ssn = nil
    self.dln = nil
    self.save(validate: false)
  end
  
  def default_state_abbrev
    'VA'
  end
  
  def registration_county
    registration_locality_name
  end
  
  def steps
    %w(step_1 step_2 step_3 step_4 complete)
  end
  
  def num_steps
    4
  end
  
  def first_registration?
    # If the check response has 
    return !JSON.parse(va_check_response)["IsRegisteredVoter"]
  rescue
    nil
  end
  
  
  
  def async_submit_to_online_reg_url
    self.va_submission_complete = false
    self.va_check_complete = false
    self.save
    self.delay.do_complete_voter_submission    
  end
  
  def do_complete_voter_submission
    if self.check_voter_confirmation
      self.submit_to_online_reg_url
    end
  end
  
  def va_api_headers(method)
    t = Time.now
    key = OpenSSL::PKey::RSA.new(ENV['VA_API_PRIVATE_KEY'])
    api_key = RockyConf.ovr_states.VA.api_settings.api_key
    cert = ENV['VA_API_CERT']
    payload = {
      "iss" => RockyConf.ovr_states.VA.api_settings.api_username,
      "name" =>RockyConf.ovr_states.VA.api_settings.api_username,
      "jti" => "{method}-#{self.id}-#{t.to_i}",
      "iat" =>  t.to_i,
      "exp" =>  (t+ 600).to_i,
      "key" => api_key
    }
    token = JWT.encode payload, key, 'RS256'
    return {
      content_type: :json,
      accept: :json,
      "Timestamp" => t.iso8601,
      "BinarySecurityToken" => Base64.encode64(cert.to_s).gsub("\n",''),
      "Authorization" => "Bearer #{token}"
    }
  end
  
  def check_voter_confirmation_url
    server = RockyConf.ovr_states.VA.api_settings.api_url
    File.join(server, "Voter/Confirmation" +"?"+ RestClient::Payload::UrlEncoded.new({
      "lastName" => self.last_name,
      "firstName" => self.first_name,
      "Ssn9" => self.ssn.to_s.gsub(/[^\d]/,''),
      "driversLicenseNumber" => self.dln.to_s.gsub(/\s-/, ''),
      "dobYear" => self.date_of_birth.year,
      "dobDay" => self.date_of_birth.day,
      "dobMonth" => self.date_of_birth.month, 
      "localityName" => self.registration_locality_name,
      "format" => "json"
    }).to_s)
  end
  
  def check_voter_confirmation
    # Submit to voter confirmation request for eligibility
    url = check_voter_confirmation_url
    result = nil
    begin
      response = RestClient::Request.execute(method: :get, url: url, headers: va_api_headers("check"))
    rescue Exception => error
      if error.respond_to?(:response)
        response = error.response
      else
        response = error.message
      end
    end
    self.va_check_response = response.to_s
    self.save(validate: false)
    result = JSON.parse(response.to_s)
    if result["IsProtected"]
      set_protected_voter!
      return false
    end
    self.va_check_is_registered_voter = result["IsRegisteredVoter"]
    self.va_check_has_dmv_signature = result["HasDmvSignature"]
    self.va_check_voter_id = result["VoterId"]
    self.save(validate: false)

    if !self.va_check_has_dmv_signature #Can't submit w/out DMV signature
      self.va_check_error = true
      self.registrant.skip_state_flow!
      return false
    end
    return true
  rescue Exception=>e
    self.va_check_error = true
    self.registrant.skip_state_flow!
    
    AdminMailer.va_registration_error(self, [e.message, e.backtrace], "Unhandled error during voter check. Registrant Switched to paper").deliver_now    
    
    return false
  ensure
    self.va_check_complete = true
    self.save(validate: false)    
  end
  
  def set_protected_voter!
    self.registrant.delete
    self.delete
  end
  
  # {
#     "SendingAgency":"String",
#     "Location":"String",
#     "SendingAgencyTimestamp":"0001-01-01T00:00:00.0000000",
#     "IsTestRecord":false,
#     "VoterRegistrations": [
#       {
#         "VoterId":"String",
#         "IsUSCitizen":false,
#         "DMVUSCitizenFlag":"String",
#         "VoterConsentGiven":false,
#         "LastName":"String",
#         "FirstName":"String",
#         "MiddleName":"String",
#         "DoesNotHaveMiddleName":false,
#         "Suffix":"String",
#         "PreviousLastName":"String",
#         "PreviousFirstName":"String",
#         "PreviousMiddleName":"String",
#         "PreviousSuffix":"String",
#         "Gender":"String",
#         "DOB":"String",
#         "SSN":"String",
#         "DriversLicenseNo":"String",
#         "VoterSubmissionId":"String",
#         "EmailAddress":"String",
#         "PhoneNumber":"String",
#         "ResidenceAddress": {
#           "AddressLine1":"String",
#           "AddressLine2":"String",
#           "City":"String",
#           "State":"String",
#           "ZipCode":"String",
#           "Locality":"String",
#           "Country":"String"
#           },
#         "MailingAddress": {
#           "AddressLine1":"String",
#           "AddressLine2":"String",
#           "City":"String",
#           "State":"String",
#           "ZipCode":"String",
#           "Locality":"String",
#           "Country":"String"
#         },
#       "IsProhibited":false,
#       "IsRightsRestored":false,
#       "IsMilitary":false,
#       "IsProtected":false,
#       "IsLawEnforcement":false,
#       "IsCourtProtected":false,
#       "IsConfidentialityProgram":false,
#       "IsBeingStalked":false,
#       "IsRegisteredInAnotherState":false,
#       "NonVARegisteredState":"String",
#       "RegisterToVoteConfirmation":false,
#       "VoterNonConsentReason":"String",
#       "AcceptPrivacyNotice":false,
#       "AcceptWarningStatement":false,
#       "IsAddressCorrect":false,
#       "IsCustomerInformationCorrect":false,
#       "HasElectionOfficialInterest":false
#       }
#       ]
#     }
  
  def to_va_data
    {
      "SendingAgency" => "Rock the Vote", #?
      "Location"  => "register.rockthevote.com", #?
      "SendingAgencyTransactionTimestamp" => self.updated_at.iso8601,
      "IsTestRecord"=> false,
      "VoterRegistrations"=> [
        {
          "VoterId" => self.va_check_voter_id,
          "IsUSCitizen" => self.confirm_us_citizen,
          
          "VoterConsentGiven" => self.confirm_voter_record_update,
          "LastName" => self.last_name,
          "FirstName" => self.first_name,
          "MiddleName" => self.middle_name,
          "DoesNotHaveMiddleName" => self.confirm_no_middle_name,
          "Suffix" => self.name_suffix,
          "PreviousLastName" => self.previous_last_name,
          "PreviousFirstName" => self.previous_first_name,
          "PreviousMiddleName" => self.previous_middle_name,
          "PreviousSuffix" => self.previous_name_suffix,
          "Gender" => self.gender,
          "DOB" => self.date_of_birth.iso8601,
          "SSN" => self.ssn.to_s.gsub(/[^\d]/,''),
          "DriversLicenseNo" => self.dln.to_s.gsub(/\s-/, ''),
          "VoterSubmissionId" => self.id,
          "EmailAddress" => self.email,
          "PhoneNumber" => self.phone,
          "ResidenceAddress" => {
            "AddressLine1" => self.registration_address_1,
            "AddressLine2" => self.registration_address_2,
            "City" => self.registration_city,
            "State" => "VA",
            "ZipCode" => self.registration_zip_code,
            "Locality" => self.registration_locality_name
          },
          "MailingAddress" => {
            "AddressLine1" => self.mailing_address_1,
            "AddressLine2" => self.mailing_address_2,
            "City" => self.mailing_city,
            "State" => self.mailing_state,
            "ZipCode" => self.mailing_state,
            "Locality" => self.mailing_address_locality
          },
          "IsProhibited" => self.convicted_of_felony?,
          "IsRightsRestored" =>self.convicted_of_felony? ? self.right_to_vote_restored : nil,
          # "IsMilitary" => is_military?,
          # "IsProtected" => is_protected?,
          # "IsLawEnforcement" => is_law_enforcement?,
          # "IsCourtProtected" => is_court_protected?,
          # "IsConfidentialityProgram" => is_confidentiality_program?,
          # "IsBeingStalked" => is_being_stalked?,
          "IsRegisteredInAnotherState" => registered_in_other_state?,
          "NonVARegisteredState" => other_registration_state_abbrev,          
          "RegisterToVoteConfirmation" => self.confirm_register_to_vote?,
          "AcceptPrivacyNotice" => self.confirm_affirm_privacy_notice?,
          "AcceptWarningStatement" => self.confirm_voter_fraud_warning?,
          #"HasElectionOfficialInterest" => self.interested_in_being_poll_worker?
        }
      ]

    }
  end
  
  def registration_locality_name
    loc = self.class.localities.detect { |l| l["Code"] == self.registration_locality.to_s }
    loc ? loc["Name"] : nil
  end
  
  def mailing_address_locality_name
    loc = self.class.localities.detect { |l| l["Code"] == self.mailing_address_locality.to_s }
    loc ? loc["Name"] : nil
  end
  
  def state_api_error   
    va_submission_error
  end
  
  def submit_to_online_reg_url
    server = RockyConf.ovr_states.VA.api_settings.api_url
    url = File.join(server, "Voter/Submit?format=json")
    response = RestClient.post(url, self.to_va_data.to_json, va_api_headers("submission"))
    result = JSON.parse(response)
    
    # TODO - what is the response actually like??
    if result["Confirmations"] && result["Confirmations"].any?
      self.va_transaction_id  = result["Confirmations"][0]["ConfirmationId"]
      self.save(validate: false)
    else
      self.va_submission_error ||= []
      if result["TransactionErrorMessage"]
        self.va_submission_error << "#{DateTime.now}: #{result["TransactionErrorMessage"]}"
      end
      if result["Errors"] && result["Errors"].any?
        result["Errors"].each do |error|
          self.va_submission_error << "#{DateTime.now}: #{error}"
        end
      end
    end
    if !self.va_transaction_id.blank?
      self.update_original_registrant
      self.registrant.complete_registration_with_state!
      #deliver_confirmation_email
    else
      self.va_submission_error ||= []
      self.va_submission_error << "#{DateTime.now}: No ID returned from VA submission"
      self.registrant.skip_state_flow!
      AdminMailer.va_registration_error(self, self.va_submission_error, "Registrant Switched to paper").deliver_now
    end
  rescue Exception=>e
    self.va_submission_error ||= []
    self.va_submission_error << [e.message, e.backtrace].flatten
    self.registrant.skip_state_flow!
    AdminMailer.va_registration_error(self, self.va_submission_error, "Registrant Switched to paper").deliver_now
  ensure
    self.va_submission_complete = true
    self.save(validate: false)        
  end

  # {
  #   "TransactonId":0,
  #   "TransactionTimestamp":"2018-08-23T12:46:27.3851675-04:00",
  #   "TransactionErrorMessage":"String",
  #   "VoterRegistrationsAccepted":0,
  #   "VoterRegistrationsWithErrors":0,
  #   "Errors":
  #   [
  #     {"ErrorId":0,
  #       "ErrorTimestamp":"2018-08-23T12:46:27.3851675-04:00",
  #       "VoterSubmissionId":"String",
  #       "ErrorMessage":"String",
  #       "FieldErrors":[
  #         {
  #           "FieldName":"String",
  #           "Issue":"String"
  #         }
  #       ]
  #     }
  #   ],
  #   "Confirmations":[{
  #     "ConfirmationId":0,
  #     "ConfirmationTimestamp":"2018-08-23T12:46:27.3851675-04:00",
  #     "VoterSubmissionId":"String",
  #     "ErrorMessage":"String"
  #   }]
  # }

  def mappings
    {
      "email" => "email_address",
      "confirm_us_citizen"  => "us_citizen",
      #"confirm_will_be_18"  => "will_be_18_by_election",
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
      "mailing_city"  => "mailing_city",
      "mailing_zip_code"  => "mailing_zip_code",
      
      "opt_in_email"  => "opt_in_email",
      "opt_in_sms"  => "opt_in_sms",
      "phone" => "phone",
      "partner_opt_in_email"=>"partner_opt_in_email",
      "partner_opt_in_sms"=>"partner_opt_in_sms",
      "partner_volunteer"=>"partner_volunteer",
      

      "locale"  => "locale"
    }
  end
  
  def set_from_original_registrant
    # TODO: address & mailing address multi line
    # has_mailing related to is_military / is_protected
    r = self.registrant
    mappings.each do |k,v|
      val = r.send(v)
      self.send("#{k}=", val)
    end
    regs = r.home_address.to_s.split(', ')
    self.registration_address_1 = regs[0]
    self.registration_address_2 = regs[1..regs.length].to_a.join(', ')

    mails = r.mailing_address.to_s.split(', ')
    self.mailing_address_1 = mails[0]
    self.mailing_address_2 = mails[1..mails.length].to_a.join(', ')
    
    
    if r.mailing_state
      self.mailing_state = r.mailing_state.abbreviation
    end
    self.save(validate: false)
  end
  
  def update_original_registrant
    r = self.registrant
    mappings.each do |k,v|
      val = self.send(k)
      r.send("#{v}=", val)
    end
    
    r.home_address = [self.registration_address_1, self.registration_address_2].collect{|v| v.blank? ? nil : v}.compact.join(', ')
    r.mailing_address = [self.mailing_address_1, self.mailing_address_2].collect{|v| v.blank? ? nil : v}.compact.join(', ')
    
    r.has_ssn = !self.confirm_no_ssn?
    r.has_state_license = !self.confirm_no_dln?
    
    
    if !self.mailing_state.blank? #always an abbrev
      r.mailing_state = GeoState[self.mailing_state]
    else
      r.mailing_state = nil
    end
    r.save(validate: false)
  end    
  
  def has_state_license?
    !self.confirm_no_dln?
  end
  
  def has_ssn?
    !self.confirm_no_ssn?
  end
end
