require 'rails_helper'

RSpec.describe CanvassingShiftGrommetRequest, type: :model do
  describe "#grommet_request_id" do
    it { is_expected.to validate_presence_of(:grommet_request_id) }
  end
  describe "#shift_external_id" do
    it { is_expected.to validate_presence_of(:shift_external_id) }
  end
  
end
