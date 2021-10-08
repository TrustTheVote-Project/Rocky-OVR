class RequestLog < ActiveRecord::Base
  
  before_save :truncate_cols

  def truncate_cols
    req_size = RequestLog.columns_hash['request_body'].limit || 65535
    self.request_body = self.request_body.to_s.truncate(req_size)
    resp_size = RequestLog.columns_hash['response_body'].limit || 65535
    self.response_body = self.response_body.to_s.truncate(resp_size)
  end
    
  def log_uri(uri)
    update_attributes(request_uri: uri)
  end

  def log_request(http, request)
    request_data = RequestLog.build_request_data(http, request)
    update_attributes(RequestLogSession.censor.protect(request_data, RequestLogSession.registrant))
  end

  def log_response(response, duration, error)
    response_data = RequestLog
      .build_response_data(response)
      .merge(build_error_messages(error))
      .merge(RequestLog.build_duration_data(duration, :network_duration_ms))

    update_attributes(RequestLogSession.censor.protect(response_data, RequestLogSession.registrant))
  end

  def log_error(error)
    update_attributes(RequestLogSession.censor.protect(build_error_messages(error)))
  end

  def log_total_duration(duration, error=nil)
    data = RequestLog
      .build_duration_data(duration, :total_duration_ms)
      .merge(build_error_messages(error))
    censored_data = RequestLogSession.censor.protect(data, RequestLogSession.registrant)
    update_attributes(censored_data)
  end

  def self.build_request_data(http, request)
    {
      request_body: request.body || request.instance_variable_get(:@body_data),
      request_headers: request.each_header.map { |h,v| "#{h}=#{v}" }.join(";"),
    }
  end

  def self.build_response_data(response)
    {
      response_code: response&.code,
      response_body: response&.body&.force_encoding("UTF-8"),
    }
  end

  def self.build_duration_data(duration, key)
    {
      key => duration.in_milliseconds.to_i,
    }
  end

  def build_error_messages(error)
    new_error = nil
    if error.present?
      if error.is_a?(Exception)
        new_error = "#{error.class.name}: #{error.message}".force_encoding("UTF-8")
      else
        new_error = "#{error}".force_encoding("UTF-8")
      end
    end

    { error_messages: [error_messages, new_error].compact.join("\n") }
  end
end
