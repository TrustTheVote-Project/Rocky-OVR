module AbrStateMethods::AK
  
  PDF_FIELDS = {'abr_email': {:method=>"email"},
                'abr_first_name': {:method=>"first_name"},
                'abr_last_name': {:method=>"last_name"},
                'abr_middle_name': {},
                'abr_name_suffix': {:method=>"name_suffix"},
                'abr_previous_full_name': {},
                'abr_citizen_selections': {
                                            options:['abr_citizen_yes',
                                                     'abr_citizen_no']
                                          },
                'abr_id_type_3': {},
                'abr_street_number': {},
                'abr_street_name': {},
                'abr_city': {:method=>"city"},
                'abr_18years_selections': {
                                            options: ['abr_18_yes',
                                                      'abr_18_no']
                                          },
                'abr_id_no2': {},
                'abr_id_type1': {},
                'abr_id_type2': {},
                'date_of_birth_mm_dd_yyyy': {},
                'abr_delivery_address_type1': {},
                'abr_party_selections': {},
                'abr_mailing_address_line_1': {},
                'abr_unit': {:method=>"unit"},
                'abr_mailing_city': {},
                'abr_mailing_state_abbrev': {},
                'abr_mailing_zip': {},
                'abr_election': { options: ['abr_election_REAA',
                                            'abr_election_all',
                                            'abr_election_general',
                                            'abr_election_primary',
                                            'abr_election_special'
                                           ]
                                },
                'abr_uocava_status': { options: ['active',
                                                 'overseas'
                                       ]
},
                'ab_uocava_send_options': { options: [ 'fax',
                                                      'mail',
                                                      'overseas'
                                                    ]
                                          },
                'abr_phone_day': {},
                'abr_phone_evening': {},
                'abr_fax': {},
                'abr_gender': { options: ['male', 'female']},
                'PRA': {},
                'Date': {}
                 
               }
  
  EXTRA_FIELDS = ["has_ballot_mailing_address", "has_mailing_address", "dln_soft_validation"]

  def form_field_items
    [
      {"us_citizen": {type: :checkbox, required: true}},
      {"attest_is_18": {type: :checkbox, required: true}},
      {"has_mailing_address": {type: :checkbox}},
      {"Perm Mailing 1": {visible: "has_mailing_address", min: 3, max: 50}},
      {"Perm Mailing 2": {visible: "has_mailing_address"}},
      {"Perm Mailing 3": {visible: "has_mailing_address"}},
      {"ADL": {length: 7, ui_regexp: "^[0-9]{7}$", hidden: "attest_no_ssn_or_dln"}},
      {"SSN or Last 4": {hidden: "attest_no_ssn_or_dln"}},
      {"attest_no_ssn_or_dln": { type: :checkbox}}, # Must either provide ssn, alaska state ID or check "attest_no..."
      {"gender": {type: :radio, options: ["male", "female"]}},
      "Party",
      {"attest_remote": {type: :checkbox}},
      {"has_ballot_mailing_address": {type: :checkbox}},
      {"Ballot Mailing Address 1": {visible: "has_ballot_mailing_address"}},
      {"Ballot Mailing Address 2": {visible: "has_ballot_mailing_address"}},
      {"Ballot Mailing Address 3": {visible: "has_ballot_mailing_address"}},
      "Former Name",
      "Voter No",
      {"dln_soft_validation": {type: :hidden}}
    ]
  end
  
  def custom_form_field_validations
    if !self.attest_no_ssn_or_dln && self.ssn_or_last_4.blank? && self.adl.blank?
      errors.add(:ssn_or_last_4, custom_required_message("SSN or Last 4"))
      errors.add(:adl, custom_required_message("ADL"))
    end
  end
  
  # Methods below map from UI attributes to PDF fields
  def attest_remote
    self.remote_ak_and_overseas == "On"
  end
  def attest_remote=(value)
    if !!value && !["0", "off", "false", ""].include?(value.to_s.downcase)
      self.remote_ak_and_overseas = "On"
    else
      self.remote_ak_and_overseas = "Off"
    end
  end
  
  def us_citizen
    self.us_citizen_yes == "Yes"
  end
  
  def us_citizen=(value)
    if !!value && !["0", "off", "false", ""].include?(value.to_s.downcase)
      self.us_citizen_yes = "Yes"
      self.us_citizen_no = "Off"
    else 
      self.us_citizen_yes = "Off"
      self.us_citizen_no = "No"
    end
  end
  
  def attest_is_18
    self.n_18_years_yes == "Yes_2"
  end
  
  def attest_is_18=(value)
    if !!value && !["0", "off", "false", ""].include?(value.to_s.downcase)
      self.n_18_years_yes = "Yes_2"
      self.n_18_years_no = "Off"
    else 
      self.n_18_years_yes = "Off"
      self.n_18_years_no = "No_2"
    end
  end
  
  def attest_no_ssn_or_dln
    self.no_ssn_or_adl == "On"
  end
  
  def attest_no_ssn_or_dln=(value)
    if !!value && !["0", "off", "false", ""].include?(value.to_s.downcase)
      self.no_ssn_or_adl = "On"
    else 
      self.no_ssn_or_adl = "Off"
    end
  end
  
  def gender
    return "female" if self.female == "Female"
    return "male" if self.male == "Male"
    return nil
  end
  
  def ballot_selection
    return "dem" if self.ad_ballot == "On"
    return "rep" if self.rep_ballot == "On"
    return ""
  end
  def ballot_selection=(value)
    if value.to_s.downcase == "dem"
      self.ad_ballot = "On"
      self.rep_ballot = "Off"
    elsif value.to_s.downcase == "rep"
      self.ad_ballot = "Off"
      self.rep_ballot = "On"
    else
      self.ad_ballot = "Off"
      self.rep_ballot = "Off"      
    end
  end
  
  def gender=(value)
    if value.to_s.downcase == "male"
      self.male = "Male"
      self.female = "Off"
    elsif value.to_s.downcase == "female"
      self.male = "Off"
      self.female = "Female"
    else
      self.male == "Off"
      self.female == "Off"
    end
      
  end
  
end
