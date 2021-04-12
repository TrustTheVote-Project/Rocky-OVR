module AbrHelper

  def current_step
    @current_step
  end

  def find_partner
    @partner = Partner.find_by_id(params[:partner]) || Partner.find(Partner::DEFAULT_ID)
    @partner_id = @partner.id
    set_params
  end
  
  def set_params
    @use_short_form = true
    @old_wl = @partner && @partner.whitelabeled? && @partner.any_css_present? && !@partner.partner3_css_present?
    @locale = 'en'
    @votercheck = params[:votercheck].to_s.downcase
    @source = params[:source]
    @tracking = params[:tracking]
    @email = params[:email]
    @first_name = params[:first_name]
    @last_name = params[:last_name]
    @state_abbrev = params[:state_abbrev] || params[:state]
    @zip = params[:zip]
    @home_state = @state_abbrev.blank? ? nil : GeoState[@state_abbrev.to_s.upcase]
    @home_state ||= @zip ? GeoState.for_zip_code(@zip.strip) : nil
  end
    
end