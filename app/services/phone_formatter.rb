class PhoneFormatter
  class InvalidPhoneNumber < StandardError; end

  ERROR_MESSAGE = "Invalid phone number: \"%s\". Expected phone number format is 10 digits. Spaces and dashes are ignored, " +
      "optional +1 and a pair of round braces can be used once. E.g. \"+1 (123) 456-7890\""

  def self.process(phone_number)
    # Remove non-digits
    v = phone_number.gsub(/[^\d]/,'')
    if v.size == 11 and v[0] == "1" # Remove initial 1 if it's extra
      v = v[-10..-1]
    end

    if v.size != 10
      raise InvalidPhoneNumber.new(ERROR_MESSAGE % phone_number)
    end
    # format output
    "#{v[0..2]}-#{v[3..5]}-#{v[6..9]}"
  end
end
