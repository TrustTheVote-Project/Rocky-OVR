module AbrStateMethods::MI

  PDF_FIELDS = {
      "Year of Birth": {
      method: "date_of_birth_yyyy"
      },
      "Email Address": {
      method: "email"
      },
      "Phone": {
      method: "phone"
      },
      "M.I": {
      method: "middle_initial"
      },
      "First Name": {
      method: "first_name"
      },
      "Last Name": {
      method: "last_name"
      },
      "Township Jurisdiction": {
        method: "jurisdiction_town"
      }, #TODO - if checked below, value: "X"
      "City Jurisdiction": {
        method: "jurisdiction_city"
      }, #TODO - if checked below, value: "X"
      "Street Address applicant": {
      method: "address"
      },
      "City address applicant": {
      method: "city"
      },
      "Zip Code address applicant": {
      method: "zip"
      },
      "County where applying": {},
      "Jurisdiction Name": {}, #TODO - is there a way to automatically fill this in according to address?
                               #Have not done TBD
      "Add my name to permanent absentee list": { 
      options: ["Off", "On"],
      value: "Off"
      },
      "November 3 Address": {},
      "November 4 City": {},
      "November 3 State": {},
      "November 3 Zip": {},
      "Nov 3 Address End Date_es_:date": {
        method: "address_enddate_mm_dd_yyyy"
      },
      "Nov 3 Address Begin Date_es_:date": {
        method: "address_begindate_mm_dd_yyyy"
      },
      "Name of person appling for ballot": {
      method: "full_name"
      },
      "Name of Person assisting the voter": {},
      "Date of Birth of person assisting_es_:date": {
        method: "assist_birthdate_mm_dd_yyyy"
      },
      "Adress of person assisting": {},
      "Both_2020_Elections": { 
      options: ["Off", "Yes"],
      value: "Off"
      },
      "August_4_2020_Primary": { 
      options: ["Off", "Yes"],
      value: "Off"
      },
      "November_3_2020_General_Election": { 
      options: ["Off", "Yes"],
      value: "Yes"
      },
      #"voter_signature": {},
      #"date": {},
      #"assistant_signature": {},
      #"assistant_signed_date": {},
  }
  EXTRA_FIELDS = ["has_mailing_address", "assistant", 'jurisdiction_type', 'assist_birthdate', 'assist_birthdate_mm','assist_birthdate_dd','assist_birthdate_yyyy','address_begindate','address_begindate_mm','address_begindate_dd','address_begindate_yyyy','address_enddate', 'address_enddate_mm','address_enddate_dd','address_enddate_yyyy']

  def jurisdiction_town
    return ("X") if self.jurisdiction_type.to_s=='town'

  end

  def jurisdiction_city
    return ("X") if self.jurisdiction_type.to_s=='city'
  end

  def assist_birthdate_mm_dd_yyyy
    dates = [assist_birthdate_mm, assist_birthdate_dd, assist_birthdate_yyyy].collect {|d| d.blank? ? nil : d}.compact
    dates && dates.length == 3 ? dates.join("/") : nil
  end

  def address_begindate_mm_dd_yyyy
    dates = [address_begindate_mm, address_begindate_dd, address_begindate_yyyy].collect {|d| d.blank? ? nil : d}.compact
    dates && dates.length == 3 ? dates.join("/") : nil
  end

  def address_enddate_mm_dd_yyyy
    dates = [address_enddate_mm, address_enddate_dd, address_enddate_yyyy].collect {|d| d.blank? ? nil : d}.compact
    dates && dates.length == 3 ? dates.join("/") : nil
  end

  def test_date(datestring)
    begin
      @mydate = Date.strptime(datestring, "%m/%d/%Y")
      return true
    rescue ArgumentError
      return false
    end
  end

  def form_field_items
      [
      {"County where applying": {type: :select, required: true, include_blank: true, options: [
          "Alcona",
          "Alger",
          "Allegan",
          "Alpena",
          "Antrim",
          "Arenac",
          "Baraga",
          "Barry",
          "Bay",
          "Benzie",
          "Berrien",
          "Branch",
          "Calhoun",
          "Cass",
          "Charlevoix",
          "Cheboygan",
          "Chippewa",
          "Clare",
          "Clinton",
          "Crawford",
          "Delta",
          "Dickinson",
          "Eaton",
          "Emmet",
          "Genesee",
          "Gladwin",
          "Gogebic",
          "Grand Traverse",
          "Gratiot",
          "Hillsdale",
          "Houghton",
          "Huron",
          "Ingham",
          "Ionia",
          "Iosco",
          "Iron",
          "Isabella",
          "Jackson",
          "Kalamazoo",
          "Kalkaska",
          "Kent",
          "Keweenaw",
          "Lake",
          "Lapeer",
          "Leelanau",
          "Lenawee",
          "Livingston",
          "Luce",
          "Mackinac",
          "Macomb",
          "Manistee",
          "Marquette",
          "Mason",
          "Mecosta",
          "Menominee",
          "Midland",
          "Missaukee",
          "Monroe",
          "Montcalm",
          "Montmorency",
          "Muskegon",
          "Newaygo",
          "Oakland",
          "Oceana",
          "Ogemaw",
          "Ontonagon",
          "Osceola",
          "Oscoda",
          "Otsego",
          "Ottawa",
          "Presque Isle",
          "Roscommon",
          "Saginaw",
          "St. Clair",
          "St. Joseph",
          "Sanilac",
          "Schoolcraft",
          "Shiawassee",
          "Tuscola",
          "Van Buren",
          "Washtenaw",
          "Wayne",
          "Wexford",
      ]}},
      #{"city_instructions": {type: :instructions}},
      {"jurisdiction_type": {type: :radio, options: ['town','city'], required: true}},
      #{"Township Jurisdiction": {type: :checkbox, classes: "indent"}},
      #{"City Jurisdiction": {type: :checkbox, classes: "indent"}},
      {"Jurisdiction Name": { required: true}},
      {"has_mailing_address": {type: :checkbox}},
      {"November 3 Address": {visible: "has_mailing_address", required: :if_visible}},
      {"November 4 City": {visible: "has_mailing_address", required: :if_visible, classes: "half"}},
      {"November 3 State": {visible: "has_mailing_address", required: :if_visible, classes: "quarter", type: :select, options: GeoState.collection_for_select}},
      {"November 3 Zip": {visible: "has_mailing_address", required: :if_visible, classes: "quarter last"}},
      {"address_begindate": { type: :date, m: "address_begindate_mm", d: "address_begindate_dd", y: "address_begindate_yyyy", visible: "has_mailing_address", required: :if_visible, classes: "half"}},
      {"address_enddate": { type: :date, m: "address_enddate_mm", d: "address_enddate_dd", y: "address_enddate_yyyy",visible: "has_mailing_address", required: :if_visible, classes: "half last"}},
      {"assistant": {type: :checkbox}},
      {"Name of Person assisting the voter": {visible: "assistant", required: :if_visible, classes: "half"}},
      #{"Date of Birth of person assisting_es_:date": {type: :date, visible: "assistant", required: :if_visible, classes: "half last", regexp: /\A[0-9]{2}\/[0-9]{2}\/[0-9]{4}\z/}},
      {"assist_birthdate": {visible: "assistant", required: :if_visible, type: :date, m: "assist_birthdate_mm", d: "assist_birthdate_dd", y: "assist_birthdate_yyyy"}},
      {"Adress of person assisting": {visible: "assistant", required: :if_visible}},
      ]
  end


  def custom_form_field_validations
      # e.g:
      # make sure delivery is selected if reason ==3
      # e.g:
      # make sure fax is provided if faxtype is selected for delivery

      if self.assistant.to_s=="1" && !self.test_date(self.assist_birthdate_mm_dd_yyyy.to_s)
       errors.add("assist_birthdate", custom_format_message("bad_date") )
      end

      if self.has_mailing_address.to_s == "1" && !self.test_date(self.address_begindate_mm_dd_yyyy.to_s)
        errors.add("address_begindate", custom_format_message("bad_date") )
        errors.add('address_begindate', self.address_begindate_mm_dd_yyyy.to_s)
      end

      if self.has_mailing_address.to_s == "1" && !self.test_date(self.address_enddate_mm_dd_yyyy.to_s)
        errors.add("address_enddate", custom_format_message("bad_date") )
        errors.add('address_enddate', self.address_enddate_mm_dd_yyyy.to_s)
      end

  end


end
