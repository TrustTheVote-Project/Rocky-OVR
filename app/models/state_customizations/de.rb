class DE < StateCustomization

  def enabled_for_language?(lang, reg)
    return true if ovr_settings.blank?
    lang_list = ovr_settings["languages"]
    return true if lang_list.blank? || lang_list.empty?
    return lang_list.include?(lang)
  end
  
end