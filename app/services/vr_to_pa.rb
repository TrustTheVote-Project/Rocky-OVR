class VRToPA
  class ParsingError < StandardError;
  end

  REQUIRED = true
  OPTIONAL = false
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

  attr_accessor :mods

  def initialize(voter_records_req)
    @voter_records_request = voter_records_req
    @request = @voter_records_request['voter_registration']
    @mods = []
    raise ParsingError.new('Invalid input, voter_registration value not found') if @request.nil?
  end

  def convert
    result = {}
    result['batch'] = "0"
    result['FirstName'] = read([:name, :first_name], REQUIRED)
    result['MiddleName'] = read([:name, :middle_name])
    result['LastName'] = read([:name, :last_name], REQUIRED)
    result['TitleSuffix'] = read([:name, :title_suffix])

    value = query([:voter_classifications], :type, 'united_states_citizen', :assertion, REQUIRED)
    result['united-states-citizen'] = bool_to_int(value, "united_states_citizen")

    value = query([:voter_classifications], :type, 'eighteen_on_election_day', :assertion, REQUIRED)
    result['eighteen-on-election-day'] = bool_to_int(value, "eighteen_on_election_day")

    result['isnewregistration'] = is_new_registration
    result['name-update'] = name_update
    result['address-update'] = address_update
    result['ispartychange'] = ""
    result['isfederalvoter'] = ""

    # YYYY-MM-DD is expected
    result['DateOfBirth'] = VRToPA.format_date(read([:date_of_birth], REQUIRED), "date_of_birth")
    result['Gender'] = parse_gender(read([:gender]))
    result['Ethnicity'] = parse_race(read([:race]))

    result['Phone'] = phone


    result['Email'] = email
    result['streetaddress'] = street_address
    result['streetaddress2'] = ""
    #result['unittype'] = read([:registration_address, :numbered_thoroughfare_address, :complete_sub_address, :sub_address_type])
    # 'unittype' in the JSON is always "APT" - it's not actaully collected, so we expect
    # that the user will actually enter in "Apt" as part of the unit number and don't
    # want duplicate data going through
    result['unittype'] = ''
    result['unitnumber'] = unitnumber

    result['municipality'] = municipality(:registration_address)
    result['city'] = municipality(:registration_address)

    result['zipcode'] = zip_code(:registration_address)
    result['donthavePermtOrResAddress'] = ''
    result['county'] = query([:registration_address, :numbered_thoroughfare_address, :complete_place_names],
                             :place_name_type, 'County', :place_name_value, REQUIRED)


    has_mailing_address = read([:registration_address_is_mailing_address]) == false
    if has_mailing_address
      result['mailingaddress'] = read([:mailing_address, :numbered_thoroughfare_address, :complete_street_name])
      result['mailingcity'] = municipality(:mailing_address)
      result['mailingstate'] = read([:mailing_address, :numbered_thoroughfare_address, :state])
      result['mailingzipcode'] = zip_code(:mailing_address)
    else
      result['mailingaddress'] = ''
      result['mailingcity'] = ''
      result['mailingstate'] = ''
      result['mailingzipcode'] = ''
    end

    result['drivers-license'] = drivers_license

    result['ssn4'] = ssn4
    result['signatureimage'] = readsignature
    result['continueAppSubmit'] = "1"
    result['donthavebothDLandSSN'] = dont_have_both_ids

    result['politicalparty'] = party[:politicalparty]
    result['otherpoliticalparty'] = party[:otherpoliticalparty]
    result['needhelptovote'] = ""
    result['typeofassistance'] = ""

    result['preferredlanguage'] = query([:additional_info], :name, 'preferred_language', :string_value)

    result['voterregnumber'] = ""

    result['previousreglastname'] = prev_last_name
    result['previousregfirstname'] = prev_first_name
    result['previousregmiddlename'] = prev_middle_name

    result['previousregaddress'] = prev_reg_address
    result['previousregcity'] = prev_reg_city
    result['previousregstate'] = prev_reg_state
    result['previousregzip'] = prev_reg_zip

    result['previousregcounty'] = prev_reg_county
    
    result['previousregyear'] = ""
    result['declaration1'] = "1"
    
    result['assistedpersonname'] = assisted_person_name
    result['assistedpersonAddress'] = assisted_person_address
    result['assistedpersonphone'] = assisted_person_phone
    result['assistancedeclaration2'] = any_assitant_declaration
    validate_assisted_person_data(result)
    result['ispollworker'] = ""
    result['bilingualinterpreter'] = ""
    result['pollworkerspeaklang'] = ""
    result['secondEmail'] = ""

    # Removed from PA API:
    # result['sendcopyinmail'] = send_copy_in_mail || send_copy_in_mail2

    return [result, self.mods]
  end

  def is_new_registration_boolean
    empty_prev_reg = is_empty(read([:previous_registration_address]))
    empty_prev_name = is_empty(read([:previous_name]))
    prev_state = read("previous_registration_address.numbered_thoroughfare_address.state")
    prev_state_outside_pa = !empty_prev_reg && prev_state.is_a?(String) && prev_state != "PA"
    return (empty_prev_reg && empty_prev_name) || prev_state_outside_pa
  end

  def is_new_registration
     is_new_registration_boolean ? "1" : "0"
  end

  def send_copy_in_mail
    value = query([:voter_classifications], :type, 'send_copy_in_mail', :assertion)
    value = false if is_empty(value)
    bool_to_int(value, "send_copy_in_mail")
  end

  # we don't know where it can come from
  def send_copy_in_mail2
    value = query([:additional_info], :name, 'send_copy_in_mail', :string_value)
    value = false if is_empty(value)
    bool_to_int(value, "send_copy_in_mail")
  end

  def phone(section = nil)
    value = query([section, :contact_methods].compact, :type, 'phone', :value)
    is_empty(value) ? "" : PhoneFormatter.process(value)
  rescue PhoneFormatter::InvalidPhoneNumber => e
    self.mods << "Invalid #{section} Phone \"#{value}\" removed from PA Submission"
    if section == :registration_helper # For helper, we need data here because it may be required by PA but not validated
      return value
    else     
      return ""
    end
  end

  def prev_reg_county
    is_new_registration_boolean ? nil : query([:previous_registration_address, :numbered_thoroughfare_address, :complete_place_names],
                                          :place_name_type, 'County', :place_name_value)
  end

  def prev_reg_zip
    is_new_registration_boolean ? nil : zip_code(:previous_registration_address, address_update == "1")
  end

  def prev_reg_state
    is_new_registration_boolean ? nil : read([:previous_registration_address, :numbered_thoroughfare_address, :state])
  end

  def prev_reg_city
    is_new_registration_boolean ? "" : municipality(:previous_registration_address, address_update == "1")
  end

  def prev_reg_address
    is_new_registration_boolean ? nil : read([:previous_registration_address, :numbered_thoroughfare_address, :complete_street_name], address_update == "1")
  end

  def address_update
    is_new_registration_boolean ? "0" : (is_empty(read([:previous_registration_address])) ? "0" : "1")
  end

  def prev_middle_name
    is_new_registration_boolean ? nil : read([:previous_name, :middle_name])
  end

  def prev_first_name
    is_new_registration_boolean ? nil : read([:previous_name, :first_name], name_update == "1")
  end

  def prev_last_name
    is_new_registration_boolean ? nil : read([:previous_name, :last_name], name_update == "1")
  end

  def name_update
    is_empty(read([:previous_name])) ? "0" : "1"
  end

  def zip_code(section, is_required=true)
    v = safe_strip(read([section, :numbered_thoroughfare_address, :zip_code], is_required))
    if is_empty(v) || v =~ /^\d{5}(-\d{4})?$/
      v
    else
      raise ParsingError.new("Invalid ZIP code \"#{v}\". Expected format is NNNNN or NNNNN-NNNN")
    end
  end

  def municipality(section, is_required=REQUIRED)
    query(
        [section, :numbered_thoroughfare_address, :complete_place_names],
        :place_name_type, 'MunicipalJurisdiction', :place_name_value, is_required)
  end

  def street_address
    join_non_empty([
                       read([:registration_address, :numbered_thoroughfare_address, :complete_address_number]),
                       read([:registration_address, :numbered_thoroughfare_address, :complete_street_name], REQUIRED)
                   ], ' ')
  end
  
  def unitnumber
    un = read([:registration_address, :numbered_thoroughfare_address, :complete_sub_address, :sub_address])
    un = un.to_s
    valid = un.length <= 15
    raise ParsingError.new("Unit number must be 15 characters or less. #{un} is #{un.length} characters") unless valid
    un
  end

  def drivers_license
    dl = query([:voter_ids], :type, 'drivers_license', :string_value)
    dl = "" if is_empty(dl)
    dl = dl.to_s.strip.gsub(/[^\d]/,'')
    valid = dl == "" || dl =~ /^\d{8}$/
    raise ParsingError.new("Invalid drivers licence value \"%s\": 8 digits are expected" % dl) unless valid
    dl
  end

  def read(keys, required=false)
    keys = keys.split(".") if keys.is_a? String
    value = @request
    keys.each do |key|
      break if value.nil?
      value = value[key.to_s]
      raise ParsingError.new("Required value #{keys.join('.')} not found") if required && is_empty(value)
    end
    value
  end

  def readsignature
    data = read([:signature, :image])
    type = read([:signature, :mime_type])
    
    if !is_empty(data)
      data = process_signature(data)
      return "data:#{type};base64,#{data}"
    else
      return ""
    end

  end

  SIG_WIDTH = 180
  SIG_HEIGHT = 60
  def process_signature(base64data)
    image_blob = ActiveSupport::Base64.decode64(base64data)
    src = Tempfile.new('src')
    dst = Tempfile.new('dst')
    begin
      src.binmode
      src.write(image_blob)
      src.close
      wh = `identify -format "%wx%h" #{src.path}`
      if wh !="#{SIG_WIDTH}x#{SIG_HEIGHT}"
        dst.close
        #  -background skyblue -extent 100x60
        cmd = "convert #{src.path} -background white -extent #{SIG_WIDTH}x#{SIG_HEIGHT} #{dst.path}"
        `#{cmd}`
        dst.open
        dst.binmode
        converted = dst.read
        converted64 = ActiveSupport::Base64.encode64(converted)
        self.mods << "Converted #{wh} image to #{SIG_WIDTH}x#{SIG_HEIGHT}"
        return converted64.gsub("\n",'')
      else
        return base64data
      end
    ensure
       src.close
       src.unlink   # deletes the temp file
       dst.close
       dst.unlink   # deletes the temp file
    end
  end

  def query(keys, key, value, output, required=false)
    objects = read(keys, required) || []
    raise ParsingError.new("Array is expected #{objects.class.name} found") unless objects.is_a? Array
    result = objects.find { |obj| obj[key.to_s] == value }
    raise ParsingError.new("Not found #{key} == #{value} in #{objects}") if is_empty(result) && required
    result ? result[output.to_s] : ""
  end

  def str_to_bool(v, error_field_name = "")
    case v
      when "true"
        true
      when "false"
        false
      else
        if error_field_name != ""
          raise ParsingError.new("Invalid string value: \"#{v}\" for #{error_field_name}. Expected: \"true\" or \"false\"")
        else
          false
        end
    end
  end

  def bool_to_int(v, error_field_name = "")
    raise ParsingError.new("Boolean expected, #{v.class.name} found (#{error_field_name} #{v})") unless is_bool(v)
    v ? "1" : "0"
  end

  def is_bool(v)
    [true, false].include?(v)
  end

  def parse_gender(gender)
    return 'M' if gender.to_s.downcase.strip == 'male'
    return 'F' if gender.to_s.downcase.strip == 'female'
    return ''
  end

  def is_empty(value)
    [nil, {}, "", []].include?(value)
  end

  RACE_RULES =
      {
          "american indian / alaskan native" => "I",
          "asian / pacific islander" => "A",
          "black (not hispanic)" => "B",
          "hispanic" => "H",
          "white (not hispanic)" => "W",
          "other" => "O"
      }

  def parse_race(race)
    RACE_RULES[race.to_s.downcase.strip] || ""
  end

  PARTIES_NAMES = {
      "democratic" => "D",
      "republican" => "R",
      "green"      => "GR",
      "libertarian"=> "LN",
      "none" => "NF"
  }

  def party
    @party ||= begin
      name = read([:party], REQUIRED)
      v = PARTIES_NAMES[name.to_s.downcase.strip]
      v ? {politicalparty: v, otherpoliticalparty: ""} : {politicalparty: "OTH", otherpoliticalparty: name}
    end
  end

  def email
    v = safe_strip(query([:contact_methods], :type, 'email', :value))
    if is_empty(v)
      ""
    else
      valid = v.is_a?(String) && v =~ /^[^\s@]+@[^\s@]+\.[\w]{2,}$/
      if valid #ParsingError.new("Invalid e-mail value \"#{v}\".") unless valid
        return v
      else
        self.mods << "Invalid email \"#{v}\" removed from PA submission."
        return ""
      end
    end
  end

  def ssn4
    v = safe_strip(query([:voter_ids], :type, 'ssn4', :string_value))
    if is_empty(v)
      ""
    else
      valid = v.is_a?(String) && v =~ /^\d{4}$/
      raise ParsingError.new("Invalid SSN4 value \"#{v}\", expected: 4 digits value") unless valid
      v
    end
  end

  def no_such_voter_id(type)
    v = query([:voter_ids], :type, type, :attest_no_such_id)
    v_val = query([:voter_ids], :type, type, :string_value)
    return '1' if is_empty(v_val)
    raise ParsingError.new("Wrong attest_no_such_id value for #{type}: \"#{v}\"") if is_empty(v) || !is_bool(v)

    bool_to_int(v)
  end

  def any_assitant_declaration
    [assistant_declaration, assistance_declaration2].max
  end

  def assistant_declaration
    value = query([:additional_info], :name, 'assistant_declaration', :string_value)
    value = str_to_bool(value)
    bool_to_int(value)
  end

  def assistance_declaration2
    value = query([:additional_info], :name, 'assistance_declaration2', :boolean_value)
    value = false if value == ""
    bool_to_int(value)
  end
  
  def validate_assisted_person_data(result)
    if result['assistancedeclaration2'] == '1'
      if is_empty(result['assistedpersonname']) || is_empty(result['assistedpersonAddress']) || is_empty(result['assistedpersonphone'])
        result['assistancedeclaration2'] = '0'
        self.mods << "Assistance declaration changed to FALSE in submission to PA due to missing assistant data"
      end
    end
  end

  def dont_have_both_ids
    v = no_such_voter_id('ssn4') == '1' &&
        no_such_voter_id('drivers_license') == '1'
    if v
      [ssn4: ssn4, drivers_license: drivers_license].each do |name, id|
        raise ParsingError.new("Non empty #{name} when attest_no_such_id == true") unless is_empty(id)
      end
      "1"
    else
      "0"
    end
  end

  def assisted_person_name
    name = read("registration_helper.name")
    return "" if is_empty(name)
    if any_assitant_declaration.to_s != "1"
      self.mods << "Removed assistant name \"#{name}\" in submission to PA due to missing assistant declaration."
      return "" 
    end
    parts = %w(first_name middle_name last_name title_suffix)
    join_non_empty(parts.map { |k| name[k] }, ' ')
  end

  def assisted_person_address
    address = read "registration_helper.address.numbered_thoroughfare_address"
    return "" if is_empty(address)
    if any_assitant_declaration.to_s != "1"
      self.mods << "Removed assistant address \"#{address}\"in submission to PA due to missing assistant declaration."
      return "" 
    end

    line1 = join_non_empty([address["complete_address_number"], address["complete_street_name"]], ' ')
    city = query(
        "registration_helper.address.numbered_thoroughfare_address.complete_place_names",
        :place_name_type, 'MunicipalJurisdiction', :place_name_value)
    state = address["state"]
    zip_code = address["zip_code"]
    line2 = join_non_empty([city, state, zip_code], " ")

    join_non_empty([line1, line2], ", ")
  end

  def assisted_person_phone
    assistant_phone = phone(:registration_helper)
    return "" if is_empty(assistant_phone)
    if any_assitant_declaration.to_s != "1"
      self.mods << "Removed assistant phone \"#{assistant_phone}\" in submission to PA due to missing assistant declaration."
      return "" 
    end
    assistant_phone
  end

  def join_non_empty(objects, separator)
    objects.reject { |v| is_empty(v) }.join(separator)
  end

  def self.format_date(value, error_field_name=nil)
    # Date.parse(value).strftime("%m/%d/%Y")
    Date.parse(value).strftime("%Y-%m-%d")
  rescue ArgumentError => e
    if error_field_name.nil?
      ""
    else
      raise ParsingError.new("Invalid date value \"#{value}\" for \"#{error_field_name}\", #{e.message}")
    end
  end

  def safe_strip(value)
    if value.respond_to? :strip
      value.strip
    else
      value
    end
  end
end
