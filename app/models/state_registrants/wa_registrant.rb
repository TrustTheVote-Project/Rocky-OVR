class StateRegistrants::WARegistrant < StateRegistrants::Base

  delegate :allow_desktop_signature?, :state_voter_check_url, to: :registrant

 
  

  
  def self.permitted_attributes
    attrs = super
    return ([attrs,
            :issue_date_day,
            :issue_date_month,
            :issue_date_year].flatten)
  end

  def sms_number_for_continue_on_device
    self.read_attribute(:sms_number_for_continue_on_device) || self.phone
  end

  def email_address_for_continue_on_device
    self.read_attribute(:email_address_for_continue_on_device) || self.email
  end

  def signature_step
    "step_3"
  end

  def self.localities
  [{"Code" =>"01","Name"=>"Adams"},
    {"Code" =>"02","Name"=>"Asotin"},
    {"Code" =>"03","Name"=>"Benton"},
    {"Code" =>"04","Name"=>"Chelan"},
    {"Code" =>"05","Name"=>"Clallam"},
    {"Code" =>"06","Name"=>"Clark"},
    {"Code" =>"07","Name"=>"Columbia"},
    {"Code" =>"08","Name"=>"Cowlitz"},
    {"Code" =>"09","Name"=>"Douglas"},
    {"Code" =>"10","Name"=>"Ferry"},
    {"Code" =>"11","Name"=>"Franklin"},
    {"Code" =>"12","Name"=>"Garfield"},
    {"Code" =>"13","Name"=>"Grant"},
    {"Code" =>"14","Name"=>"Grays Harbor"},
    {"Code" =>"15","Name"=>"Island"},
    {"Code" =>"16","Name"=>"Jefferson"},
    {"Code" =>"17","Name"=>"King"},
    {"Code" =>"18","Name"=>"Kitsap"},
    {"Code" =>"19","Name"=>"Kittitas"},
    {"Code" =>"20","Name"=>"Klickitat"},
    {"Code" =>"21","Name"=>"Lewis"},
    {"Code" =>"22","Name"=>"Lincoln"},
    {"Code" =>"23","Name"=>"Mason"},
    {"Code" =>"24","Name"=>"Okanogan"},
    {"Code" =>"25","Name"=>"Pacific"},
    {"Code" =>"26","Name"=>"Pend Oreille"},
    {"Code" =>"27","Name"=>"Pierce"},
    {"Code" =>"28","Name"=>"San Juan"},
    {"Code" =>"29","Name"=>"Skagit"},
    {"Code" =>"30","Name"=>"Skamania"},
    {"Code" =>"31","Name"=>"Thurston"},
    {"Code" =>"32","Name"=>"Spokane"},
    {"Code" =>"33","Name"=>"Stevens"},
    {"Code" =>"34","Name"=>"Snohomish"},
    {"Code" =>"35","Name"=>"Wahkiakum"},
    {"Code" =>"36","Name"=>"Walla Walla"},
    {"Code" =>"37","Name"=>"Whatcom"},
    {"Code" =>"38","Name"=>"Whitman"},
    {"Code" =>"39","Name"=>"Yakima"},
    {"Code" =>"99","Name"=>"State"}]
  end

  validates_with WARegistrantValidator
  @use_newui2020  = true # CTW Not correct -- 

  
  serialize :wa_submission_error, Array

  def set_issue_date_from_parts
    date=nil
    date = Date.civil(issue_date_year.to_i, issue_date_month.to_i, issue_date_day.to_i) rescue nil
    if (!date.nil?) 
      if (date >Date.parse("1900-01-01"))
        self.issue_date=date
      end
    else
      self.issue_date=nil
    end
  
  
  end

  def issue_date_day
    @issue_date_day || issue_date&.day 
  end
  def issue_date_day=(string_value)
    @issue_date_day= string_value
    set_issue_date_from_parts
  end
  def issue_date_month
   @issue_date_month || issue_date&.month 
  end
  def issue_date_month=(string_value)
    @issue_date_month= string_value
    set_issue_date_from_parts
  end
  def issue_date_year
     @issue_date_year ||  issue_date&.year
  end    
  def issue_date_year=(string_value)
    @issue_date_year= string_value
    set_issue_date_from_parts
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
    status == step_list.last && valid? 
  end
  
  def submitted?
    wa_submission_complete? || (wa_check_complete? && wa_check_error?)
  end
  
  def state_transaction_id
    wa_transaction_id
  end
  
  def cleanup!
    self.ssn4 = nil
    self.driver_license = nil
    self.save(validate: false)
  end
  
  def default_state_abbrev
    'WA'
  end


  
  def steps
    %w(step_1 step_2 step_3 step_4 complete)
  end


  def num_steps
    4
  end
 
  
 
  def async_submit_to_online_reg_url
    self.wa_submission_complete = false
    self.wa_check_complete = false
    self.save
    self.delay.do_complete_voter_submission    
  end

  def issue_date=(string_value)
    issue_date = nil
    if string_value.is_a?(String)
      if matches = string_value.match(/\A(\d{1,2})\D+(\d{1,2})\D+(\d{4})\z/)
        m,d,y = matches.captures
        issue_date = Date.civil(y.to_i, m.to_i, d.to_i) rescue string_value
      elsif matches = string_value.match(/\A(\d{4})\D+(\d{1,2})\D+(\d{1,2})\z/)
        y,m,d = matches.captures
        issue_date = Date.civil(y.to_i, m.to_i, d.to_i) rescue string_value
      else
        issue_date = string_value
      end
    else
      issue_date = string_value
    end
    write_attribute(:issue_date, issue_date)
  end


  def do_complete_voter_submission
    #if self.check_voter_confirmation
      self.submit_to_online_reg_url
    #end
  end

  def wa_api_headers(method)
    return {}
  end


