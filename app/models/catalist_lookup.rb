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
  
  def matched_data
    lookup! if self.match.blank?
    return nil if match["count"] == 0 || match["mrPersons"].blank? || match["mrPersons"].length == 0
    match["mrPersons"].each do |person|
      return person if person["voterstatus"] == "active"
    end
    return nil
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
