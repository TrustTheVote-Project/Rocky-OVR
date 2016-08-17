# to run only this spec:
# require File.expand_path('../../../app/services/vr_to_pa', __FILE__)

describe VRToPA do
  let(:input) { raise 'input is not re-defined' }
  let(:adapter) { VRToPA.new("voter_registration" => input) }
  let(:parameters) do
    {
        email: :email_value,
        ssn4: :ssn4_value
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
        "party" => "democratic",
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
            }
        ]
    }
  end


  describe 'convert' do
    subject { adapter.convert }
    let(:input) { full_input }

    it 'returns all values' do
      expect(subject).to include({"Email" => :email_value})
      expect(subject).to include({"ssn4" => :ssn4_value})
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
end