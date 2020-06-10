require 'rails_helper'

RSpec.describe StateRegistrants::PARegistrant, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
  
  describe "custom_advance" do
    let(:pa_registrant) { StateRegistrants::PARegistrant.new }
    let(:mock_controller) { double("Controller")}
    let(:flash) { {} }
    context "when continuing on SMS device" do
      let(:mock_client) { double("TwilioClient")}
      let(:mock_client_messages) { double("TwilioClientMessages")}
      let(:params) { {sms_continue_on_device: true} }
      before(:each) do
        pa_registrant.stub(:twilio_client).and_return(mock_client)
        pa_registrant.stub(:signature_capture_url).and_return "signature_capture_url"
        mock_client.stub(:messages).and_return(mock_client_messages)
        mock_controller.stub(:flash).and_return(flash)
      end
      it "adds an error message if sms number is blank" do
        pa_registrant.custom_advance(mock_controller, params)
        expect(pa_registrant.errors[:sms_number_for_continue_on_device]).to be_present
      end
      it "adds an error message if sms number is invalid" do
        pa_registrant.sms_number_for_continue_on_device = "123"
        pa_registrant.custom_advance(mock_controller, params)
        expect(pa_registrant.errors[:sms_number_for_continue_on_device]).to be_present
      end
      it "sends a text if phone is valid" do
        pa_registrant.phone = "123-123-1234"
        expect(mock_client_messages).to receive(:create)
        pa_registrant.custom_advance(mock_controller, params)
        expect(flash[:success]).not_to be_blank
      end
      it "sends a text if sms-for-continue is valid" do
        pa_registrant.sms_number_for_continue_on_device = "123-123-1234"
        expect(mock_client_messages).to receive(:create)
        pa_registrant.custom_advance(mock_controller, params)
        expect(flash[:success]).not_to be_blank
      end
      
    end
  end
  
  describe "to_pa_data" do
    let(:pa_registrant) { StateRegistrants::PARegistrant.new }
    before(:each) do
      pa_registrant.stub(:parse_party).and_return({political_party: "party"})
    end
    it "includes dln" do
      pa_registrant.penndot_number = "12341234"
      expect(pa_registrant.to_pa_data['drivers-license']).to eq("12341234")
    end
    it "includes ssn" do
      pa_registrant.ssn4 = "1234"
      expect(pa_registrant.to_pa_data['ssn4']).to eq("1234")
    end
    context "when user indicates they dont have dln" do
      it "does not include dln" do
        pa_registrant.penndot_number = "12341234"
        pa_registrant.confirm_no_penndot_number = true
        expect(pa_registrant.to_pa_data['drivers-license']).to eq("")
      end      
    end
    context "when user indicates they dont have ssn4" do
      it "does not include dln" do
        pa_registrant.ssn4 = "1234"
        pa_registrant.confirm_no_dl_or_ssn = true
        expect(pa_registrant.to_pa_data['ssn4']).to eq("")
      end      
    end
  end
  
end
