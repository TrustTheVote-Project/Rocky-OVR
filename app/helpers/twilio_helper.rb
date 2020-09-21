module TwilioHelper
  def twilio_client
    @twilio_client ||= Twilio::REST::Client.new twilio_sid, twilio_token      
  end
  
  def twilio_sid
    @twilio_sid ||= ENV['TWILIO_SID']
  end
  
  def twilio_token
    @twilio_token ||= ENV["TWILIO_TOKEN"]
  end
  
  def twilio_phone_number 
    @twilio_phone_number ||= ENV['TWILIO_NUMBER']
  end
end