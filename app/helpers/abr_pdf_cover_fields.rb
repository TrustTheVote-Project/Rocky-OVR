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
    if home_state_abbrev
        RockyConf.absentee_states[home_state_abbrev]&.abr_status_check_url
    end
  end

  def cover_state_reminders
    reminders="";
    reminders+= I18n.t("states.custom.#{i18n_key}.abr.abr_status_check_intro", default: "")
    reminders+="\n\n";
    reminders+=  abr_status_check_url.to_s
    reminders+="\n\n";
    reminders+= I18n.t("states.custom.#{i18n_key}.abr.state_reminder_1", default: "")
    reminders+="\n";
    reminders+= I18n.t("states.custom.#{i18n_key}.abr.state_reminder_2", default: "")
  end

end
        