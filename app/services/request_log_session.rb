class RequestLogSession
  class BaseCensor
    def self.protect(request_data=nil, registrant=nil)
      return request_data
    end
  end
  Parameters = Struct.new(:request_log, :context, :censor, :registrant, :abr) do
    def initialize(registrant=nil, context={ client_id: 'unknown' }, censor=nil, abr=nil)
      instance = RequestLog.create!(context.merge(registrant_id: registrant&.uid, abr_id: abr&.uid))
      super(instance, context, censor || BaseCensor, registrant, abr)
    end
  end

  def self.send_and_log(http, request)
    response = nil
    instance = current_parameters&.request_log

    instance.log_request(http, request) if instance
    timing = Timing.measure do
      response = http.request(request)
    end
    instance.log_response(response, timing.duration, timing.error) if instance

    raise timing.error if timing.error.present?
    response
  end

  def self.current_parameters
    @@current_parameters ||= nil
    @@current_parameters&.value
  end

  def self.request_log_instance
    current_parameters&.request_log
  end

  def self.registrant
    current_parameters&.registrant
  end
  
  def self.abr
    current_parameters&.abr
  end
  
  def self.censor
    current_parameters&.censor
  end

  def self.make_call_with_logging(registrant:, client_id:, censor: nil, abr: nil, &block)
    @@current_parameters = Concurrent::ThreadLocalVar.new { Parameters.new(registrant, {client_id: client_id}, censor, abr) }
    instance = current_parameters.request_log

    timing = Timing.measure(&block)
    instance.log_total_duration(timing.duration, timing.error)

    raise timing.error if timing.error.present?
  ensure
    @current_parameters = nil    
  end
end
