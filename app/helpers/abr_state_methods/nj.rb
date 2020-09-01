module AbrStateMethods::NJ
  
  PDF_FIELDS = {
    "2 Last Name Type or Print": {
      method: "last_name"
    },
    "First Name Type or Print": {
      method: "first_name"
    },
    "Middle Name or Initial": {
      method: "middle_name"
    },
    "Suffix Jr Sr III": {
      method: "name_suffix"
    },
    "Street Address or RD": {
      method: "address_line_1"
    },
    "Apt": {
      method: "unit"
    },
    "Municipality CityTown": {
      method: "city"
    },
    "State": {
      method: "home_state_abbrev"
    },
    "Zip": {
      method: "zip"
    },
    "7 EMail Address Optional": {
      method: "email"
    },
    "Apt_2": {},
    "Municipality CityTown_2": {},
    "Address of Messenger": {},
    "Apt_3": {},
    "Municipality CityTown_3": {},
    "State_3": {},
    "Election": { 
      options: ["All", "Fire", "General", "Municipal", "Off", "Primary", "School", "Special"],
      value: "General"
    },
    "UOCAVA": { options: ["Off", "Choice1", "Choice2", "Choice3", "Choice4"], default: "Off" },
    #"voter_signature": {}
    "Date_of_Birth": {
      method: "date_of_birth_mm_dd_yyyy"
    },
    "Phone": {
      method: "phone"
    },
    "Same_Address": { 
      options: ["Off", "Yes"], 
      method:"same_address_conditional" 
    }, 
    "Mailing_Address_1": {
      method: "full_name_conditional" #Only if different mailing address
    },
    "Mailing_Address_2": {},
    "Mailing_Address_3": {},
    "Mailing_Address_4": {},
    #"Todays_Date": {}
    #"Signature_of_Assistor": {}
    #"Date_Assistor": {}
    "State_2": {},
    "Zip_2": {},
    "Address_Assistor": {},
    "Name_Assistor": {},
    "Authorizied_Messenger_Name": {},
    "Date_of_Birth_Messenger": {
      method: "messenger_birthdate"
    },
    #"voter_signature_2": {},
    #"messenger_signature": {}
    #"Signed_Date": {}
    #"messenger_date": {}
  }
  EXTRA_FIELDS = ["has_mailing_address", "assistant", "messenger","messenger_birth_date", "messenger_birth_dd","messenger_birth_mm","messenger_birth_yyyy"]
  
  
  def form_field_items
    [
      {"has_mailing_address": {type: :checkbox}},
      {"Mailing_Address_2":{visible: "has_mailing_address"}},
      {"Mailing_Address_3":{visible: "has_mailing_address"}},
      {"UOCAVA_only": {type: :instructions}},
      {"UOCAVA": {type: :radio}},
      {"assistant": {type: :checkbox}},
      {"Name_Assistor": {visible: "assistant", required: :if_visible}},
      {"Address_Assistor": {visible: "assistant", classes: "three-quarter", required: :if_visible}},
      {"Apt_2": {visible: "assistant", classes: "quarter last"}},
      {"Municipality CityTown_2": {visible: "assistant", classes: "half", required: :if_visible}},
      {"State_2": {visible: "assistant", required: :if_visible, classes: "quarter", type: :select, options: GeoState.collection_for_select, include_blank: true}},
      {"Zip_2": {visible: "assistant", required: :if_visible, classes: "quarter last"}},
      {"messenger": {type: :checkbox}},
      {"Authorizied_Messenger_Name": {visible: "messenger", required: :if_visible}},
      {"Address of Messenger": {visible: "messenger", required: :if_visible, classes: "three-quarter"}},
      {"Apt_3": {visible: "messenger", classes: "quarter last"}},
      {"Municipality CityTown_3": {visible: "messenger", required: :if_visible, classes: "half"}},
      {"State_3": {visible: "messenger", required: :if_visible, classes: "half last", type: :select, options: GeoState.collection_for_select, include_blank: true}},
      # TODO: change to type: :date #ToDone
      {"messenger_birth_date": {visible: "messenger", type: :date,  m: "messenger_birth_mm", d: "messenger_birth_dd", y: "messenger_birth_yyyy", required: :if_visible}},
      # TODO: Messenger zip code is currently erroneously filled by Zip_2 above (Assistant zip code). We need a zip_3
    ]
  end

  # Methods below map from UI attributes to PDF fields

  def same_address_conditional
    return self.has_mailing_address.to_s == "1" ? "Off" : "Yes"
  end

  def full_name_conditional
    if(self.has_mailing_address.to_s == "1")
      return self.full_name
    end
  end

  def test_date(datestring)
    begin
      @mydate = Date.strptime(datestring, "%m/%d/%Y")
      return true
    rescue ArgumentError
      return false
    end
  end


  def messenger_birthdate
    if self.messenger.to_s == "1"
      dateparts = [messenger_birth_mm, messenger_birth_dd, messenger_birth_yyyy].collect {|d| d.blank? ? nil : d}.compact
      datestring=dateparts.join("/")
      if dateparts && dateparts.length == 3 && self.test_date(datestring)
        return datestring
      elsif dateparts  && dateparts.length >=1
        return ('Invalid')
      else 
        return(nil)
      end 
    end 
  end


  def custom_form_field_validations
    if ((self.messenger.to_s == "1") && (self.messenger_birthdate.to_s=='Invalid')) #nil case is handled by 'Required'
         errors.add("messenger_birth_date",custom_required_message("messenger_birth_date"))       
    end    
  end
  
 
end