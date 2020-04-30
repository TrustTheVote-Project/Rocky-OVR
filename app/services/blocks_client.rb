class BlocksClient

  require 'net/http'

  class NetworkingError < StandardError; end
  class InvalidResponseError < NetworkingError; end

  def self.get_token
    path = "account/sign_in"
    headers = {'Content-Type' => 'application/json'}
    
    email = ENV['BLOCKS_USER_EMAIL']
    password = ENV['BLOCKS_USER_PASSWORD']
    
    body = {
      email: email,
      password: password
    }
    
    send(:post, path, body: body, headers: headers)    
  end

  def self.create_shift(canvasser_id:, location_id:, staging_location_id:, shift_start:, shift_end:, shift_type:, soft_count_cards_total_collected:, token:)
    path = "shifts"
    headers = {'Content-Type' => 'application/json'}
    body = {
      shift: {
        canvasser_id: canvasser_id,
        location_id: location_id,
        staging_location_id: staging_location_id,
        shift_start: shift_start,
        shift_end: shift_end,
        shift_type: shift_type,
        soft_count_cards_total_collected: soft_count_cards_total_collected,
      },
      jwt: token
    }
    send(:post, path, body: body, headers: headers)
  end
  
  def self.upload_registrations(shift_id, registrations, shift_status: "voter_registration", token:)
    path = "shifts/#{shift_id}/digital_batch"
    headers = {'Content-Type' => 'application/json'}
    
    body = {
      batch: {
        shift_status: shift_status,
        forms: registrations
      },
      jwt: token
    }
    send(:post, path, body: body, headers: header) 
  end
  
  BASE_PATH = "/api/v1/external/"

  def self.send(method, path, body: {}, params: {}, headers: {})
    uri = URI.join(RockyConf.blocks_configuration.url, BASE_PATH, path)
    uri.query = params.to_query if params.any?
    RequestLogSession.request_log_instance.log_uri(uri) if RequestLogSession.request_log_instance

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
    #request.set_form_data(body) if body.any?
    request.body = body.to_json if body.any?

    Rails.logger.debug "BLOCKS:REQUEST>> #{uri.inspect}"

    response = begin
      RequestLogSession.send_and_log(http, request)
    rescue StandardError => e
      raise NetworkingError, e
    end

    Rails.logger.debug "BLOCKS:RESPONSE>> #{response.inspect}"
    Rails.logger.debug "BLOCKS:RESPONSE>> #{response.body.to_s}"

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
