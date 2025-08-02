NUM_REGISTRATIONS = 5
NUM_API_REGISTRATIONS = 0

path = File.expand_path(__FILE__).split("/")
path.pop
path = path.join("/")

CREATE_SHIFT = File.join(path, 'create-shift.rb')
UPDATE_SHIFT = File.join(path, 'update-shift.rb')
END_SHIFT = File.join(path, 'end-shift.rb')
GROMMET_REGISTER = File.join(path, 'make-grommet-request.rb')
API_REGISTER = File.join(path, 'make-api-request.rb')

def run(cmd, args)
  command = "ruby #{cmd} #{args.join(" ")}"
  # puts command
  output = `#{command}`
  puts output
  return output.to_s.strip
end

session_id = "'My Session::#{Time.now.to_i}'"
partner_tracking_id = "'customid::#{Time.now.to_i}'"
partner_id = 7

base_args = [partner_tracking_id, partner_id]

shift_id = run(CREATE_SHIFT, base_args)
puts "Got shift id '#{shift_id}'"
base_args.unshift(shift_id)

error_cases = [
  [:street_number, "ERROR"], # Grommet resubmits - but our tests always fail bc name isn't changed
  [:street_number, "6.0"], # License not found
  [:street_number, "incomplete"], # don't submit to api
  [:street_number, "10.0"], # Busy, retry
  [:street_number, "11.0"], # Error, retry
  [:street_number, "4.0"], # Multiple addresses, Gives up
  [:street_number, "0.0"], # Validation error, Gives up  
  [:first_name, "!#wrong@field.com"] # Rocky errors and never submits to MI
]

error_idx = 0 # make sure we start with a non-registrant

NUM_REGISTRATIONS.times do |i|
  full_name = "'Valid Name'"
  street_number = "1.0"
  if i % 3 == 0
    if error_idx >= error_cases.length
      error_idx = 0
    end
    error_case = error_cases[error_idx]
    if error_case[0] == :first_name
      full_name = error_case[1]
    elsif error_case[0] == :street_number
      street_number = error_case[1]
    end
    error_idx += 1
  end
  run(GROMMET_REGISTER, [base_args, full_name, street_number].flatten)
  sleep(1)
end

NUM_API_REGISTRATIONS.times do |i|
  first_name = "Test-#{i}"
  run(API_REGISTER, [partner_id, first_name].flatten)
  sleep(1)
end


run(UPDATE_SHIFT, [shift_id, 2, NUM_REGISTRATIONS].flatten)
run(END_SHIFT, [shift_id])