#  {"firstName"=>"fname", 
#    "lastName"=>"lname", 
#    "residenceAddress"=>"raddress", 
#    "residenceCity"=>"Seattle", 
#    "residenceState"=>"WA", 
#    "residenceZip"=>"98001", 
#    "mailingZip"=>"98002", 
#    "mailingAddress"=>"maddress", 
#    "mailingCity"=>"mcity", 
#    "mailingState"=>"WA", 
#    "isResident"=>true, 
#    "isCitizen"=>true, 
#    "customerID"=>"RTVAVR", 
#    "transactionID"=>"001122334456"}
  
  def to_wa_data

    {

      "isResident"	=>	1, #hard coded as such (from zip in this context)
      "isCitizen"	=>	self.is_citizen,


      "nameSuffix"	=>	self.name_suffix,
      "firstName"	=>	self.first_name,
      "middleName"	=>	self.middle_name,
      "lastName"	=>	self.last_name,

      "Gender"	=>	self.gender,


      "prevNameSuffix"	=>	self.prev_name_suffix,
      "prevFirstName"	=>	self.prev_first_name,
      "prevLastName"	=>	self.prev_last_name,
      "prevMiddleName"	=>	self.prev_middle_name,

 


      "residenceUnitNumber"	=>	self.residence_unit_number,
      "residenceUnitType"	=>	self.residence_unit_type,
      "residenceAddress"	=>	self.residence_address,
      "residenceCity"	=>	self.residence_city,
      "residenceState"	=>	self.residence_state,
      "residenceZip"	=>	self.residence_zip,
      "resCountyCode"	=>	self.res_county_code,



      "mailingUnitNumber"	=>	self.mailing_unit_number,
      "mailingUnitType"	=>	self.mailing_unit_type,
      "mailingAddress"	=>	self.mailing_address,
      "mailingCity"	=>	self.mailing_city,
      "mailingState"	=>	self.mailing_state,
      "mailingZip"	=>	self.mailing_zip,
      "mailCountyCode"	=>	self.mail_county_code,


      "AddressChange"	=>	self.has_previous_address, #todo
      "resAddressChangeMadeDate"	=>	self.res_address_change_made_date, #todo




      "prevResidenceUnitNumber"	=>	self.prev_residence_unit_number,
      "prevResidenceUnitType"	=>	self.prev_residence_unit_type,
      "prevResidenceAddress"	=>	self.prev_residence_address,
      "prevResidenceCity"	=>	self.prev_residence_city,
      "prevResidenceState"	=>	self.prev_residence_state,
      "prevResidenceZip"	=>	self.prev_residence_zip,
      "prevResCountyCode"	=>	self.prev_res_county_code,




      "mailAddressChangeMadeDate"	=>	self.mail_address_change_made_date,

      "prevMailingUnitType"	=>	self.prev_mailing_unit_number,
      "prevMailingUnitNumber"	=>	self.prev_mailing_unit_type,
      "prevMailingAddress"	=>	self.prev_mailing_address,
      "prevMailingCity"	=>	self.prev_mailing_city,
      "prevMailingState"	=>	self.prev_mailing_state,
      "prevMailingZip"	=>	self.prev_mailing_zip,
      "prevMailCountyCode"	=>	self.prev_mail_county_code,


      #"dateOfBirth"	=>	self.date_of_birth. #CTW check format

      "dateOfBirth"	=>	self.date_of_birth.strftime("%m/%d/%Y"),

      "driverLicense"	=>	self.driver_license.to_s.gsub(/\s-/, ''),
  
      
      "issue_date" =>self.issue_date.iso8601, #CTW check foramt
      "SSN4"	=>	self.ssn4, #CTW Check
      
      #"DLE"	=>	self.unknown,  Ask Alex
      #"oldDLN"	=>	self.unknown,  Ask Alex

  
      "MilitaryFlag"	=>	self.military_flag, 
      "isHomeless"	=> self.is_homeless,
      
      #"Signature"	=>	self.foo, # Need to know format and then ask Alex how to collect
      "Signature" =>self.class.resize_signature_url(voter_signature_image),

      "transactionID" => self.uid,
      "registrationDate"	=>	self.updated_at.iso8601, # CTW ask Alex *now*, check format
      "customerID"	=>	'RTVAVR',

    }

  end


  # Could adapt below for county codes!!!
