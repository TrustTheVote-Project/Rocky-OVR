class ZipCodeCountyAddress < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :geo_state
  
  validates :zip, uniqueness: true, presence: true
  validates :geo_state_id, presence: true
  
  serialize :county, Array
  serialize :cities, Array
  serialize :unacceptable_cities, Array
  
  require 'resolv-replace'
  
  DAYS_TO_CACHE = 3
  
  def check_address
    self.last_checked = DateTime.now
    self.save
    begin
      region_id = lookup_region
      if region_id
        addresses = lookup_office_address(region_id)
        if !addresses.blank?
          self.attributes = addresses
          self.save
        end
      end
    rescue Exception=>e
      #raise e
      Rails.logger.info "Unable to lookup LEO address for #{self.zip}"
    end
  end
  
  def lookup_region
    county_name = self.county.first
    city_name = self.cities.first
    state_abbr = self.geo_state.abbreviation
    # Region lookup by first county name
    regions = []
    [ ["region_name", county_name],
      ["municipality_name", city_name],
      ["county_name", county_name],
      ["county_name", city_name],
      ["county_name", county_name.to_s.gsub(/(county|borough|parish)/i, '').strip ],
      ["municipality_name", county_name]
    ].each do |filter_name, filter_value|
      if filter_value
        regions = self.class.search_regions(filter_name, filter_value, state_abbr)
      end
      raise "Too may region results!" if regions.count > 5
      break if regions.any?
    end
    if regions.any?
      response = regions.first
      #"resource_uri": "/api/v2/regions/16588
      region_uri = response["resource_uri"]
      if region_uri && region_uri =~ /(\d+)$/
        return $1
      end
    end
    return nil
  end
  
  def address
    ensure_up_to_date
    return full_vr_address
  end
  
  def req_address
    ensure_up_to_date
    return full_req_address
  end
  
  def full_vr_address
    addr = [self.vr_address_to,
     self.vr_street1,
     self.vr_street2,
     [self.vr_city, self.vr_state, self.vr_zip].compact.join(', ')
    ].collect {|line| line.blank? ? nil : line}.compact.join("\n").strip
    if addr.blank?
      return read_attribute(:address)
    else
      return addr
    end
  end
  
  
  def full_req_address
    addr = [self.req_address_to,
     self.req_street1,
     self.req_street2,
     [self.req_city, self.req_state, self.req_zip].compact.join(', ')
    ].collect {|line| line.blank? ? nil : line}.compact.join("\n").strip
    if addr.blank?
      return read_attribute(:address)
    else
      return addr
    end
  end
  
  
  def ensure_up_to_date
    if self.last_checked.nil? || self.last_checked < (DateTime.now - DAYS_TO_CACHE.days)
      check_address
    end
  end
  
  def lookup_office_address(region_id)
    return nil if region_id.blank?
    offices = self.class.get(self.class.office_uri(region_id))
    if offices.any?
      raise "Too many offices for region #{region_id}" if offices.count > 5
      office = offices.first
      mailing_office = select_address_from_office(office)
      req_mailing_office = select_req_address_from_office(office)
      addresses = nil
      if mailing_office
        addresses ||= {}
        addresses[:vr_address_to] = mailing_office["address_to"]
        addresses[:vr_street1] = mailing_office["street1"]
        addresses[:vr_street2] = mailing_office["street2"]
        addresses[:vr_city] = mailing_office["city"]
        addresses[:vr_state] = mailing_office["state"]
        addresses[:vr_zip] = mailing_office["zip"]
      end
      if req_mailing_office
        addresses ||= {}
        addresses[:req_address_to] = req_mailing_office["address_to"]
        addresses[:req_street1] = req_mailing_office["street1"]
        addresses[:req_street2] = req_mailing_office["street2"]
        addresses[:req_city] = req_mailing_office["city"]
        addresses[:req_state] = req_mailing_office["state"]
        addresses[:req_zip] = req_mailing_office["zip"]
      end
      return addresses
    end
    return nil
  end
  
  def select_address_from_office(office)
    # First find any "addresses" where 
    # "type"=>"name" == "Voter Registration Mailing Address"
    if office["addresses"] && office["addresses"].is_a?(Array)
      # additional_address = office["addresses"].find {|addr| addr["type"] && addr["type"]["name"]=="Voter Registration Mailing Address"}
      # Look for is_regular_mail first
      dom_vr_address = office["addresses"].find {|addr| addr["is_regular_mail"] && (addr["functions"] || []).include?("DOM_VR")}
      # Otherwise take the first that includes DOM_VR
      dom_vr_address ||= office["addresses"].find {|addr| (addr["functions"] || []).include?("DOM_VR")}
      if dom_vr_address
        return dom_vr_address
      end
    end
    return nil
  end
  
  def select_req_address_from_office(office)
    if office["addresses"] && office["addresses"].is_a?(Array)
      # additional_address = office["addresses"].find {|addr| addr["type"] && addr["type"]["name"]=="Voter Registration Mailing Address"}
      # Look for is_regular_mail first
      dom_req_address = office["addresses"].find {|addr| addr["is_regular_mail"] && (addr["functions"] || []).include?("DOM_REQ")}
      # Otherwise take the first that includes DOM_REQ
      dom_req_address ||= office["addresses"].find {|addr| (addr["functions"] || []).include?("DOM_REQ")}
      if dom_req_address
        return dom_req_address
      end
    end
    return nil
  end
  
  
  
  def self.search_regions(filter_name, filter_value, state_abbr)
    return get(region_uri(filter_name, filter_value, state_abbr))
  end
  
  
  def self.region_uri(filter_name, filter_value, state_abbr)
    params = {}
    params["state_abbr"] = state_abbr
    params[filter_name]=filter_value
    api_uri("/regions", params)
  end
  
  def self.office_uri(region_id)
    params = {}
    params["region"]=region_id
    api_uri("/offices", params)
  end
  
  def self.api_uri(path, params)
    params["oauth_consumer_key"]=StateImporter::CountyAddresses.oauth_token
    return "#{StateImporter::CountyAddresses.api_uri}#{path}?#{params.collect{|k,v| "#{k}=#{URI.encode(v.to_s)}"}.join("&")}"    
  end
  
  
  def self.get(path)
    response =  JSON.parse(self.get_ssl("#{StateImporter::CountyAddresses.base_uri}#{path}" ))
    return response["objects"]
  rescue Exception => e
    return []
  end
  
  
  def self.get_no_ssl(url, headers={}, &block)
    RestClient::Request.execute(method: :get, url: url, headers: headers, verify_ssl: false, &block)
  end
  
  
  def self.get_ssl(url, headers={}, &block)
    RestClient::Request.execute(method: :get, url: url, headers: headers, verify_ssl: true, &block)
  end
  
  #address = [row["address to"], row["street 1"], row["street 2"], "#{row["city"]}, #{row["state"]} #{row["zip"]}"].collect{|l| l.strip.blank? ? nil : l}.compact.join("\n")
  
end
