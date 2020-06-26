require 'rails_helper'

describe ZipCodeCountyAddress do
  
  it { should validate_uniqueness_of(:zip) }
  it { should validate_presence_of(:zip) }
  it { should validate_presence_of(:geo_state_id) }
  
  it "has county as an array" do
    z  = ZipCodeCountyAddress.new
    expect(z.county).to eq([])
  end
  it "has citie as an array" do
    z  = ZipCodeCountyAddress.new
    expect(z.cities).to eq([])
  end
  it "has unaceptable_cities as an array" do
    z  = ZipCodeCountyAddress.new
    expect(z.unacceptable_cities).to eq([])
  end
  
  
  describe '#address' do
    let(:z) { ZipCodeCountyAddress.new }
    before(:each) do
      z.address = "db_address"
    end
    it "returns the db address if zip code has been looked up within DAYS_TO_CACHE days" do
      z.last_checked = DateTime.now - (ZipCodeCountyAddress::DAYS_TO_CACHE.days - 1.minute)
      expect(z).not_to receive(:check_address)
      expect(z.address).to eq("db_address")
    end
    it "looks up an office address when never checked" do
      expect(z.last_checked).to be_nil
      expect(z).to receive(:check_address)
      z.address
    end
    it "looks up an office address via the usvotefoundation API if not updated within 3 days" do
      z.last_checked = DateTime.now - (ZipCodeCountyAddress::DAYS_TO_CACHE.days + 1.minute)
      expect(z).to receive(:check_address)      
      z.address
    end
  end
  
  describe "#check_address" do
    let(:z) { ZipCodeCountyAddress.new }
    before(:each) do
      z.address = "db_address"
    end
    
    it "sets the last_checked when complete regardless of success or failure" do
      expect(z.last_checked).to be_nil
      expect(z).to receive(:save)
      expect(z).to receive(:lookup_region) { raise "Broken" }
      z.check_address
      expect(z.last_checked).not_to be_nil      
    end
    it "does not lookup the address if no region is found" do
      expect(z).to receive(:lookup_region).and_return(nil)
      expect(z).not_to receive(:lookup_office_address);
      z.check_address
      expect(z.address).to eq("db_address")
    end
    it "sets the db_address when successful" do
      expect(z).to receive(:lookup_region).and_return("1234")
      expect(z).to receive(:lookup_office_address).with("1234").and_return("New Address");
      z.check_address
      expect(z.address).to eq("New Address")
    end
    it "does not set address if lookup returns nil" do
      expect(z).to receive(:lookup_region).and_return("1234")
      expect(z).to receive(:lookup_office_address).with("1234").and_return(nil)
      z.check_address
      expect(z.address).to eq("db_address")
    end
  end
  
  describe "#lookup_region" do
    let(:z) { ZipCodeCountyAddress.new }
    before(:each) do
      ZipCodeCountyAddress.stub(:search_regions).and_return([])
      z.county = ["county name"]
      z.cities = ["city name"]
      z.geo_state = GeoState["CA"]
    end
    # Region lookup by first county name
    # County lookup by first county name
    # municipality lookup by first county name
    # city lookup by first city
    it "looks for offices according to county name(s) and city name(s)" do
      expect(ZipCodeCountyAddress).to receive(:search_regions).with("region_name", "county name", "CA")
      expect(ZipCodeCountyAddress).to receive(:search_regions).with("county_name", "county name", "CA")
      expect(ZipCodeCountyAddress).to receive(:search_regions).with("municipality_name", "county name", "CA")
      expect(ZipCodeCountyAddress).to receive(:search_regions).with("municipality_name", "city name", "CA")
      z.lookup_region      
    end
    
    it "returns nil if no regions are found" do
      expect(z.lookup_region).to be_nil
    end
    it "returns nil if no counties or cities are in the record" do
      z.county = []
      z.cities = []
      
      expect(z.lookup_region).to be_nil
    end
    it "returns nil if the region inlcudes a blank or invalid resource_uri" do
      ZipCodeCountyAddress.stub(:search_regions).and_return([{
        "resource_not_uri"=>"/api/v2/regions/a"
      }])
      expect(z.lookup_region).to be_nil
      ZipCodeCountyAddress.stub(:search_regions).and_return([{
        "resource_uri"=>"/api/v2/regions/a"
      }])
      expect(z.lookup_region).to be_nil
    end
    it "returns the id integer from the resource_uri when valid" do 
      ZipCodeCountyAddress.stub(:search_regions).and_return([{
        "resource_uri"=>"/api/v2/regions/2424"
      }])
      expect(z.lookup_region).to eq("2424")
    end
  end
  
  describe '#lookup_office_address(region_id)' do
    let(:z) { ZipCodeCountyAddress.new }
    it "returns nil if no match" do
      ZipCodeCountyAddress.stub(:get).and_return([])
      expect(z.lookup_office_address("123")).to be_nil
    end
    it "returns nil if no region_id" do
      expect(z.lookup_office_address("")).to be_nil
    end
    it "returns nil if no mailing_address" do
      ZipCodeCountyAddress.stub(:get).and_return([{
        "express_address"=> {
          "street1"=> "abc"
        }
      }])
      expect(z.lookup_office_address("123")).to be_nil
    end
    it "returns addresses of is_regular_mail=>true and functions=>[DOM_VR]" do
      ZipCodeCountyAddress.stub(:get).and_return([{
        "addresses"=>[
          {
            "street1"=> "The Wrong Street",
            "city"=>    "B",
            "state"=>   "AA",
            "zip"=>     "00000",
            "is_regular_mail"=>true,            
          },
          {
            "street1"=> "The Right Street",
            "city"=>    "Boston",
            "state"=>   "MA",
            "zip"=>     "02110",
            "is_regular_mail"=>true,
            "functions"=> ["ABC", "DOM_VR", "DEF"]
          }          
        ],
        "mailing_address"=> {
          "street1"=> "The Street",
          "city"=>    "Oston",
          "state"=>   "MM",
          "zip"=>     "111111"
        }
      }])
      expect(z.lookup_office_address("123")).to eq("The Right Street\nBoston, MA, 02110")      
    end
    it "returns first address with DOM_VR function regardless of is_regular_mail setting" do
      ZipCodeCountyAddress.stub(:get).and_return([{
        "addresses"=>[
          {
            "street1"=> "The Wrong Street",
            "city"=>    "B",
            "state"=>   "AA",
            "zip"=>     "00000",
            "is_regular_mail"=>true,            
          },
          {
            "street1"=> "The Right Street",
            "city"=>    "Boston",
            "state"=>   "MA",
            "zip"=>     "02110",
            "functions"=> ["ABC", "DOM_VR", "DEF"]
          },
          {
            "street1"=> "Another Wrong Street",
            "city"=>    "Boston",
            "state"=>   "MA",
            "zip"=>     "02110",
            "functions"=> ["ABC", "DOM_VR", "DEF"]
          }          
        ],
        "mailing_address"=> {
          "street1"=> "The Street",
          "city"=>    "Oston",
          "state"=>   "MM",
          "zip"=>     "111111"
        }
      }])
      expect(z.lookup_office_address("123")).to eq("The Right Street\nBoston, MA, 02110")            
    end

  end
  
  
end
