module AbrStateMethods::DC
  
  PDF_FIELDS = {
    "Date of Birth": {
      method: "date_of_birth_mm_dd_yyyy"
    },
    "Telephone No": {
      method: "phone"
    },
    "Email": {
      method: "email"
    },
    "DC Registered Address": {
      method: "address"
    },
    "Current DC Residence Address PO Boxes will not be accepted": {
      method: "address_city_state_zip"
    },
    "Ballot Mailing Address if different from above": {},
    #"Date": {},
    "Address": {},
    "Telephone Number": {},
    "Election Type": {
      value: "General"
    },
    #"Date_2": {},
    "Primary_Election_Date": {
      value: "11/03/2020"
    },
    "Identification_Number": {},
    "Full_Name": {
      method: "full_name"
    },
    "Request_scope": { options: ["Off", "permanent", "single", "year"],
      value: "single"
    },
    #"voter_signature": {},
    #"assistant_signature": {},
  }
  EXTRA_FIELDS = ["has_mailing_address", "assistant"]
  
  # def whatever_it_is_you_came_up_with
  #   # TODO when blah is selected it should be "abc" and otherwise left blank
  # end
  
  
  def form_field_items
    [
      {"Identification_Number": {required: true}},
      {"has_mailing_address": {type: :checkbox}},
      {"Ballot Mailing Address if different from above": {visible: "has_mailing_address"}},
      {"assistant": {type: :checkbox}}
      {"Address": {visible: "assistant", required: :if_visible}},
      {"Telephone Number": {visible: "assistant", required: :if_visible}},
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
    # e.g:
    # make sure delivery is selected if reason ==3
    # e.g:
    # make sure fax is provided if faxtype is selected for delivery
  end
  
 
end