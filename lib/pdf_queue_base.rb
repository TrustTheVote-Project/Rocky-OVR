module PdfQueueBase
  
  def queue_url
    ENV["SQS_QUEUE_URL"]
  end
  
  def count
    resp  = queue.get_queue_attributes({
      queue_url: queue_url, # required
      attribute_names: ["ApproximateNumberOfMessages", "ApproximateNumberOfMessagesNotVisible"]
    })
    return (resp.attributes["ApproximateNumberOfMessages"].to_i + resp.attributes["ApproximateNumberOfMessagesNotVisible"].to_i)
  rescue
    return 0
  end
  
  def queue_registrant(registrant_id)
    puts self.class.to_s
    puts queue_url
    resp = queue.send_message({
      queue_url: queue_url, # required
      message_body: "#{self.name}::#{registrant_id}", # required
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
    Rails.logger.error "Registraint #{options[:registrant_id]} not queued for PDF generation!:\n#{e.message}\n#{e.backtrace.join("\n")}"
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
      if self == PriorityPdfGeneration
        next_queue
        return nil
      end
      if self == PdfDeliveryGeneration
        next_queue
        return nil
      end
      sleep(sleep_timeout)
      return nil
    end
  end
  
  def next_queue
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
  
  def receive
    message = retrieve_from_queue
    registrant_id = nil
    generation_class = nil
    if message
      generation_class, registrant_id = message.body.split("::")
      if registrant_id.blank?
        # This is an old message 
        registrant_id = generation_class.dup
        generation_class = self.class.name
      end
    end
    return [registrant_id, message, generation_class]
  end
  
  def klass
    Registrant
  end
  
  def generate(registrant_id, message)
    puts "Generate for #{self.name}"
    r = klass.find(registrant_id)
    if r && r.pdf_ready?        
      Rails.logger.warn "Tried to generate PDF for #{r.id} that was already complete"
      delete_from_queue(message)
    elsif r && r.generate_pdf #(true)
      finalized = r.finalize_pdf
    
      if !finalized
        Rails.logger.error "FAILED to finalize registrant #{r.id} (#{r.errors.inspect}) for message #{message}"
      end
      # puts "Generated #{r.pdf_path}"
      delete_from_queue(message)
    else
      Rails.logger.error "FAILED to generate #{self.name} #{message}"
    end
  end
  
  def receive_and_generate
    puts "Receive and generate for #{self.name}"
    registrant_id, message, klass = receive
    puts registrant_id, message, klass
    if registrant_id && message && klass
      klass.constantize.generate(registrant_id, message)
    else
      next_queue
    end
  rescue Exception => e
    raise e
    Rails.logger.error("#{Time.now} Error finding and generating PDF:\n#{e.message}\n#{e.backtrace.join("\n")}")
    sleep(15)
    #raise e
  end
  
  
end