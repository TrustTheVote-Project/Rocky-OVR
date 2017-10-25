class StateRegistrants::PARegistrant < ActiveRecord::Base
  UNITS = {APT: "APARTMENT",
    BSM: "BASEMENT",
    BOX: "BOX #",
    BLD: "BUILDING",
    DEP: "DEPARTMENT",
    FL: "FLOOR",
    FRN: "FRONT",
    HNG: "HANGER",
    LBB: "LOBBY",
    LOT: "LOT",
    LOW: "LOWER",
    OFC: "OFFICE",
    PH: "PENTHOUSE",
    PIE: "PIER",
    POL: "POLL",
    REA: "REAR",
    RM: "ROOM",
    SID: "SIDE",
    SLI: "SLIP",
    SPC: "SPACE",
    STO: "STOP",
    STE: "SUITE",
    TRL: "TRAILER",
    UNI: "UNIT",
    UPP: "UPPER",
    CBN: "CABIN",
    HUB: "HUB",
    SMC: "STUDENT MAILING CENTER",
    TH: "TOWNHOUSE"
  }
  
  COUNTIES =%w(ADAMS ALLEGHENY ARMSTRONG BEAVER BEDFORD BERKS BLAIR BRADFORD BUCKS BUTLER CAMBRIA CAMERON CARBON CENTRE CHESTER CLARION CLEARFIELD CLINTON COLUMBIA CRAWFORD CUMBERLAND DAUPHIN DELAWARE ELK ERIE FAYETTE FOREST FRANKLIN FULTON GREENE HUNTINGDON INDIANA JEFFERSON JUNIATA LACKAWANNA LANCASTER LAWRENCE LEBANON LEHIGH LUZERNE LYCOMING MCKEAN MERCER MIFFLIN MONROE MONTGOMERY MONTOUR NORTHAMPTON NORTHUMBERLAND PERRY PHILADELPHIA PIKE POTTER SCHUYLKILL SNYDER SOMERSET SULLIVAN SUSQUEHANNA TIOGA UNION VENANGO WARREN WASHINGTON WAYNE WESTMORELAND WYOMING YORK)
  
  include RegistrantMethods
  
  validates_with PARegistrantValidator
  

  delegate :titles, :suffixes, :races, :state_parties, to: :registrant
  delegate :requires_race?, :requires_party?, :require_age_confirmation?, :require_id?, :en_localization, :to => :registrant
    
    
  before_create :set_default_opt_ins
    
  def self.from_registrant(reg)
    sr = self.find_by_registrant_id(reg.uid) || self.new
    sr.registrant_id = reg.uid
    sr.email = reg.email_address
    sr.registration_zip_code = reg.home_zip_code
    sr.locale = reg.locale
    sr.status = :step_2
    sr.save!
    sr
  end
  def registrant
    Registrant.find_by_uid(self.registrant_id)
  end
  
  def to_param
    self.registrant_id
  end
  
  def set_default_opt_ins
    self.opt_in_email = true
    self.opt_in_sms = true
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
  
  STEPS=%w(step_1 step_2 step_3 step_4 complete)
  def step_list
    STEPS
  end
  
  def advance!
    self.status = next_step
    self.save!
  end
  
  def aasm_current_state
    status
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
  
  def async_submit_to_online_reg_url
    self.pa_submission_complete = false
    self.save
    self.delay.submit_to_online_reg_url
  end
  
  
  def to_pa_data
    #TODO
  end
  
  def submit_to_online_reg_url
    result = PARegistrationRequest.send_request(self.to_pa_data)
    registrant.pa_submission_complete = true
    registrant.save
    if result[:error].present?
      registrant.pa_submission_error = [result[:error].to_s]
      registrant.save!
      # No retries for this flow
      Rails.logger.warn("PA Registration Error for StateRegistrants::PARegistrant id: #{registrant.id} params:\n#{registrant.state_ovr_data}\n\nErrors:\n#{registrant.pa_submission_error}")
      AdminMailer.pa_registration_error(registrant, registrant.pa_submission_error).deliver
    elsif result[:id].blank? || result[:id]==0
        registrant.pa_submission_error = ["PA returned response with no errors and no transaction ID"]
        #complete it, but go on to PDF generation?
        registrant.pa_transaction_id = nil
        registrant.save!
        Rails.logger.warn("PA Registration Error for StateRegistrants::PARegistrant id: #{registrant.id} params:\n#{registrant.state_ovr_data}\n\nErrors:\n#{registrant.pa_submission_error}")
        AdminMailer.pa_registration_error(registrant, registrant.pa_submission_error).deliver
    else
      registrant.pa_transaction_id = result[:id]
      registrant.save!
      #TODO - modify the original registrant record?
    end
  end
  
  
end
