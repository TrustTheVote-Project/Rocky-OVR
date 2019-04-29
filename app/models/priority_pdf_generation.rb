class PriorityPdfGeneration
  extend PdfQueueBase

  def self.sleep_timeout
    0
  end
  
  def self.queue_url
    ENV["SQS_PRIORITY_QUEUE_URL"]
  end
  
  def self.next_queue
    PdfDeliveryGeneration.receive_and_generate
  end
  
end
