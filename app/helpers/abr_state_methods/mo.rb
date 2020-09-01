module AbrStateMethods::MO
  
  PDF_FIELDS = {
    "do hereby request an absentee ballot for the": {
      method: "full_name"
    },
    "Election": {
      value: "11/03/2020"
    },
    "undefined": {sensitive: true}, #last 4 ssn
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
    "Street Address or PO Box": {
      method: "mailing_address_1_if_different"
    },
    "City State Zip Code_2": {
      method: "mailing_address_2_if_different"      
    },
    "Include Area Code": {
      method: "phone"
    },
    #Date
    #voter_signature
  }
  EXTRA_FIELDS = ["has_mailing_address", "mailing_address_1", "mailing_address_2"]
  
  def form_field_items
    [
      {"undefined": {required: true, regexp: /\A\d{4}\z/ }},
      {"reason_for_request": {type: :radio, required: true, options: [
        "absent", "incapacity", "religious", "election_official", "incarceration", "confidential"
      ]}},
      {"has_mailing_address": {type: :checkbox}}, 
      {"mailing_address_1": {visible: "has_mailing_address"}},
      {"mailing_address_2": {visible: "has_mailing_address"}},
    ]
  end
  
  def mailing_address_1_if_different
    self.has_mailing_address == "1" ? mailing_address_1 : address
  end
  def mailing_address_2_if_different
    self.has_mailing_address == "1" ? mailing_address_2 : address_city_state_zip
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
    if self.has_mailing_address == "1"
      custom_validates_presence_of("mailing_address_1")
      custom_validates_presence_of("mailing_address_2")
    end
  end
  
 
end