=begin  
  def registration_locality_name
    loc = self.class.localities.detect { |l| l["Code"] == self.registration_locality.to_s }
    loc ? loc["Name"] : nil
  end
  
  def mailing_address_locality_name
    loc = self.class.localities.detect { |l| l["Code"] == self.mailing_address_locality.to_s }
    loc ? loc["Name"] : nil
  end
=end  
  def state_api_error   
    wa_submission_error
  end


#CTW This is the major API customization
# Check success/error and do the right thing
# Update data and save
# Forward user to appropriate place

=begin

Response as:
  {
  "returnToken":"",
  "transactionID":"12345",
  "return_code":"E",
  "error_code":"042",
  "error_message":"Generated error 042 with field firstName: This is a generated error"
}

=end

  def submit_to_online_reg_url
    server = RockyConf.ovr_states.WA.api_settings.api_url
    #url = File.join(server, "/register/")
    url=server

    puts ("Posting to: #{url} data: #{self.to_wa_data.to_json}")
    #Switch to HTTP (ala some other model)
    response = RestClient.post(url, self.to_wa_data.to_json, wa_api_headers("submission"))
    result = JSON.parse(response)
    
    # TODO - what is the response actually like??
    # Should always get a transactionID
    if result["transactionID"] 
      self.wa_transaction_id  = result["transactionID"]
      self.save(validate: false)
    end

    # IF token success otherwise error
    if result["returnToken"] 
      self.return_token  = result["returnToken"]
      self.save(validate: false)
    else
      self.wa_submission_error ||= []
      if result["return_code"]
        self.wa_submission_error << "#{DateTime.now}: Return Code #{result["return_code"]}"
      end
      if result["error_code"]
        self.wa_submission_error << "#{DateTime.now}: Error Code #{result["error_code"]}"
      end
      if result["error_message"]
        self.wa_submission_error << "#{DateTime.now}: Error message #{result["error_message"]}"
      end
      

    end

    #CTW This is post API submission

    if !self.return_token.blank?  # Is this success or failure
      self.update_original_registrant
      self.registrant.complete_registration_with_state!  #It is complete already (so this is confirm?)
    else
      self.wa_submission_error ||= []
      self.wa_submission_error << "#{DateTime.now}: No WA return_token"
      self.registrant.skip_state_flow!
      AdminMailer.wa_registration_error(self, self.wa_submission_error, "Registrant Switched to paper").deliver_now
    end

  rescue Exception=>e
    self.wa_submission_error ||= []
    self.wa_submission_error << [e.message, e.backtrace].flatten
    self.registrant.skip_state_flow!
    AdminMailer.wa_registration_error(self, self.wa_submission_error, "Registrant Switched to paper").deliver_now
  ensure
    self.wa_submission_complete = true
    self.save(validate: false)
        
  end

def allow_desktop_signature?
  #Allow later customization
  return false
end


  def home_state
    "Washington"
  end

  def home_state_name
    "Washington"
  end

  def home_state_abbrev
    "WA"
  end

  def mappings
    {

      #n might need? 
      "email" => "email_address",
      "is_citizen"  => "us_citizen",
      #"confirm_will_be_18"  => "will_be_18_by_election",
      
      "date_of_birth" => "date_of_birth",
      
      
      "name_title"  => "name_title",
      "first_name"  => "first_name",
      "middle_name" => "middle_name",
      "last_name" => "last_name",
      "name_suffix" => "name_suffix",
      
      "has_previous_name"  => "change_of_name",
      
      "prev_first_name" => "prev_first_name",
      "prev_last_name"  => "prev_last_name",
      "prev_middle_name" => "prev_middle_name",
      "prev_name_suffix" => "prev_name_suffix", # do we have?

      "residence_city" => "home_city",
      "residence_address" => "home_address",# do we have?
      "residence_unit_number" => "home_unit",
      #"residence_state" => "home_state",# hard code?


      "residence_zip" => "home_zip_code",
      
      "has_mailing_address" => "has_mailing_address",
      
      "mailing_city"  => "mailing_city",
      "mailing_zip"  => "mailing_zip_code",
      
      "opt_in_email"  => "opt_in_email",
      "opt_in_sms"  => "opt_in_sms",
      "phone" => "phone",
      

       "partner_opt_in_email"=>"partner_opt_in_email", #query Alex 
       "partner_opt_in_sms"=>"partner_opt_in_sms",#query Alex 
        "partner_volunteer"=>"partner_volunteer",#query Alex 
      

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

    self.save(validate: false)
  end
  
  def update_original_registrant
    r = self.registrant
    mappings.each do |k,v|
      val = self.send(k)
      r.send("#{v}=", val)
    end

    r.save(validate: false)
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

end
