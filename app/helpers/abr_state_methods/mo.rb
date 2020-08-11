module AbrStateMethods::MO
  
  PDF_FIELDS = {
    "do hereby request an absentee ballot for the": {
      method: "full_name"
    },
    "Election": {
      value: "11/03/2020"
    },
    "undefined": {}, #last 4 ssn
    "Absence on Election Day from the jurisdiction of the election authority in which I am registered": {},
    "Incapacity or confinement due to illness or physical disability including caring for a person who is incapacitatedor": {},
    "Religious belief or practice": {},
    "Employment as an election authority or by an election authority at a location other than my polling place": {},
    "Incarceration although I have retained all the necessary qualifications for voting": {},
    "Certified participation in the address confidentiality program established under sections 589660 to 589681": {},
    "Street Address": {
      method: "address"
    },
    "City State Zip Code": {
      method: "address_city_state_zip"
    },
    "Street Address or PO Box": {},
    "City State Zip Code_2": {},
    "Include Area Code": {
      method: "phone"
    },
    #Date
    #voter_signature
  }
  EXTRA_FIELDS = []
  
  def form_field_items
    [
      {"undefined": {required: true, regexp: /\A\d{4}\z/ }},
      {"reason_for_request": {type: :radio, required: true, options: [
        "absent", "incapacity", "religious", "election_official", "incarceration", "confidential"
      ]}}, #TODO- map to reasons above
      {"Street Address or PO Box": {required: true}},
      {"City State Zip Code_2": {required: true}},
    ]
  end
  
  REASONS = {
    "absent": "Absence on Election Day from the jurisdiction of the election authority in which I am registered",
    "incapacity": "Incapacity or confinement due to illness or physical disability including caring for a person who is incapacitatedor",
    "religious": "Religious belief or practice",
    "election_official": "Employment as an election authority or by an election authority at a location other than my polling place",
    "incarceration": "Incarceration although I have retained all the necessary qualifications for voting",
    "confidential": "Certified participation in the address confidentiality program established under sections 589660 to 589681"
  }
  def reason_for_request=(val)
    REASONS.values.each do |f|
      self.send("#{self.class.make_method_name(f)}=", "")
    end
    REASONS.each do |v,f|
      if val.to_s == v.to_s
        self.send("#{self.class.make_method_name(f)}=", "X")
      end
    end    
  end
  
  def reason_for_request
    REASONS.each do |v,f|
      return v.to_s if self.send(self.class.make_method_name(f)).to_s == "X"
    end     
    return nil 
  end

  
  def custom_form_field_validations
    # make sure delivery is selected if reason ==3
    # make sure fax is provided if faxtype is selected for delivery
  end
  
 
end