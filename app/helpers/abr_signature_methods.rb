module AbrSignatureMethods
  METHODS = [
    :voter_signature_image,
    :signature_method,
    :sms_number_for_continue_on_device,
    :email_address_for_continue_on_device
  ]
  def allow_desktop_signature?
    true
  end  

  def signature_capture_url
    step_3_abr_url(self.to_param,  :protocol => "https", :host=>RockyConf.default_url_host)
  end

  def signature_attrs
    # Always allow these methods
    AbrSignatureMethods::METHODS
  end

  def capture_signature?
    return RockyConf.absentee_states[home_state_abbrev] && !RockyConf.absentee_states[home_state_abbrev][:email_delivery].blank?
  end

  def validates_signature
    if capture_signature? && advancing_to_step_4?
      self.validates_presence_of(:voter_signature_image)
      self.validates_presence_of(:signature_method)
    end
  end

  def signature_pdf_field_name
    nil
  end


end