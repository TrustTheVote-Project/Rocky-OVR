#***** BEGIN LICENSE BLOCK *****
#
#Version: RTV Public License 1.0
#
#The contents of this file are subject to the RTV Public License Version 1.0 (the
#"License"); you may not use this file except in compliance with the License. You
#may obtain a copy of the License at: http://www.osdv.org/license12b/
#
#Software distributed under the License is distributed on an "AS IS" basis,
#WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
#specific language governing rights and limitations under the License.
#
#The Original Code is the Online Voter Registration Assistant and Partner Portal.
#
#The Initial Developer of the Original Code is Rock The Vote. Portions created by
#RockTheVote are Copyright (C) RockTheVote. All Rights Reserved. The Original
#Code contains portions Copyright [2008] Open Source Digital Voting Foundation,
#and such portions are licensed to you under this license by Rock the Vote under
#permission of Open Source Digital Voting Foundation.  All Rights Reserved.
#
#Contributor(s): Open Source Digital Voting Foundation, RockTheVote,
#                Pivotal Labs, Oregon State University Open Source Lab.
#
#***** END LICENSE BLOCK *****
class GeoState < ActiveRecord::Base

  has_many :localizations, :class_name => 'StateLocalization', :foreign_key => 'state_id'
  
  delegate :online_reg_url, :redirect_to_online_reg_url, :has_ovr_pre_check?, :ovr_pre_check, :decorate_registrant, :enabled_for_language?, :require_age_confirmation?, :require_id?, :automatic_under_18_ok?, :use_state_flow?, :online_abr_enabled?, :oabr_url, :oabr_url_is_local_jurisdiction?, :to=>:state_customization

  serialize :direct_mail_partner_ids, Array

  def direct_mail_partners
    Partner.find(self.direct_mail_partner_ids)
  end

  def add_direct_mail_partner_id
    @add_direct_mail_partner_id
  end

  def add_direct_mail_partner_id=(value)
    return if value.blank?
    p = Partner.find_by_id(value)
    if p
      self.direct_mail_partner_ids ||= []
      self.direct_mail_partner_ids << value
      self.direct_mail_partner_ids.uniq!
      @add_direct_mail_partner_id = nil
    else
      @add_direct_mail_partner_id = value
    end
  end

  validate :validate_direct_mail_partner_ids
  def validate_direct_mail_partner_ids
    if @add_direct_mail_partner_id
      errors.add(:add_direct_mail_partner_id, "Partner #{@add_direct_mail_partner_id} not found")
    end
  end

  def self.[](id_or_abbrev)
    init_all_states
    case id_or_abbrev
    when Integer
      @@all_states_by_id[id_or_abbrev]
    when String
      @@all_states_by_abbrev[id_or_abbrev]
    end
  end
  
  def self.collection_for_select
    init_all_states
    [['','']] + @@all_states_by_abbrev.map { |abbrev, state| [state.name, abbrev] }.sort
  end

  def self.collection_for_select_full_name
    init_all_states
    [['','']] + @@all_states_by_abbrev.map { |abbrev, state| [state.name, state.name] }.sort
  end

  def self.init_all_states
    @@all_states_by_id ||= all.inject([]) { |arr,state| arr[state.id] = state; arr }
    @@all_states_by_abbrev ||= @@all_states_by_id[1..-1].index_by(&:abbreviation)
  end

  def self.reset_all_states
    @@all_states_by_id = nil
    @@all_states_by_abbrev = nil
  end

  def counties_file_path
    Rails.root.join("data/counties/#{abbreviation.downcase}.yml").to_s
  end

  def counties
    if !@counties
      if File.exists?(counties_file_path)
        file = []
        File.open(counties_file_path) do |f|
          file = YAML.load(f)
        end
        @counties = {}
        file.each do |c|
          c = c.to_unsafe_h if c.respond_to?(:to_unsafe_h)
          c = c.with_indifferent_access
          @counties[c[:name].downcase.underscore] = c
        end
      else
        @counties = {}
      end
    end
    return @counties
  end

  def county_collection_for_select
    counties.map { |abbrev, meta| [meta[:name], abbrev] }.sort
  end

  # ZIP codes
  
  def self.read_zip_file(file_name)
    lines = File.new(File.join(Rails.root, "data/zip_codes/#{file_name}")).readlines
    Hash[*(lines.collect {|line| line.chomp.split(',')}.flatten)]
  end
  
  def self.county_registrar_addresses(raise_errors = true)
    @@county_registrar_addresses ||= read_county_registrar_addresses(raise_errors)
  end
  def self.reset_county_registrar_addresses
    @@county_registrar_addresses = nil
  end
  
  def self.read_county_registrar_addresses(raise_errors = true)
    #COUNTY,STREET 1,STREET 2,CITY,STATE,ZIP,PHONE
    cra = {}
    errors = []
    city_matched_zip_codes = []
    CSV.foreach(county_addresses_file, {:headers=>:first_row}) do |cased_row|
      row = {}
      cased_row.each {|k,v| row[k.downcase] = v.to_s.strip }
      row["state"] = row["state"].upcase
      if %w(WI MI).include?(row["state"])
        next
      end
      cra[row["state"]] ||= {}
      county_file_name = ActiveSupport::Multibyte::Chars.new(row["county"]).mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/n,'')
      
      if county_zip_codes[row["state"]].nil?
        errors << "State #{row["state"]} missing!"
      else
        county_name = get_city_name_from_zip_codes(row["state"], county_file_name, errors)
        
        address = [row["address to"], row["street 1"], row["street 2"], "#{row["city"]}, #{row["state"]} #{row["zip"]}"].collect{|l| l.strip.blank? ? nil : l}.compact.join("\n")
        
        if !county_name.nil?
          if cra[row["state"]].has_key?(county_name)
            raise "Duplicate county #{row["county"]} for state #{row["state"]}"
          end
          
          # keep a list of all *city* matched zip codes
          cra[row["state"]][county_name] = [address, city_zip_codes[row["state"]][county_name], "city"]
          city_matched_zip_codes += city_zip_codes[row["state"]][county_name].flatten
        else 
          county_name = get_county_name_from_zip_codes(row["state"], county_file_name, errors)
          if !county_name.nil?
            if cra[row["state"]].has_key?(county_name)
              raise "Duplicate city #{row["county"]} for state #{row["state"]}"
            end
        
            cra[row["state"]][county_name] = [address, county_zip_codes[row["state"]][county_name], "county"]
          end
        end
      end
    end
    
    #clean out any city_matched_zip_codes from county names
    cra.each do |state, region_list|
      region_list.each do |region, addr_zip_type|
        if addr_zip_type[2] == "county"
          addr_zip_type[1].delete_if do |zip| 
            if city_matched_zip_codes.include?(zip) 
              puts "Removing #{zip} from county #{region}"
              true
            else
              false
            end
          end
        end
      end
    end
    
    #uniquify lines
    cra.each do |state, region_list|
      region_list.each do |region, addr_zip_type|
        addr_zip_type[1].uniq!
      end
    end
    
    if errors.any?
      msg = "The following counties are missing from the zip code database:\n" + errors.join("\n")
      if raise_errors
        raise msg
      else
        puts msg
      end
    end
    cra
  end
  
  def self.get_county_name_from_zip_codes(state, county_name, errors)
    attempted_name = county_name
    county_name = county_name.to_s.downcase.gsub("&", "and")
    if county_zip_codes[state].has_key?(county_name)
      return county_name
    end
    
    # NYC fix
    if county_name =~ /\((.+ county)\)/
      nyc_county_name = $1
      if county_zip_codes[state].has_key?(nyc_county_name)
        return nyc_county_name
      end
    end
    
    # try without spaces
    concat_county_name = county_name.gsub(/\s/,'')
    if county_zip_codes[state].has_key?(concat_county_name)
      return concat_county_name
    end
    
    
    
    # try the "st." substitution
    st_county_name = county_name.to_s.downcase.gsub(/st\./, "saint")
    if county_zip_codes[state].has_key?(st_county_name)
      return st_county_name
    end
    st_county_name = county_name.to_s.downcase.gsub(/(st\.|saint)/, "st")
    if county_zip_codes[state].has_key?(st_county_name)
      return st_county_name
    end
    
    # try adding suffix
    county_name = county_name + ((state == "LA") ? " parish" : " county")
    if county_zip_codes[state].has_key?(county_name)
      return county_name
    end
    
    # try without spaces
    concat_county_name = county_name.gsub(/\s/,'')
    if county_zip_codes[state].has_key?(concat_county_name)
      return concat_county_name
    end
    

    # try the "st." substitution
    st_county_name = county_name.to_s.downcase.gsub(/st\./, "saint")
    if county_zip_codes[state].has_key?(st_county_name)
      return st_county_name
    end
    st_county_name = county_name.to_s.downcase.gsub(/(st\.|saint)/, "st")
    if county_zip_codes[state].has_key?(st_county_name)
      return st_county_name
    end

    errors << "#{state}: #{attempted_name}"
    
    return nil
  end
  
  def self.get_city_name_from_zip_codes(state, county_name, errors)
    attempted_name = county_name
    county_name = county_name.to_s.downcase
    if city_zip_codes[state].has_key?(county_name)
      return county_name
    end
    
    
    # try the "st." substitution
    st_county_name = county_name.to_s.downcase.gsub(/st\./, "saint")
    if city_zip_codes[state].has_key?(st_county_name)
      return st_county_name
    end
    st_county_name = county_name.to_s.downcase.gsub(/(st\.|saint)/, "st")
    if city_zip_codes[state].has_key?(st_county_name)
      return st_county_name
    end
    
    # try removing " City" and "City of " and "Town of"
    # and township and hyphens
    city_name = county_name.gsub(/^city\s+of\s+/,'').
      gsub(/\s+city$/,'').
      gsub(/^town\s+of\s+/,'').
      gsub(/ township/,'').
      gsub(/\s+twp$/,'').
      gsub(/-/,' ')
    if city_zip_codes[state].has_key?(city_name)
      return city_name
    end

    # # try removing twp and plt
    # city_name = city_name.
    #   gsub(/\s+twp$/,'').
    #   gsub(/\s+plt$/,'')
    # if city_zip_codes[state].has_key?(city_name)
    #   return city_name
    # end

    
    # try the "st." substitution
    st_county_name = city_name.to_s.downcase.gsub(/\sst\.?\s/, " saint ")
    if city_zip_codes[state].has_key?(st_county_name)
      return st_county_name
    end
    st_county_name = city_name.to_s.downcase.gsub(/(st\.|saint)/, "st")
    if city_zip_codes[state].has_key?(st_county_name)
      return st_county_name
    end
    
    
    
    return nil
  end
  
  cattr_writer :county_addresses_file
  def self.county_addresses_file
    @@county_addresses_file ||= Rails.root.join("data/zip_codes/county_addresses.csv")
  end
  
  # from http://www.unitedstateszipcodes.org/zip_code_database.cs
  cattr_writer :zip_code_database_file
  def self.zip_code_database_file
    @@zip_code_database_file ||= Rails.root.join("data/zip_codes/zip_code_database.csv")
  end
  
  def self.county_zip_codes
    @@county_zip_codes ||= []
    if @@county_zip_codes.empty?
      @@county_zip_codes, @@city_zip_codes = read_zip_code_database
    end
    return @@county_zip_codes
  end
  
  def self.city_zip_codes
    @@city_zip_codes ||= []
    if @@city_zip_codes.empty?
      @@county_zip_codes, @@city_zip_codes = read_zip_code_database
    end
    return @@city_zip_codes
  end
  
  def self.reset_county_zip_codes
    @@county_zip_codes = nil
  end
  
  def self.read_zip_code_database
    #1. Read list of counties from zip_code_database
    #2. Read county-addresses into memory
    #3. Make sure all county-address counties are in zip database
    #4. Map county/state/zip/addresses and commit to DB
    CSV.foreach(zip_code_database_file, {:headers=>:first_row}) do |row|
      z = ZipCodeCountyAddress.find_by_zip(row["zip"]) || ZipCodeCountyAddress.new(zip: row["zip"])
      z.geo_state = GeoState[row["state"]]
      next if z.geo_state.blank?
      z.zip = row["zip"]
      
      z.county << row["county"].to_s.downcase

      # also add the county without apostraphes
      county_clean = "#{row["county"]}".gsub(/'/, '').to_s.downcase
      z.county << county_clean

      # also add the county without spaces
      county_concat = "#{row["county"]}".gsub(/\s/, '').to_s.downcase
      z.county << county_concat
      
      # make uniq!
      z.county.uniq!
      

      z.cities << row["primary_city"].to_s.downcase

      # also add the city, county version 
      city_county = "#{row["primary_city"]}, #{row["county"]}".to_s.downcase
      z.cities << city_county

      # also add the city without apostraphes
      city_clean = "#{row["primary_city"]}".gsub(/'/, '').to_s.downcase
      z.cities << city_clean
      
      acceptables = row["acceptable_cities"].to_s.split(',')
      acceptables.each do |ac|        
        z.cities << ac.to_s.downcase.strip
      end
      
      z.cities.uniq!
      
      unacceptables = row["unacceptable_cities"].to_s.split(',')
      unacceptables.each do |ac|
        z.unacceptable_cities << ac.to_s.downcase.strip
      end
      z.unacceptable_cities.uniq!
      
      z.save!
      
    end
    
  end

  def self.zip5map
    @@zip5 ||= read_zip_file('zip5.csv')
  end

  def self.zip3map
    @@zip3 ||= read_zip_file('zip3.csv')
  end

  def self.for_zip_code(zip)
    #self[ zip5map[zip] || zip3map[zip] ]
    #self[zip5map[zip]]
    zip5 = zip[0, 5] # Extract the first 5 digits of the ZIP code
    self[zip5map[zip5]]
  end

  def self.valid_zip_code?(zip)
    !for_zip_code(zip).nil?
  end
  
  def self.states_with_online_registration
    RockyConf.states_with_online_registration
  end
  
  def get_localization(locale)
    localizations.find_or_initialize_by(locale: locale.to_s)
  end
  
  def state_customization
    @state_customization ||= StateCustomization.for(self)
  end 
  
  def online_reg_enabled?(locale, reg=nil)
    GeoState.states_with_online_registration.include?(self.abbreviation) && self.enabled_for_language?(locale, reg)
  end
  
  def abr_office(zip_code=nil)
    zcc = zip_code.nil? ? nil : ZipCodeCountyAddress.where(:zip=>zip_code).first    
    zcc&.ensure_up_to_date
    return zcc
  end
  
  def abr_address(zip_code=nil)
    county_address_zip = zip_code.nil? ? nil : ZipCodeCountyAddress.where(:zip=>zip_code).first
    if county_address_zip && !county_address_zip.req_address.blank?
      county_address_zip.req_address.gsub(/\n/,"<br/>")
    else
      state_abr_addr = read_attribute(:registrar_abr_address)
      return state_abr_addr.blank? ? registrar_address(zip_code) : state_abr_addr
    end    
  end

  def registrar_address(zip_code=nil)
    county_address_zip = zip_code.nil? ? nil : ZipCodeCountyAddress.where(:zip=>zip_code).first
    if county_address_zip && county_address_zip.address
      county_address_zip.address.gsub(/\n/,"<br/>")
    else
      state_registrar_address
    end
  end

  def state_registrar_address
    read_attribute(:registrar_address)
  end
    
  def to_param
    self.abbreviation.upcase
  end
  
end
