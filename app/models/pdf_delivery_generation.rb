class PdfDeliveryGeneration
  # attr_accessible :title, :body
  # belongs_to :registrant
  # validates_presence_of :registrant_id
  
  extend PdfQueueBase
  
    
  def self.sleep_timeout
    0
  end
  
  def self.queue_url
    ENV["SQS_PRIORITY_QUEUE_URL"]
  end    
    
  def self.next_queue
    PdfGeneration.receive_and_generate
  end
    
    
  def self.generate(registrant_id, message)
    r = Registrant.find(registrant_id)
    if r && r.pdf_delivery && r.pdf_delivery.pdf_ready?
      Rails.logger.warn "Tried to generate PDF for #{r.id} that was already complete"
      delete_from_queue(message)      
    elsif r && r.pdf_delivery && r.mail_redacted_pdf # See if pdf_delivery has been created so we don't create twice.
      finalized = r.pdf_delivery.finalize_pdf
    
      if !finalized
        Rails.logger.error "FAILED to finalize registrant #{r.id} (#{r.errors.inspect}) for message #{message}"
      end
      # puts "Generated #{r.pdf_path}"
      delete_from_queue(message)
    else
      Rails.logger.error "FAILED to generate #{self.name} #{message}"
    end
  end
  
end