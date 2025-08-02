module CatalistLookupReportingMethods
  CSV_HEADER = [
    "uid", 
    "first", 
    "middle", 
    "last", 
    "suffix", 
    "gender", 
    "birthdate", 
    "address", 
    "city", 
    "state_abbrev", 
    "zip", 
    "county", 
    "phone", 
    "email", 
    "created_at", 
    "updated_at", 
    "match_status", 
    "partner_id", 
    "tracking_source", 
    "tracking_id", 
    "phone_type", 
    "opt_in_email", 
    "opt_in_sms", 
    "partner_opt_in_email", 
    "partner_opt_in_sms",
    "abr_uid",
    "registrant_uid",
    "utm_source",
    "utm_medium",
    "utm_campaign",
    "utm_term",
    "utm_content",
    "other_parameters",
  ]

  

  def to_csv_array
    CSV_HEADER.collect{|m| self.send(m) }
  end

  def abr_uid
    self.abr&.uid
  end

  def registrant_uid
    self.catalist_lookups_registrant&.registrant_uid
  end

  def match_status
    return match && match["status"]
  end

end