module AbrReportingMethods
  CSV_HEADER = [
    :uid,
    :current_step,
    :max_step,
    :tracking_source,
    :tracking_id,
    :email,
    :first_name,
    :middle_name,
    :last_name,
    :name_suffix,
    :street_number,
    :street_name,
    :street_line2,
    :unit,
    :city,
    :registration_county,
    :home_state_abbrev,
    :zip,
    :phone,
    :phone_type,
    :date_of_birth,
    :created_at,
    :opt_in_email,
    :opt_in_sms,
    :partner_opt_in_email,
    :partner_opt_in_sms,
    :votercheck,
    :pdf_ready,
    :finish_with_state,
    :confirm_email_delivery, #whether a user confirms to have their ABR delivered via email
    :viewed_steps,
  ]

  def viewed_steps
    render_view_events.collect{|te| te.tracking_data[:rendered_step] }.join(",")
  end

  def to_csv_array
    CSV_HEADER.collect{|m| self.send(m) }
  end
end