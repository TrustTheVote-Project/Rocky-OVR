module AbrStateMethods::VA
  
  PDF_FIELDS = {
    "Last Name": {
      method: "last_name"
    },
    "First Name": {
      method: "first_name"
    },
    "Middle Name": {
      method: "middle_name"
    },
    "Suffix": {
      method: "name_suffix"
    },
    "in the citycounty of": {
      #method: "registration_county_name"
    },
    "Birth_Year": {},
    "SSN_Last_4": {sensitive: true},
    "Election": {
      options: ["Democratic_Primary", "General", "Republican_Primary", "Off"],
      value: "General"
    },
    "VBM_for_all": {
      options: ["No", "Off", "Yes"],
      value: "No"
    },
    "Primary_Ballot": {
      options: ["Democratic_Party", "None", "Off", "Republican_Party"],
      value: "None"
    },
    "Address_1": {
      method: "address_line_1"
    },
    "Mailing_Address_1": {},
    "Address_2": {
      method: "unit"
    },
    "Mailing_Address_2": {},
    "Zip_Code": {
      method: "zip"
    },
    "Address_3": {
      method: "city"
    },
    "Mailing_Address_3": {},
    "Mailing_Zip_Code": {},
    "Mailing_State": {},
    "Mailing_Country": {},
    "Telephone": {
      method: "phone"
    },
    "Email_Fax": {
      method: "email"
    },
    "Last_Date_of_Residency": {
      #method: "collect_residency_last_date", #date field not in use
    },
    "Category_Code": {
      method: "collect_codes",
    }, #TODO - this is a text field, but really should be a series of checkboxes...
    "Deliver_to": {
      options: ["Residence", "ballot_mailing_address", "email_address"]
    },
    "need_assistance": {
      options: ["Off", "On"]
    },
    "Assistant_Name": {},
    "Assistant_City": {},
    "Assistant_Address": {},
    "Assistant_State": {},
    "Assistant_Phone": {},
    "Assistant_Apt": {},
    "Asistant_Zip": {},
    #assistant_signature
    #voter_signature
    #Asistant_Sign_Date
    #Voter_Sign_Date
   
  }
  EXTRA_FIELDS = ["has_mailing_address", "UOCAVA", "moved_permanently", "A", "B", "C", "D", "last_residency_date", "residency_mm","residency_dd", "residency_yyyy"]
  
  def form_field_items
    [
      {"Birth_Year": {min: 4, max: 4,}},
      {"SSN_Last_4": {min: 4, max: 4, required: true, }},
      {"UOCAVA": {type: :checkbox}},
      #TODO- the text field "Category_Code" should be filled in with the letter(s) of whatever is checked below: A, B, C, and/or D
      {"A": {type: :checkbox, visible: "UOCAVA", classes: "indent"}},
      {"B": {type: :checkbox, visible: "UOCAVA", classes: "indent"}}, #TODO- this text is too long and gets cut off. Can that be fixed?
      {"C": {type: :checkbox, visible: "UOCAVA", classes: "indent"}},
      {"moved_permanently": {visible: "C", type: :checkbox, classes: "indent-2"}}, #TODO- can you change the placement of this? It really should be indented so the user knows it's a subset of the C option. #ToDone
      {"Last_Date_of_Residency":{visible: "moved_permanently", classes: "indent-2", required: :if_visible, regexp: /\A[0-9]{2}\/[0-9]{2}\/[0-9]{4}\z/}}, #TODO- this should also be indented the same amount as above #ToDone

      #{"last_residency_date": {visible: "moved_permanently", classes: "indent-2", xtype: :date,  m: "residency_mm", d: "residency_dd", y: "residency_yyyy"}}, #date view/hide toggle is not working
      {"D": {type: :checkbox, visible: "UOCAVA",  classes: "indent"}}, #TODO- this text is too long and gets cut off. Can that be fixed?
      {"Deliver_to": {visible: "UOCAVA", type: :radio, required: true}},
      {"has_mailing_address": {type: :checkbox}},
      {"Mailing_Address_1": {visible: "has_mailing_address",required: :if_visible, classes: "three-quarter"}},
      {"Mailing_Address_2": {visible: "has_mailing_address", classes: "quarter last"}},
      {"Mailing_Address_3": {visible: "has_mailing_address", required: :if_visible}},
      {"Mailing_State": {visible: "has_mailing_address",required: :if_visible, type: :select, options: GeoState.collection_for_select, include_blank: true, classes:"half"}},
      {"Mailing_Zip_Code": {visible: "has_mailing_address",required: :if_visible, min: 5, max: 10, classes:" half last"}},
      {"Mailing_Country": {visible: "has_mailing_address"}},
      {"need_assistance": {type: :checkbox}},
      {"Assistant_Name": {visible: "need_assistance", required: :if_visible}},
      {"Assistant_Address": {visible: "need_assistance", required: :if_visible, classes: "three-quarter"}},
      {"Assistant_Apt": {visible: "need_assistance", classes: "last quarter"}},
      {"Assistant_City": {visible: "need_assistance", required: :if_visible}},
      {"Assistant_State": {visible: "need_assistance", required: :if_visible, type: :select, options: GeoState.collection_for_select, include_blank: true, classes: "half"}},
      {"Asistant_Zip": {visible: "need_assistance", required: :if_visible, classes: "half last"}},
      {"Assistant_Phone": {visible: "need_assistance", classes: "three-quarter"}}, #optional therefore no RegEx format enforcement?
    ]
  end
  #e.g.
  # [
  #   {"Security Number": {required: true}},
  #   {"State": {visible: "has_mailing_address", type: :select, options: GeoState.collection_for_select, include_blank: true, }},
  #   {"ZIP_2": {visible: "has_mailing_address", min: 5, max: 10}},
  #   {"identification": {
  #     type: :radio,
  #     required: true,
  #     options: ["dln", "ssn4", "photoid"]}},
  #   {"OR": {visible: "identification_dln", min: 8, max: 8, regexp: /\A[a-zA-Z]{2}\d{6}\z/}},
  #   {"OR_2": {visible: "identification_ssn4", min: 4, max: 4, regexp: /\A\d{4}\z/}},
  # ]
  


  def test_date(datestring)
    begin
      @mydate = Date.strptime(datestring, "%m/%d/%Y")
      return true
    rescue ArgumentError
      return false
    end
  end


  def collect_residency_last_date
    if self.moved_permanently.to_s == "1"
      dateparts = [residency_mm, residency_dd, residency_yyyy].collect {|d| d.blank? ? nil : d}.compact
      datestring=dateparts.join("/")
      if dateparts && dateparts.length == 3 && self.test_date(datestring)
        return datestring
      elsif dateparts  && dateparts.length >=1
        return ('') #Invalid
      else 
        return(nil)
      end 
    end 
  end

  def collect_codes
    values = ["A", "B", "C", "D"].map {|m| self.send(m).to_s=="1"?m:nil}
    return (values.compact.join(", "))
  end
 
  def custom_form_field_validations
    
  end

  

end