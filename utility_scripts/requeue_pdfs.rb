def regenerate(d)
  if d.registrant.pdf_writer.valid?
    if d.registrant.pdf_writer.generate_pdf(true, true, d.registrant.pdf_is_esigned?, d.created_at)
      d.delay.deliver_via_api
      return true
    else
      return false
    end
  else
    return false
  end
end

results = {}

PdfDelivery.where("created_at > ? and api_vendor_id is null", "2023-04-28").includes("registrant").each do |d|
  results[d.id] = regenerate(d)
end