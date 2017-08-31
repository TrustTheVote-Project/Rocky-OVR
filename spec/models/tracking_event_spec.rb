require 'rails_helper'

RSpec.describe TrackingEvent, :type => :model do
  describe "create_from_data" do
    it "returns the tracking event" do
      t = TrackingEvent.create_from_data({})
      expect(t).to be_a(TrackingEvent)
    end
    it "creates a new tracking event" do
      expect {
        TrackingEvent.create_from_data({})
      }.to change {
        TrackingEvent.count
      }.by(1)
    end
    it "assigns data to attributes that match" do
      t = TrackingEvent.create_from_data({
        source_tracking_id: "abc",
        "partner_tracking_id" => 123
      })
      t.reload #To force data into correct types
      expect(t.source_tracking_id).to eq("abc")
      expect(t.partner_tracking_id).to eq("123")
    end
    it "assigns geo_location hash from data attributes" do
      t = TrackingEvent.create_from_data({
        geo_location: {"lat"=> 123, "lon"=>244}
      })
      t.reload #To force data into correct types
      expect(t.geo_location).to eq({"lat"=> 123, "lon"=>244})
    end
    it "handles bad geo_location data type from data attributes" do
      t = TrackingEvent.create_from_data({
        geo_location: "abc"
      })
      t.reload #To force data into correct types
      expect(t.geo_location).to eq({})
      expect(t.tracking_data["geo_location"]).to eq("abc")
    end
    it "sets other attributes from the data into the open tracking_data hash" do
      t = TrackingEvent.create_from_data({
        source_tracking_id: "abc",
        "partner_tracking_id" => 123,
        "anything_else"=> "test",
        "even"=>{
          "something"=>["complex", "works"]
        },
        "tracking_data"=>'its a trap'
      })
      t.reload
      expect(t.tracking_data["partner_tracking_id"]).to be_nil
      expect(t.tracking_data["source_tracking_id"]).to be_nil
      expect(t.tracking_data).to eq({
        "anything_else"=> "test",
        "even"=>{
          "something"=>["complex", "works"]
        },
        "tracking_data"=>'its a trap'
      })
    end
  end
end
