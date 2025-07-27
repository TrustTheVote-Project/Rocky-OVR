module AbrStateMethods::TN
  
  PDF_FIELDS = {
    "Full Legal Name": {
      method: "full_name"
    },
    "Address Where You Live": {
      method: "address"
    },
    "City": {
      method: "city"
    },
    "ZIP": {
      method: "zip"
    },
    "Date of Birth": {
      method: "date_of_birth_mm_dd_yyyy"
    },
    "Phone": {
      method: "phone"
    },
    "Full Social Security Number": { sensitive: true },
    "Email": {
      method: "email"
    },
    "Mailing Address (if different)": {},
    "Mailing City": {},
    "Mailing State": {},
    "Mailing ZIP": {},
    "Election Type": { 
      options: ["Off", "General Only"],
      value: "General Only"
    },
    "Reason": { options: ["Choice1", "Choice10", "Choice11", "Choice2", "Choice3", "Choice4", "Choice5", "Choice6", "Choice7", "Choice8", "Choice9", "Choice12", "Choice13", "Choice14", "Choice15", ] },
    "CDL or TWIC Number": { sensitive: true },
    "Transmission": { options: ["Off", "By Email", "By Mail"], method: "selected_transmission" },
    # DATE:
    #"Date": {}
    #"Assistance Date": {}
    "Address of Person Assisting": {},
    "Address of Witness": {},
    #"Witness Date": {}
    "Mailing_Address_Same_As_Residence": { options: ["Off", "Same as Above"] },
    #"voter_signature": {}
    #"assistant_signature": {}
    #"witness_signature": {}
  }
  EXTRA_FIELDS = ["has_mailing_address", "voter_cannot_sign", "transmission_13", "transmission_14", "transmission_15"]

  
  def form_field_items
    [
      {"Full Social Security Number": {required: true, min: 9, max: 11}},
      {"has_mailing_address": {type: :checkbox}},
      {"Mailing Address (if different)": {visible: "has_mailing_address", required: :if_visible}},
      {"Mailing City": {visible: "has_mailing_address", required: :if_visible}},
      {"Mailing State": {visible: "has_mailing_address", required: :if_visible, type: :select, options: GeoState.collection_for_select}},
      {"Mailing ZIP": {visible: "has_mailing_address", required: :if_visible}},
      {"voter_cannot_sign": {type: :checkbox}},
      {"Address of Person Assisting": {visible: "voter_cannot_sign", required: :if_visible}},
      {"Address of Witness": {visible: "voter_cannot_sign", required: :if_visible}},
      {"Reason": {type: :radio, required: true}},
      {"CDL or TWIC Number": {visible: "reason_choice12"}},
      {"transmission_13": {type: :radio, options: ["By Email", "By Mail"], visible: "reason_choice13", required: "custom"}},
      {"transmission_14": {type: :radio, options: ["By Email", "By Mail"], visible: "reason_choice14", required: "custom"}},
      {"transmission_15": {type: :radio, options: ["By Email", "By Mail"], visible: "reason_choice15", required: "custom"}},
    ]
  end
  
  def selected_transmission
    if self.reason == "Choice13"
      return self.transmission_13
    elsif self.reason == "Choice14"
      return self.transmission_14
    elsif self.reason == "Choice15"
      return self.transmission_15
    end
    "Off"
  end

  
  def custom_form_field_validations
    if self.reason == "Choice12"
      custom_validates_presence_of("CDL or TWIC Number")
    end
    if self.reason == "Choice13"
      custom_validates_presence_of("transmission_13")
    elsif self.reason == "Choice14"
      custom_validates_presence_of("transmission_14")
    elsif self.reason == "Choice15"
      custom_validates_presence_of("transmission_15")
    end
    
  end
  
 
end