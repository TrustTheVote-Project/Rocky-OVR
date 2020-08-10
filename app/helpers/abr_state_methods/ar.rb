module AbrStateMethods::AR
  
  PDF_FIELDS = {
    "TO COUNTY CLERK 1": {}, #TODO county clerk's name
    "TO COUNTY CLERK 2": {}, #TODO county clerk's address
    "TO COUNTY CLERK 3": {}, #TODO county clerk's city, state, zip
    "Printed or Typed Name of Voter": {
      method: "full_name"
    },
    "Voting Residence Address of Voter": {
      method: "address"
    },
    "Date of Birth of the Voter": {
      method: "date_of_birth_mm_dd_yyyy"
    },
    "City or Town State and Zip Code": {
      method: "address_city_state_zip"
    },
    "E-mail Address": {
    },
    "Reason": {
      options: ["absent", "illness", "long_term_care"]
    },
    "Reside": {
      options: ["UOCAVA_1", "UOCAVA_2", "UOCAVA_3", "outside_county", "within_county"]
    },
    "Election": {
      options: ["All_Elections_In_Federal_Cycle", "All_Elections_In_One_Year", "Annual_School", "General", "Nonpartisan_General", "Off", "Preferential_Primary", "Special_Election"],
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
    #DATE -today's date    
    #Designated_Bearer_Signature_es_:signer:signature
    #voter_signature
    
  }
  EXTRA_FIELDS = []
 
  def form_field_items
    [
      {"Reason": {required: true, type: :radio}}, 
      {"Reside": {required: true, type: :radio}}, 
      {"Where_Receive": {required: true, type: :radio}}, 
      {"Mailing_Address_1": {visible: "where_receive_mail"}}, 
      {"Mailing_Address_2": {visible: "where_receive_mail"}},
      {"Mailing_Address_3": {visible: "where_receive_mail"}},
      {"delivery_email_address": {visible: "where_receive_electronic_means"}},
      {"Designated_Bearer_Name": {visible: "where_receive_designated_bearer"}},
    ]
  end
  
  def delivery_email_address
    email_address || email
  end
  def delivery_email_address=(val)
    email_address = val
  end
  
  def custom_form_field_validations
    if self.where_receive == "designated_bearer"
      custom_validates_presence_of("Designated_Bearer_Name")
    end
    if self.where_receive == "Mail"
      [1,2,3].each do |i|
        f = "Mailing_Address_#{i}"
        custom_validates_presence_of(f)
      end
    end
    
  end
  
 
end