module AbrStateMethods::IL::Bloomington
  
  PDF_FIELDS = {
    "name": {}
    FieldType: Text
    FieldName: name
    FieldNameAlt: 
    FieldFlags: 0
    FieldJustification: Left
    ---
    # 
    "residence2": {}
    FieldType: Text
    FieldName: residence2
    FieldNameAlt: 
    FieldFlags: 0
    FieldJustification: Left
    ---
    # 
    "Birthdate": {}
    FieldType: Text
    FieldName: Birthdate
    FieldNameAlt: 
    FieldFlags: 0
    FieldJustification: Left
    ---
    # 
    "residence1": {}
    FieldType: Text
    FieldName: residence1
    FieldNameAlt: 
    FieldFlags: 0
    FieldJustification: Left
    ---
    # 
    "mail_address": {}
    FieldType: Text
    FieldName: mail_address
    FieldNameAlt: 
    FieldFlags: 0
    FieldJustification: Left
    ---
    # 
    "mail_city": {}
    FieldType: Text
    FieldName: mail_city
    FieldNameAlt: 
    FieldFlags: 0
    FieldJustification: Left
    ---
    # 
    "mail_apt_number": {}
    FieldType: Text
    FieldName: mail_apt_number
    FieldNameAlt: 
    FieldFlags: 0
    FieldJustification: Left
    ---
    # 
    "mail_state": {}
    FieldType: Text
    FieldName: mail_state
    FieldNameAlt: 
    FieldFlags: 0
    FieldJustification: Left
    ---
    # 
    "mail_zip": {}
    FieldType: Text
    FieldName: mail_zip
    FieldNameAlt: 
    FieldFlags: 0
    FieldJustification: Left
    ---
    # 
    "Applicant_printed_name": {}
    FieldType: Text
    FieldName: Applicant_printed_name
    FieldNameAlt: 
    FieldFlags: 0
    FieldJustification: Left
    ---
    # 
    "signed_day": {}
    FieldType: Text
    FieldName: signed_day
    FieldNameAlt: 
    FieldFlags: 0
    FieldJustification: Left
    ---
    # 
    "signed_month": {}
    FieldType: Text
    FieldName: signed_month
    FieldNameAlt: 
    FieldFlags: 0
    FieldJustification: Left
    ---
    # 
    #"signature": {}
  }
  EXTRA_FIELDS = ["has_mailing_address"]
  ig
  # def whatever_it_is_you_came_up_with
  #   # TODO when blah is selected it should be "abc" and otherwise left blank
  # end
  
  
  def form_field_items
    [
      {"has_mailing_address": {type: :checkbox}},
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