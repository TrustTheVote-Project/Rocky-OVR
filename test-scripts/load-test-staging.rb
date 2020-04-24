#!/usr/bin/env ruby
require 'rest-client'
num_threads = 50
threads = []
num_threads.times do |i|
  threads << Thread.new do
    begin
      puts "Starting Request #{i}"
      id = (i % 2) + 2
      #puts id
      #&before=2019-01-01
      resp = RestClient.get("https://staging.rocky.rockthevote.com/api/v3/registrations.json?partner_id=#{id}&partner_API_key=1b573fa91bea1a2904ade27f0f4edb9d65f1306c")
      puts "Done with request #{i}"
    rescue Exception => e
      puts "#{e.message}"
      puts "Thread #{i} died"
    end
  end
end


threads.each {|t| t.join }

puts "Done"