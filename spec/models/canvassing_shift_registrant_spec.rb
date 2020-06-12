require 'rails_helper'

RSpec.describe CanvassingShiftRegistrant, type: :model do
  
  describe "#registrant_id" do
    it { is_expected.to validate_presence_of(:registrant_id) }
  end
  describe "#shift_external_id" do
    it { is_expected.to validate_presence_of(:shift_external_id) }
  end
  
end
