module PdfQueueBase
  
  def queue_url
    ENV["SQS_QUEUE_URL"]
  end
  
  def queue_registrant(registrant_id)
    resp = queue.send_message({
      queue_url: queue_url, # required
      message_body: "#{registrant_id}", # required
      delay_seconds: 0,
    })
    return resp
  end
  
  def create!(options)
    if options[:registrant_id].blank?
      raise "Cannot create a PdfGeneration with no registrant_id in the options! #{options}"
    end
    queue_registrant(options[:registrant_id])
  rescue Exception => e
    Rails.logger.error "Registraint #{options[:registrant_id]} not queued for PDF generation!:\n#{e.message}\n#{e.backtrace}"
    return false
  end
  
  def queue
    @@queue_client ||= Aws::SQS::Client.new(
      region: 'us-west-2',
      access_key_id: ENV['SQS_AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['SQS_AWS_SECRET_ACCESS_KEY'])
  end
  
  def retrieve_from_queue
    resp = queue.receive_message({
      queue_url: queue_url, # required
      max_number_of_messages: 1,
      wait_time_seconds: 3,
    })
    if resp.messages.any?
      return resp.messages[0]
      #receipt_handle
      #body == registrant_id
    else
      sleep(sleep_timeout)
      return nil
    end
  end
  
  def delete_from_queue(message)
    receipt_handle = message.receipt_handle
    resp = queue.delete_message({
      queue_url: queue_url, # required
      receipt_handle: receipt_handle, # required
    })
    return resp
  end
  
  def sleep_timeout
    3
  end
  
  # def retrieve
  #   pdfgen_id = nil
  #   self.transaction do
  #     pdfgen  = self.where(:locked => false).lock(true).first
  #     if pdfgen
  #       pdfgen.locked = true
  #       pdfgen.save!
  #       pdfgen_id = pdfgen.id
  #     end
  #   end
  #   if pdfgen_id.nil?
  #     # Try an old locked one
  #     self.transaction do
  #       pdfgen  = self.where(:locked => true).where("updated_at < ?", 10.minutes.ago).lock(true).first
  #       if pdfgen
  #         pdfgen.locked = true
  #         pdfgen.updated_at = Time.now
  #         pdfgen.save!
  #         pdfgen_id = pdfgen.id
  #       end
  #     end
  #     if pdfgen_id.nil?
  #       if self.count != 0
  #         Rails.logger.warn "#{Time.now} Couldn't get lock on any #{self.class.name}"
  #       elsif self == PriorityPdfGeneration
  #         PdfGeneration.find_and_generate
  #         return nil
  #       end
  #       sleep(sleep_timeout)
  #       return nil
  #     end
  #   end
  #   return pdfgen_id
  # end
  
  # def self.find_and_remove
  #   pdfgen_id = retrieve
  #   if pdfgen_id
  #     pdfgen = self.find(pdfgen_id)
  #     pdfgen.delete
  #     puts "Removed #{pdfgen.id}"
  #   end
  # end
  
  # def self.find_and_htmlify
  #   pdfgen_id = retrieve
  #   if pdfgen_id
  #     pdfgen = self.find(pdfgen_id)
  #     r = pdfgen.registrant
  #     if r && r.pdf_writer.registrant_to_html_string
  #       r.finalize_pdf
  #       puts "Generated HTML for #{r.id}"
  #       pdfgen.delete
  #     else
  #       puts "FAILED to generate HTML for #{r.id}"
  #     end
  #   end
  # end
  
  def receive_and_generate
    message = retrieve_from_queue
    if message
      registrant_id = message.body
      r = Registrant.find(registrant_id)
      if r && r.pdf_ready?        
        Rails.logger.warn "Tried to generate PDF for #{r.id} that was already complete"
        delete_from_queue(message)
      elsif r && r.generate_pdf #(true)
        finalized = r.finalize_pdf
      
        if !finalized
          Rails.logger.error "FAILED to finalize registrant #{r.id} from pdfgen id #{pdfgen_id} (#{r.errors.inspect})"
        end
        # puts "Generated #{r.pdf_path}"
        delete_from_queue(message)
      else
        Rails.logger.error "FAILED to generate #{self.class.name} id #{pdfgen_id}"
      end
    end
  rescue Exception => e
    Rails.logger.error("#{Time.now} Error finding and generating PDF:\n#{e.message}\n#{e.backtrace}")
    sleep(15)
    #raise e
  end
  
  # def find_and_generate
  #   pdfgen_id = retrieve
  #   if pdfgen_id
  #     pdfgen = self.find(pdfgen_id, :include => :registrant)
  #     r = pdfgen.registrant
  #
  #     if r && r.pdf_ready?
  #       Rails.logger.warning "Tried to generate PDF for #{r.id} that was already complete"
  #     elsif r && r.generate_pdf #(true)
  #       finalized = r.finalize_pdf
  #
  #       if !finalized
  #         Rails.logger.error "FAILED to finalize registrant #{r.id} from pdfgen id #{pdfgen_id} (#{r.errors.inspect})"
  #       end
  #       # puts "Generated #{r.pdf_path}"
  #       pdfgen.delete
  #     else
  #       Rails.logger.error "FAILED to generate #{self.class.name} id #{pdfgen_id}"
  #     end
  #   end
  # rescue Exception => e
  #   raise e
  #   Rails.logger.error "#{Time.now} Error finding and generating PDF:\n#{e.message}\n#{e.backtrace}"
  #   sleep(15)
  #   #raise e
  # end
  
end