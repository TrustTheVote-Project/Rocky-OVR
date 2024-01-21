class PostalmethodsClient

  require 'net/http'

  BASE_PATH = "/v1/"

  class NetworkingError < StandardError; end
  class InvalidResponseError < NetworkingError; end

  def self.domain
    "https://api.secure.postalmethods.com"
    #/Letter/send
  end

  def self.api_key
    return ENV['POSTALMETHODS_API_KEY']
  end

  def self.send_letter(url: nil, 
    delivery_id: ,
    pdf_url:
  )
    path = "Letter/send"
    
    body = {
      appendPageForAddress: false,
      replyOnEnvelope: true,
      perforation: false,
      refId: delivery_id,
      fileUrl: pdf_url,
      'returnAddress.Company': "Rock the Vote",
      'returnAddress.AddressLine1': "200 Massachusetts Ave NW, Suite 700",
      'returnAddress.City': 'Washington',
      'returnAddress.State': 'DC',
      'returnAddress.Zipcode': '20001',    
    }
    
    send(:post, path, body: body, url: url)    
  end

  def self.send_letter_with_address(url: nil, 
      delivery_id: ,
      pdf_url: ,
      #send_to: ,
      description: ,
      send_address1: ,
      send_address2: ,
      send_city: ,
      send_state: ,
      send_zipcode: ,
      reply_address_name: ,
      reply_address1: ,
      reply_address2: ,
      reply_address_city: ,
      reply_address_state: ,
      reply_address_zipcode: ,
      return_to: "", 
      return_address1: "",
      return_address2: "",
      return_city: "",
      return_state: "",
      return_zipcode: "" 
    )
    path = "Letter/sendWithAddress"
    
    body = {
      appendPageForAddress: false,
      appendReplyOnEnvelopeAddress: false,
      replyOnEnvelope: true,
      perforation: false,
      refId: delivery_id,
      fileUrl: pdf_url,
      myDescription: description,
      #'sendToAddress.Company': send_to,
      'sendToAddress.AddressLine1': send_address1,
      'sendToAddress.AddressLine2': send_address2,
      'sendToAddress.City': send_city,
      'sendToAddress.State': send_state,
      'sendToAddress.Zipcode': send_zipcode,
      'returnAddress.Company': "Rock the Vote",
      'returnAddress.AddressLine1': "200 Massachusetts Ave NW, Suite 700",
      'returnAddress.City': 'Washington',
      'returnAddress.State': 'DC',
      'returnAddress.Zipcode': '20001',
      'replyonEvelopeAddress.Name': reply_address_name,
      'replyonEvelopeAddress.AddressLine1': reply_address1,
      'replyonEvelopeAddress.AddressLine2': reply_address2,
      'replyonEvelopeAddress.City': reply_address_city,
      'replyonEvelopeAddress.State': reply_address_state,
      'replyonEvelopeAddress.Zipcode': reply_address_zipcode,

      # 'returnAddress.Company': return_to,
      # 'returnAddress.AddressLine1': return_address1,
      # 'returnAddress.AddressLine2': return_address2,
      # 'returnAddress.City': return_city,
      # 'returnAddress.State': return_state,
      # 'returnAddress.Zipcode': return_zipcode,
      
    }
    
    send(:post, path, body: body, url: url)    
  end



  def self.send(method, path, body: {}, headers: {}, url: nil)
    base_url = self.domain || url
    uri = URI.join(base_url, BASE_PATH, path)
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
    
    request["Secret-Key"]  = self.api_key

    headers.each do |key, value|
      request.add_field(key, value)
    end
    form_data = body.stringify_keys.to_a.collect{ |a| a.collect {|v| v.to_s }} # convert everything to strings
    request.set_form form_data, 'multipart/form-data'
    Rails.logger.debug "POSTALMETHODS:REQUEST>> #{uri.inspect}"

    response = begin
      RequestLogSession.send_and_log(http, request)
    rescue StandardError => e
      raise NetworkingError, e
    end

    Rails.logger.debug "POSTALMETHODS:RESPONSE>> #{response.inspect}"
    Rails.logger.debug "POSTALMETHODS:RESPONSE>> #{response.body.to_s}"

    raise InvalidResponseError, "#{uri}\n#{response.code}: #{response.body}" if response.code != "200"

    puts response.body 
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
