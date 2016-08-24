# used to run only this spec:
require File.expand_path('../../../app/services/vr_to_pa', __FILE__)
require File.expand_path('../../../app/services/phone_formatter', __FILE__)
require 'date'
require 'json'

def expected_result(filename)
  expected_base_filename = File.basename(filename, ".json") + ".out.json"
  expected_path = File.expand_path("../../fixtures/files/PA/out_pa_request_data/" + expected_base_filename, __FILE__)
  expected = JSON.load(File.new(expected_path))
end

def convert(filename)
  input = JSON.load(File.new(filename))
  VRToPA.new(input["rocky_request"]["voter_records_request"]).convert
end

describe VRToPA do

  describe 'old converted results are stable' do
    Dir.glob(File.expand_path("../../fixtures/files/PA/in_rocky_requests/*.json", __FILE__)) do |filename|
      output = convert(filename)
      expected = expected_result(filename)

      # for better errors output:
      it filename do
        output.each do |k, v|
          expect("#{k}" => expected[k]).to eql("#{k}" => v)
        end
      end
    end
  end
end