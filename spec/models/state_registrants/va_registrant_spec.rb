require 'rails_helper'

RSpec.describe StateRegistrants::VARegistrant, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
  
  describe "#check_voter_confirmation_url" do
    let (:va_registrant) { StateRegistrants::VARegistrant.new }
    before(:each) do 
      va_registrant.stub(:date_of_birth).and_return 18.years.ago
    end
    it "encodes query strings" do
      va_registrant.first_name = "Joe`s Name"
      expect(va_registrant.check_voter_confirmation_url).to include("Joe%60s+Name")
    end
  end
  
  describe "#to_va_data" do
    let (:va_registrant) { StateRegistrants::VARegistrant.new }
    before(:each) do 
      va_registrant.stub(:updated_at).and_return DateTime.now
      va_registrant.stub(:date_of_birth).and_return 18.years.ago
    end
    subject { va_registrant.to_va_data["VoterRegistrations"][0] }
    context "User is not convicted of felony" do
      before(:each) do
        va_registrant.convicted_of_felony = false
      end
      it "includes IsProhibited" do
        expect(subject["IsProhibited"]).to eq(false)        
      end
      it "Does not include IsRightsRestored" do
        expect(subject["IsRightsRestored"]).to be_nil  
        va_registrant.right_to_vote_restored = false      
        expect(subject["IsRightsRestored"]).to be_nil        
        va_registrant.right_to_vote_restored = true      
        expect(subject["IsRightsRestored"]).to be_nil        
      end
    end
    context "User is convicted of felony" do
      before(:each) do
        va_registrant.convicted_of_felony = true
      end
      it "includes IsProhibited" do
        expect(subject["IsProhibited"]).to eq(true)
      end
      it "includes IsRightsRestored" do
        expect(subject["IsRightsRestored"]).to eq(nil)
      end
      it "includes IsRightsRestored false" do
        va_registrant.right_to_vote_restored = false
        expect(subject["IsRightsRestored"]).to eq(false)
      end
      it "includes IsRightsRestored true" do
        va_registrant.right_to_vote_restored = true
        expect(subject["IsRightsRestored"]).to eq(true)
      end
      
    end
  end
end
