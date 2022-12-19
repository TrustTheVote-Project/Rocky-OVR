# require_relative './test-scripts/create-web-registrations.rb'
# load './test-scripts/create-web-registrations.rb'


class CreateWebRegistration
  
  def self.run_all
    
    old_logger = ActiveRecord::Base.logger
    ActiveRecord::Base.logger = nil
    
    
    pid = 2
    partner = Partner.find(pid)
    initial_count = partner.registrants.count
    intial_pa_count = partner.registrants.where(home_state: GeoState["PA"]).count
    intial_pa_complete_count = partner.registrants.where(home_state: GeoState["PA"], status: "complete").count
    2.times { self.create_partial_pa(pid) }
    2.times { self.create_partial_ma(pid) } 
    2.times { self.create_api_success_pa(pid) } # Adds to valid regs
    2.times { self.create_api_failure_pa(pid) } 
    2.times { self.create_api_failure_pa_finish_on_paper(pid) } #Adds to valid regs
    
    puts "New reg records: #{partner.registrants.count - initial_count} should be 10"
    puts "New PA reg records: #{partner.registrants.where(home_state: GeoState["PA"]).count - intial_pa_count} should be 8"
    puts "New PA complete records: #{partner.registrants.where(home_state: GeoState["PA"], status: "complete").count - intial_pa_complete_count} should be 4"
    
    ActiveRecord::Base.logger = old_logger
    
    
  end
  
  def self.create_partial_pa(partner_id)    
    r = Registrant.new(partner_id: partner_id, email_address: "alex+test@osetinstitute.org", home_zip_code: "19000")
    r.save!
  end
  def self.create_partial_ma(partner_id)    
    r = Registrant.new(partner_id: partner_id, email_address: "alex+test@osetinstitute.org", home_zip_code: "02113")
    r.save!
  end
  
  def self.create_api_success_pa(pid)
    r = Registrant.new(partner_id: pid)
    r.locale = "en"
    r.date_of_birth = Date.parse("1979-06-16") 
    r.email_address = "alex.mekelburg@osetinstitute.org"
    r.first_name = "Name"
    r.home_address = "Address"
    r.home_city = "Carrum"
    r.home_state_id = "PA"
    r.home_zip_code = "19001"
    r.last_name = "User"
    r.name_title = "Mr."
    r.party = "Democratic"
    r.race = "Other"
    r.us_citizen = "1"
    r.opt_in_email = "1"
    r.partner_opt_in_sms = "0"
    r.send_confirmation_reminder_emails = "1"
    r.save!
    sr = r.state_registrant
    sr.registration_county = "ADAMS"
    sr.penndot_number ="12341234"
    sr.ssn4="1234"
    sr.save!
    sr.submit_to_online_reg_url
  end
  
  def self.create_api_failure_pa(pid)
    r = Registrant.new(partner_id: pid)
    r.locale = "en"
    r.date_of_birth = Date.parse("1979-06-16") 
    r.email_address = "alex.mekelburg@osetinstitute.org"
    r.first_name = "ERROR"
    r.home_address = "Address"
    r.home_city = "Carrum"
    r.home_state_id = "PA"
    r.home_zip_code = "19001"
    r.last_name = "User"
    r.name_title = "Mr."
    r.party = "Democratic"
    r.race = "Other"
    r.us_citizen = "1"
    r.opt_in_email = "1"
    r.partner_opt_in_sms = "0"
    r.send_confirmation_reminder_emails = "1"
    r.save!
    sr = r.state_registrant
    sr.registration_county = "ADAMS"
    sr.penndot_number ="12341234"
    sr.ssn4="1234"
    sr.save!
    sr.submit_to_online_reg_url
    
  end
  
  def self.create_api_failure_pa_finish_on_paper(pid)
    r = Registrant.new(partner_id: pid)
    r.locale = "en"
    r.date_of_birth = Date.parse("1979-06-16") 
    r.email_address = "alex.mekelburg@osetinstitute.org"
    r.first_name = "ERROR"
    r.home_address = "Address"
    r.home_city = "Carrum"
    r.home_state_id = "PA"
    r.home_zip_code = "19001"
    r.last_name = "User"
    r.name_title = "Mr."
    r.party = "Democratic"
    r.race = "Other"
    r.us_citizen = "1"
    r.opt_in_email = "1"
    r.partner_opt_in_sms = "0"
    r.send_confirmation_reminder_emails = "1"
    r.save!
    sr = r.state_registrant
    sr.registration_county = "ADAMS"
    sr.penndot_number ="12341234"
    sr.ssn4="1234"
    sr.save!
    sr.submit_to_online_reg_url
      
    r = sr.registrant
    r.reload
      
    r.state_id_number = "NONE"
    r.will_be_18_by_election = true
    r.has_state_license = false
    r.advance_to_step_1
    r.advance_to_step_2
    r.advance_to_step_3
    r.advance_to_step_4
    r.advance_to_step_5
    r.complete!
  end
  
end