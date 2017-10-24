class StateRegistrants::PARegistrant < ActiveRecord::Base
  # attr_accessible :title, :body

  attr_accessor :new_locale
  belongs_to :registrant
  
  delegate :titles, :suffixes, to: :registrant
    
  def self.from_registrant(reg)
    sr = self.find_by_registrant_id(reg.id) || self.new
    sr.registrant_id = reg.id
    sr.email = reg.email_address
    sr.registration_zip_code = reg.home_zip_code
    sr.locale = reg.locale
    sr.status = :step_2
    sr.save!
    sr
  end
  
  def num_steps
    4
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
  def use_state_flow?
    true
  end
  def short_form?
    true
  end
  def use_short_form?
    true
  end
  def home_state_abbrev
    "PA"
  end
  def home_state_name
    "Pennsylvania"
  end
  
  
  # TODO make this reusable
  def check_locale_change
    if !self.new_locale.blank? && self.new_locale != self.locale
      selected_name_title_key = name_title_key
      selected_name_suf_key = name_suffix_key
      selected_prev_name_title_key = prev_name_title_key
      selected_prev_name_suf_key = prev_name_suffix_key
      selected_race_key = race_key
      party_idx = state_parties.index(self.party)
      selected_phone_key = phone_type_key
      
      self.locale = self.new_locale
      
      self.name_title=I18n.t("txt.registration.titles.#{selected_name_title_key}", locale: self.locale)
      self.name_suffix=I18n.t("txt.registration.suffixes.#{selected_name_suf_key}", locale: self.locale)
      self.prev_name_title=I18n.t("txt.registration.titles.#{selected_prev_name_title_key}", locale: self.locale)
      self.prev_name_suffix=I18n.t("txt.registration.suffixes.#{selected_prev_name_suf_key}", locale: self.locale)
      self.race = I18n.t("txt.registration.races.#{selected_race_key}", locale: self.locale)
      self.party = state_parties[party_idx] if party_idx
      self.phone_type=I18n.t("txt.registration.phone_types.#{selected_phone_key}", locale: self.locale)
      
    end
  end
  
end
