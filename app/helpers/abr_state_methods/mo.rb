module AbrStateMethods::MO
  
  PDF_FIELDS = {
    "do hereby request an absentee ballot for the": {
      method: "full_name"
    },
    "Election": {
      value: "11/03/2020"
    },
    "undefined": {}, #last 4 ssn
    "Absence on Election Day from the jurisdiction of the election authority in which I am registered": {},
    "Incapacity or confinement due to illness or physical disability including caring for a person who is incapacitatedor": {},
    "Religious belief or practice": {},
    "Employment as an election authority or by an election authority at a location other than my polling place": {},
    "Incarceration although I have retained all the necessary qualifications for voting": {},
    "Certified participation in the address confidentiality program established under sections 589660 to 589681": {},
    "Street Address": {
      method: "address"
    },
    "City State Zip Code": {}, #TODO- make this work
    "Street Address or PO Box": {},
    "City State Zip Code_2": {},
    "Include Area Code": {
      method: "phone"
    },
    #Date
    #voter_signature
  }
  EXTRA_FIELDS = ["reason_for_request"]
  
  def form_field_items
    [
      {"undefined": {required: true}},
      {"reason_for_request": {type: :radio, options: []}}, #TODO- map to reasons above
      {"Street Address or PO Box": {required: true}},
      {"City State Zip Code_2": {required: true}},
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
  
  
  def custom_form_field_validations
    # make sure delivery is selected if reason ==3
    # make sure fax is provided if faxtype is selected for delivery
  end
  
 
end