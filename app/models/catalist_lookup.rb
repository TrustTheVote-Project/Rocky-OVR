class CatalistLookup < ActiveRecord::Base
  has_one :abrs_catalist_lookup
  has_one :abr, through: :abrs_catalist_lookup
  
  serialize :match, Hash
  
  belongs_to :state,    :class_name => "GeoState"
  
  def to_catalist_params
    {
      first: first,
      last: last,
      address: address,
      city: city,
      state: state_abbrev,
      zip: zip,
      birthdate: format_birthdate(birthdate)
    }
  end
  
  def lookup!
    service = CatalistService.new
    self.match = service.retrieve(abr: abr, params: to_catalist_params)
    self.save
  end
  
  def is_match?
    return !matched_data.nil?
  end
  
  # {"count"=>1,
  #  "mrPersons"=>
  #   [{"dwid"=>"1231231",
  #     "matchRate"=>1.0,
  #     "distanceScore"=>nil,
  #     "distance"=>nil,
  #     "matchMethod"=>nil,
  #     "firstname"=>"A",
  #     "middlename"=>"M",
  #     "lastname"=>"M",
  #     "namesuffix"=>nil,
  #     "gender"=>"male",
  #     "birthdate"=>"XXXX-XX-XX",
  #     "regaddrline1"=>"XXXX",
  #     "regaddrline2"=>"",
  #     "regaddrcity"=>"XXXX",
  #     "regaddrstate"=>"XX",
  #     "regaddrzip"=>"XXXXX",
  #     "mailaddrline1"=>"XXXXX",
  #     "mailaddrline2"=>"",
  #     "mailaddrcity"=>"XXXX",
  #     "mailaddrstate"=>"XX",
  #     "mailaddrzip"=>"XXXXX",
  #     "phone"=>nil,
  #     "voterstatus"=>"active", #active, inactive, multipleAppearances, unregistered, unmatchedMember;
  #     "additionalProperties"=>{}}],
  #  "matchMethod"=>"STANDARD", #  standard, name, name-address, distance, email, phon 
  #  "status"=>"OK"}
  # {"count"=>0, "mrPersons"=>[], "matchMethod"=>"STANDARD", "status"=>"OK"} 
  def matched_data
    lookup! if self.match.blank?
    return nil if match["count"] == 0 || match["mrPersons"].blank? || match["mrPersons"].length == 0
    match["mrPersons"].each do |person|
      return person if person["voterstatus"] == "active"
    end
    return nil
  end
  
  def match_name
    matched_data && "#{matched_data["firstname"]} #{matched_data["middlename"]} #{matched_data["lastname"]}"
  end
  def match_address1
    matched_data && "#{matched_data["regaddrline1"]}"
  end
  def match_address2
    matched_data && "#{matched_data["regaddrline2"]}"
  end
  def match_city
    matched_data && "#{matched_data["regaddrcity"]}"
  end
  def match_state
    matched_data && "#{matched_data["regaddrstate"]}"
  end
  def match_zip
    matched_data && "#{matched_data["regaddrzip"]}"
  end
  
  
  
  def state_abbrev
    state && state.abbreviation
  end
  def state_name
    state && state.name
  end
  
  
  private 
  def format_birthdate(date)
    self.class.format_birthdate(date)
  end
  def self.format_birthdate(date)
    return date.strftime("%m%d%Y")
  end
  
  
end
