# used to run only this spec:
require File.dirname(__FILE__) + '/../rails_helper'

describe BlocksService do
  
  describe "#form_from_registrant" do
    it "returns a blocks-formatted version of the registrant" do
      r = FactoryGirl.create(:maximal_registrant)
      expect(BlocksService.form_from_registrant(r)).to eq({
        date_of_birth: r.date_of_birth&.to_s("%Y-%m-%d"),
        eligible_voting_age: true, #r.ineligible_age checks for is==18 *now* not by deadline?
        email_address: r.email_address,
        first_name: r.first_name,
        middle_name: r.middle_name,
        last_name: r.last_name,
        name_suffix: r.english_name_suffix,
        gender: r.gender,
        phone_number: r.phone,
        signature: r.is_grommet? ? r.api_submitted_with_signature : !r.existing_state_registrant&.voter_signature_image.blank?,
        us_citizen: !!r.us_citizen,
        county: r.is_grommet? ? r.home_county : r.existing_state_registrant&.registration_county,
        voting_city: r.home_city,
        voting_state: r.home_state_abbrev,
        voting_street_address_one: r.home_address,
        voting_street_address_two: r.home_unit,
        voting_zipcode: r.home_zip_code,
        ethnicity: r.english_race,
      })
    end
  end
  
  describe "#form_from_grommet_request" do
    it "builds a registrant and uses form_form_registrant" do
      req = GrommetRequest.new(request_params: {rocky_request: "hash"})
      mock_registrant = double("Registrant").as_null_object
      expect(V4::RegistrationService).to receive(:create_pa_registrant).with("hash").and_return(mock_registrant)
      expect(mock_registrant).to receive(:basic_character_replacement!)
      expect(BlocksService).to receive(:form_from_registrant).with(mock_registrant).and_return("Expected Result")
      expect(BlocksService.form_from_grommet_request(req)).to eq("Expected Result")
    end
  end
  
  before(:each) do
    allow(RequestLogSession).to receive(:make_call_with_logging).and_yield
    allow(BlocksClient).to receive(:get_token).and_return("jwt"=>"token")
  end
  describe "new" do
    it "sets the token" do
      expect(BlocksClient).to receive(:get_token).and_return("jwt"=>"token")
      s = BlocksService.new
      expect(s.instance_variable_get(:@token)).to eq("token")
    end
  end
  
  context "instance methods" do
    let(:s) { BlocksService.new}
    describe "token" do
      it "returns a pre-set token" do
        s.instance_variable_set(:@token, "my-token")
        expect(s).not_to receive(:get_token)
        expect(s.token).to eq("my-token")
      end
      it "gets a token if not set" do
        s.instance_variable_set(:@token, nil)
        expect(s).to receive(:get_token).and_return("got token")
        expect(s.token).to eq("got token")      
      end
    end
  
    describe "get_token" do
      it "calls BlocksClient.get_token with logging" do
        s.instance_variable_set(:@token, nil)
        expect(RequestLogSession).to receive(:make_call_with_logging).and_yield
        expect(BlocksClient).to receive(:get_token)
        s.get_token
      end
      it "sets the @token variable" do
        s.instance_variable_set(:@token, nil)
        allow(BlocksClient).to receive(:get_token).and_return("jwt"=>"a token")
        s.get_token
        expect(s.instance_variable_get(:@token)).to eq("a token")      
      end
    end
  
    describe "build_canvassing_shift" do
      it "builds blocks shift args from an instance of canvassing_shift"
    end
  
    describe "upload_canvassing_shift" do 
      before(:each) do
        allow(s).to receive(:build_canvassing_shift_blocks_hash)
        allow(s).to receive(:build_blocks_forms_from_canvassing_shift)
        allow(s).to receive(:upload_registrations)
      end
      it "calls create_shift with blocks shift args" do
        shift = double(CanvassingShift)
        expect(s).to receive(:build_canvassing_shift_blocks_hash).with(shift, "digital_voter_registration").and_return("transformed shift args")
        expect(s).to receive(:create_shift).with("transformed shift args").and_return({
          "shift"=> {"id" => "shift_id"}
        })
        s.upload_canvassing_shift(shift)
      end
      it "calls upload registratinos for the shift ID and forms"
    end
  end
  

  
  
  
  
end