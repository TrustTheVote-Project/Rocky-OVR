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
        signature: r.is_grommet? ? r.api_submitted_with_signature : !r.existing_state_registrant&.voter_signature_image&.blank?,
        us_citizen: !!r.us_citizen,
        county: r.is_grommet? ? r.home_county : r.existing_state_registrant&.registration_county,
        voting_city: r.home_city,
        voting_state: r.home_state_abbrev,
        voting_street_address_one: r.home_address,
        voting_street_address_two: r.home_unit,
        voting_zipcode: r.home_zip_code,
        ethnicity: r.english_race,
        metadata: {
          rtv_uid: r.uid,
          sms_opt_in: r.partner_opt_in_sms?,
          robo_call_opt_in: r.partner_opt_in_sms?,
          email_opt_in: r.partner_opt_in_email?,
          preferred_language: r.is_grommet? ? r.grommet_preferred_language : r.locale,
          volunteer_with_partner: r.partner_volunteer?,
          phone_type: r.phone_type
        }
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
      it "calls upload registrations for the shift ID and forms" do
        shift = double(CanvassingShift)
        forms = double("FormsList")
        allow(s).to receive(:create_shift).and_return({
          "shift"=> {"id" => "shift_id"}
        })
        allow(forms).to receive(:any?).and_return(true)
        expect(s).to receive(:build_blocks_forms_from_canvassing_shift).with(shift).and_return(forms)
        expect(s).to receive(:upload_registrations).with("shift_id", forms)
        s.upload_canvassing_shift(shift)
      end
    end
    
    
    describe "get_locations" do
      let(:partner) { FactoryGirl.create(:partner) }
      let(:turf_id) { "123" }
      before(:each) do 
        allow(RockyConf).to receive(:blocks_configuration).and_return(OpenStruct.new({
          partners: {
            partner.id => OpenStruct.new({turf_id: turf_id})
          }          
        }))
      end
      it "calls get_locations on the blocks client with logging" do
        expect(RequestLogSession).to receive(:make_call_with_logging).and_yield
        expect(BlocksClient).to receive(:get_locations).with(turf_id, token: s.token)        
        s.get_locations()
      end
      it "uses turf_id when present" do
        expect(RequestLogSession).to receive(:make_call_with_logging).and_yield
        expect(BlocksClient).to receive(:get_locations).with("456", token: s.token, url: RockyConf.blocks_configuration.url)        
        s.get_locations( turf_id: "456")
      end
    end
    describe "add_metadata_to_form" do
      it "makes call to BlocksClient with logging and added token" do
        input1 = double("Input")
        input2 = double("Input")
        expect(RequestLogSession).to receive(:make_call_with_logging).and_yield
        expect(BlocksClient).to receive("add_metadata_to_form").with(input1, input2, token: s.token)        
        s.add_metadata_to_form(input1, input2)
      end      
    end
    describe "create_canvasser" do
      it "makes call to BlocksClient with logging and added token" do
        input1 = {first_name: "val", last_name: "val", phone_number: "val", email: "val", turf_id: "val"}
        expect(RequestLogSession).to receive(:make_call_with_logging).and_yield
        expect(BlocksClient).to receive("create_canvasser").with(**input1, token: s.token, url: RockyConf.blocks_configuration.url)
        s.create_canvasser(input1)
      end            
    end
    describe "create_shift" do
      it "makes call to BlocksClient with logging and added token" do
        input1 = {canvasser_id: "val", location_id: "val", staging_location_id: "val", shift_start: "val", shift_end: "val", shift_type: "val", soft_count_cards_total_collected: "val"}
        expect(RequestLogSession).to receive(:make_call_with_logging).and_yield
        expect(BlocksClient).to receive("create_shift").with(**input1, token: s.token)        
        s.create_shift(input1)
      end            
    end
    describe "upload_registrations" do
      it "makes call to BlocksClient with logging and added token" do
        input1 = double("Input")
        input2 = double("Input")
        expect(RequestLogSession).to receive(:make_call_with_logging).and_yield
        expect(BlocksClient).to receive("upload_registrations").with(input1, input2, token: s.token, url: RockyConf.blocks_configuration.url)        
        s.upload_registrations(input1, input2)
      end      
      
    end
    
    
    describe "build_blocks_forms_from_canvassing_shift" do
      it "builds a list of form items from canvassing shift registrations/grommet requests" do
        reg_type = double(Registrant)
        reg_type.stub(:is_a?).with(Registrant).and_return(true)
        req_type = double(GrommetRequest)
        req_type.stub(:is_a?).with(Registrant).and_return(false)
        req_type.stub(:is_a?).with(GrommetRequest).and_return(true)
        shift = double(CanvassingShift)
        expect(shift).to receive(:registrants_or_requests).and_return([
          reg_type,
          req_type
        ])
        expect(BlocksService).to receive(:form_from_registrant).with(reg_type).and_return("reg args")
        expect(BlocksService).to receive(:form_from_grommet_request).with(req_type).and_return("req args")
        expect(s.send(:build_blocks_forms_from_canvassing_shift,shift)).to eq(["reg args", "req args"])
      end
    end


    describe "build_canvassing_shift_blocks_hash" do
      it "builds blocks shift args from an instance of canvassing_shift" do
        partner = FactoryGirl.create(:partner)
        turf_id = "123"
        shift = CanvassingShift.new
        shift.partner_id = partner.id
        shift.canvasser_first_name = "First Name"
        shift.canvasser_last_name = "Last Name"
        shift.canvasser_email = "email"
        shift.canvasser_phone = "phone"
        shift.abandoned_registrations = 1
        shift.completed_registrations  = 5
        shift.clock_in_datetime = 2.hours.ago
        shift.clock_out_datetime = 1.hour.ago
        
        canvasser_args = {
          turf_id: turf_id,
          last_name: shift.canvasser_last_name, first_name: shift.canvasser_first_name, email: shift.canvasser_email, phone_number: shift.canvasser_phone
        }
        
        expect(RockyConf).to receive(:blocks_configuration).and_return(OpenStruct.new({
          partners: {
            partner.id => OpenStruct.new({turf_id: turf_id})
          },
          default_location_id: "default_location",
          default_staging_location_id: "staging_location"          
        })).at_least(1).times
        
        expect(s).to receive(:create_canvasser).with(canvasser_args).and_return({"canvasser"=>{"id"=>"canvasser_id"}})
        
        expect(s.send(:build_canvassing_shift_blocks_hash, shift, "shift type")).to eq({
          canvasser_id: "canvasser_id",
          location_id: "default_location",
          staging_location_id: "staging_location", 
          shift_start: shift.clock_in_datetime.in_time_zone("America/New_York").iso8601, 
          shift_end: shift.clock_out_datetime.in_time_zone("America/New_York").iso8601, 
          shift_type: "shift type", 
          soft_count_cards_total_collected: shift.completed_registrations, # + shift.completed_registrations,
          soft_count_cards_complete_collected: shift.completed_registrations,
          soft_count_cards_incomplete_collected: shift.abandoned_registrations
        })
        
      end
    end
    
    
    
  end
  

  
  
  
  
end