module AbrStateMethods::TX
  
  def self.included(klass)
    klass.extend(AbrStateMethods::ClassMethods)
    klass.add_pdf_fields({
      "Suffix Jr Sr III etc": {
        method: "name_suffix"
      },
      "First Name": {
        method: "first_name"
      },
      "Middle Initial": {}, #TODO- fill this in from the middle name
      "2 Residence Address See back of this application for instructions": {
        method: "address"
      },
      "City TX": {
        method: "city"
      },
      "ZIP Code": {
        method: "zip"
      },
      "3 Mail my ballot to If mailing address differs from residence address please complete Box  7": {}
      "State": {},
      "ZIP Code_2": {},
      "4 Date of Birth mmddyyyy Optional Contact Information Optional Please list phone number andor email address  Used in case our office has questions": {
        method: "email" 
        #add phone number field if possible
      },
      "Date of Birth mmddyyyy Optional": {}, #month only - max: 2
      "Annual Application": {
        options: ["Off", "On"],
        value: "Off"
      },
      "Republican Primary": {
        options: ["Off", "On"],
        value: "Off"
      },
      "If applicant is unable to mark Box 10 and you are acting as a Witness to that fact please check this box and sign below": {},
      "If you assisted the applicant in completing this application in the applicants presence or emailedmailed or faxed the application on behalf of the applicant please check this box as an Assistant and sign below": {},
      "Refer to Instructions on back for clarification": {},
      "Day of date of birth": {}, #day only - max: 2
      "Year of date of birth": {}, #year only - max: 4
      "Month of date you can begin to receive mail at this address": {},
      "Day of date you can begin to receive mail at this address": {},
      "Year of date you can begin to receive mail at this address": {},
      "Month of date of return to residence address": {},
      "Day of date of return to residence address": {},
      "Year of date of return to residence address": {},
      "Reason for voting by mail:": {},
      FieldNameAlt: Reason for voting by mail:
      FieldFlags: 0
      FieldJustification: Left
      FieldStateOption: 65 years of age or older. (Complete box #6a
      FieldStateOption: Confinement to jail. (Complete box #6b)
      FieldStateOption: Disability. (Complete box #6a
      FieldStateOption: Expected absence from the county. (Complete box #6b and box #8
      FieldStateOption: Off
      ---
      FieldType: Button
      FieldName: If requesting this ballot be mailed to a different address (other than residense), indicate where the ballot will be mailed
      FieldNameAlt: If requesting this ballot be mailed to a different address (other than residense), indicate where the ballot will be mailed.
      FieldFlags: 0
      FieldJustification: Left
      FieldStateOption: Address of the jail
      FieldStateOption: Address outside the county
      FieldStateOption: Hospital
      FieldStateOption: Mailing address as listed on my voter registration certificate
      FieldStateOption: Nursing home, assisted living facility, or long term care facility
      FieldStateOption: Off
      FieldStateOption: Relative; relationship
      FieldStateOption: Retirement center
      ---
      FieldType: Text
      FieldName: Date of signature
      FieldNameAlt: Date of signature
      FieldFlags: 0
      FieldJustification: Left
      ---
      FieldType: Text
      FieldName: City of witness
      FieldNameAlt: City of witness
      FieldFlags: 0
      FieldJustification: Left
      ---
      FieldType: Text
      FieldName: Zip code of witness
      FieldNameAlt: Zip code of witness
      FieldFlags: 0
      FieldJustification: Left
      ---
      FieldType: Text
      FieldName: State of witness
      FieldNameAlt: State of witness
      FieldFlags: 0
      FieldJustification: Left
      ---
      FieldType: Text
      FieldName: Street address of witness
      FieldNameAlt: Street address of witness
      FieldFlags: 0
      FieldJustification: Left
      ---
      FieldType: Text
      FieldName: Apartment number (if applicable) of witness
      FieldNameAlt: Apartment number (if applicable) of witness
      FieldFlags: 0
      FieldJustification: Left
      ---
      FieldType: Button
      FieldName: Select only if your 65 or older or live with a disability:
      FieldNameAlt: Select only if your 65 or older or live with a disability:
      FieldFlags: 0
      FieldJustification: Left
      FieldStateOption: Any resulting runoff
      FieldStateOption: May election
      FieldStateOption: November election
      FieldStateOption: Off
      FieldStateOption: Other
      ---
      FieldType: Button
      FieldName: Select only if absent from the county or confined to jail:
      FieldNameAlt: Select only if absent from the county or confined to jail:
      FieldFlags: 0
      FieldJustification: Left
      FieldStateOption: Any resulting runoff
      FieldStateOption: May election
      FieldStateOption: November election
      FieldStateOption: Off
      FieldStateOption: Other
      ---
      FieldType: Button
      FieldName: You must declare one political party to vote in a primary:
      FieldNameAlt: You must declare one political party to vote in a primary:
      FieldFlags: 0
      FieldJustification: Left
      FieldStateOption: Democratic Primary
      FieldStateOption: Off
      ---
      FieldType: Button
      FieldName: 2 - You must declare one political party to vote in a primary:
      FieldNameAlt: You must declare one political party to vote in a primary:
      FieldFlags: 0
      FieldJustification: Left
      FieldStateOption: Democratic Primary
      FieldStateOption: Off
      FieldStateOption: Republican Primary
      ---
      FieldType: Text
      FieldName: From: name
      FieldNameAlt: From: name
      FieldFlags: 0
      FieldJustification: Left
      ---
      FieldType: Text
      FieldName: From: address
      FieldNameAlt: From: address
      FieldFlags: 0
      FieldJustification: Left
      ---
      FieldType: Text
      FieldName: From: city and state
      FieldNameAlt: From: city and state
      FieldFlags: 0
      FieldJustification: Left
      ---
      FieldType: Text
      FieldName: To: Early Voting Clerk's address
      FieldNameAlt: To: Early Voting Clerk's address
      FieldFlags: 0
      FieldJustification: Left
      ---
      FieldType: Text
      FieldName: To: Early Voting Clerk's state
      FieldNameAlt: To: Early Voting Clerk's state
      FieldFlags: 0
      FieldJustification: Left
      ---
      FieldType: Text
      FieldName: 1 Last Name Please print information
      FieldNameAlt: Last Name (Please print information)
      FieldFlags: 0
      FieldJustification: Left
      ---
      FieldType: Text
      FieldName: Relative; relationship
      FieldNameAlt: Relative; relationship
      FieldFlags: 0
      FieldJustification: Left
      ---
      FieldType: Text
      FieldName: early voting clerks fax
      FieldNameAlt: early voting clerk&#8217;s fax
      FieldFlags: 0
      FieldJustification: Left
      ---
      FieldType: Text
      FieldName: City
      FieldNameAlt: City
      FieldFlags: 0
      FieldJustification: Left
      ---
      FieldType: Text
      FieldName: Early voting clerk's address
      FieldNameAlt: Early voting clerk's address
      FieldFlags: 0
      FieldJustification: Left
      ---
      FieldType: Text
      FieldName: Other
      FieldNameAlt: Other
      FieldFlags: 0
      FieldJustification: Left
      ---
      FieldType: Text
      FieldName: 2 - Other
      FieldNameAlt: Other
      FieldFlags: 0
      FieldJustification: Left
      ---
      FieldType: Button
      FieldName: Print
      FieldNameAlt: Print Form
      FieldFlags: 65536
      FieldJustification: Left
      ---
      FieldType: Button
      FieldName: Reset
      FieldNameAlt: Clear Form
      FieldFlags: 65536
      FieldJustification: Left
      
    })
    klass.define_state_value_attribute("has_mailing_address")
  end
  
  def form_field_items
    [
      {"has_mailing_address": {type: :checkbox}},
      {"3 Mail my ballot to If mailing address differs from residence address please complete Box  7": {visible: "has_mailing_address"}},
      {"CITY_2": {visible: "has_mailing_address"}},
      #TODO- fill in state options
      {"State": {visible: "has_mailing_address", type: :select, }},
      {"ZIP Code_2": {visible: "has_mailing_address", min: 5, max: 10}},
      {"If applicant is unable to mark Box 10 and you are acting as a Witness to that fact please check this box and sign below": {type: :checkbox}}, 
      {"If you assisted the applicant in completing this application in the applicants presence or emailedmailed or faxed the application on behalf of the applicant please check this box as an Assistant and sign below": {
        visible: "If applicant is unable to mark Box 10 and you are acting as a Witness to that fact please check this box and sign below", 
        type: :checkbox}},
      {"Refer to Instructions on back for clarification": {
        visible: "If applicant is unable to mark Box 10 and you are acting as a Witness to that fact please check this box and sign below"}},
        #witness' relationship to applicant
      
    ]
  end
  
  def custom_form_field_validations
    # make sure delivery is selected if reason ==3
    # make sure fax is provided if faxtype is selected for delivery
  end

  
end