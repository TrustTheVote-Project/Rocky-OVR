require 'rails_helper'

RSpec.describe CanvassingShift, type: :model do
  it { is_expected.to validate_presence_of(:shift_external_id) }
  
  describe "required fields" do
    subject { CanvassingShift.new }
    context "when building from web" do
      before(:each) do
        subject.shift_source = CanvassingShift::SOURCE_WEB
      end
      it { is_expected.to validate_presence_of(:canvasser_first_name) }
      it { is_expected.to validate_presence_of(:canvasser_last_name) }
      it { is_expected.to validate_presence_of(:partner_id) }
      it { is_expected.to validate_presence_of(:canvasser_phone) }
      it { is_expected.to validate_presence_of(:canvasser_email) }
      it { is_expected.to validate_presence_of(:shift_location) }
    end
    context "when not building from web" do
      before(:each) do
        subject.shift_source = CanvassingShift::SOURCE_GROMMET
      end
      it { is_expected.not_to validate_presence_of(:canvasser_first_name) }
      it { is_expected.not_to validate_presence_of(:canvasser_last_name) }
      it { is_expected.not_to validate_presence_of(:partner_id) }
      it { is_expected.not_to validate_presence_of(:canvasser_phone) }
      it { is_expected.not_to validate_presence_of(:canvasser_email) }
      it { is_expected.not_to validate_presence_of(:shift_location) }
    end
  end
  
  describe "#location_options" do
    let(:b) { double("BlocksService") }
    let(:p) { double("Partner") }
    before(:each) do
      allow(RockyConf.blocks_configuration).to receive(:default_location_id).and_return("default-id")
      allow(BlocksService).to receive(:new).and_return(b)
      allow(b).to receive(:get_locations).with(p).and_return({
        "locations"=> [
          {"name"=>"Location 1",
          "id"=>"L1"},
          {"name"=>"Location 2",
          "id"=>"L2"}
        ]
      })
    end
    it "gets locations for the given partner" do
      expect(CanvassingShift.location_options(p)).to eq([
        ["Location 1", "L1"],
        ["Location 2", "L2"]
      ])
    end
    it "returns default location when partner is missing" do
      allow(b).to receive(:get_locations).with(nil).and_raise "error"
      expect(CanvassingShift.location_options(nil)).to eq([
        ["Default Location", "default-id"]
      ])
    end
    it "returns default location when blockes returns non" do
      allow(b).to receive(:get_locations).with(p).and_return(nil)
      expect(CanvassingShift.location_options(p)).to eq([
        ["Default Location", "default-id"]
      ])
      allow(b).to receive(:get_locations).with(p).and_return([])
      expect(CanvassingShift.location_options(p)).to eq([
        ["Default Location", "default-id"]
      ])
    end
  end
  
  describe "canvasser_name" do
    it "returns concatenated first and last names" do
      c = CanvassingShift.new
      c.canvasser_first_name = "First"
      c.canvasser_last_name = "Last"
      expect(c.canvasser_name).to eq("First Last")
      
      c.canvasser_first_name = "First "
      expect(c.canvasser_name).to eq("First Last")
      
      c.canvasser_last_name = " "
      expect(c.canvasser_name).to eq("First")

      c.canvasser_last_name = "Last  Name " 
      expect(c.canvasser_name).to eq("First Last  Name")
      
      c.canvasser_first_name = nil
      expect(c.canvasser_name).to eq("Last  Name")
      
      c.canvasser_last_name = nil
      expect(c.canvasser_name).to eq("")
    end
  end
  describe "canvasser_name=" do
    it "splits value and assigns first and last names" do
      c = CanvassingShift.new
      c.canvasser_name = "First"
      expect(c.canvasser_first_name).to eq("First")
      expect(c.canvasser_last_name).to eq("")

      c.canvasser_name = " First"
      expect(c.canvasser_first_name).to eq("First")
      expect(c.canvasser_last_name).to eq("")

      c.canvasser_name = "First Last"
      expect(c.canvasser_first_name).to eq("First")
      expect(c.canvasser_last_name).to eq("Last")

      c.canvasser_name = "   First    Last   More   "
      expect(c.canvasser_first_name).to eq("First")
      expect(c.canvasser_last_name).to eq("Last More")

      c.canvasser_name = ""
      expect(c.canvasser_first_name).to eq("")
      expect(c.canvasser_last_name).to eq("")
      
    end
  end
  
  describe "set_attributes_from_data!" do
    let(:c) { CanvassingShift.new }
    before(:each) do
      allow(c).to receive(:save!)
    end
    it "sets :shift_location from :canvass_location_id" do
      c.set_attributes_from_data!({canvass_location_id: "shift-location"})
      expect(c.shift_location).to eq("shift-location")
    end
    it "saves the record" do
      expect(c).to receive(:save!)
      expect(c.set_attributes_from_data!({})).to eq(c)
    end
    it "sets standard params" do
      %w(partner_id
        source_tracking_id
        partner_tracking_id
        geo_location
        open_tracking_id
        canvasser_name
        canvasser_first_name
        canvasser_last_name
        canvasser_phone
        canvasser_email
        device_id
        abandoned_registrations
        completed_registrations
      ).each_with_index do |attr_name, idx|
        # Use ints and compare stringified because of type casting
        c.set_attributes_from_data!({attr_name => idx})
        expect(c.send(attr_name).to_s).to eq(idx.to_s)
      end
      %w(
        clock_in_datetime
        clock_out_datetime
      ).each_with_index do |attr_name, idx|
        d = DateTime.now
        c.set_attributes_from_data!({attr_name => d})
        expect(c.send(attr_name)).to eq(d)
      end
      
      
    end
  end
  
  describe "set_counts" do
    context "for web shifts with registrations" do
      it "sets completed registrations to number of complete registrations" do
        c = CanvassingShift.create!(shift_external_id: "shift-id", shift_source: CanvassingShift::SOURCE_WEB, canvasser_first_name: "F", canvasser_last_name: "L", canvasser_phone: "1231231234", canvasser_email: "test@test.com", shift_location: "123", partner: FactoryGirl.create(:partner))
        3.times do
          r = FactoryGirl.create(:completed_registrant)
          r.shift_id = "shift-id"
        end
        c.set_counts
        expect(c.completed_registrations).to eq(3)        
      end
      it "sets abandoned registrations to number of total registrations minus complete ones" do
        c = CanvassingShift.create!(shift_external_id: "shift-id", shift_source: CanvassingShift::SOURCE_WEB, canvasser_first_name: "F", canvasser_last_name: "L", canvasser_phone: "1231231234", canvasser_email: "test@test.com", shift_location: "123", partner: FactoryGirl.create(:partner))
        r = FactoryGirl.create(:completed_registrant)
        r.shift_id = "shift-id"
        r.abandon!
        r = FactoryGirl.create(:step_1_registrant)
        r.shift_id = "shift-id"
        r.abandon!
        r = FactoryGirl.create(:step_3_registrant)
        r.shift_id = "shift-id"
        r.abandon!
        r = FactoryGirl.create(:step_5_registrant)
        r.shift_id = "shift-id"
        r.abandon!
        c.set_counts
        expect(c.registrants.count).to eq(4)
        expect(c.abandoned_registrations).to eq(3)        
      end
    end
  end
  
  describe "is_ready_to_submit?" do
    it "returns true if both clock-in and -out are present" do
      c = CanvassingShift.new
      expect(c.is_ready_to_submit?).to eq(false)
      c.clock_in_datetime = DateTime.now
      expect(c.is_ready_to_submit?).to eq(false)
      c.clock_out_datetime = DateTime.now
      expect(c.is_ready_to_submit?).to eq(true)
      c.clock_in_datetime = nil
      expect(c.is_ready_to_submit?).to eq(false)
      
    end
  end
  
  describe "check_submit_to_blocks" do
    let(:c) { CanvassingShift.new }
    it "does not submit to blocks if already submitted" do
      allow(c).to receive(:is_ready_to_submit?).and_return(true)
      allow(c).to receive(:submitted_to_blocks?).and_return(true)
      expect(c).not_to receive(:delay)
      c.check_submit_to_blocks
    end
    it "does not submit to blocks if not ready" do
      allow(c).to receive(:is_ready_to_submit?).and_return(false)
      allow(c).to receive(:submitted_to_blocks?).and_return(false)
      expect(c).not_to receive(:delay)      
      c.check_submit_to_blocks
    end
    it "delays the submission process if ready and not yet submitted" do
      allow(c).to receive(:is_ready_to_submit?).and_return(true)
      allow(c).to receive(:submitted_to_blocks?).and_return(false)
      dj = double { "DelayedJob" }
      expect(c).to receive(:delay).and_return(dj)
      expect(dj).to receive(:submit_to_blocks)
      c.check_submit_to_blocks
    end
  end
  
  describe "submit_to_blocks" do
    let(:c) { CanvassingShift.new }
    let(:service) { double("Service") }
    before(:each) do
      allow(BlocksService).to receive(:new).and_return(service)
      allow(service).to receive(:upload_canvassing_shift)
      c.submitted_to_blocks = false
    end
    it "checks already submitted and ready state" do
      allow(c).to receive(:is_ready_to_submit?).and_return(true)
      c.submitted_to_blocks = true
      expect(BlocksService).not_to receive(:new)
      expect(service).not_to receive(:upload_canvassing_shift)
      c.submit_to_blocks
      
      allow(c).to receive(:is_ready_to_submit?).and_return(false)
      c.submitted_to_blocks = false
      expect(BlocksService).not_to receive(:new)
      expect(service).not_to receive(:upload_canvassing_shift)
      c.submit_to_blocks      
    end
    it "submits shift to blocks service" do
      allow(c).to receive(:is_ready_to_submit?).and_return(true)
      c.submitted_to_blocks = false
      expect(service).to receive(:upload_canvassing_shift).with(c)
      c.submit_to_blocks
    end
    it "updates to submitted: true" do
      allow(c).to receive(:is_ready_to_submit?).and_return(true)
      c.submitted_to_blocks = false
      expect(service).to receive(:upload_canvassing_shift).with(c)
      c.submit_to_blocks
      expect(c.submitted_to_blocks?).to be(true)
    end
  end
  
  describe "registrations_or_requests" do
    it "returns a consolidated lists of registrations or un-realized grommet requests" do
      shift_id = "shift-id"
      c = CanvassingShift.create(shift_external_id: shift_id, shift_source: CanvassingShift::SOURCE_GROMMET)
      5.times do |i|
        req = GrommetRequest.create
        CanvassingShiftGrommetRequest.create(shift_external_id: shift_id, grommet_request_id: req.id)
        if i < 4
          if i < 3
            r = FactoryGirl.create(:completed_registrant, state_ovr_data: {"grommet_request_id"=>req.id})
            r.shift_id = shift_id
          else
            r = FactoryGirl.create(:step_2_registrant, state_ovr_data: {"grommet_request_id"=>req.id})
            r.shift_id = shift_id            
          end
        end
      end
      expect(c.registrants.count).to eq(4)
      expect(c.grommet_requests.count).to eq(5)
      expect(c.registrations_or_requests).to eq([
        c.registrants,
        c.grommet_requests.last(1)
      ].flatten)
      
    end
  end
  
  
end
