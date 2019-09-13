class PdfGeneration
  # attr_accessible :title, :body
  # belongs_to :registrant
  # validates_presence_of :registrant_id
  
  extend PdfQueueBase
  
  def self.queue_url
    ENV["SQS_QUEUE_URL"]
  end
  
  
end