deliveries = PdfDelivery.where(pdf_ready: nil).where("created_at > ? ", 6.months.ago).includes(:registrant)
deliveries.each do |d|
  puts PdfDeliveryGeneration.create!(registrant_id: d.registrant_id)
end


rs_ids = Registrant.where(status: "complete", pdf_ready: nil).where("finish_with_state != ?", true).where("using_state_online_registration != ?", true).where("created_at > ?", 6.months.ago).pluck(:id)

delivered_ids = PdfDelivery.where(registrant_id: rs_ids).where(pdf_ready: true).pluck(:registrant_id)
submitted_via_api_ids = Registrant.includes(:home_state).find(rs_ids).collect {|r| r.submitted_via_state_api? ? r.id : nil}.compact

puts rs_ids.count - (delivered_ids.count + submitted_via_api_ids.count)

bad_rs = rs_ids - (delivered_ids + submitted_via_api_ids)

.select {|r| r.pdf_delivery.nil? || r.pdf_delivery.pdf_ready.nil? }

rs.includes(:pdf_delivery).collect {|r| r.pdf_delivery }.compact.count

rs.includes(:pdf_delivery).each do |r|
  puts [r.id, r.reminders_left, !!r.pdf_delivery, r.pdf_delivery ? r.pdf_delivery.pdf_ready : r.pdf_ready].join("::")
end

# finish_with_state 
# using_state_online_registration
# pdf_delivery.pdf_ready
# pdf_ready
# final_reminder_delivered
