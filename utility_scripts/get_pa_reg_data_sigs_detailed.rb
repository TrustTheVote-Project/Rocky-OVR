ids = []
r.deliveries.each do |d|
  d.registrant.pdf_writer.generate_pdf(true, true, d.registrant.pdf_is_esigned?, d.created_at)
end
pp ds

d.registrant.pdf_writer.generate_pdf(true, true, d.registrant.pdf_is_esigned?, d.created_at)

# regs = []
# Registrant.where("created_at > ? and created_at < ?", Date.parse("2022-09-17"), Date.parse("2022-09-24")).where(status: "complete").includes(:pdf_delivery, :voter_signature).find_in_batches(batch_size: 1000) do |batch|
#   batch.each do |r|
#     regs.push([r.id, r.uid, r.requested_pdf_assistance?])
#   end
# end

csvstr = ''
1.times do
  csvstr = CSV.generate do |csv|
    StateRegistrants::PARegistrant.where("created_at < ?", Date.parse("2022-09-02")).where("original_partner_id IS NOT NULL and original_partner_id != ''").find_in_batches(batch_size: 5000) do |batch|
      batch.each do |r|
        csv << [r.registrant_id, r.original_partner_id]
      end
    end
  end
end


uids = []
app_id_sigs = {}
counties = {}
genders = {}
data = {}
csvstr = ""

StateRegistrants::PARegistrant.where(registrant_id: uids).find_each do |sr|
  app_id_sigs[sr.registrant_id] = sr.voter_signature_image
  counties[sr.registrant_id] = sr.registration_county
  genders[sr.registrant_id] = sr.registrant.gender
  data[sr.registrant_id] = sr.registrant.to_csv_extended_array
end
Registrant.where(uid: uids).find_each do |r|
  if r.is_grommet? && uids.include?(r.uid)
    app_id_sigs[r.uid] = r.grommet_submission["signature"] ? "data:#{r.grommet_submission["signature"]["mime_type"]};base64,#{r.grommet_submission["signature"]["image"]}" : "no sig"      
    counties[r.uid] = r.home_county
    genders[r.uid] = r.gender
    data[r.uid] = r.to_csv_extended_array
  end
end



csvstr = CSV.generate do |csv|
  head = [] #Registrant::CSV_HEADER_EXTENDED
  head << "County"
  head << "Gender"
  head << "Signature"
  csv << head
  1.times do
    uids.each do |id|
      if data[id]
        arr = [] #data[id]
        arr << counties[id]
        arr << genders[id]
        arr << app_id_sigs[id]
        csv << arr
      else
        csv << ["not found"]
      end
    end
  end
end

puts csvstr




app_id_sigs = {}
counties = {}
genders = {}
data = {}
csvstr = ""
distribute_reads do
  StateRegistrants::PARegistrant.where(pa_transaction_id: ids).includes(:registrant).find_each do |sr|
    app_id_sigs[sr.pa_transaction_id] = sr.voter_signature_image
    counties[sr.pa_transaction_id] = sr.registration_county
    genders[sr.pa_transaction_id] = sr.registrant.gender
    data[sr.pa_transaction_id] = sr.registrant.to_csv_extended_array
  end
end


pa = GeoState['PA']

distribute_reads do
  Registrant.where(home_state: pa).where("state_ovr_data IS NOT NULL and status='complete' and created_at > ?", Date.parse("2020-01-01")).find_each do |r|
    if r.is_grommet? && ids.include?(r.state_ovr_data["pa_transaction_id"])
      app_id_sigs[r.state_ovr_data["pa_transaction_id"]] = r.grommet_submission["signature"] ? "data:#{r.grommet_submission["signature"]["mime_type"]};base64,#{r.grommet_submission["signature"]["image"]}" : "no sig"      
      counties[r.state_ovr_data["pa_transaction_id"]] = r.home_county
      genders[r.state_ovr_data["pa_transaction_id"]] = r.gender
      data[r.state_ovr_data["pa_transaction_id"]] = r.to_csv_extended_array
    end
  end
end

csvstr = CSV.generate do |csv|
  head = Registrant::CSV_HEADER_EXTENDED
  head << "County"
  head << "Gender"
  head << "Signature"
  csv << head
  1.times do
    ids.each do |id|
      if data[id]
        arr = data[id]
        arr << counties[id]
        arr << genders[id]
        arr << app_id_sigs[id]
        csv << arr
      else
        csv << ["not found"]
      end
    end
  end
end

