class RemotePartner < ActiveResource::Base
  self.site = RockyConf.api_host_name
  self.prefix = "/api/v3/"
  self.element_name = "partner"
  
  
  def self.find_by_id(id)
    if !id.blank?
      self.find(id)
    else
      nil
    end
  rescue
    nil
  end
  
  def to_param
    self.id.to_s
  end
  
  (Partner.column_names + [:custom_logo, :header_logo_url]).each do |column|
    define_method "#{column}" do
      self.attributes[column] || nil
    end
    define_method "#{column}=" do |val|
      self.attributes[column]= val
    end
  end
  
  [:custom_logo, :whitelabeled, 
   :application_css_present, :registration_css_present, :partner_css_present,
        :ask_for_volunteers,
        :partner_ask_for_volunteers,
        :rtv_email_opt_in,
        :partner_email_opt_in,
        :rtv_sms_opt_in,
        :partner_sms_opt_in
  ].each do |method|
      
     define_method("#{method}?") do
       self.send("#{method}") == true
     end
      
  end
  

  
end