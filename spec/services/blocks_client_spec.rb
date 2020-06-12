# used to run only this spec:
require File.dirname(__FILE__) + '/../rails_helper'

describe BlocksClient do
  let(:mock_logger) { double("Logger") }
  let(:mock_http) { double("http").as_null_object }
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
    it "adds headers"
    it "adds request body in JSON format"
    it "returns response body json"
    it "throws invalid response for code != 200"
    it "throws invalid response for invalid response body"
  end
  
end