class VRToPA
  REQUIRED = true
  # for reference only
  # FIELDS = {
  #     "batch" => 0,
  #     "FirstName" => nil,
  #     "MiddleName" => nil,
  #     "LastName" => nil,
  #     "TitleSuffix" => nil,
  #     "united-states-citizen" => nil,
  #     "eighteen-on-election-day" => nil,
  #     "isnewregistration" => nil,
  #     "name-update" => nil,
  #     "address-update" => nil,
  #     "ispartychange" => nil,
  #     "isfederalvoter" => nil,
  #     "DateOfBirth" => nil,
  #     "Gender" => nil,
  #     "Ethnicity" => nil,
  #     "Phone" => nil,
  #     "Email" => nil,
  #     "streetaddress" => nil,
  #     "streetaddress2" => nil,
  #     "unittype" => nil,
  #     "unitnumber" => nil,
  #     "city" => nil,
  #     "zipcode" => nil,
  #     "donthavePermtOrResAddress" => nil,
  #     "county" => nil,
  #     "municipality" => nil,
  #     "mailingaddress" => nil,
  #     "mailingcity" => nil,
  #     "mailingstate" => nil,
  #     "mailingzipcode" => nil,
  #     "drivers-license" => nil,
  #     "ssn4" => nil,
  #     "signatureimage" => nil,
  #     "continueAppSubmit" => nil,
  #     "donthavebothDLandSSN" => nil,
  #     "politicalparty" => nil,
  #     "otherpoliticalparty" => nil,
  #     "needhelptovote" => nil,
  #     "typeofassistance" => nil,
  #     "preferredlanguage" => nil,
  #     "voterregnumber" => nil,
  #     "previousreglastname" => nil,
  #     "previousregfirstname" => nil,
  #     "previousregmiddlename" => nil,
  #     "previousregaddress" => nil,
  #     "previousregcity" => nil,
  #     "previousregstate" => nil,
  #     "previousregzip" => nil,
  #     "previousregcounty" => nil,
  #     "previousregyear" => nil,
  #     "declaration1" => nil,
  #     "assistedpersonname" => nil,
  #     "assistedpersonAddress" => nil,
  #     "assistedpersonphone" => nil,
  #     "assistancedeclaration2" => nil,
  #     "ispollworker" => nil,
  #     "bilingualinterpreter" => nil,
  #     "pollworkerspeaklang" => nil,
  #     "secondEmail" => nil
  # }

  #
  # SAMPLE_VR_REQUEST = {
      # "rocky_request" => {
      #     "lang" => "en",
      #     "phone_type" => "home",
      #     "partner_id" => 1,
      #     "opt_in_email" => false,
      #     "opt_in_sms" => false,
      #     "opt_in_volunteer" => false,
      #     "partner_opt_in_sms" => true,
      #     "partner_opt_in_email" => true,
      #     "partner_opt_in_volunteer" => false,
      #     "finish_with_state" => true,
      #     "created_via_api" => true,
      #     "source_tracking_id" => "Aaron Huttner",
      #     "partner_tracking_id" => "22201",
      #     "geo_location" => {
      #         "lat" => 123,
      #         "long" => -123
      #     },
      #     "open_tracking_id" => "metro canvasing",
      #     "voter_records_request" => {

          #     "type" => "registration",
          #     "generated_date" => "2016-06-16T19=>44=>45+00=>00",
          #     "voter_registration" => {
          #         "date_of_birth" => "2016-06-16",
          #         "mailing_address" => {
          #             "numbered_thoroughfare_address" => {
          #                 "complete_address_number" => "\"\"",
          #                 "complete_street_name" => "801 N. Monroe",
          #                 "complete_sub_address" => {
          #                     "sub_address_type" => "APT",
          #                     "sub_address" => "Apt 306"
          #                 },
          #                 "complete_place_names" => [
          #                     {
          #                         "place_name_type" => "MunicipalJurisdiction",
          #                         "place_name_value" => "Philadelphia"
          #                     },
          #                     {
          #                         "place_name_type" => "County",
          #                         "place_name_value" => "Philadelphia"
          #                     }
          #                 ],
          #                 "state" => "Virginia",
          #                 "zip_code" => "22201"
          #             }
          #         },
          #         "previous_registration_address" => {
          #             "numbered_thoroughfare_address" => {
          #                 "complete_address_number" => "\"\"",
          #                 "complete_street_name" => "801 N. Monroe",
          #                 "complete_sub_address" => {
          #                     "sub_address_type" => "APT",
          #                     "sub_address" => "Apt 306"
          #                 },
          #                 "complete_place_names" => [
          #                     {
          #                         "place_name_type" => "MunicipalJurisdiction",
          #                         "place_name_value" => "Philadelphia"
          #                     },
          #                     {
          #                         "place_name_type" => "County",
          #                         "place_name_value" => "Philadelphia"
          #                     }
          #                 ],
          #                 "state" => "Virginia",
          #                 "zip_code" => "22201"
          #             }
          #         },
          #         "registration_address" => {
          #             "numbered_thoroughfare_address" => {
          #                 "complete_address_number" => "\"\"",
          #                 "complete_street_name" => "801 N. Monroe",
          #                 "complete_sub_address" => {
          #                     "sub_address_type" => "APT",
          #                     "sub_address" => "Apt 306"
          #                 },
          #                 "complete_place_names" => [
          #                     {
          #                         "place_name_type" => "MunicipalJurisdiction",
          #                         "place_name_value" => "Philadelphia"
          #                     },
          #                     {
          #                         "place_name_type" => "County",
          #                         "place_name_value" => "Philadelphia"
          #                     }
          #                 ],
          #                 "state" => "Virginia",
          #                 "zip_code" => "22201"
          #             }
          #         },
          #         "registration_address_is_mailing_address" => false,
          #         "name" => {
          #             "first_name" => "Aaron",
          #             "last_name" => "Huttner",
          #             "middle_name" => "Bernard",
          #             "title_prefix" => "Mr",
          #             "title_suffix" => "Jr"
          #         },
          #         "previous_name" => {
          #             "first_name" => "Aaron",
          #             "last_name" => "Huttner",
          #             "middle_name" => "Bernard",
          #             "title_prefix" => "Mr",
          #             "title_suffix" => "Jr"
          #         },
          #         "gender" => "male",
          #         "race" => "American Indian / Alaskan Native",
          #         "party" => "democratic",
          #         "voter_classifications" => [
          #             {
          #                 "type" => "eighteen_on_election_day",
          #                 "assertion" => true
          #             },
          #             {
          #                 "type" => "united_states_citizen",
          #                 "assertion" => true
          #             },
          #             {
          #                 "type" => "send_copy_in_mail",
          #                 "assertion" => true
          #             },
          #             {
          #                 "type" => "agreed_to_declaration",
          #                 "assertion" => true
          #             }
          #         ],
          #         "signature" => {
          #             "mime_type" => "image/png",
          #             "image" => "?"
          #         },
          #         "voter_ids" => [
          #             {
          #                 "type" => "drivers_license",
          #                 "string_value" => "1243asdf",
          #                 "attest_no_such_id" => false
          #             }
          #         ],
          #         "contact_methods" => [
          #             {
          #                 "type" => "phone",
          #                 "value" => "555-555-5555",
          #                 "capabilities" => ["voice", "fax", "sms"]
          #             }
          #         ],
          #         "additional_info" => [
          #             {
          #                 "name" => "preferred_language",
          #                 "string_value" => "english"
          #             }
          #         ]
          #     }
          # }

      # }
  # }



  def initialize(voter_records_req)
    @voter_records_request = voter_records_req
    @request = @voter_records_request['voter_registration']
    raise 'Invalid input, voter_registration value not found' if @request.nil?
  end

  def convert
    result = {}
    result['batch'] ="0"
    result['FirstName'] = read([:name, :first_name], REQUIRED)
    result['MiddleName'] = read([:name, :middle_name], REQUIRED)
    result['LastName'] = read([:name, :last_name])
    result['TitleSuffix'] = read([:name, :title_suffix])

    value = query([:voter_classifications], :type, 'united_states_citizen', :assertion)
    result['united-states-citizen'] = bool_to_int(value)

    value = query([:voter_classifications], :type, 'eighteen_on_election_day', :assertion)
    result['eighteen-on-election-day'] = bool_to_int(value)

    result['isnewregistration'] =
        (is_empty(read([:previous_registration_address])) && is_empty(read([:previous_name]))) ? "1" : "0"
    result['name-update'] = is_empty(read([:previous_name])) ? "0" : "1"
    result['address-update'] = is_empty(read([:previous_registration_address])) ? "0" : "1"
    result['ispartychange'] = ""
    result['isfederalvoter'] = ""

    result['DateOfBirth'] = read([:date_of_birth])
    result['Gender'] = parse_gender(read([:gender]))
    result['Ethnicity'] = 'A' # read([:race]) TODO convert

    value = query([:contact_methods], :type, 'phone', :value)
    result['Phone'] = value


    result['Email'] = "" # TODO
    result['streetaddress'] = read([:registration_address, :numbered_thoroughfare_address, :complete_street_name])
    result['streetaddress2'] = ""
    result['unittype'] = read([:registration_address, :numbered_thoroughfare_address, :complete_sub_address, :sub_address_type])
    result['unitnumber'] = read([:registration_address, :numbered_thoroughfare_address, :complete_sub_address, :sub_address])

    result['city'] = query([:registration_address, :numbered_thoroughfare_address, :complete_place_names],
                           :place_name_type, 'City', :place_name_value)

    result['zipcode'] = read([:registration_address, :numbered_thoroughfare_address, :zip_code])
    result['donthavePermtOrResAddress'] = ''

    result['county'] = query([:registration_address, :numbered_thoroughfare_address, :complete_place_names],
                  :place_name_type, 'County', :place_name_value)


    result['municipality'] = query([:registration_address, :numbered_thoroughfare_address, :complete_place_names], :place_name_type, 'MunicipalJurisdiction', :place_name_value)

    result['mailingaddress'] = read([:mailing_address, :numbered_thoroughfare_address, :complete_street_name])
    result['mailingcity'] = query([:mailing_address, :numbered_thoroughfare_address, :complete_place_names],
                                  :place_name_type, 'City', :place_name_value)
    result['mailingstate'] = read([:mailing_address, :numbered_thoroughfare_address, :state])
    result['mailingzipcode'] = read([:mailing_address, :numbered_thoroughfare_address, :zip_code])

    result['drivers-license'] = query([:voter_ids], :type, 'drivers_license', :string_value)

    result['ssn4'] = "1234"
    result['signatureimage'] = read([:signature, :image])
    result['continueAppSubmit'] = "1"
    result['donthavebothDLandSSN'] = "0"
    result['politicalparty'] = "OTH"
    result['otherpoliticalparty'] = read([:party])
    result['needhelptovote'] = ""
    result['typeofassistance'] = ""

    result['preferredlanguage'] = query([:additional_info], :name, 'preferred_language', :string_value)

    result['voterregnumber'] = ""
    result['previousreglastname'] = read([:previous_name, :last_name])
    result['previousregfirstname'] = read([:previous_name, :first_name])
    result['previousregmiddlename'] = read([:previous_name, :middle_name])
    result['previousregaddress'] = read([:previous_registration_address, :numbered_thoroughfare_address, :complete_street_name])
    result['previousregcity'] = query([:previous_registration_address, :numbered_thoroughfare_address, :complete_place_names],
                                      :place_name_type, 'City', :place_name_value)
    result['previousregstate'] = read([:previous_registration_address, :numbered_thoroughfare_address, :state])
    result['previousregzip'] = read([:previous_registration_address, :numbered_thoroughfare_address, :zip_code])

    result['previousregcounty'] = query([:previous_registration_address, :numbered_thoroughfare_address, :complete_place_names],
                  :place_name_type, 'County', :place_name_value)

    result['previousregyear'] = ""
    result['declaration1'] = "1"
    result['assistedpersonname'] = ""
    result['assistedpersonAddress'] = ""
    result['assistedpersonphone'] = ""
    result['assistancedeclaration2'] = "1"
    result['ispollworker'] = ""
    result['bilingualinterpreter'] = ""
    result['pollworkerspeaklang'] = ""
    result['secondEmail'] = ""

    result
  end


  private

  def read(keys, required=false)
    value = @request
    keys.each do |key|
      break if value.nil?
      value = value[key.to_s]
      raise "Value #{keys.join('.')} not found in #{@request}" if required && value.nil?
    end
    value
  end

  def query(keys, key, value, output, required=false)
    objects = read(keys, required)
    raise "Array is expected #{objects.class.name} found" unless objects.is_a? Array
    result = objects.find { |obj| obj[key.to_s] == value }
    raise("Not found #{key} == #{value} in #{objects}") if required
    result ? result[output.to_s] : ""
  end

  def bool_to_int(v)
    raise "Boolean expected, #{v.class.name} found" unless [true, false].include?(v)
    v ? "1": "0"
  end

  def parse_gender(gender)
    gender == 'male' ? 'M' : 'F'
  end

  def is_empty(value)
    value.nil? || (value.is_a?(Hash) && value.keys.size == 0)
  end
end
