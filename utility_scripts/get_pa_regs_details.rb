csvstr = ""
distribute_reads do
  grommet_reg_uids = Registrant.where(home_state: GeoState["PA"]).where("created_at > ? AND state_ovr_data IS NOT NULL and state_ovr_data != '--- {}\\n'", Date.parse("2020-05-19")).where("state_ovr_data LIKE '%errors%'").pluck(:uid)

  web_regs_uids = StateRegistrants::PARegistrant.where("pa_submission_error IS NOT NULL and pa_submission_error != ''").where("created_at > ?", Date.parse("2020-05-19")).pluck(:registrant_id)

  uids = [grommet_reg_uids, web_regs_uids].flatten

  csvstr = CSV.generate do |csv|
    header = Registrant::CSV_HEADER_EXTENDED
    header << "Signature" 
    csv << 
    Registrant.where(uid: uids).find_each do |r|
      arr = r.to_csv_extended_array
      arr << r.normalized_signature_image
      csv << arr
    end
  end
end

csvstr = CSV.generate do |csv|
  csv << Registrant::CSV_HEADER_EXTENDED
  StateRegistrants::PARegistrant.where("pa_transaction_id IS NOT NULL AND pa_transaction_id != ?", '').includes(:registrant).find_each do |sr|
    arr = sr.registrant.to_csv_extended_array
    arr[46] = sr.confirm_no_penndot_number? ? 'No' : 'Yes'
    arr[47] = sr.confirm_no_dl_or_ssn? ? 'No' : 'Yes'
    csv << arr
  end
end

csvstr = CSV.generate do |csv|
  csv << ["ID", "Registrant ID", "Registrant UID", "partner_id", "created_at", "email", "has_dln", "has_ssn"]
  StateRegistrants::PARegistrant.where(status: "complete").where("created_at > ?", Date.parse("2019-12-31")).includes(:registrant).find_each do |sr|
    csv << [sr.id, sr.registrant&.id, sr.registrant_id, sr.registrant&.partner_id, sr.created_at.in_time_zone("America/New_York").to_s, sr.email, sr.confirm_no_penndot_number? ? 'No' : 'Yes', sr.confirm_no_dl_or_ssn? ? 'No' : 'Yes']
  end
end



  def s3_connection
    @connection ||= Fog::Storage.new({
      :provider                 => 'AWS',
      :aws_access_key_id        => ENV['PDF_AWS_ACCESS_KEY_ID'],
      :aws_secret_access_key    => ENV['PDF_AWS_SECRET_ACCESS_KEY'],
      :region                   => 'us-west-2'
    })    
  end
  
  
  s3_connection.directories.get('rocky-report-objects').files.create(
    :key    => "production/custom/pa-regs-with-original-partner-id.csv",
    :body   => csvstr,
    :content_type => "text/csv",
    :encryption => 'AES256', #Make sure its encrypted on their own hard drives
    :public => false)