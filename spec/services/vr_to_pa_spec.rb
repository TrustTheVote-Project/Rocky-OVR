# to run only this spec:
# require File.expand_path('../../../app/services/vr_to_pa', __FILE__)

describe VRToPA do
  let(:input) { raise 'input is not re-defined' }
  let(:adapter) { VRToPA.new("voter_registration" => input) }
  let(:parameters) do
    {
        email: :email_value,
        ssn4: :ssn4_value,
        party: 'party_value',
        assistance_declaration2: true,
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
                        "place_name_value" => "Philadelphia"
                    },
                    {
                        "place_name_type" => "County",
                        "place_name_value" => "Philadelphia"
                    }
                ],
                "state" => "Virginia",
                "zip_code" => "22201"
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
                        "place_name_value" => "Philadelphia"
                    },
                    {
                        "place_name_type" => "County",
                        "place_name_value" => "Philadelphia"
                    }
                ],
                "state" => "Virginia",
                "zip_code" => "22201"
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
                        "place_name_value" => "Philadelphia"
                    },
                    {
                        "place_name_type" => "County",
                        "place_name_value" => "Philadelphia"
                    }
                ],
                "state" => "Virginia",
                "zip_code" => "22201"
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
                "name" => "assistance_declaration2",
                "boolean_value" => parameters[:assistance_declaration2]
            }
        ],
        "registration_helper" => {
            "registration_address" => {
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
    test_cases =
        {
            "democratic" => {politicalparty: "D", otherpoliticalparty: ""},
            "Democratic" => {politicalparty: "D", otherpoliticalparty: ""},
            " Democratic " => {politicalparty: "D", otherpoliticalparty: ""},
            "republican" => {politicalparty: "R", otherpoliticalparty: ""},
            "Republican" => {politicalparty: "R", otherpoliticalparty: ""},
            "other" => {politicalparty: "OTH", otherpoliticalparty: ""},
            "Other" => {politicalparty: "OTH", otherpoliticalparty: ""},
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
  describe 'assistance_declaration2' do
    subject { adapter.assistance_declaration2 }
    context 'no additional info' do
      let(:input) { {} }
      it 'default 0' do
        expect(subject).to eql "0"
      end
    end
    context 'no assistance_declaration2 info' do
      let(:input) { {"additional_info" => [{"name" => "n1", "string_value" => "s1"}]} }
      it 'default 0' do
        expect(subject).to eql "0"
      end
    end
    context 'assistance_declaration2 info set to true ' do
      let(:input) { {"additional_info" => [{"name" => "assistance_declaration2", "boolean_value" => true}]} }
      it 'default 0' do
        expect(subject).to eql "1"
      end
    end
    context 'assistance_declaration2 invalid info  ' do
      let(:input) { {"additional_info" => [{"name" => "assistance_declaration2", "another_value" => 42}]} }
      it 'default 0' do
        expect { subject }.to raise_error VRToPA::ParsingError
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

      it "raises en error " do
        expect { subject }.to raise_error(VRToPA::ParsingError)
      end
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
                "registration_address" => {
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
end