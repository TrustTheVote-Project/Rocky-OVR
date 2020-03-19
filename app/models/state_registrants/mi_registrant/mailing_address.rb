module StateRegistrants::MIRegistrant::MailingAddress
  
  TYPES = %w(
    STANDARD
    PO_BOX
    MILITARY
    INTERNATIONAL
  )     
  # STANDARD
  # :mailing_address_1 Number
  # :mailing_address_2 Name
  # :mailing_address_3 Type
  # :mailing_city 
  # :mailing_state
  # :mailing_zip_code
  
  
  # PO Box
  # :mailing_address_1 Number
  # :mailing_city 
  # :mailing_state
  # :mailing_zip_code
  
  
  # Military
  # :mailing_address_1 - UNIT, CMR or PSC
  # :mailing_address_2 - Box Group ID
  # :mailing_address_3 - Box Number
  # :mailing_city APO or FPO
  # :mailing_state AA, AE or AP
  # :mailing_zip_code 5 digits exactly
  def mailing_military_units
    %w(UNIT CMR PSC)
  end
  def mailing_military_cities
    %w(APO FPO)
  end
  def mailing_military_states
    %w(AA AE AP)
  end
  
  
  # International
  # :mailing_address_1
  # :mailing_address_2
  # :mailing_address_3 (1,2,3 get concatenated into DeliveryAddress in 1 line)
  # :mailing_zip_code
  # :mailing_country
            
            
  def mailing_address_types
    TYPES.collect {|c| [I18n.t("states.custom.mi.mailing_address_types.#{c}"), c]}
  end          

  

end