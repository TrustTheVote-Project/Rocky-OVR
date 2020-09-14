module AbrStateMethods::WI

  PDF_FIELDS = {
    "Municipality": { options: ["City", "Town", "Village"] },
    "Town Village City": {
      method: "city"
    },
    "County": { method: "registration_county_name" },
    "Last Name": {
      method: "last_name"
    },
    "First Name": {
      method: "first_name"
    },
    "Middle Name": {
      method: "middle_name"
    },
    "Suffix eg Jr II etc": {
      method: "name_suffix"
    },
    "Date of Birth MMDDYYYY": {
      method: "date_of_birth_mm_dd_yyyy"
    },
    "Phone": {
      method: "phone"
    },
    "Email": {
      method: "email"
    },
    "Residence Address Street Number  Name": {
      method: "address_line_1"
    },
    "Apt Number": {
      method: "unit"
    },
    "City": {
      method: "city"
    },
    "State  ZIP": {
        method: "state_and_zip"
    }, #TODO - make this work.
    "Mailing Address Street Number  Name": {},
    "Apt Number_2": {},
    "City_2": {},
    "State  ZIP_2": {
      method: "state_and_zip2" #TODONE
    },
    "Care Facility Name if applicable": {},
    "C  O if applicable": {},
    "Fax Number": {},
    "Email Address": {
      method: "receive_by_email" #TODO #TODONE
    },
    "The elections on the following dates": {
      value: "11/03/2020"
    },
    "Agent Last Name": {},
    "Agent First Name": {},
    "Agent Middle Name": {},
    "Agent Address": {},
    #"Todays Date": {},
    #"Todays Date_2": {},
    "Certify": {
        #options: ["Yes"],
        method: 'agent_request_yes'
        },

    "UOCAVA": { options: ["Military", "Permanent_Overseas", "Temporary_Overseas"] },
    "receive_by": { options: ["Mail", "Clerk_Office", "Email", "Fax"] },
    "which_election": { 
      options: ["dated_election", "indefinitely", "this_year"],
      value: "dated_election"
    },
    #"voter_signature": {},
    #"agent_signature_1": {},
    #"agent_signature_2": {},
  }

  EXTRA_FIELDS = ["has_mailing_address","request_agent", "military_overseas", "state_mail", "zip_mail"] 
  
  def receive_by_email
      return self.email if self.receive_by.to_s=='Email'
     # TODO when "receive_by_email" is selected, it should autofill with "email" and otherwise left blank
  end

  def state_and_zip
      return "#{self.home_state_abbrev} #{self.zip}"
  end

  def state_and_zip2
      return "#{self.state_mail.to_s} #{self.zip_mail}" 
  end
  
  def agent_request_yes
      self.request_agent ? "Yes" : "Off"
  end
  
  def form_field_items
    
    [
      {"Municipality": {type: :radio, required: true}},
      {"military_overseas": {type: :checkbox }},
      {"UOCAVA": {type: :radio, visible: "military_overseas", required: :if_visible}},

      {"receive_by": {type: :radio, required: true}},
      {"Fax Number": {visible: "receive_by_fax"}},
      {"has_mailing_address": {type: :checkbox}},
      {"Mailing Address Street Number  Name": {visible: "has_mailing_address",required: :if_visible, classes: "three-quarter"}},
      {"Apt Number_2": {visible: "has_mailing_address", classes: "quarter last"}},
      {"City_2": {visible: "has_mailing_address",required: :if_visible, classes: "half"}},
      #{"State  ZIP_2": {visible: "has_mailing_address", classes: "half last"}},
      {"state_mail": {visible: "has_mailing_address",required: :if_visible, classes: "quarter", type: :select, options: GeoState.collection_for_select, include_blank: true}},
      {"zip_mail": {visible: "has_mailing_address",required: :if_visible,min: 5, max: 10, classes: "quarter last"}},
      
      {"Care Facility Name if applicable": {visible: "has_mailing_address"}},
      {"C  O if applicable": {visible: "has_mailing_address"}},

      {"request_agent": {type: :checkbox}},
     #{"Certify": {type: :radio}},
      {"Agent First Name": {visible: "request_agent", required: :if_visible, classes: "half"}},
      {"Agent Middle Name": {visible: "request_agent", classes: "half last"}},
      {"Agent Last Name": {visible: "request_agent", required: :if_visible}},
      {"Agent Address": {visible: "request_agent", required: :if_visible}},
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
  
  def request_agent_yes
      self.request_agent.to_s=='1' ? 'Yes' : 'Off'
  end
  
  def custom_form_field_validations
    # e.g:
    # make sure delivery is selected if reason ==3
    # e.g:
    # make sure fax is provided if faxtype is selected for delivery

    if (self.receive_by.to_s=='Email' or self.receive_by.to_s=='Fax') && self.military_overseas.to_s!='1'
          errors.add("receive_by",custom_format_message("receive_by"))
    end
 
  end
  
 
end
  
