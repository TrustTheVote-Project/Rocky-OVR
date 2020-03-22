class RequestLog < ActiveRecord::Base

  RequestData = Struct.new(:request_host, :request_path, :request_headers, :request_body) do
    def initialize(request_host:, request_path:, request_headers:, request_body:)
      super(request_host, request_path, request_headers, request_body)
    end
  end

  ResponseData = Struct.new(:response_code, :response_body, :error_class, :error_message) do
    def initialize(response_code:, response_body:, error_class:, error_message:)
      super(response_code, response_body, error_class, error_message)
    end
  end

  def self.send_and_log(http, request, censor, log_context={})
    error = nil
    result = nil
    duration = 0
    start_time = nil

    log = pre_log(build_request_data(http, request), censor, log_context)
    begin
      start_time = Time.now
      response = http.request(request)
    rescue => e
      error = e
    ensure
      duration = Time.now - start_time
    end
    log.post_log(build_response_data(response, error), duration)

    raise error if error.present?
    response
  end

  def self.pre_log(request_data, censor, log_context)
    params = request_data
      .to_h
      .merge(log_context)
      .merge(client_id: censor.client_id)

    self.create!(censor.protect(params))
  end

  def post_log(response_data, duration)
    params = response_data
      .to_h
      .merge(duration_ms: duration.in_milliseconds.to_i)

    update_attributes(params)
  end

  def self.build_request_data(http, request)
    params = {
      request_host: http.address,
      request_path: request.path,
      request_body: request.body,
      request_headers: request.each_header.map { |h,v| "#{h}=#{v}" }.join(";")
    }

    RequestLog::RequestData.new(params)
  end

  def self.build_response_data(response, error)
    params = {
      response_code: response&.code,
      response_body: response&.body,
      error_class: error&.class&.name,
      error_message: error&.message,
    }

    RequestLog::ResponseData.new(params)
  end
end
