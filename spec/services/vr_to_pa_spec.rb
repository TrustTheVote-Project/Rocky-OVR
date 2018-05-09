# used to run only this spec:
#require File.expand_path('../../../app/services/vr_to_pa', __FILE__)
#require File.expand_path('../../../app/services/phone_formatter', __FILE__)
#require 'date'
require File.dirname(__FILE__) + '/../rails_helper'

describe VRToPA do
  let(:input) { raise 'input is not re-defined' }
  let(:adapter) { VRToPA.new("voter_registration" => input) }
  let(:full_input) do
    {
        "date_of_birth" => "2016-06-16",
        "mailing_address" => {
            "numbered_thoroughfare_address" => {
                "complete_address_number" => "",
                "complete_street_name" => "444 N. Street",
                "complete_sub_address" => [{
                    "sub_address_type" => "APT",
                    "sub_address" => "306"
                }],
                "complete_place_names" => [
                    {
                        "place_name_type" => "MunicipalJurisdiction",
                        "place_name_value" => "Mailing City"
                    },
                    {
                        "place_name_type" => "County",
                        "place_name_value" => "Mailing County"
                    }
                ],
                "state" => "PA1",
                "zip_code" => "33333"
            }
        },
        "previous_registration_address" => {
            "numbered_thoroughfare_address" => {
                "complete_address_number" => "",
                "complete_street_name" => "222 N. Street",
                "complete_sub_address" => [{
                    "sub_address_type" => "APT",
                    "sub_address" => "306"
                }],
                "complete_place_names" => [
                    {
                        "place_name_type" => "MunicipalJurisdiction",
                        "place_name_value" => "Previous City"
                    },
                    {
                        "place_name_type" => "County",
                        "place_name_value" => "Prev County"
                    }
                ],
                "state" => "PA",
                "zip_code" => "22222"
            }
        },
        "registration_address" => {
            "numbered_thoroughfare_address" => {
                "complete_address_number" => "",
                "complete_street_name" => "333 N. Street",
                "complete_sub_address" => [{
                    "sub_address_type" => "APT",
                    "sub_address" => "306"
                }],
                "complete_place_names" => [
                    {
                        "place_name_type" => "MunicipalJurisdiction",
                        "place_name_value" => "Registration City"
                    },
                    {
                        "place_name_type" => "County",
                        "place_name_value" => "Registration County"
                    }
                ],
                "state" => "PA2",
                "zip_code" => "11111"
            }
        },
        "registration_address_is_mailing_address" => false,
        "name" => {
            "first_name" => "Aaron",
            "last_name" => "Huttner",
            "middle_name" => "Bernard",
            "title_prefix" => "Mr",
            "title_suffix" => "Jr"
        },
        "previous_name" => {
            "first_name" => "PFN",
            "last_name" => "PLN",
            "middle_name" => "PMN",
            "title_prefix" => "PTP",
            "title_suffix" => "PTS"
        },
        "gender" => "male",
        "race" => "American Indian / Alaskan Native",
        "party" => 'party_value',
        "voter_classifications" => [
            {
                "type" => "eighteen_on_election_day",
                "assertion" => true
            },
            {
                "type" => "united_states_citizen",
                "assertion" => true
            },
            {
                "type" => "send_copy_in_mail",
                "assertion" => true
            },
            {
                "type" => "agreed_to_declaration",
                "assertion" => true
            }
        ],
        "signature" => {
            "mime_type" => "image/png",
            "image" => "iVBORw0KGgoAAAANSUhEUgAAALQAAAA8CAYAAADPLpCHAAAABHNCSVQICAgIfAhkiAAAALxJREFUeJzt0sEJACAQwDB1/53PJQShJBP00T0zsyDi/A6AlwxNiqFJMTQphibF0KQYmhRDk2JoUgxNiqFJMTQphibF0KQYmhRDk2JoUgxNiqFJMTQphibF0KQYmhRDk2JoUgxNiqFJMTQphibF0KQYmhRDk2JoUgxNiqFJMTQphibF0KQYmhRDk2JoUgxNiqFJMTQphibF0KQYmhRDk2JoUgxNiqFJMTQphibF0KQYmhRDk2JoUgxNiqFJua/tBHRXM+srAAAAAElFTkSuQmCC"
        },
        "voter_ids" => [
            {
                "type" => "drivers_license",
                "string_value" => "12345678",
                "attest_no_such_id" => false
            },
            {
                "type" => "ssn4",
                "string_value" => "1234",
                "attest_no_such_id" => false
            }
        ],
        "contact_methods" => [
            {
                "type" => "phone",
                "value" => "555-555-5555",
                "capabilities" => %w(voice fax sms)
            },
            {
                "type" => "email",
                "value" => "valid@email.value",
                "capabilities" => %w(voice fax sms)
            }
        ],
        "additional_info" => [
            {
                "name" => "preferred_language",
                "string_value" => "English"
            },
            {
                "name" => "assistant_declaration",
                "string_value" => "true"
            }
        ],
        "registration_helper" => {
            "address" => {
                "numbered_thoroughfare_address" => {
                    "complete_address_number" => "55",
                    "complete_street_name" => "Assistant Street",
                    "complete_sub_address" => [{
                        "sub_address_type" => "APT",
                        "sub_address" => "555"
                    }],
                    "complete_place_names" => [
                        {
                            "place_name_type" => "MunicipalJurisdiction",
                            "place_name_value" => "Assistant City"
                        },
                        {
                            "place_name_type" => "County",
                            "place_name_value" => "Helper County"
                        }
                    ],
                    "state" => "Assistant State",
                    "zip_code" => "22222"
                }
            },
            "contact_methods" => [
                {
                    "type" => "phone",
                    "value" => "1234567890",
                    "capabilities" => %w(voice fax sms)
                }
            ],
            "name" => {
                "first_name" => "Assistant",
                "last_name" => "Name"
            }
        }

    }
  end

  describe 'convert' do
    subject { adapter.convert[0] }
    let(:input) { full_input }

    it 'returns all values' do
      expect(subject["Email"]).to eql("valid@email.value")
      expect(subject["ssn4"]).to eql("1234")
      expect(subject["politicalparty"]).to eql("OTH")
      expect(subject["otherpoliticalparty"]).to eql("party_value")
      expect(subject["assistancedeclaration2"]).to eql("1")
      expect(subject["donthavebothDLandSSN"]).to eql("0")
      expect(subject["assistedpersonname"]).to eql("Assistant Name")
      expect(subject["assistedpersonAddress"]).to eql("55 Assistant Street, Assistant City Assistant State 22222")
      expect(subject["assistedpersonphone"]).to eql("123-456-7890")
      expect(subject["city"]).to eql("Registration City")
      expect(subject["mailingcity"]).to eql("Mailing City")
      expect(subject["previousregcity"]).to eql("Previous City")
      expect(subject["zipcode"]).to eql("11111")
      expect(subject["previousregzip"]).to eql("22222")
      expect(subject["mailingzipcode"]).to eql("33333")
      expect(subject["Phone"]).to eql("555-555-5555")
      # Removed from PA
      # expect(subject["sendcopyinmail"]).to eql("1")
      expect(subject["sendcopyinmail"]).to eql(nil)
      expect(subject["isnewregistration"]).to eql("0")

      expect(subject["batch"]).to eql("0")
      expect(subject["FirstName"]).to eql("Aaron")
      expect(subject["MiddleName"]).to eql("Bernard")
      expect(subject["LastName"]).to eql("Huttner")
      expect(subject["united-states-citizen"]).to eql("1")
      expect(subject["eighteen-on-election-day"]).to eql("1")
      expect(subject["name-update"]).to eql("1")
      expect(subject["address-update"]).to eql("1")
      expect(subject["ispartychange"]).to eql("")
      expect(subject["isfederalvoter"]).to eql("")
      expect(subject["DateOfBirth"]).to eql("2016-06-16")
      expect(subject["Gender"]).to eql("M")
      expect(subject["Ethnicity"]).to eql("I")
      expect(subject["streetaddress"]).to eql("333 N. Street")
      expect(subject["streetaddress2"]).to eql("")
      expect(subject["unittype"]).to eql("APT")
      expect(subject["unitnumber"]).to eql("306")
      expect(subject["donthavePermtOrResAddress"]).to eql("")
      expect(subject["county"]).to eql("Registration County")
      expect(subject["municipality"]).to eql("Registration City")
      expect(subject["mailingaddress"]).to eql("444 N. Street, APARTMENT 306")
      expect(subject["mailingcity"]).to eql("Mailing City")
      expect(subject["mailingstate"]).to eql("PA1")
      expect(subject["previousregstate"]).to eql("PA")
      expect(subject["drivers-license"]).to eql("12345678")
      expect(subject["signatureimage"]).to eql("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAALQAAAA8CAYAAADPLpCHAAAABHNCSVQICAgIfAhkiAAAALxJREFUeJzt0sEJACAQwDB1/53PJQShJBP00T0zsyDi/A6AlwxNiqFJMTQphibF0KQYmhRDk2JoUgxNiqFJMTQphibF0KQYmhRDk2JoUgxNiqFJMTQphibF0KQYmhRDk2JoUgxNiqFJMTQphibF0KQYmhRDk2JoUgxNiqFJMTQphibF0KQYmhRDk2JoUgxNiqFJMTQphibF0KQYmhRDk2JoUgxNiqFJMTQphibF0KQYmhRDk2JoUgxNiqFJua/tBHRXM+srAAAAAElFTkSuQmCC")
      expect(subject["continueAppSubmit"]).to eql("1")
      expect(subject["donthavebothDLandSSN"]).to eql("0")
      expect(subject["needhelptovote"]).to eql("")
      expect(subject["typeofassistance"]).to eql("")
      expect(subject["preferredlanguage"]).to eql("English")
      expect(subject["voterregnumber"]).to eql("")
      expect(subject["previousreglastname"]).to eql("PLN")
      expect(subject["previousregfirstname"]).to eql("PFN")
      expect(subject["previousregmiddlename"]).to eql("PMN")
      expect(subject["previousregaddress"]).to eql("222 N. Street, APARTMENT 306")
      expect(subject["previousregcounty"]).to eql("Prev County")
      expect(subject["previousregyear"]).to eql("")
      expect(subject["declaration1"]).to eql("1")
      expect(subject["ispollworker"]).to eql("")
      expect(subject["bilingualinterpreter"]).to eql("")
      expect(subject["pollworkerspeaklang"]).to eql("")
      expect(subject["secondEmail"]).to eql("")
    end
  end

  describe 'email' do
    subject { adapter.email }
    let(:email) { "test@email.com" }
    let(:email2) { "test2@email.com" }

    context 'multiple contact methods' do
      let(:input) do
        {
            "contact_methods" => [
                {
                    "type" => "phone",
                    "value" => "555-555-5555",
                    "capabilities" => %w(voice fax sms)
                },
                {
                    "type" => "email",
                    "value" => email
                }
            ]
        }
      end

      it 'extracts value' do
        expect(subject).to eql(email)
      end
    end

    context 'multiple emails' do
      let(:input) do
        {
            "contact_methods" => [
                {
                    "type" => "email",
                    "value" => email
                },
                {
                    "type" => "email",
                    "value" => email2
                }
            ]
        }
      end

      it 'returns 1st appearance' do
        expect(subject).to eql(email)
      end
    end

    context 'no contact methods' do
      let(:input) { {} }

      it 'returns empty string' do
        expect(subject).to eql ""
      end
    end
  end
  

  describe 'party' do
    context 'custom tests' do
      test_cases =
          {
              "democratic" => {politicalparty: "D", otherpoliticalparty: ""},
              "Democratic" => {politicalparty: "D", otherpoliticalparty: ""},
              " Democratic " => {politicalparty: "D", otherpoliticalparty: ""},
              "republican" => {politicalparty: "R", otherpoliticalparty: ""},
              "Republican" => {politicalparty: "R", otherpoliticalparty: ""},
              "other" => {politicalparty: "OTH", otherpoliticalparty: "other"},
              "Other" => {politicalparty: "OTH", otherpoliticalparty: "Other"},
              "none" => {politicalparty: "NF", otherpoliticalparty: ""},
              "None" => {politicalparty: "NF", otherpoliticalparty: ""},
              "green" => {politicalparty: "GR", otherpoliticalparty: ""},
              "Green" => {politicalparty: "GR", otherpoliticalparty: ""},
              "green2" => {politicalparty: "OTH", otherpoliticalparty: "green2"},
              "Green2" => {politicalparty: "OTH", otherpoliticalparty: "Green2"},
          }

      it 'supports pre defined cases' do
        test_cases.each do |test, er|
          adapter = VRToPA.new("voter_registration" => {"party" => test})
          expect(adapter.party).to eql(er)
        end
      end
    end

    context 'empty input' do
      subject { adapter.party }
      let(:input) { {} }
      it 'raise error' do
        expect { subject }.to raise_error /party/
      end
    end
  end
  
  describe 'parse_gender' do
    let(:input) { full_input }
    context 'if the value is like " MALE " ' do
      it 'returns M' do
        g = "MALE"
        expect(adapter.parse_gender(g)).to eql "M"
        g = " MALE "
        expect(adapter.parse_gender(g)).to eql "M"
        g = " mALE    "
        expect(adapter.parse_gender(g)).to eql "M"
        g = "male"
        expect(adapter.parse_gender(g)).to eql "M"
      end
    end
    context 'if the value is like " FEMALE " ' do
      it 'returns M' do
        g = "FEMALE"
        expect(adapter.parse_gender(g)).to eql "F"
        g = " FEMALE "
        expect(adapter.parse_gender(g)).to eql "F"
        g = " feMALE    "
        expect(adapter.parse_gender(g)).to eql "F"
        g = "female"
        expect(adapter.parse_gender(g)).to eql "F"
      end
    end
    context 'if the value is not like male or female' do
      it 'returns M' do
        g = "FE-MALE"
        expect(adapter.parse_gender(g)).to eql ""
        g = " MALE."
        expect(adapter.parse_gender(g)).to eql ""
        g = ""
        expect(adapter.parse_gender(g)).to eql ""
        g = nil
        expect(adapter.parse_gender(g)).to eql ""
      end
    end
    
  end  
  describe 'assistant_declaration' do
    subject { adapter.assistant_declaration }
    context 'no additional info' do
      let(:input) { {} }
      it 'default 0' do
        expect(subject).to eql "0"
      end
    end
    context 'no assistant_declaration info' do
      let(:input) { {"additional_info" => [{"name" => "n1", "string_value" => "s1"}]} }
      it 'default 0' do
        expect(subject).to eql "0"
      end
    end

    context 'assistant_declaration info set to true ' do
      let(:input) { {"additional_info" => [{"name" => "assistant_declaration", "string_value" => "true"}]} }
      it '== 1' do
        expect(subject).to eql "1"
      end
    end

    context 'assistant_declaration info set to false ' do
      let(:input) { {"additional_info" => [{"name" => "assistant_declaration", "string_value" => "false"}]} }
      it '== 0' do
        expect(subject).to eql "0"
      end
    end

    context 'assistant_declaration invalid info  ' do
      let(:input) { {"additional_info" => [{"name" => "assistant_declaration", "another_value" => 42}]} }
      it 'default 0' do
        expect { subject }.not_to raise_error
      end
    end
  end
  describe 'assistance_declaration validation' do
    subject { adapter.convert[0] }
    context 'when declaration is true' do
      let(:input) { full_input }
      before(:each) do
        input["additional_info"] = [{"name" => "assistant_declaration", "string_value" => "true"}]
        input["registration_helper"]["name"] = {}
      end
      it 'sets it to false' do
        expect(subject["assistancedeclaration2"]).to eq("0")
      end
    end
    context 'when declaration is false' do
      let(:input) { full_input }
      before(:each) do
        input["additional_info"] = [{"name" => "assistant_declaration", "string_value" => "false"}]
        input["registration_helper"] = {
            "address" => {
                "numbered_thoroughfare_address" => {
                    "complete_address_number" => "1",
                    "complete_street_name" => "Street",
                    "complete_sub_address" => [{
                        "sub_address_type" => "APT",
                        "sub_address" => "100"
                    }],
                    "complete_place_names" => [
                        {
                            "place_name_type" => "MunicipalJurisdiction",
                            "place_name_value" => "City"
                        },
                        {
                            "place_name_type" => "County",
                            "place_name_value" => "County"
                        }
                    ],
                    "state" => "State",
                    "zip_code" => "22222"
                }
            }
        }
      end
      it "returns a result with empty assistant data" do
        expect(subject["assistedpersonname"]).to eq("")
        expect(subject["assistedpersonAddress"]).to eq("")
        expect(subject["assistedpersonphone"]).to eq("")
      end
    end


  end
  describe 'dont_have_both_DL_and_SSN' do
    subject { adapter.dont_have_both_ids }
    context 'no DL and SSN' do
      let(:input) do
        {
            "voter_ids" => [
                {
                    "type" => "drivers_license",
                    "attest_no_such_id" => true
                },
                {
                    "type" => "ssn4",
                    "attest_no_such_id" => true
                }
            ]
        }
      end

      it "1" do
        expect(subject).to eql("1")
      end
    end

    context 'no DL and there is SSN' do
      let(:input) do
        {
            "voter_ids" => [
                {
                    "type" => "drivers_license",
                    "attest_no_such_id" => true
                },
                {
                    "type" => "ssn4",
                    "string_value" => "1234",
                    "attest_no_such_id" => false
                }
            ]
        }
      end

      it "0" do
        expect(subject).to eql("0")
      end
    end

    context 'there is DL and no SSN' do
      let(:input) do
        {
            "voter_ids" => [
                {
                    "type" => "drivers_license",
                    "string_value" => "12345678",
                    "attest_no_such_id" => false
                },
                {
                    "type" => "ssn4",
                    "attest_no_such_id" => true
                }
            ]
        }
      end

      it "0" do
        expect(subject).to eql("0")
      end
    end

    context 'there is DL and no entire SSN record' do
      let(:input) do
        {
            "voter_ids" => [
                {
                    "type" => "drivers_license",
                    "string_value" => "123456",
                    "attest_no_such_id" => false
                }
            ]
        }
      end

      it "raises en error " # do
      #   expect { subject }.to raise_error(VRToPA::ParsingError)
      # end
    end
  end
  describe 'assisted_person_name' do
    subject { adapter.assisted_person_name }
    context 'full name provided' do
      let(:input) do
        {
            "additional_info" => [{"name" => "assistant_declaration", "string_value" => "true"}],
            "registration_helper" => {
                "name" => {
                    "first_name" => "FN",
                    "last_name" => "LN",
                    "middle_name" => "MN",
                    "title_prefix" => "Ms",
                    "title_suffix" => "III"
                }
            }
        }
      end
      it 'loads full name without title prefix' do
        expect(subject).to eql('FN MN LN III')
      end
    end
    context 'minimalistic name provided' do
      let(:input) do
        {
          "additional_info" => [{"name" => "assistant_declaration", "string_value" => "true"}],
          "registration_helper" => {
                "name" => {
                    "first_name" => "FN",
                    "last_name" => "LN"
                }
            }
        }
      end
      it 'loads full name' do
        expect(subject).to eql('FN LN')
      end
    end
  end
  describe 'assisted_person_address' do
    subject { adapter.assisted_person_address }
    context 'full address defined' do
      let(:input) do
        {
          "additional_info" => [{"name" => "assistant_declaration", "string_value" => "true"}],
          "registration_helper" => {
                "address" => {
                    "numbered_thoroughfare_address" => {
                        "complete_address_number" => "1",
                        "complete_street_name" => "Street",
                        "complete_sub_address" => [{
                            "sub_address_type" => "APT",
                            "sub_address" => "100"
                        }],
                        "complete_place_names" => [
                            {
                                "place_name_type" => "MunicipalJurisdiction",
                                "place_name_value" => "City"
                            },
                            {
                                "place_name_type" => "County",
                                "place_name_value" => "County"
                            }
                        ],
                        "state" => "State",
                        "zip_code" => "22222"
                    }
                }
            }
        }
      end
      it 'loads full address' do
        expect(subject).to eql('1 Street, City State 22222')
      end
    end
  end

  describe 'assisted_person_phone' do
    subject { adapter.assisted_person_phone }
    context 'phone is defined' do
      let(:input) do
        {
          "additional_info" => [{"name" => "assistant_declaration", "string_value" => "true"}],
          "registration_helper" => {
                "contact_methods" => [
                    {
                        "type" => "phone",
                        "value" => "555-555-5555",
                        "capabilities" => %w(voice fax sms)
                    }
                ]
            }
        }
      end

      it 'loads phone number' do
        expect(subject).to eql('555-555-5555')
      end
    end
  end

  describe 'assisted_person_info' do
    subject { adapter }
    context 'data not provided' do
      let(:input) { {} }

      it 'loads nothing' do
        expect(subject.assisted_person_name).to eql ""
        expect(subject.assisted_person_address).to eql ""
        expect(subject.assisted_person_phone).to eql ""
      end
    end
  end

  describe 'street_address' do
    subject { adapter.street_address }
    context 'empty address' do
      let(:input) { {} }
      it 'raises error' do
        expect { subject }.to raise_error /complete_street_name/
      end
    end
  end
  
  describe 'unit' do
    subject { adapter.convert[0] }
    context 'old format' do 
      let(:input) { full_input.merge({
        "registration_address" => {
            "numbered_thoroughfare_address" => {
                "complete_address_number" => "",
                "complete_street_name" => "333 N. Street",
                "complete_sub_address" => {
                    "sub_address_type" => "APT",
                    "sub_address" => "Apt 306"
                },
                "complete_place_names" => [
                    {
                        "place_name_type" => "MunicipalJurisdiction",
                        "place_name_value" => "Registration City"
                    },
                    {
                        "place_name_type" => "County",
                        "place_name_value" => "Registration County"
                    }
                ],
                "state" => "PA2",
                "zip_code" => "11111"
            }
        }
      }) }
      it "popultates unit and unit type" do
        expect(subject["unittype"]).to eq("APT")
        expect(subject["unitnumber"]).to eq("Apt 306")
      end
    end
    context 'new format' do 
      let(:input) { full_input.merge({
        "registration_address" => {
            "numbered_thoroughfare_address" => {
                "complete_address_number" => "",
                "complete_street_name" => "333 N. Street",
                "complete_sub_address" => [{
                  "sub_address_type" => "UNI ",
                  "sub_address" => " 5E"
                }],
                "complete_place_names" => [
                    {
                        "place_name_type" => "MunicipalJurisdiction",
                        "place_name_value" => "Registration City"
                    },
                    {
                        "place_name_type" => "County",
                        "place_name_value" => "Registration County"
                    }
                ],
                "state" => "PA2",
                "zip_code" => "11111"
            }
        }
      }) }
      it "popultates unit and unit type" do
        expect(subject["unittype"]).to eq("UNI")
        expect(subject["unitnumber"]).to eq("5E")
      end
    end
  end
  
  describe 'street_address_2' do
    subject { adapter.convert[0]["streetaddress2"] }
    context 'empty address' do
      let(:input) { full_input }
      it 'returns a blank' do
        expect(subject).to eq("")
      end
    end
    context "request only inclues unit number" do
      context "old format" do
        let(:input) { full_input.merge({
          "registration_address" => {
              "numbered_thoroughfare_address" => {
                  "complete_address_number" => "",
                  "complete_street_name" => "444 N. Street",
                  "complete_sub_address" => {
                      "sub_address_type" => "APT",
                      "sub_address" => "306"
                  },
                  "complete_place_names" => [
                      {
                          "place_name_type" => "MunicipalJurisdiction",
                          "place_name_value" => "Registration City"
                      },
                      {
                          "place_name_type" => "County",
                          "place_name_value" => "Registration County"
                      }
                  ],
                  "state" => "PA2",
                  "zip_code" => "11111"                  
              }
          }        
        }) }
        it "return a blank" do
          expect(subject).to eq("")
        end
      end
      context "new format" do
        let(:input) { full_input.merge({
          "registration_address" => {
              "numbered_thoroughfare_address" => {
                  "complete_address_number" => "",
                  "complete_street_name" => "444 N. Street",
                  "complete_sub_address" => [{
                    "sub_address_type" => "UNI",
                    "sub_address" => "306"
                  }],
                  "complete_place_names" => [
                      {
                          "place_name_type" => "MunicipalJurisdiction",
                          "place_name_value" => "Registration City"
                      },
                      {
                          "place_name_type" => "County",
                          "place_name_value" => "Registration County"
                      }
                  ],
                  "state" => "PA2",
                  "zip_code" => "11111"
              }
          }        
        }) }
        it "return a blank" do
          expect(subject).to eq("")
        end
      end
    end
    context "includes a LINE2" do
      let(:input) { full_input.merge({
        "registration_address" => {
            "numbered_thoroughfare_address" => {
                "complete_address_number" => "",
                "complete_street_name" => "444 N. Street",
                "complete_sub_address" => [{
                    "sub_address_type" => "FLR",
                    "sub_address" => "3rd"
                    }, {
                     "sub_address_type"=>"LINE2",
                     "sub_address" =>" my line 2 " 
                    }
                ],
                "complete_place_names" => [
                    {
                        "place_name_type" => "MunicipalJurisdiction",
                        "place_name_value" => "Registration City"
                    },
                    {
                        "place_name_type" => "County",
                        "place_name_value" => "Registration County"
                    }
                ],
                "state" => "PA2",
                "zip_code" => "11111"
            }
        }        
      }) }
      it "return a stripped value" do
        expect(subject).to eq("my line 2")
      end
    end
    
  end
  describe 'unitnumber' do
    subject { adapter.convert }
    context 'too long input' do
      let(:input) { full_input }
      before(:each) do
        input["registration_address"]["numbered_thoroughfare_address"]["complete_sub_address"][0]["sub_address"] = "1234567890123456"
      end
      it 'raises error' do
        
        expect { subject }.to raise_error /must be 15 characters/i
      end
    end
  end
  
  describe 'municipality' do
    context "empty municipality" do
      subject { adapter.municipality(:registration_address) }
      let(:input) { {} }
      it 'raises error' do
        expect { subject }.to raise_error /complete_place_names/
      end
    end
    context "non empty municipality" do
      subject { adapter.municipality(:registration_address) }
      let(:input) do
        {
            "registration_address" => {
                "numbered_thoroughfare_address" => {
                    "complete_address_number" => "",
                    "complete_street_name" => "801 N. Monroe",
                    "complete_sub_address" => [{
                        "sub_address_type" => "APT",
                        "sub_address" => "306"
                    }],
                    "complete_place_names" => [
                        {
                            "place_name_type" => "MunicipalJurisdiction",
                            "place_name_value" => "Philadelphia"
                        }
                    ]
                }
            }
        }
      end
      it 'raises error' do
        expect { subject }.not_to raise_error
        expect(subject).to eql('Philadelphia')
      end
    end
  end

  describe "zip_code" do
    subject { adapter.zip_code(:registration_address) }
    context "empty input" do
      let(:input) { {} }
      it "raises error" do
        expect { subject }.to raise_error /zip_code not found/
      end
    end
  end

  describe 'format_date' do
    let(:field_name) { nil }
    let(:date_string) { nil }

    subject do
      raise "date_string must be redefined" if date_string.nil?
      if field_name.nil?
        VRToPA.format_date(date_string)
      else
        VRToPA.format_date(date_string, field_name)
      end
    end

    context "required field" do
      let(:field_name) { "uniq_field_name" }

      context "invalid date_string value" do
        let(:date_string) { "aaa" }
        it "raises field-related error" do
          expect { subject }.to raise_error /uniq_field_name/
        end
      end


      context "valid date_string value" do
        let(:date_string) { "1999-12-31" }

        it 'no error' do
          expect { subject }.not_to raise_error
        end
        it 'valid value' do
          expect(subject).to eql(date_string)
        end
      end
    end

    context 'not required field' do
      context 'invalid date_string value' do
        let(:date_string) { "aaa" }

        it 'no error' do
          expect { subject }.not_to raise_error
        end
        it 'empty' do
          expect(subject).to be_empty
        end
      end

      context 'valid date_string value' do
        let(:date_string) { "2000-12-31" }

        it 'no error' do
          expect { subject }.not_to raise_error
        end
        it 'valid value' do
          expect(subject).to eql("2000-12-31")
        end
      end

    end
  end

  describe "prev names" do
    subject { [adapter.prev_first_name, adapter.prev_last_name, adapter.prev_middle_name] }

    context "empty input" do
      let(:input) { {} }
      it "returns nothing" do
        expect(subject).to eql [nil, nil, nil]
      end
    end

    context "full input" do
      let(:input) do
        {
            "previous_name" => {
                "first_name" => "fn",
                "last_name" => "ln",
                "middle_name" => "mn",
            }
        }
      end
      it "returns nothing" do
        expect(subject).to eql %w(fn ln mn)
      end
    end

    context "partly empty input" do
      let(:input) do
        {
            "previous_name" => {
                "first_name" => "fn"
            }
        }
      end

      it "raise error" do
        expect { subject }.to raise_error /last_name/
      end
    end
  end
  describe "mailing_address" do
    subject { adapter.convert[0] }
    context "with unit and line2 subaddress" do
      let(:input) do
        full_input.merge({"mailing_address" => {
            "numbered_thoroughfare_address" => {
                "complete_address_number" => "",
                "complete_street_name" => "222 N. Street",
                "complete_sub_address" => [{
                    "sub_address_type" => "SKIPPED",
                    "sub_address" => "F"
                },
                {
                    "sub_address_type" => "APT",
                    "sub_address" => "111"
                },
                {
                    "sub_address_type" => "LINE2",
                    "sub_address" => "Line2 Content"
                }],
                "complete_place_names" => [
                    {
                        "place_name_type" => "MunicipalJurisdiction",
                        "place_name_value" => "Previous City"
                    },
                    {
                        "place_name_type" => "County",
                        "place_name_value" => "Prev County"
                    }
                ],
                "state" => "PA",
                "zip_code" => "22222"
            }
        }})
      end
      it "returns an address with unit and line2 content" do
        expect(subject["mailingaddress"]).to eq("222 N. Street, APARTMENT 111\nLine2 Content")        
      end
      
    end
    context "without subaddres" do
      let(:input) do
        full_input.merge({"mailing_address" => {
            "numbered_thoroughfare_address" => {
                "complete_address_number" => "",
                "complete_street_name" => "222 N. Street",
                "complete_sub_address" => [{
                    "sub_address_type" => "SKIPPED",
                    "sub_address" => "F"
                },
                {
                    "sub_address_type" => "APT",
                    "sub_address" => "111"
                },
                {
                    "sub_address_type" => "LINE2",
                    "sub_address" => "Line2 Content"
                }],
                "complete_place_names" => [
                    {
                        "place_name_type" => "MunicipalJurisdiction",
                        "place_name_value" => "Previous City"
                    },
                    {
                        "place_name_type" => "County",
                        "place_name_value" => "Prev County"
                    }
                ],
                "state" => "PA",
                "zip_code" => "22222"
            }
        }})
      end
      it "returns an address without unit and line2 content" do
        expect(subject["mailingaddress"]).to eq("222 N. Street, APARTMENT 111\nLine2 Content")        
      end
    end
  end

  describe "prev_reg_address" do
    context "empty input" do
      let(:input) { {} }
      it "return empty" do
        expect(adapter.prev_reg_address).to be_nil
        expect(adapter.prev_reg_city).to eql ""
        expect(adapter.prev_reg_state).to be_nil
        expect(adapter.prev_reg_zip).to be_nil
      end
    end
    context "partly empty input" do
      let(:input) { {"previous_registration_address" => {"not_empty" => "value"}} }
      it "raise error (except state)" do
        expect { adapter.prev_reg_address }.to raise_error
        expect { adapter.prev_reg_city }.to raise_error
        expect { adapter.prev_reg_state }.not_to raise_error
        expect { adapter.prev_reg_zip }.to raise_error
      end
    end
    context "line 2 and unit input" do
      subject { adapter.convert[0] }
      let(:input) do
        full_input.merge({"previous_registration_address" => {
            "numbered_thoroughfare_address" => {
                "complete_address_number" => "",
                "complete_street_name" => "222 N. Street",
                "complete_place_names" => [
                    {
                        "place_name_type" => "MunicipalJurisdiction",
                        "place_name_value" => "Previous City"
                    },
                    {
                        "place_name_type" => "County",
                        "place_name_value" => "Prev County"
                    }
                ],
                "state" => "PA",
                "zip_code" => "22222"
            }
        }})
      end
      it "returns an address with unit and line2 content" do
        expect(subject["previousregaddress"]).to eq("222 N. Street")        
      end
    end
    context "is new registration" do
      let(:input){ 
        {
          "previous_registration_address" => {
              "numbered_thoroughfare_address" => {
                  "complete_address_number" => "",
                  "complete_street_name" => "222 N. Street",
                  "complete_sub_address" => [{
                      "sub_address_type" => "APT",
                      "sub_address" => "306"
                  }],
                  "complete_place_names" => [
                      {
                          "place_name_type" => "MunicipalJurisdiction",
                          "place_name_value" => "Previous City"
                      },
                      {
                          "place_name_type" => "County",
                          "place_name_value" => "Prev County"
                      }
                  ],
                  "state" => "PA",
                  "zip_code" => "22222"
              }
          },
        }
      }
      it "returns blank prev-reg when is_new_registration" do
        allow(adapter).to receive(:is_new_registration_boolean).and_return(true)
        expect(adapter.prev_reg_address).to be_nil
        expect(adapter.prev_reg_city).to eql ""
        expect(adapter.prev_reg_state).to be_nil
        expect(adapter.prev_reg_zip).to be_nil 
        expect(adapter.address_update).to eql("0")       
      end
    end
  end

  describe "phone" do
    subject { adapter.phone }

    context "empty phone" do
      let(:input) { {} }
      it "returns nothing" do
        expect(subject).to eql("")
      end
    end

    context "valid phone" do
      let(:input) do
        {
            "contact_methods" => [
                {
                    "type" => "phone",
                    "value" => "+1-555-555-5555",
                    "capabilities" => %w(voice fax sms)
                }
            ]
        }
      end
      it "returns formatted phone" do
        expect(subject).to eql("555-555-5555")
      end
    end

    context "invalid phone" do
      let(:input) do
        {
            "contact_methods" => [
                {
                    "type" => "phone",
                    "value" => "+5-555-555",
                    "capabilities" => %w(voice fax sms)
                }
            ]
        }
      end
      it "removes phone" do
        expect(subject).to eql("")
      end
    end
  end

  describe "drivers_license" do
    subject { adapter.drivers_license }
    context "empty input" do
      let(:input) { {} }
      it "empty" do
        expect(subject).to eql ""
      end
    end

    context "valid DL" do
      let(:input) do
        {
            "voter_ids" => [
                {
                    "type" => "drivers_license",
                    "string_value" => "1234-5678",
                    "attest_no_such_id" => false
                }
            ]
        }
      end
      it "empty" do
        expect(subject).to eql "12345678"
      end
    end

    context "invalid DL" do
      let(:input) do
        {
            "voter_ids" => [
                {
                    "type" => "drivers_license",
                    "string_value" => "123-45678-9",
                    "attest_no_such_id" => false
                }
            ]
        }
      end
      it "raises error" do
        expect { subject }.to raise_error
      end
    end
  end

  describe "SSN4" do
    subject { adapter.ssn4 }
    context "empty input" do
      let(:input) { {} }
      it "empty" do
        expect(subject).to eql("")
      end
    end

    context "valid input" do
      let(:input) do
        {
            "voter_ids" => [
                {
                    "type" => "ssn4",
                    "string_value" => "  1234  ",
                    "attest_no_such_id" => false
                }
            ]
        }
      end
      it "returns value" do
        expect(subject).to eql("1234")
      end
    end

    context "invalid input" do
      let(:input) do
        {
            "voter_ids" => [
                {
                    "type" => "ssn4",
                    "string_value" => "  12345  ",
                    "attest_no_such_id" => false
                }
            ]
        }
      end

      it "raises error" do
        expect { subject }.to raise_error /SSN4/
      end
    end
  end
  describe "zip_code" do
    subject { adapter.zip_code(:example, required) }
    let(:input) do
      {
          "example" =>
              {
                  "numbered_thoroughfare_address" => {
                      "zip_code" => zip_code_value
                  }
              }
      }
    end
    context "required" do
      let(:required) { true }

      context "valid" do
        let(:zip_code_value) { " 12345 " }
        it "returns value" do
          expect(subject).to eql("12345")
        end
      end

      context "empty" do
        let(:zip_code_value) { "" }
        it "raises error" do
          expect { subject }.to raise_error /Required/
        end
      end

      context "invalid" do
        let(:zip_code_value) { " 123345 " }
        it "raises error" do
          expect { subject }.to raise_error /ZIP/
        end
      end
    end
    context "optional" do
      let(:required) { false }

      context "valid" do
        let(:zip_code_value) { " 12345-6789 " }
        it "returns value" do
          expect(subject).to eql("12345-6789")
        end
      end

      context "empty" do
        let(:zip_code_value) { "" }
        it "returns nothing" do
          expect(subject).to eql("")
        end
      end

      context "invalid" do
        let(:zip_code_value) { " 12345 - 6789 " }
        it "raises error" do
          expect { subject }.to raise_error /ZIP/
        end
      end
    end
  end

  describe "email" do
    subject { adapter.email }
    let(:input) do
      {
          "contact_methods" => [
              {
                  "type" => "email",
                  "value" => email,
                  "capabilities" => %w(voice fax sms)
              }
          ]
      }
    end

    context "missing email value" do
      let(:input) { {} }

      it "empty" do
        expect(subject).to eql("")
      end
    end

    context "empty email value" do
      let(:email) { "  " }

      it "empty" do
        expect(subject).to eql("")
      end
    end

    context "valid email value" do
      let(:email) { " account-n.a.m.e+ext@super.domain.com  " }

      it "correct" do
        expect(subject).to eql("account-n.a.m.e+ext@super.domain.com")
      end
    end

    context "invalid email value" do
      let(:email) { " account@super@domain.com  " }

      it "remove email" do
        expect(subject).to eq("")
      end
    end
  end

  describe "send_copy_in_mail" do
    subject { adapter.send_copy_in_mail }
    let(:input) do
      {
          "voter_classifications" => [
              {
                  "type" => "send_copy_in_mail",
                  "assertion" => send_copy_in_mail
              }
          ]
      }
    end

    context "skipped section" do
      let(:input) { {} }
      it "0" do
        expect(subject).to eql("0")
      end
    end

    context "true value" do
      let(:send_copy_in_mail) { true }
      it "1" do
        expect(subject).to eql("1")
      end
    end

    context "false value" do
      let(:send_copy_in_mail) { false }
      it "0" do
        expect(subject).to eql("0")
      end
    end
  end

  describe "is_new_registration" do
    subject { adapter.is_new_registration }

    context "empty input" do
      let(:input) { {} }
      it "1" do
        expect(subject).to eql("1")
      end
    end

    context "prev name found" do
      let(:input) { {"previous_name" => {"somthing" => "value"}} }
      it "0" do
        expect(subject).to eql("0")
      end
    end

    context "prev PA registration found" do
      let(:input) do
        {
            "previous_registration_address" => {
                "numbered_thoroughfare_address" => {
                    "state" => "PA"
                }
            }
        }
      end
      it "0" do
        expect(subject).to eql("0")
      end
    end

    context "prev registration outside PA found" do
      let(:input) do
        {
            "previous_registration_address" => {
                "numbered_thoroughfare_address" => {
                    "state" => "VI"
                }
            }
        }
      end
      it "1" do
        expect(subject).to eql("1")
      end
    end
  end

  describe "readsignature" do
    subject { adapter.readsignature }
    context "when there is image content" do
      let(:input) do
        {
            "signature" => {
              "mime_type" => "image/img-type",
              "image" => "content"
          }
        }
      end
      it "returns a combined mime_type/image" do
        expect { subject.to eql("data:image/img-type;base64,content")}
      end
    end
    context "when there is no image content" do
      let(:input) do
        {
            "signature" => {
              "mime_type" => "image/img-type",
              "image" => " "
          }
        }
      end
      it "returns a blank string" do
        expect { subject.to eql("")}
      end
    end
    context "when there is no signature content" do
      let(:input) do
        {
            "not_a_signature" => { }
        }
      end
      it "returns a blank string" do
        expect { subject.to eql("")}
      end
    end
  end

  # probably this is a temporary method:
  describe "send_copy_in_mail2" do
    subject { adapter.send_copy_in_mail2 }
    let(:input) do
      {
          "additional_info" => [
              {
                  "name" => "send_copy_in_mail",
                  "string_value" => "true"
              }
          ]
      }
      it '1' do
        expect(subject).to eql("1")
      end
    end
  end
end