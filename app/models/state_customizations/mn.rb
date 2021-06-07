class MN < StateCustomization
  def enabled_for_language?(locale, reg=nil)
    # This is for transitions to onine state registration vs direct API calls
    false
  end
  
  def use_state_flow?(registrant)
    #return false
    return false if ovr_settings.blank?
    lang_list = ovr_settings["languages"]
    return true if lang_list.blank? || lang_list.empty?
    return lang_list.include?(registrant.locale)    
    
    # return false if reg && !reg.has_state_license? && reg.does_not_have_ssn4?
    # return false if reg && !reg.will_be_18_by_election?
    
  end
  
end