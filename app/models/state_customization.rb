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

class StateCustomization
  
  attr_accessor :state
  
  def self.for(state)
    klass = class_exists?(state.abbreviation) ?  state.abbreviation.constantize : self
    klass.new(state)
  end
  
  def initialize(state)
    @state = state
  end
  
  def automatic_under_18_ok?(registrant)
    return false
  end
  
  def use_state_flow?(registrant)
    false
  end
  
  def online_reg_enabled?(locale, registrant = nil)
    GeoState.states_with_online_registration.include?(state.abbreviation) && self.enabled_for_language?(locale, registrant)
  end
  
  def enabled_for_language?(lang, reg)
    if require_id?
      return false if reg && !reg.has_state_license?
    end
    if require_age_confirmation?
      return false if reg && !reg.will_be_18_by_election?
    end    
    return true if ovr_settings.blank?
    lang_list = ovr_settings["languages"]
    return true if lang_list.blank? || lang_list.empty?
    return lang_list.include?(lang)
  end
  
  def online_reg_url(registrant)
    state.online_registration_url
  end
  
  def redirect_to_online_reg_url(registrant)
    return false if ovr_settings.blank?
    return true #!!ovr_settings.redirect_to_online_reg_url
  end
  
  def ovr_settings
    RockyConf.ovr_states[state.abbreviation]
  end
  
  def abr_settings
    RockyConf.absentee_states[state.abbreviation]
  end
  
  def online_abr_enabled?(abr)
    oabr_url(abr).present?
  end
  
  def oabr_url_is_local_jurisdiction?(abr = nil)
    puts oabr_url(abr)
    puts abr_settings&.online_req_url
    oabr_url(abr) != abr_settings&.online_req_url
  end
  
  def oabr_url(abr = nil)
    if abr && abr_settings&.counties
      begin
        url = abr_settings&.counties[abr.county_from_zip.downcase].online_req_url
        return url unless url.blank?
      rescue
      end
      begin
        abr.cities_from_zip.each do |city|
          url = abr_settings.cities[city.downcase.strip]&.online_req_url
          return url unless url.blank?
        end
        url = abr_settings.cities[abr.city.downcase.strip].online_req_url
        return url unless url.blank?
      rescue
      end
    end
    abr_settings&.online_req_url
  end
  
  
  def has_ovr_pre_check?(registrant)
    false
  end
  
  def ovr_pre_check(registrant=nil, controller=nil)
    raise "Not Implemented"
  end
  
  def decorate_registrant(registrant=nil, controller=nil)
  end
  
  def require_age_confirmation?
    return false if ovr_settings.blank?
    return ovr_settings["require_age_confirmation"]
  end
  
  def require_id?
    return true if ovr_settings.blank?
    return ovr_settings["require_id"]!=false
  end
  
protected
  def self.class_exists?(class_name)
    klass = Module.const_get(class_name)
    return klass.is_a?(Class)
  rescue NameError
    return false
  end
  
end