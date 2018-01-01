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
  
  
  def requires_mailing_address?
    is_protected? || is_military? || no_usps_address?
  end
  
  def is_protected?
    is_court_protected? || is_law_enforcement? || is_confidentiality_program? || is_being_stalked?
  end
  
  def ssn_digits
    self.ssn.to_s.gsub(/[^\d]/, '')
  end
  
  def dln_digits
    self.dln.to_s.gsub(/[^\d]/, '')
  end
  
  def gender
    # TODO determine based on title and return 'M' or 'F'
  end
  
  def complete?
    status == step_list.last && valid? && confirm_affirm_privacy_notice? && confirm_voter_fraud_warning?
  end
  
  
  def cleanup!
    # TODO make sure we don't keep SSN
    raise NotImplementedError
  end
  
  def num_steps
    raise NotImplementedError
  end
  
  def default_state_abbrev
    raise NotImplementedError
  end
  
  def steps
    %w(step_1 step_2 step_3 complete)
  end
  
  def num_steps
    3
  end
  
  
  def async_submit_to_online_reg_url
    raise NotImplementedError
    self.va_submission_complete = false
    self.save
    self.delay.check_voter_confirmation
  end
  
  def check_voter_confirmation
    # Submit to voter confirmation request for eligibility
    server = RockyConf.ovr_states.VA.api_settings.api_url
    api_key = RockyConf.ovr_states.VA.api_settings.api_key
    url = File.join(server, "vX/voter-confirmation")
    result = RestClient.post(url, )
    result = PARegistrationRequest.send_request(self.to_pa_data)
    self.pa_submission_complete = true
    self.save
  end
  
  
  def submit_to_online_reg_url
    raise NotImplementedError
  end

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
      
      "mailing_city"  => "mailing_city",
      "mailing_zip_code"  => "mailing_zip_code",
      #"mailing_state" => "mailing_state",
      
      "opt_in_email"  => "opt_in_email",
      "opt_in_sms"  => "opt_in_sms",
      "phone" => "phone",

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
    if !self.mailing_state.blank? #always an abbrev
      r.mailing_state = GeoState[self.mailing_state]
    else
      r.mailing_state = nil
    end
    r.save(validate: false)
  end    
end
