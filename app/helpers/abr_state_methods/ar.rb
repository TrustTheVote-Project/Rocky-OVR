module AbrStateMethods::AR
  
  PDF_FIELDS = {
    "TO COUNTY CLERK 1": {}, #county clerk's name
    "TO COUNTY CLERK 2": {}, #county clerk's address
    "TO COUNTY CLERK 3": {}, #county clerk's city, state, zip
    #DATE
    "Printed or Typed Name of Voter": {
      method: "full_name"
    },
    "Voting Residence Address of Voter": {
      method: "address"
    },
    "Date of Birth of the Voter": {
      method: "date_of_birth_mm_dd_yyyy"
    },
    "City or Town State and Zip Code": {}, #TODO
    "E-mail Address": {
      method: "email" #TODO- only fill in email if "where_receive_electronic_means" radio option
    },
    "Reason": {
      options: ["absent", "illness", "long_term_care"]
    },
    "Reside": {
      options: ["UOCAVA_1", "UOCAVA_2", "UOCAVA_3", "outside_county", "within_county"]
    }
    "Election": {
      options: ["All_Elections_In_Federal_Cycle", "All_Elections_In_One_Year", "Annual_School", "General", "Nonpartisan_General", "Off", "Preferential_Primary", "Special_Election"]
      value: "Nonpartisan_General" 
      #right?
    },
    "Mailing_Address_1": {},
    "Mailing_Address_2": {},
    "Mailing_Address_3": {},
    "Where_Receive": {
      options: ["County_Clerk_Office", "Designated_Bearer", "Electronic_Means", "Mail"]
    },
    "Designated_Bearer_Name": {},
    #Designated_Bearer_Signature_es_:signer:signature
    #voter_signature
    
  }
  EXTRA_FIELDS = []
 
  def form_field_items
    [
      {"Reason": {required: true, type: :radio, options: []}}, #TODO- grab options from above
      {"Reside": {required: true, type: :radio, options: []}}, #TODO- grab options from above
      {"Where_Receive": {required: true, type: :radio, options: []}}, #TODO- grab options from above
      {"Mailing_Address_1": {visible: "where_receive_mail"}}, 
      {"Mailing_Address_2": {visible: "where_receive_mail"}},
      {"Mailing_Address_3": {visible: "where_receive_mail"}},
      {"Designated_Bearer_Name": {visible: "where_receive_designated_bearer"}},
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