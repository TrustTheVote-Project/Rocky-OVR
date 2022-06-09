module AbrStateMethods::WY
  
  PDF_FIELDS = {'Date': {},
                'abr_last_name': {:method=>"last_name"},
                'abr_first_name': {:method=>"first_name"},
                'abr_middle_name': {},
                'abr_street_name': {method: "street_name"},
                'abr_street_number': {method: "street_number"},
                'abr_unit': {:method=>"unit"},
                'abr_city': {:method=>"city"},
                'abr_home_state_abbrev': {:method=>"home_state_abbrev"},
                'abr_zip': {:method=>"zip"},
                'date_of_birth_mm_dd_yyyy': {:method => "date_of_birth_mm_dd_yyyy"},
                'abr_phone': {:method=>"phone"},
                'abr_email': {:method=>"email"},
                'abr_mailing_unit': {},
                'abr_mailing_city': {},
                'abr_mailing_state_abbrev': {},
                'abr_mailing_zip': {},
                'abr_election_type1': {},
                'abr_election_type2': {},
                'abr_party': {},
                'abr_mailing_address_line_1': {},
                'abr_request_name': {},
                'abr_active_military': {options: ['active_military_yes',
                                                  'active_military_no']}
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
