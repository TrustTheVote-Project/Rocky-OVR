#***** BEGIN LICENSE BLOCK *****
#
#Version: RTV Public License 1.0
#
#The contents of this file are subject to the RTV Public License Version 1.0 (the
#"License"); you may not use this file except in compliance with the License. You
#may obtain a copy of the License at: http://www.osdv.org/license12b/
#
#Software distributed under the License is distributed on an "AS IS" basis,
#WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
#specific language governing rights and limitations under the License.
#
#The Original Code is the Online Voter Registration Assistant and Partner Portal.
#
#The Initial Developer of the Original Code is Rock The Vote. Portions created by
#RockTheVote are Copyright (C) RockTheVote. All Rights Reserved. The Original
#Code contains portions Copyright [2008] Open Source Digital Voting Foundation,
#and such portions are licensed to you under this license by Rock the Vote under
#permission of Open Source Digital Voting Foundation.  All Rights Reserved.
#
#Contributor(s): Open Source Digital Voting Foundation, RockTheVote,
#                Pivotal Labs, Oregon State University Open Source Lab.
#
#***** END LICENSE BLOCK *****
require File.expand_path(File.dirname(__FILE__) + '/../../../rails_helper')

describe Api::V4::CanvassingShiftsController do
  before(:each) do
    BlocksClient.stub(:get_token).and_return({
      "jwt"=>"abc123"
    })
    BlocksClient.stub(:send)
  end
  describe "create" do
    let(:query) {{
      partner_id: 5,
      shift_location: 123,
      canvasser_first_name: "First",
      canvasser_last_name: "Last",
      canvasser_email: "test@test.test",
      canvasser_phone: "(123) 456-1234",
      device_id: "xxx"
    }}
    subject { post :create, params: query, as: 'json' }
    it "returns a 200" do
      expect(subject.status).to eq(200)
    end
    it "creates a new canvassing shift" do
      expect { subject }.to change { CanvassingShift.count }.by(1)
      cs = CanvassingShift.last
      expect(cs.partner_id).to eq(5)
      expect(cs.canvasser_first_name).to eq("First")
      expect(cs.canvasser_last_name).to eq("Last")
      expect(cs.canvasser_email).to eq("test@test.test")
      expect(cs.canvasser_phone).to eq("(123) 456-1234")
      expect(cs.device_id).to eq("xxx")      
    end
    it "returns a shift_id" do
      expect(JSON.parse(subject.body)["shift_id"]).to eq(CanvassingShift.last.shift_external_id)
    end
    context "missing parameters" do
      let(:query) {{
      }}
      it "returns a 422" do
        expect(subject.status).to eq(422)
      end
      it "includes messages for missing params" do 
        body = JSON.parse(subject.body)
        required_params = [:partner_id,
          :canvasser_first_name,
          :canvasser_last_name,
          :canvasser_email,
          :canvasser_phone,
          :device_id,
        ]
        required_params.each do |param|
          expect(body["errors"]).to include("Missing Parameter: #{param}")
        end
      end
    end
  end
  
  
  describe "update" do
    let(:clockin) { 5.hours.ago.iso8601 }
    let(:clockout) { 1.hour.ago.iso8601 }
    let(:shift_id) { "grommet-123abc" }
    let(:canvassing_shift) { double(CanvassingShift).as_null_object }
    let(:query) {{
      clock_in_datetime: clockin,
      clock_out_datetime: clockout,
      abandoned_registrations: 3,
      completed_registrations: 10
    }}
    subject { put :update, params: query.merge(id: shift_id), as: 'json' }
    before(:each) do
      allow(CanvassingShift).to receive(:find_by).with(shift_external_id: shift_id).and_return(canvassing_shift)
    end
    it "returns a 200" do
      expect(subject.status).to eq(200)
    end
    it "updates the canvassing shift" do
      expect(CanvassingShift).to receive(:find_by).with(shift_external_id: shift_id)
      expect(canvassing_shift).to receive(:update_attributes).with(query)
      subject
    end
    it "returns an empty body" do
      expect(JSON.parse(subject.body)).to eq({"errors"=>[]})
    end
    context "shift not found" do
      it "returns 404 with error message" do
        expect(CanvassingShift).to receive(:find_by).with(shift_external_id: shift_id).and_return(nil)
        resp = subject
        expect(resp.status).to eq(404)
        expect(JSON.parse(resp.body)["errors"]).to include("Shift with ID #{shift_id} not found")
      end      
    end
    context "missing parameters" do
      let(:query) {{
      }}
      it "returns a 422" do
        expect(subject.status).to eq(422)
      end
      it "does not update a canvassing shift" do
        expect(CanvassingShift).not_to receive(:find_by) 
      end
      it "includes messages for missing params" do 
        body = JSON.parse(subject.body)
        required_params = [
          :clock_in_datetime,
          :clock_out_datetime,
          :abandoned_registrations,
          :completed_registrations,
        ]
        required_params.each do |param|
          expect(body["errors"]).to include("Missing Parameter: #{param}")
        end
      end
    end
  end
  
  describe "complete" do
    let(:shift_id) { "grommet-123abc" }
    let(:canvassing_shift) { double(CanvassingShift).as_null_object }
    subject { get :complete, params: {id: shift_id}, as: 'json' }
    before(:each) do
      allow(CanvassingShift).to receive(:find_by).with(shift_external_id: shift_id).and_return(canvassing_shift)
    end
    it "returns a 200" do
      expect(subject.status).to eq(200)
    end
    it "completes the canvassing shift" do
      expect(CanvassingShift).to receive(:find_by).with(shift_external_id: shift_id)
      expect(canvassing_shift).to receive(:complete!)
      subject
    end
    it "returns an empty body" do
      expect(JSON.parse(subject.body)).to eq({"errors"=>[]})
    end
    context "shift not found" do
      it "returns 404 with error message" do
        expect(CanvassingShift).to receive(:find_by).with(shift_external_id: shift_id).and_return(nil)
        resp = subject
        expect(resp.status).to eq(404)
        expect(JSON.parse(resp.body)["errors"]).to include("Shift with ID #{shift_id} not found")
      end      
    end
  end
  
end