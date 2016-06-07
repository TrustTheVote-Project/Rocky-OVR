class PriorityPdfGeneration
  extend PdfQueueBase

  def self.sleep_timeout
    0
  end
  
  def self.queue_url
    ENV["SQS_PRIORITY_QUEUE_URL"]
  end
end
