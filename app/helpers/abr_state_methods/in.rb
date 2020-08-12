module AbrStateMethods::IN
  
  PDF_FIELDS = {
    "Registration Address number and street": {
      method: "address"
    },
    "CityTown State ZIP Code": {
      method: "address_city_state_zip"
    },
    "Mailing Address number and street": {},
    "CityTown State ZIP Code_2": {},
    "Name Please print_2": {},
    "Registration Address number and street_2": {},
    "CityTown State ZIP Code_3": {},
    "Mailing Address number and street_2": {},
    "CityTown State ZIP Code_4": {},
    "Name": {
      method: "full_name"
    },
    "SSN_last_4": {},
    "No_SSN": { options: ["Off", "On"] },
    "telephone": {
      method: "phone"
    },
    "Reason": { 
      options: ["age", "caregiver", "disability", "election_duties", "expected_absence", "fail_safe_voter", "illness", "lack_transportation", "military", "religious", "sex_offender", "work"] },
    "assist_phone_day": {},
    "assist_phone_evening": {},
    "birth_date": {
      method: "date_of_birth_mm_dd_yyyy"
    },
    "election_date": {
      value: "11/03/2020"
    },
    "party": { 
      options: ["Democrat", "Off", "Republican", "public_question_only"],
      value: "Off"
    },
    "assist_birthdate": {},
  }
  EXTRA_FIELDS = ["has_mailing_address", "assistant", "ssn4"]
 
  def form_field_items
    [
      {"Reason": {required: true, type: :radio}},
      {"ssn4": {type: :checkbox}},
      {"SSN_last_4": {visible: "ssn4"}},
      {"No_SSN": {type: :checkbox}},
      {"has_mailing_address": {type: :checkbox}},
      {"Mailing Address number and street": {visible: "has_mailing_address"}},
      {"CityTown State ZIP Code_2": {visible: "has_mailing_address"}},
      {"assistant": {type: :checkbox}},
      {"Name Please print_2": {visible: "assistant"}},
      {"Registration Address number and street_2": {visible: "assistant"}},
      {"CityTown State ZIP Code_3": {visible: "assistant"}},
      {"Mailing Address number and street_2": {visible: "assistant"}},
      {"CityTown State ZIP Code_4": {visible: "assistant"}},
      {"assist_phone_day": {visible: "assistant"}},
      {"assist_phone_evening": {visible: "assistant"}},
      {"assist_birthdate": {visible: "assistant"}}
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