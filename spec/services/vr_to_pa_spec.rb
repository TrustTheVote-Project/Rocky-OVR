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
        assistance_declaration2: true
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
        ]
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

end