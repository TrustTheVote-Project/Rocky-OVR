module AbrStateMethods::STATE_ABBREV
  
  PDF_FIELDS = {
    
  }
  # e.g. 
  # PDF_FIELDS = {
  #   "All in Calendar Year" => {
  #     options: ["Off", "On"],
  #     value: "Off"
  #   },
  #   "Last" => {
  #     method: "last_name"
  #   },
  #   "SSN or Last 4" => {sensitive: true},
  #   "AD Ballot" => {
  #     options: ["Off", "On"]
  #   },
  #   "Ballot Mailing Address 1"=>{},
  # }
  
  EXTRA_FIELDS = [] # For virtual fields like has_mailing_address
  # e.g.
  # EXTRA_FIELDS = ["has_mailing_address", "identification"]
  
  def form_field_items
    [
      {"Security Number": {required: true}},
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