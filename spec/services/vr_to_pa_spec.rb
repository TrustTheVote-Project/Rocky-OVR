# used to run only this spec:
require File.expand_path('../../../app/services/vr_to_pa', __FILE__)
require 'date'

describe VRToPA do
  let(:input) { raise 'input is not re-defined' }
  let(:adapter) { VRToPA.new("voter_registration" => input) }
  let(:parameters) do
    {
        email: :email_value,
        ssn4: :ssn4_value,
        party: 'party_value',
        assistant_declaration: "true",
        attest_no_ssn4_id: false
    }
  end
  let(:full_input) do
    {
        "date_of_birth" => "2016-06-16",
        "mailing_address" => {
            "numbered_thoroughfare_address" => {
                "complete_address_number" => "",
                "complete_street_name" => "801 N. Monroe",
                "complete_sub_address" => {
                    "sub_address_type" => "APT",
                    "sub_address" => "Apt 306"
                },
                "complete_place_names" => [
                    {
                        "place_name_type" => "MunicipalJurisdiction",
                        "place_name_value" => "Mailing City"
                    },
                    {
                        "place_name_type" => "County",
                        "place_name_value" => "Philadelphia"
                    }
                ],
                "state" => "Virginia",
                "zip_code" => "33333"
            }
        },
        "previous_registration_address" => {
            "numbered_thoroughfare_address" => {
                "complete_address_number" => "\"\"",
                "complete_street_name" => "801 N. Monroe",
                "complete_sub_address" => {
                    "sub_address_type" => "APT",
                    "sub_address" => "Apt 306"
                },
                "complete_place_names" => [
                    {
                        "place_name_type" => "MunicipalJurisdiction",
                        "place_name_value" => "Previous City"
                    },
                    {
                        "place_name_type" => "County",
                        "place_name_value" => "Philadelphia"
                    }
                ],
                "state" => "Virginia",
                "zip_code" => "22222"
            }
        },
        "registration_address" => {
            "numbered_thoroughfare_address" => {
                "complete_address_number" => "\"\"",
                "complete_street_name" => "801 N. Monroe",
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
                        "place_name_value" => "Philadelphia"
                    }
                ],
                "state" => "Virginia",
                "zip_code" => "11111"
            }
        },
        "registration_address_is_mailing_address" => true,
        "name" => {
            "first_name" => "Aaron",
            "last_name" => "Huttner",
            "middle_name" => "Bernard",
            "title_prefix" => "Mr",
            "title_suffix" => "Jr"
        },
        "previous_name" => {
            "first_name" => "Aaron",
            "last_name" => "Huttner",
            "middle_name" => "Bernard",
            "title_prefix" => "Mr",
            "title_suffix" => "Jr"
        },
        "gender" => "male",
        "race" => "American Indian / Alaskan Native",
        "party" => parameters[:party],
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
            "image" => "?"
        },
        "voter_ids" => [
            {
                "type" => "drivers_license",
                "string_value" => "12345678",
                "attest_no_such_id" => false
            },
            {
                "type" => "ssn4",
                "string_value" => parameters[:ssn4],
                "attest_no_such_id" => parameters[:attest_no_ssn4_id]
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
                "value" => parameters[:email],
                "capabilities" => %w(voice fax sms)
            }
        ],
        "additional_info" => [
            {
                "name" => "preferred_language",
                "string_value" => "english"
            },
            {
                "name" => "assistant_declaration",
                "string_value" => parameters[:assistant_declaration]
            }
        ],
        "registration_helper" => {
            "address" => {
                "numbered_thoroughfare_address" => {
                    "complete_address_number" => "55",
                    "complete_street_name" => "Assistant Street",
                    "complete_sub_address" => {
                        "sub_address_type" => "APT",
                        "sub_address" => "555"
                    },
                    "complete_place_names" => [
                        {
                            "place_name_type" => "MunicipalJurisdiction",
                            "place_name_value" => "Assistant City"
                        },
                        {
                            "place_name_type" => "County",
                            "place_name_value" => "County"
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
    subject { adapter.convert }
    let(:input) { full_input }

    it 'returns all values' do
      expect(subject).to include("Email" => :email_value)
      expect(subject).to include("ssn4" => :ssn4_value)
      expect(subject).to include("politicalparty" => "OTH")
      expect(subject).to include("otherpoliticalparty" => "party_value")
      expect(subject).to include("assistancedeclaration2" => "1")
      expect(subject).to include("donthavebothDLandSSN" => "0")
      expect(subject).to include("assistedpersonname" => "Assistant Name")
      expect(subject).to include("assistedpersonAddress" => "55 Assistant Street, Assistant City Assistant State")
      expect(subject).to include("assistedpersonphone" => "1234567890")
      expect(subject).to include("city" => "Registration City")
      expect(subject).to include("mailingcity" => "Mailing City")
      expect(subject).to include("previousregcity" => "Previous City")
      expect(subject["assistedpersonAddress"]).to include("Assistant City")
      expect(subject).to include("zipcode" => "11111")
      expect(subject).to include("mailingzipcode" => "33333")

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
              "green" => {politicalparty: "OTH", otherpoliticalparty: "green"},
              "Green" => {politicalparty: "OTH", otherpoliticalparty: "Green"},
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
                    "string_value" => "123456",
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
      it 'loads full name' do
        expect(subject).to eql('Ms FN MN LN III')
      end
    end
    context 'minimalistic name provided' do
      let(:input) do
        {
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
            "registration_helper" => {
                "address" => {
                    "numbered_thoroughfare_address" => {
                        "complete_address_number" => "1",
                        "complete_street_name" => "Street",
                        "complete_sub_address" => {
                            "sub_address_type" => "APT",
                            "sub_address" => "100"
                        },
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
        expect(subject).to eql('1 Street, City State')
      end
    end
  end

  describe 'assisted_person_phone' do
    subject { adapter.assisted_person_phone }
    context 'phone is defined' do
      let(:input) do
        {
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
                    "complete_address_number" => "\"\"",
                    "complete_street_name" => "801 N. Monroe",
                    "complete_sub_address" => {
                        "sub_address_type" => "APT",
                        "sub_address" => "Apt 306"
                    },
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
end