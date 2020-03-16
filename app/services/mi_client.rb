class MiClient

  require 'net/http'

  class NetworkingError < StandardError; end
  class InvalidResponseError < NetworkingError; end

  def self.health_check
    send(:get, 'api/OnlineVoter/HealthCheck')
  end

  # MiClient.street_match(sender_name: 'TESTOVR', address_line_1: '1125 PALMER LN', city: 'EAST LANSING', zip_code: '48823')
  def self.street_match(sender_name:, address_line_1:, city:, zip_code:)
    headers = {'Content-Type' => 'text/json'}
    body = {
      "SenderName" => sender_name,
      "AddressLine1" => address_line_1,
      "City" => city,
      "ZipCode" => zip_code,
    }
    send(:get, 'api/OnlineVoter/GetOnlineVoterStreetMatch', body: body, headers: headers)
  end

  def self.send(method, path, body: {}, params: {}, headers: {})
    uri = URI.join(RockyConf.ovr_states.MI.api_settings.api_url, path)
    uri.query = params.to_query if params.any?

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == 'https'
    # FIXME use proper CA file
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    http.read_timeout = 125

    klass = case method
    when :get
      Net::HTTP::Get
    when :post
      Net::HTTP::Post
    else
      raise ArgumentError
    end
    request = klass.new(uri.request_uri)

    headers.each do |key, value|
      request.add_field(key, value)
    end
    request.set_form_data(body) if body.any?

    Rails.logger.debug "MI:REQUEST>> #{uri.inspect}"

    response = begin 
      http.request(request)
    rescue StandardError => e
      raise NetworkingError, e
    end

    Rails.logger.debug "MI:RESPONSE>> #{response.inspect}"
    Rails.logger.debug "MI:RESPONSE>> #{response.body.to_s}"

    raise InvalidResponseError, "#{response.code}: #{response.body}" if response.code != "200"

    result = begin
      if response.body.present?
        JSON.parse(response.body) 
      else
        nil
      end
    rescue JSON::ParserError => exception
      raise InvalidResponseError, "Invalid JSON: #{response.body}"
    end

    result
  end
end
