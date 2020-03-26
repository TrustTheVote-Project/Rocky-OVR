class RequestLog < ActiveRecord::Base

  def log_uri(uri)
    update_attributes(request_uri: uri)
  end

  def log_request(http, request)
    request_data = RequestLog.build_request_data(http, request)
    update_attributes(MiCensor.protect(request_data))
  end

  def log_response(response, duration, error)
    response_data = RequestLog
      .build_response_data(response)
      .merge(build_error_messages(error))
      .merge(RequestLog.build_duration_data(duration, :network_duration_ms))

    update_attributes(MiCensor.protect(response_data))
  end

  def log_total_duration(duration, error=nil)
    data = RequestLog
      .build_duration_data(duration, :total_duration_ms)
      .merge(build_error_messages(error))

    update_attributes(MiCensor.protect(data))
  end

  def self.build_request_data(http, request)
    {
      request_body: request.body,
      request_headers: request.each_header.map { |h,v| "#{h}=#{v}" }.join(";"),
    }
  end

  def self.build_response_data(response)
    {
      response_code: response&.code,
      response_body: response&.body,
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
      new_error = "#{error.class.name}: #{error.message}"
    end

    { error_messages: [error_messages, new_error].compact.join("\n") }
  end
end
