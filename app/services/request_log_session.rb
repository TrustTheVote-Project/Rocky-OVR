class RequestLogSession
  Parameters = Struct.new(:request_log, :registrant, :context) do
    def initialize(registrant, context={ client_id: 'unknown' })
      instance = RequestLog.create!(context.merge(registrant_id: registrant.registrant_id))
      super(instance, registrant)
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
    @current_parameters&.value
  end

  def self.request_log_instance
    current_parameters&.request_log
  end

  def self.registrant
    current_parameters.registrant
  end

  def self.make_call_with_logging(registrant:, client_id:, &block)
    @current_parameters = Concurrent::ThreadLocalVar.new { Parameters.new(registrant, client_id: client_id) }
    instance = current_parameters.request_log

    timing = Timing.measure(&block)
    instance.log_total_duration(timing.duration, timing.error)

    raise timing.error if timing.error.present?
  ensure
    @current_parameters = nil    
  end
end
