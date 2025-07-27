module StateRegistrants::MIRegistrant::MailingAddress

  STANDARD_TYPE= "STANDARD".freeze
  PO_BOX_TYPE = "PO_BOX".freeze
  MILITARY_TYPE= "MILITARY".freeze
  INTERNATIONAL_TYPE = "INTERNATIONAL".freeze
  TYPES = [
    STANDARD_TYPE,
    PO_BOX_TYPE,
    MILITARY_TYPE,
    INTERNATIONAL_TYPE
  ]
  # STANDARD
  # :mailing_address_1 Number
  def mailing_address_number
    mailing_address_1
  end
  # :mailing_address_2 Name
  def mailing_address_street_name
    mailing_address_2
  end
  # :mailing_address_3 Type
  def mailing_address_street_type
    mailing_address_3
  end
  # :mailing_city 
  # :mailing_state
  # :mailing_zip_code
  
  
  # PO Box
  # :mailing_address_1 Number
  def mailing_po_box_number
    mailing_address_1
  end
  # :mailing_city 
  # :mailing_state
  # :mailing_zip_code
  
  
  # Military
  # :mailing_address_1 - UNIT, CMR or PSC
  def mailing_military_group_type
    mailing_address_1
  end
  # :mailing_address_2 - Box Group ID
  def mailing_military_group_number
    mailing_address_2
  end
  # :mailing_address_3 - Box Number
  def mailing_military_box_number
    mailing_address_3
  end
  # :mailing_city APO or FPO
  # :mailing_state AA, AE or AP
  # :mailing_zip_code 5 digits exactly
  def mailing_military_units
    %w(UNIT CMR PSC)
  end
  def mailing_military_cities
    %w(APO FPO DPO)
  end
  def mailing_military_states
    %w(AA AE AP)
  end
  
  
  # International
  # :mailing_address_1
  # :mailing_address_2
  # :mailing_address_3 (1,2,3 get concatenated into DeliveryAddress in 1 line)
  def mailing_international_address2
    [mailing_address_2, mailing_address_3].collect {|v| v.blank? ? nil : v }.compact.join(", ")
  end
  # :mailing_zip_code
  # :mailing_country
            
            
  def mailing_address_types
    TYPES.collect {|c| [I18n.t("states.custom.mi.mailing_address_types.#{c}"), c]}
  end          

  

end