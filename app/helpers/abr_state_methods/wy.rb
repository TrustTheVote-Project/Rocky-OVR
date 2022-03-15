module AbrStateMethods::WY
  
  PDF_FIELDS = {
      "LAST NAME": {
        method: "last_name"
      },
      "FIRST NAME": {
        method: "first_name"
      },
      "MIDDLE": {
        method: "middle_name"
      },      
      "COUNTY RESIDENTIAL ADDRESS": {
        method: "address"
      },
      "CITY": {
        method: "city"
      },
      "STATE": {
        method: "home_state_abbrev"
      },
      "ZIP": {
        method: "zip"
      },
      "DATE OF BIRTH": {
        method: "date_of_birth_mm_dd_yyyy"
      },
      "CONTACT PHONE NUMBER": {
        method: "phone"
      },
      "ACTIVE MILITARY Y  N": {
      },
      "EMAIL optional": {
        method: "email"
      },
      "MAIL MY BALLOT TO": {},
      "CITY_2": {},
      "STATE_2": {},
      "ZIP_2": {},
      "2020 PRIMARY": {	
        options: ["Off", "On"],	
        value: "Off"	
      },	
      "2020 GENERAL": {	
        options: ["Off", "On"],	
        value: "On"	
      },	
      "Individual's name who may pick up my ballot": {},	
      "Date": {
        method: "date_for_signature"
      }
      #voter_signature	      #voter_signature      
  
  }

  def signature_pdf_field_name
    "voter_signature"
  end

  EXTRA_FIELDS = ["has_mailing_address"]
  
  def form_field_items
    [
      {"has_mailing_address": {type: :checkbox}},
      {"MAIL MY BALLOT TO": {visible: "has_mailing_address"}},
      {"CITY_2": {visible: "has_mailing_address"}},
      {"STATE_2": {visible: "has_mailing_address", type: :select, options: GeoState.collection_for_select}},
      {"ZIP_2": {visible: "has_mailing_address", min: 5, max: 10}},
      {"ACTIVE MILITARY Y  N": {required: true, type: :radio, options: ["Y", "N"]}},
      {"Individual's name who may pick up my ballot": {}}
    ]
  end
  
  def custom_form_field_validations
    if self.has_mailing_address.to_s == "1"
      [:mail_my_ballot_to, :city_2, :state_2, :zip_2].each do |f|
        errors.add(f, custom_required_message(f)) if self.send(f).blank?
      end
    end
  end
  
  
end