# used to run only this spec:
require File.dirname(__FILE__) + '/../rails_helper'

describe BlocksClient do
  let(:mock_logger) { double("Logger") }
  let(:mock_http) { double("http").as_null_object }
  let(:mock_request) { double("Request").as_null_object }
  
  let(:mock_response) { double("Response").as_null_object }
  let(:mock_body) { double("Body").as_null_object }
  let(:mock_uri) { double("URI").as_null_object }
  before(:each) do 
    mock_logger.stub(:log_uri)
    mock_response.stub(:body).and_return(mock_body)
    mock_response.stub(:code).and_return("200")
    allow(URI).to receive(:join).and_return(mock_uri)
    RequestLogSession.stub(:request_log_instance).and_return(mock_logger)
    RequestLogSession.stub(:send_and_log).and_return(mock_response)
    Net::HTTP.stub(:new).and_return(mock_http)
    allow(Net::HTTP::Get).to receive(:new).and_return(mock_request)
    
  end
  
  # Send does the bulk of the work
  describe "send" do
    let(:params) { {a: "b" } }
    before(:each) do 
      mock_uri.stub(:request_uri).and_return("http://localhost")
    end
    it "constructs a uri" do
      expect(URI).to receive(:join).with(RockyConf.blocks_configuration.url, BlocksClient::BASE_PATH, "path").and_return(mock_uri)
      BlocksClient.send(:get, "path")
    end
    it "does not construct a query if params are empty" do
      expect(mock_uri).not_to receive(:query=)
      BlocksClient.send(:get, "path", params: {})      
    end
    it "constructs a query if params are present" do
      expect(mock_uri).to receive(:query=).with(params.to_query)
      BlocksClient.send(:get, "path", params: params)
    end
    it "sets up http options" do
      expect(mock_http).to receive(:use_ssl=)
      expect(mock_http).to receive(:verify_mode=).with(OpenSSL::SSL::VERIFY_NONE)
      expect(mock_http).to receive(:read_timeout=)
      BlocksClient.send(:get, "path")
    end
    it "uses method based on method param" do
      allow(mock_uri).to receive(:request_uri).and_return("request_uri")
      expect(Net::HTTP::Get).to receive(:new).with("request_uri")
      BlocksClient.send(:get, "path")
    end
    it "adds headers" do
      expect(mock_request).to receive(:add_field).with("key", "value")
      BlocksClient.send(:get, "path", headers: {"key"=>"value"})      
    end
    it "adds request body in JSON format" do
      body = {key: "value"}
      expect(body).to receive(:to_json).and_return("json formatted body")
      expect(mock_request).to receive(:body=).with("json formatted body")
      BlocksClient.send(:get, "path", body: body)            
    end
    it "returns response body json" do
      mock_response.stub(:body).and_return("response_body")
      expect(JSON).to receive(:parse).with("response_body").and_return("formatted response")
      expect(BlocksClient.send(:get, "path")).to eq("formatted response")
    end
    it "throws invalid response for code != 200" do
      mock_response.stub(:code).and_return("500")
      expect { BlocksClient.send(:get, "path") }.to raise_error(BlocksClient::InvalidResponseError)
    end
    it "throws invalid response for invalid response body" do
      mock_response.stub(:body).and_return("response_body") #non JSON-parseable string
      expect { BlocksClient.send(:get, "path") }.to raise_error(BlocksClient::InvalidResponseError)
    end
  end
  
  context "specific methods" do
    let(:mock_json_result) { double("mock json result") }
    let(:headers) { {'Content-Type' => 'application/json'} }
    before(:each) do
      allow(BlocksClient).to receive(:send).and_return(mock_json_result)
    end
    describe "get_token" do
      it "sends email and password post to account/sign_in" do
        allow(ENV).to receive(:[]).with("BLOCKS_USER_EMAIL").and_return("BLOCKS_USER_EMAIL")
        allow(ENV).to receive(:[]).with("BLOCKS_USER_PASSWORD").and_return("BLOCKS_USER_PASSWORD")
        body = {
          email: 'BLOCKS_USER_EMAIL',
          password: 'BLOCKS_USER_PASSWORD'
        }
        expect(BlocksClient).to receive(:send).with(:post, "account/sign_in", body: body, headers: headers, url: nil)
        BlocksClient.get_token
      end
    end
    
    describe "get_locations" do
      it "sends get request to turfts/<id>/locations" do
        turf_id = "123"
        body = {jwt: "token"}
        expect(BlocksClient).to receive(:send).with(:get, "turfs/#{turf_id}/locations", body: body, headers: headers, url: nil)
        BlocksClient.get_locations(turf_id, token: "token")
      end      
    end

    describe "add_metadata_to_form" do
      it "sends put request to forms/<id>/add_metadata" do
        form_id = "123"
        
        meta_data = {
          firstName: "new first name"
        }
        
        body = {
          content: meta_data,
          jwt: "token"
        }
        
        expect(BlocksClient).to receive(:send).with(:put, "forms/#{form_id}/add_metadata", body: body, headers: headers, url: nil)
        BlocksClient.add_metadata_to_form(form_id, meta_data, token: "token")
      end      
    end
    
    describe "create_canvasser" do
      it "sends patch request to turfs/<id>/canvassers/upsert" do
        turf_id = "123"
        
        first_name = "First"
        last_name= "Last"
        email= "email"
        phone="phone"
        
        body = {
          canvasser: {
            first_name: first_name,
            last_name: last_name,
            phone_number: phone,
            email: email
          },
          jwt: "token"
        }
        
        expect(BlocksClient).to receive(:send).with(:patch, "turfs/#{turf_id}/canvassers/upsert", body: body, headers: headers, url: nil)
        BlocksClient.create_canvasser(first_name: first_name, last_name: last_name, email: email, phone_number: phone, turf_id: turf_id, token: "token")
      end      
    end
    
    describe "create_shift" do
      it "sends post request to shifts" do
        canvasser_id ="123"
        location_id  = "456"
        staging_location_id = "135"
        shift_start = 2.hours.ago
        shift_end   = 1.hour.ago
        shift_type  = "type"
        soft_count_cards_total_collected      = 5
        soft_count_cards_complete_collected   = 10
        soft_count_cards_incomplete_collected = 2
        
        body = {
          shift: {
            canvasser_id: canvasser_id,
            location_id: location_id,
            staging_location_id: staging_location_id,
            shift_start: shift_start,
            shift_end: shift_end,
            shift_type: shift_type,
            soft_count_cards_total_collected: soft_count_cards_total_collected,
            soft_count_cards_complete_collected: soft_count_cards_complete_collected,
            soft_count_cards_incomplete_collected: soft_count_cards_incomplete_collected
          },
          jwt: "token"
        }
        
        expect(BlocksClient).to receive(:send).with(:post, "shifts", body: body, headers: headers, url: nil)
        BlocksClient.create_shift(canvasser_id: canvasser_id,
            location_id: location_id,
            staging_location_id: staging_location_id,
            shift_start: shift_start,
            shift_end: shift_end,
            shift_type: shift_type,
            soft_count_cards_total_collected: soft_count_cards_total_collected,
            soft_count_cards_complete_collected: soft_count_cards_complete_collected,
            soft_count_cards_incomplete_collected: soft_count_cards_incomplete_collected, token: "token")
      end      
    end
    
    describe "upload_registrations" do
      it "sends post request to shifts/<id>/digital_batch" do
        shift_id = "123"
        
        forms = ["some", "array"]
        
        body = {
          batch: {
            shift_status: "status",
            forms: forms
          },
          jwt: "token"
        }
        
        expect(BlocksClient).to receive(:send).with(:post, "shifts/#{shift_id}/digital_batch", body: body, headers: headers, url: nil)
        BlocksClient.upload_registrations(shift_id, forms, shift_status: "status", token: "token")
      end      
    end

    
  end
  
end