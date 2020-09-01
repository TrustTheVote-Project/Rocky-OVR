class CatalistClient

  require 'net/http'

  class NetworkingError < StandardError; end
  class InvalidResponseError < NetworkingError; end

  def self.get_token
    path = "oauth/token"
    
    client_id = ENV['CATALIST_CLIENT_ID']
    client_secret = ENV['CATALIST_CLIENT_SECRET']
    audience = RockyConf.catalist.audience
    
    body = {
      client_id: client_id,
      client_secret: client_secret,
      audience: audience,
      grant_type: "client_credentials"
    }
    
    send(:post, path, body: body, url: RockyConf.catalist.auth_url)    
  end
  
  #mr3/match/standard/retrieve/standard
  
  def self.retrieve(params:, token:)
    path = "mr3/match/standard/retrieve/standard"
    send(:get, path, params: params.merge(token: token))
  end
  
  BASE_PATH = "/"

  def self.send(method, path, body: {}, params: {}, headers: {}, url: nil)
    url ||= RockyConf.catalist.url
    uri = URI.join(url, BASE_PATH, path)
    uri.query = params.to_query if params.any?
    RequestLogSession.request_log_instance.log_uri(uri) if RequestLogSession.request_log_instance

    headers = headers.merge({'Content-Type' => 'application/json'})
    

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

    Rails.logger.debug "CATALIST:REQUEST>> #{uri.inspect}"

    response = begin
      RequestLogSession.send_and_log(http, request)
    rescue StandardError => e
      raise e
      raise NetworkingError, e
    end

    Rails.logger.debug "CATALIST:RESPONSE>> #{response.inspect}"
    Rails.logger.debug "CATALIST:RESPONSE>> #{response.body.to_s}"

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
