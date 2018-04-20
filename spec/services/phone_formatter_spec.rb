require File.expand_path('../../../app/services/phone_formatter', __FILE__)

# Format:
#   <name>: <input> -> <output>
TEST_CASES = <<-TXT
    10 digits: 1234567890 -> 123-456-7890
    10 digits and braces: (123)4567890 -> 123-456-7890
    10 digits and many dashes: 123-456-78-90 -> 123-456-7890
    10 digits, braces and many dashes: (123)456-78-90 -> 123-456-7890
    10 digits, braces and dashes: (123)456-7890 -> 123-456-7890
    10 digits, braces, dashes and spaces: (123) 456-7890 -> 123-456-7890
    10 digits and country code: +11234567890  ->  123-456-7890
    10 digits and all other valid chars: +1 (123) 456-7890  ->  123-456-7890
    9 digits: 123456789 -> error
    10 digits and +7: +7(123)456-7890 -> error
    extra braces: (123)(456)-7890 -> 123-456-7890
    extra double braces: ((123)456-7890 -> 123-456-7890
    extra "+" sign: (123)456+7890 -> 123-456-7890
    extra letters: 123 456 7890p -> 123-456-7890
TXT

def parse_and_run_test_cases
  TEST_CASES.split("\n").map { |rec| rec.match(/^(.+):(.+)->(.+)$/).captures.map { |x| x.strip } }.each do |values|
    raise "Invalid test case specification" unless values.length == 3
    yield *values
  end
end

describe PhoneFormatter do

  parse_and_run_test_cases do |name, input, output|
    describe name do
      it "for #{input} returns #{output}" do
        if output == "error"
          expect { PhoneFormatter.process(input) }.to raise_error
        else
          expect(PhoneFormatter.process(input)).to eql(output)
        end
      end
    end
  end

  context "trailing spaces" do
    input = "  123-456-7890  "
    expected_output = "123-456-7890"
    it "for \"#{input}\" returns \"#{expected_output}\"" do
      expect(PhoneFormatter.process(input)).to eql(expected_output)
    end
  end

end