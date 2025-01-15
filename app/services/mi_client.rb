class MiClient
  require 'net/http'

  # Custom error classes for networking issues and invalid responses
  class NetworkingError < StandardError; end
  class InvalidResponseError < NetworkingError; end

  # Health check endpoint to verify API availability
  def self.health_check
    send(:get, 'api/OnlineVoter/HealthCheck')
  end

  # Post voter information using NIST format
  # Example usage:
  # payload = JSON.parse(File.read('spec/fixtures/files/voter_nist.json'))
  # MiClient.post_voter_nist(payload)
  # MI:RESPONSE>> #<Net::HTTPOK 200 OK readbody=true>
  # MI:RESPONSE>> {"SenderName":"TESTOVR","IsValid":false, ...
  def self.post_voter_nist(payload)
    # return {"VoterStatusId" => "0.0"}
    headers = { 'Content-Type' => 'application/json' }
    send(:post, 'api/OnlineVoter/PostOnlineVoter_Nist', body: payload, headers: headers)
  end

  # Perform street match for address verification
  # Example usage:
  # MiClient.street_match(
  #   sender_name: 'TESTOVR',
  #   address_line_1: '1125 PALMER LN',
  #   city: 'EAST LANSING',
  #   zip_code: '48823'
  # )
  def self.street_match(sender_name:, address_line_1:, city:, zip_code:)
    headers = { 'Content-Type' => 'application/json' }
    body = {
      "SenderName" => sender_name,
      "AddressLine1" => address_line_1,
      "City" => city,
      "ZipCode" => zip_code
    }
    send(:get, 'api/OnlineVoter/GetOnlineVoterStreetMatch', body: body, headers: headers)
  end

  # Load client private key from environment variable
  def self.cert_key
    OpenSSL::PKey::RSA.new(ENV['MI_CERT_KEY'])
  end

  # Load client certificate from environment variable
  def self.cert
    OpenSSL::X509::Certificate.new(ENV['MI_CERT'])
  end

  # Send an HTTP request to the MI API
  def self.send(method, path, body: {}, params: {}, headers: {})
    uri = URI.join(RockyConf.ovr_states.MI.api_settings.api_url, path)
    uri.query = params.to_query if params.any?
    RequestLogSession.request_log_instance.log_uri(uri) if RequestLogSession.request_log_instance

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == 'https'
    http.cert = self.cert
    http.key = self.cert_key
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE # CA certificate validation disabled as per MI's requirements
    http.read_timeout = 125

    # Determine HTTP method (GET or POST)
    klass = case method
    when :get
      Net::HTTP::Get
    when :post
      Net::HTTP::Post
    else
      raise ArgumentError, "Unsupported HTTP method: #{method}"
    end

    # Create HTTP request object
    request = klass.new(uri.request_uri)

    # Set request headers
    default_headers = {
      'User-Agent' => 'MiClient/1.0', # Custom User-Agent to avoid bot detection
      'Content-Type' => 'application/json'
    }
    headers = default_headers.merge(headers)
    headers.each do |key, value|
      request.add_field(key, value)
    end

    # Set request body for POST
    request.body = body.to_json if body.any?

    Rails.logger.debug "MI:REQUEST>> #{uri.inspect}"

    # Send the request and log the response
    response = begin
      RequestLogSession.send_and_log(http, request)
    rescue StandardError => e
      raise NetworkingError, e
    end

    Rails.logger.debug "MI:RESPONSE>> #{response.inspect}"
    Rails.logger.debug "MI:RESPONSE>> #{response.body.to_s}"

    # Raise error if response is not 200 OK
    raise InvalidResponseError, "#{response.code}: #{response.body}" if response.code != "200"

    # Parse JSON response if present
    result = begin
      if response.body.present?
        JSON.parse(response.body)
      else
        nil
      end
    rescue JSON::ParserError => e
      raise InvalidResponseError, "Invalid JSON: #{response.body}"
    end

    result
  end
end
