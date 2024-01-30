class BallotStatusCheck < ActiveRecord::Base
  include TrackableMethods
  
  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :email
  validates_presence_of :zip
  validates_presence_of :partner_id
  
  validates_format_of :phone, with: /\A(?!([0-9])\1{9})[1-9]\d{2}[-\s]*\d{3}[-\s]*\d{4}\z/, allow_blank: true
  validates_format_of :email, :with => Registrant::EMAIL_REGEX, :allow_blank => true
    
  belongs_to :partner, optional: true

  def state
    zip.present? ? GeoState.for_zip_code(zip.strip) : nil
  end

  def state_abbrev
    state&.abbreviation
  end

  def locale
    "en"
  end

  def collect_email_address?
    true
  end

  def use_state_flow?
    false
  end

  def use_short_form?
    true
  end

  def any_email_opt_ins?
    collect_email_address? && (partner.rtv_email_opt_in || partner.primary? || partner.partner_email_opt_in)
  end
  
  def any_phone_opt_ins?
    partner.rtv_sms_opt_in || partner.partner_sms_opt_in? || partner.primary?
  end

  def state_registrar_office
    @state_registrar_office ||= state && state.abr_office(self.zip)
  end
  def state_registrar_address
    @state_registrar_address ||= state && state.abr_address(self.zip)
  end

  def use_leo_contact?
    return state&.state_customization&.abr_settings&.abr_track_ballot_use_leo != false    
  end

  def abr_status_check_url
    state&.state_customization&.abr_settings&.abr_status_check_url
  end
  
  def abr_track_ballot_url
    state&.state_customization&.abr_settings&.abr_track_ballot_url
  end

  def leo_lookup_url
    state&.state_customization&.abr_settings&.leo_lookup_url
  end

end
