NUM_REGISTRATIONS = 3

path = File.expand_path(__FILE__).split("/")
path.pop
path = path.join("/")

CLOCK_IN = File.join(path, 'start-shift.rb')
CLOCK_OUT = File.join(path, 'end-shift.rb')
REGISTER = File.join(path, 'make-grommet-request.rb')

def run(cmd, args)
  `ruby #{cmd} #{args.join(" ")}`
end

session_id = "'My Session::#{Time.now.to_i}'"
partner_tracking_id = "'customid'"
partner_id = 1

base_args = [session_id, partner_tracking_id, partner_id]

run(CLOCK_IN, base_args)


NUM_REGISTRATIONS.times do
  first_name = "ERROR"# "ERROR" # Set virst name to error code or ERROR or EMPTY or FORMAT or TIMEOUT see https://fake-pa-endpoint.herokuapp.com/
  run(REGISTER, [base_args, first_name].flatten)
end

run(CLOCK_OUT, [base_args, 0, NUM_REGISTRATIONS].flatten)

