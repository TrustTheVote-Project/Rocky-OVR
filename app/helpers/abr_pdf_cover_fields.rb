module AbrPdfCoverFields

  def pdf_cover_fields
    [
        "SUBMIT YOUR COMPLETED SIGNED FORM TO",
        "Request Deadline",
        "Reminders for your state",
    ]
  end

  def make_cover_fields_hash 
    self.pdf_cover_fields.map{ |fieldname| [fieldname, self.send("#{self.class.make_method_name(fieldname)}")] }.to_h
  end

  def submit_your_completed_signed_form_to
    "\n#{state_registrar_address_newlines}"
  end
  
  def request_deadline 
    "\n#{self.cover_state_deadline}"
  end

  def reminders_for_your_state 
    "#{self.cover_state_reminders}"
  end

  def state_registrar_address_newlines
    state_registrar_address.gsub(/<br>|<br\/>/,"\n")
  end

  def cover_state_deadline
    I18n.t("states.custom.#{i18n_key}.abr.request_deadline", default: '')
  end

  def abr_status_check_url
    home_state&.state_customization&.abr_settings&.abr_status_check_url
    #RockyConf.absentee_states[home_state_abbrev]&.abr_status_check_url
  end

  def leo_lookup_url
    home_state&.state_customization&.abr_settings&.leo_lookup_url
  end

  def cover_state_reminders
    tracking_info = I18n.t("states.custom.#{i18n_key}.abr.status_check_instructions", default: "")

    reminders="";
    reminders+= I18n.t("states.custom.#{i18n_key}.abr.finish_instructions_1_hint", default: I18n.t('txt.abr.finish_instructions_1_hint'))
    reminders+="\n";
    if ! tracking_info.blank?
      reminders+= I18n.t('txt.abr.finish_instructions_2').html_safe
      reminders+="\n";
      reminders+= tracking_info
    end
  end

end
        