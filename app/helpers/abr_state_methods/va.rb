module AbrStateMethods::VA

  PDF_FIELDS = {'Residence address from Section 4': {},
                'Ballot mailing address from Section 5': {},
                'Email address from Section 6': {},
                'Fax number from Section 6': {},
                'abr_last_name': {:method=>"last_name"},
                'abr_first_name': {:method=>"first_name"},
                'abr_middle_name': {},
                'abr_name_suffix': {:method=>"name_suffix"},
                'abr_last_4_ssn': {},
                'abr_election_type_selections': {},
                'abr_primary_type_selections1': {},
                'abr_election_type_selections2': {},
                'abr_election_date': {},
                'abr_county': {:method=>"county"},
                'abr_unit': {:method=>"unit"},
                'abr_city': {:method=>"city"},
                'abr_zip': {:method=>"zip"},
                'abr_mailing_unit': {:method=>"unit"},
                'abr_mailing_city': {:method=>"city"},
                'abr_mailing_state_abbrev': {:method=>"home_state_abbrev"},
                'abr_mailing_zip': {:method=>"zip"},
                'abr_phone': {},
                'abr_email': {:method=>"email"},
                'abr_mailing_country': {},
                'abr_assistant_check1': {},
                'abr_assistant_check2': {},
                'abr_assistant_phone': {},
                'abr_assistant_unit': {},
                'abr_assistant_zip': {},
                'abr_assistant_state_abbrev': {},
                'abr_assistant_city': {},
                'abr_street_number': {},
                'abr_assistant_street_number': {},
                'abr_assistant_street_name': {},
                'abr_assistant_first_name': {},
                'abr_assistant_middle_initial': {},
                'abr_assistant_last_name': {},
                'abr_assistant_suffix': {},
                'abr_street_name': {},
                'abr_mailing_street_number': {},
                'abr_mailing_street_name': {},
                'former_name': {},
                'former_address': {},
                'former_city': {},
                'former_state': {},
                'If applicable last date of residency': {},
                'date_moved': {},
                'former_zip': {},
                'mil_and_overseas_category': {}
               }

  EXTRA_FIELDS = ["has_mailing_address", "UOCAVA", "moved_permanently", "A", "B", "C", "D", "last_residency_date", "residency_mm","residency_dd", "residency_yyyy"]
  
  def form_field_items
    [
      {"SSN_Last_4": {min: 4, max: 4, required: true,classes: 'three-quarter', regexp: /\A\d{4}\z/}},
      {"UOCAVA": {type: :checkbox}},
      #TODO- the text field "Category_Code" should be filled in with the letter(s) of whatever is checked below: A, B, C, and/or D
      {"A": {type: :checkbox, visible: "UOCAVA", classes: "indent"}},
      {"B": {type: :checkbox, visible: "UOCAVA", classes: "indent"}}, #TODO- this text is too long and gets cut off. Can that be fixed?
      {"C": {type: :checkbox, visible: "UOCAVA", classes: "indent"}},
      {"moved_permanently": {visible: "C", type: :checkbox, classes: "indent-2"}}, #TODO- can you change the placement of this? It really should be indented so the user knows it's a subset of the C option. #ToDone
      {"Last_Date_of_Residency":{visible: "moved_permanently", classes: "indent-2", required: :if_visible, regexp: /\A[0-9]{2}\/[0-9]{2}\/[0-9]{4}\z/}}, #TODO- this should also be indented the same amount as above #ToDone

      #{"last_residency_date": {visible: "moved_permanently", classes: "indent-2", xtype: :date,  m: "residency_mm", d: "residency_dd", y: "residency_yyyy"}}, #date view/hide toggle is not working
      {"D": {type: :checkbox, visible: "UOCAVA",  classes: "indent"}}, #TODO- this text is too long and gets cut off. Can that be fixed?
      {"Deliver_to": {visible: "UOCAVA", type: :radio, required: :if_visible}},
      {"has_mailing_address": {type: :checkbox}},
      {"Mailing_Address_1": {visible: "has_mailing_address",required: :if_visible, classes: "three-quarter"}},
      {"Mailing_Address_2": {visible: "has_mailing_address", classes: "quarter last", max:7}},
      {"Mailing_Address_3": {visible: "has_mailing_address", required: :if_visible}},
      {"Mailing_State": {visible: "has_mailing_address",required: :if_visible, type: :select, options: GeoState.collection_for_select, classes:"half"}},
      {"Mailing_Zip_Code": {visible: "has_mailing_address",required: :if_visible, min: 5, max: 10, classes:" half last"}},
      {"Mailing_Country": {visible: "has_mailing_address"}},
      # {"need_assistance": {type: :checkbox}},
      # {"Assistant_Name": {visible: "need_assistance", required: :if_visible}},
      # {"Assistant_Address": {visible: "need_assistance", required: :if_visible, classes: "three-quarter"}},
      # {"Assistant_Apt": {visible: "need_assistance", classes: "last quarter"}},
      # {"Assistant_City": {visible: "need_assistance", required: :if_visible}},
      # {"Assistant_State": {visible: "need_assistance", required: :if_visible, type: :select, options: GeoState.collection_for_select, include_blank: true, classes: "half"}},
      # {"Asistant_Zip": {visible: "need_assistance", required: :if_visible, classes: "half last"}},
      # {"Assistant_Phone": {visible: "need_assistance", classes: "three-quarter"}}, #optional therefore no RegEx format enforcement?
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
  


  def test_date(datestring)
    begin
      @mydate = Date.strptime(datestring, "%m/%d/%Y")
      return true
    rescue ArgumentError
      return false
    end
  end


  def collect_residency_last_date
    if self.moved_permanently.to_s == "1"
      dateparts = [residency_mm, residency_dd, residency_yyyy].collect {|d| d.blank? ? nil : d}.compact
      datestring=dateparts.join("/")
      if dateparts && dateparts.length == 3 && self.test_date(datestring)
        return datestring
      elsif dateparts  && dateparts.length >=1
        return ('') #Invalid
      else 
        return(nil)
      end 
    end 
  end

  def collect_codes
    values = ["A", "B", "C", "D"].map {|m| self.send(m).to_s=="1"?m:nil}
    return (values.compact.join(", "))
  end
 
  def custom_form_field_validations
    if self.deliver_to.to_s=='ballot_mailing_address' && self.has_mailing_address.to_s!='1'
      errors.add('has_mailing_address', custom_required_message('has_mailing_address'))
    end

  end

  

end
