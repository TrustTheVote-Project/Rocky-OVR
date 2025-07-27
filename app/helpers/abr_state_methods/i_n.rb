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
    "SSN_last_4": {sensitive: true},
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
    "assist_birthdate": { method: "assist_birthdate_mm_dd_yyyy"},
  }
  EXTRA_FIELDS = ["has_mailing_address", "assistant", "ssn4", "assist_birthdate_mm", "assist_birthdate_dd", "assist_birthdate_yyyy"]
 
  def assist_birthdate_mm_dd_yyyy
    dates = [assist_birthdate_mm, assist_birthdate_dd, assist_birthdate_yyyy].collect {|d| d.blank? ? nil : d}.compact
    dates && dates.length == 3 ? dates.join("/") : nil
  end
 
  def form_field_items
    [
      {"Reason": {required: true, type: :radio}},
      {"SSN_last_4": {hidden: "no_ssn"}},
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
      {"assist_birthdate": {visible: "assistant", type: :date, m: "assist_birthdate_mm", d: "assist_birthdate_dd", y: "assist_birthdate_yyyy"}}
    ]
  end

  
  
  def custom_form_field_validations
    if self.no_ssn != "1"
      custom_validates_presence_of("SSN_last_4")
    end
    if self.has_mailing_address == "1"
      [
        "Mailing Address number and street",
        "CityTown State ZIP Code_2"
      ].each do |f|
        custom_validates_presence_of(f)
      end
    end
    if self.assistant == "1"
      [
        "Name Please print_2",
        "Registration Address number and street_2",
        "CityTown State ZIP Code_3",
        "assist_birthdate_mm_dd_yyyy"
      ].each do |f|
        custom_validates_presence_of(f)
      end
    end
  end
  
 
end