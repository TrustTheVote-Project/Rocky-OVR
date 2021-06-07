class StateRegistrants::Base < ActiveRecord::Base
  self.abstract_class = true

  attr_protected :id, :updated_at, :created_at
  
  include RegistrantMethods
  
  delegate :use_state_flow?, :skip_state_flow?, :skip_state_flow!, to: :registrant
  delegate :any_ask_for_volunteers?, :ask_for_primary_volunteers?, :question_1, :question_2, to: :registrant
  delegate :titles, :suffixes, :races, :state_parties, :phone_types, :partner, :partner_id, :state_registrar_address, :rtv_and_partner_name, :home_state_email_instructions, :email_address_to_send_from,  :finish_iframe_url, :javascript_disabled?, :canvassing_shift, to: :registrant
  delegate :has_phone?, :is_fake?, :requires_race?, :requires_party?, :require_age_confirmation?, :require_id?, :en_localization, :to => :registrant
  
  delegate :ask_for_partner_volunteers?, to: :registrant

  def check_valid_for_state_flow!
    # by default, does nothing
  end

  before_create :set_default_opt_ins

  attr_accessor :new_locale
  
  
  def self.from_registrant(reg)
    sr = self.find_by_registrant_id(reg.uid) || self.new
    sr.registrant_id = reg.uid
    sr.status ||= :step_2
    sr.set_from_original_registrant
    sr
  end
  
  include Rails.application.routes.url_helpers
  def default_url_options
    ActionMailer::Base.default_url_options
  end
  
  
  def signature_capture_url
    update_state_registrant_url(self.to_param, self.signature_step)
  end
  
  def voter_signature_image
    read_attribute(:voter_signature_image)
  rescue
    nil
  end
  
  def registration_county
    read_attribute(:registration_county)
  end
  
  
  def pdf_assistant_info
    nil
  end
  
  def has_other_party?
    false
  end
  
  def name_title_key
    key_for_attribute(:name_title, 'titles')
  end
  def english_name_title
    english_attribute_value(name_title_key, 'titles')
  end
  def name_suffix_key
    key_for_attribute(:name_suffix, 'titles')
  end
  def english_name_suffix
    english_attribute_value(name_suffix_key, 'titles')
  end
  

  def check_locale_change
    if !self.new_locale.blank? && self.new_locale != self.locale
      selected_name_title_key = name_title_key
      selected_name_suf_key = name_suffix_key
      selected_race_key = race_key
      party_idx = self.respond_to?(:party) && self.party ? state_parties.index(self.party) : nil
      selected_phone_key = self.respond_to?(:phone_type) ? phone_type_key : nil
      
      self.locale = self.new_locale
      self.registrant.locale = self.locale #So state_parties returns the correct new list
       
      self.name_title=I18n.t("txt.registration.titles.#{selected_name_title_key}", locale: self.locale) if selected_name_title_key
      self.name_suffix=I18n.t("txt.registration.suffixes.#{selected_name_suf_key}", locale: self.locale) if selected_name_suf_key
      self.race = I18n.t("txt.registration.races.#{selected_race_key}", locale: self.locale) if selected_race_key
      self.party = state_parties[party_idx] if !party_idx.nil?
      self.phone_type=I18n.t("txt.registration.phone_types.#{selected_phone_key}", locale: self.locale) if !selected_phone_key.blank?
      
      self.save(validate: false)
      self.update_original_registrant
    end
  end
  
  belongs_to :registrant, primary_key: :uid
  # def registrant
  #   @registrant ||= Registrant.find_by_uid(self.registrant_id)
  # end
  
  def uid
    self.registrant_id
  end
  def to_param
    self.registrant_id
  end
  
  def set_default_opt_ins
    self.opt_in_email = true
  end
  
  def current_step
    if status =~ /step_(\d)/
      $1
    else
      num_steps
    end
  end
  
  def is_fake
    false
  end
  
  def short_form?
    true
  end
  def use_short_form?
    true
  end
  
  def home_state
    registration_zip_code.blank? ? GeoState[self.default_state_abbrev] : GeoState.for_zip_code(registration_zip_code.strip)
  end
  
  
  def home_state_abbrev
    home_state&.abbreviation
    #"PA"
  end
  def home_state_name
    #"Pennsylvania"
    home_state.name
  end
  
  def step_list
    self.steps
  end
  
  def should_advance(params)
    params[:skip_advance] != "true"
  end  
  
  def custom_advance(controller, params)
  end
  
  def advance!
    self.status = next_step
    self.save!
  end
  
  def aasm_current_state
    status
  end

  def attributes=(*args)
    super(*args)
    update_original_registrant
  end
  
  def custom_state_flow_error_message
    return nil
  end
  
  # Whether the user has gone through all steps/data entry
  def complete?
    raise NotImplementedError
  end
  
  def submitted?
    raise NotImplementedError
  end
  
  def state_api_error   
  end
  
  def state_transaction_id
    raise NotImplementedError
  end
  
  def cleanup!
    raise NotImplementedError
  end
  
  def num_steps
    raise NotImplementedError
  end
  
  def default_state_abbrev
    raise NotImplementedError
  end
  
  def steps
    raise NotImplementedError
  end
  
  def async_submit_to_online_reg_url
    raise NotImplementedError
  end
  
  def submit_to_online_reg_url
    raise NotImplementedError
  end
  
  def mappings
    raise NotImplementedError
  end
  
  def set_from_original_registrant
    raise NotImplementedError
  end
  
  def update_original_registrant
    raise NotImplementedError
  end

  def send_chase_email?
    true
  end
end