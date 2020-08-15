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
    "Full Social Security Number": {},
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
    "Reason": { options: ["Choice1", "Choice10", "Choice11", "Choice12", "Choice13", "Choice14", "Choice15", "Choice2", "Choice3", "Choice4", "Choice5", "Choice6", "Choice7", "Choice8", "Choice9"] },
    "CDL or TWIC Number": {},
    "Transmission": { options: ["By Email", "By Mail"] },
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
  # e.g.
  # EXTRA_FIELDS = ["has_mailing_address", "identification"]
  
  # def whatever_it_is_you_came_up_with
  #   # TODO when blah is selected it should be "abc" and otherwise left blank
  # end
  
  
  def form_field_items
    [
      {"Full Social Security Number": {required: true, min: 9, max: 11}},
      {"has_mailing_address": {type: :checkbox}},
      {"Mailing Address (if different)": {visible: "has_mailing_address"}},
      {"Mailing City": {visible: "has_mailing_address"}},
      {"Mailing State": {visible: "has_mailing_address", type: :select, options: GeoState.collection_for_select, include_blank: true}},
      {"Mailing ZIP": {visible: "has_mailing_address"}},
      {"voter_cannot_sign": {type: :checkbox}},
      {"Address of Person Assisting": {visible: "voter_cannot_sign"}},
      {"Address of Witness": {visible: "voter_cannot_sign"}},
      {"Reason": {type: :radio, required: true}},
      {"CDL or TWIC Number": {visible: "reason_choice12", required: true}}, #TODO- is it possible for this to pop up directly after choice 12? Or I could just make it required so if they select choice12, they can't move on without completing it?
      #TODO- map all 3 below to "Transmission"
      {"transmission_13": {type: :radio, options: ["By Email", "By Mail"], visible: "reason_choice13", required: true}},
      {"transmission_14": {type: :radio, options: ["By Email", "By Mail"], visible: "reason_choice14", required: true}},
      {"transmission_15": {type: :radio, options: ["By Email", "By Mail"], visible: "reason_choice15", required: true}},
    ]
  end
  #e.g.
  # [
  #   {"reason_instructions": {type: :instructions}}, *"reason_instructions" does NOT get put into EXTRA_FIELDS
  #   {"County": {type: :select, required: true, include_blank: true, options: [
  #     "Adams",
  #   ]}},
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
  
  
  def custom_form_field_validations
    # make sure delivery is selected if reason ==3
    # make sure fax is provided if faxtype is selected for delivery
  end
  
 
end