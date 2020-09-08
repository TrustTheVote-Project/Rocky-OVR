module AbrSignatureMethods
  METHODS = [
    :voter_signature_image,
    :signature_method,
    :sms_number_for_continue_on_device,
    :email_address_for_continue_on_device,    
  ]
  def allow_desktop_signature?
    false
  end  

  def signature_capture_url
    step_3_abr_url(self.to_param,  :protocol => "https", :host=>RockyConf.default_url_host)
  end

  def allowed_signature_attrs
    # Always allow these methods
    [
      AbrSignatureMethods::METHODS,
      :confirm_email_delivery
    ].flatten
  end

  def collect_signature?
    # For now only collect signatuer if we also deliver via mail
    return RockyConf.absentee_states[home_state_abbrev] && !RockyConf.absentee_states[home_state_abbrev][:email_delivery].blank?
  end

  def deliver_to_elections_office_via_email?
    collect_signature? && signature_method != VoterSignature::PRINT_METHOD
  end

  def status_check_url
    home_state.counties[registration_county][:abr_status_check_url] || home_state.status_check_url
  end

  def status_check_phone
    home_state.counties[registration_county][:abr_status_check_phone] || home_state.registrar_phone
  end

  def elections_office_name
    home_state.counties[registration_county][:abr_contact_name] || "#{home_state.counties[registration_county][:name]} Elections Office"
  end

  def elections_office_email
    Rails.env.production? ? home_state.counties[registration_county][:abr_email_address] : "errors@rockthevote.com"
  end

  def email_address_to_send_form_delivery_from
    RockyConf.from_address
  end

  def validates_signature
    if deliver_to_elections_office_via_email? && advancing_to_step_4?
      self.validates_presence_of(:voter_signature_image)
      self.validates_presence_of(:signature_method)
      self.validates_acceptance_of(:confirm_email_delivery, :accept=>true)
    end
  end

  def signature_pdf_field_name
    nil
  end


end