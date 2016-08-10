class RegistrantValidator < ActiveModel::Validator
  def validate(reg)
    
     if reg.at_least_step_1?
      reg.validates_presence_of   :partner_id #, :unless=>[:remote_partner_id_present?]

      unless reg.use_short_form?
        reg.validates_inclusion_of  :has_state_license, :in=>[true,false], :unless=>[:building_via_api_call]
        reg.validate_date_of_birth
      end
      
      reg.validates_inclusion_of  :will_be_18_by_election, :in=>[true,false], :unless=>[:building_via_api_call]
    
      reg.validates_inclusion_of  :locale, :in => RockyConf.enabled_locales
      reg.validates_presence_of   :email_address, :unless=>:not_require_email_address?
      reg.validates_format_of     :email_address, :with => Authlogic::Regex.email, :allow_blank => true
      validates_zip_code  reg,     :home_zip_code
      reg.validates_presence_of   :home_state_id
      reg.validates_inclusion_of  :us_citizen, :in => [ false, true ], :unless => :building_via_api_call
    end
    
  end
  
  def validates_zip_code(reg, attr_name)
    reg.validates_presence_of(attr_name)
    reg.validates_format_of(attr_name, {:with => /^\d{5}(-\d{4})?$/, :allow_blank => true});

    if reg.errors[attr_name].empty? && !GeoState.valid_zip_code?(reg.send(attr_name))
      reg.errors.add(attr_name, :invalid_zip, :default => nil, :value => reg.send(attr_name))
    end
  end
  
end