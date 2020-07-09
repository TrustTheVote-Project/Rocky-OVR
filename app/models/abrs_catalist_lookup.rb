class AbrsCatalistLookup < ActiveRecord::Base
  belongs_to :abr
  belongs_to :catalist_lookup
  
  def self.create_lookup(abr)
    lookup_params = abr_to_catalist_lookup_params(abr)   
    c = CatalistLookup.new(lookup_params)
    c.abr = abr
    c.save! 
  end
  
  def self.abr_to_catalist_lookup_params(abr)
    {
      first: abr.first_name,
      middle: abr.middle_name,
      last: abr.last_name,
      suffix: abr.name_suffix,
      #gender: abr.gender,
      birthdate: abr.date_of_birth, #format_birthdate(abr.date_of_birth)
      address: abr.address,
      city: abr.city,
      state_id: abr.home_state_id,
      zip: abr.zip,
      #county: abr.county,
      phone: abr.phone,
      email: abr.email      
    }
  end
  
  
  
end
