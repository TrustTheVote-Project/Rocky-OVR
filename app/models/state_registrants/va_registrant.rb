class StateRegistrants::VaRegistrant < ActiveRecord::Base
  # attr_accessible :title, :body
  
  # mailing address if military (or spouse/dependent), if overseas, if not serviced by USPS or homeless, if providing PO box for privacy
  
  
  # Locality Codes
  # https://publicapi.elections.virginia.gov/V1/Locality/All 
  
  
  def gender
    # TODO determine based on title and return 'M' or 'F'
  end
  
  def cleanup
    # TODO make sure we don't keep SSN
  end
  
  
end
