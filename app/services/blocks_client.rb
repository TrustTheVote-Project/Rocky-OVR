class BlocksClient

  require 'net/http'

  class NetworkingError < StandardError; end
  class InvalidResponseError < NetworkingError; end

  def self.get_token(url: nil, url_client_path: nil)
    path = "account/sign_in"
    headers = {'Content-Type' => 'application/json'}
    
    email = ENV['BLOCKS_USER_EMAIL']
    password = ENV['BLOCKS_USER_PASSWORD']
    
    body = {
      email: email,
      password: password
    }
    
    send(:post, path, body: body, headers: headers, url: url, url_client_path: url_client_path)    
  end
  
  def self.get_locations(turf_id, token:, url: nil, url_client_path: nil)
    path = "turfs/#{turf_id}/locations"
    params = {
      fields: ["name", "id"]
    }
    headers = {'Content-Type' => 'application/json'}
    send(:get, path, params: params, token: token, headers: headers, url: url, url_client_path: url_client_path)
  end
  
  # def self.add_metadata_to_form(form_id, meta_data={}, token:, url: nil, url_client_path: nil)
  #   #591
  #   path = "forms/#{form_id}/add_metadata"
  #   headers = {'Content-Type' => 'application/json'}
  #   body = {
  #     content: meta_data,
  #     jwt: token
  #   }
  #   send(:put, path, body: body, headers: headers, url: url, url_client_path: url_client_path)    
  # end

  def self.create_canvasser(first_name:, last_name:, phone_number:, email:, turf_id:, token:, url: nil, url_client_path: nil)
    path = "turfs/#{turf_id}/canvassers/upsert"
    params = {
      fields: ["first_name", "last_name", "phone_number", "email", "id"]
    }
    headers = {'Content-Type' => 'application/json'}
    body = {
      canvasser: {
        first_name: first_name,
        last_name: last_name,
        phone_number: phone_number,
        email: email
      }
    }
    send(:post, path, body: body, params: params, token: token, headers: headers, url: url, url_client_path: url_client_path)
  end

  def self.canvassers(turf_id, token:, url: nil, url_client_path: nil)
    path = "turfs/#{turf_id}/canvassers"
    params = {
      fields: ["first_name", "last_name", "phone", "email", "id"]
    }
    
    headers = {'Content-Type' => 'application/json'}
    body = {
    }
    send(:get, path, body: body, params: params, token: token, headers: headers, url: url, url_client_path: url_client_path)
  end

  # Notes
  # field_end, field_start ?
  # no more staging location ?
  # do we always pass digital: true if we will later call /digital_batch?
  def self.create_shift(canvasser_id:, location_id:, staging_location_id:, shift_start:, shift_end:, soft_count_cards_total_collected: nil, soft_count_cards_complete_collected: nil, soft_count_cards_incomplete_collected: nil, soft_count_cards_with_phone_collected: nil, token:, url: nil, url_client_path: nil)
    path = "shifts"
    headers = {'Content-Type' => 'application/json'}
    params = {
      fields: ["id", "status"]
    }
    shift = {
      canvasser_id: canvasser_id,
      location_id: location_id,
      #staging_location_id: staging_location_id,
      shift_start: shift_start,
      shift_end: shift_end,
      field_start: shift_start,
      field_end: shift_end,
      #shift_type: shift_type
      digital: true
    }
    shift[:soft_count_cards_total_collected] = soft_count_cards_total_collected unless soft_count_cards_total_collected.nil?
    shift[:soft_count_cards_complete_collected] = soft_count_cards_complete_collected unless soft_count_cards_complete_collected.nil?
    shift[:soft_count_cards_incomplete_collected] = soft_count_cards_incomplete_collected unless soft_count_cards_incomplete_collected.nil?
    shift[:soft_count_cards_with_phone_collected] = soft_count_cards_with_phone_collected unless soft_count_cards_with_phone_collected.nil?
    shift[:soft_count_pre_registration_cards_collected] = 0

    body = {
      shift: shift
    }
    send(:post, path, body: body, params: params, token: token, headers: headers, url: url, url_client_path: url_client_path)
  end
  
  def self.upload_registrations(shift_id, registrations, shift_status: "ready_for_qc", token:, url: nil, url_client_path: nil)
    path = "shifts/#{shift_id}/digital_batch"
    headers = {'Content-Type' => 'application/json'}
    params = {
      fields: ["forms"]
    }
    body = {
      batch: {
        shift_status: shift_status,
        forms: registrations
      }
    }
    send(:post, path, body: body, token: token, headers: headers, url: url, url_client_path: url_client_path) 
  end
  
  BASE_PATH = "/api/v1/external/"

  def self.send(method, path, body: {}, params: {}, headers: {}, url: nil, url_client_path: nil, token: nil)
    base_url = url || RockyConf.blocks_configuration.url
    url_client_path = url_client_path || RockyConf.blocks_configuration.url_client_path

    uri = URI.join(base_url, File.join(url_client_path, BASE_PATH, path))
    params[:jwt] = token if token
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
    when :put
      Net::HTTP::Put
    when :patch
      Net::HTTP::Patch
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

    raise InvalidResponseError, "#{uri}\n#{response.code}: #{response.body}" if response.code != "200"

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
