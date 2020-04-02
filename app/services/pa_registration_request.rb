class PARegistrationRequest

  require 'net/http'

  PREFIX = '<APIOnlineApplicationData xmlns="OVRexternaldata"><record>'
  POSTFIX = '</record></APIOnlineApplicationData>'

  def self.send_request(params, partner_api_key = nil, locale='en')
    
    sysparm_language = locale.to_s.downcase == 'es' ? '1' : '0'
    
    # print 'PA:REQUEST>> ', params, "\n"
    server = RockyConf.ovr_states.PA.api_settings.api_url # 'https://paovrwebapi.votespa.com'
    api_key = partner_api_key || RockyConf.ovr_states.PA.api_settings.api_key
    url = "/SureOVRWebAPI/api/ovr?JSONv2&sysparm_AuthKey=#{api_key}&sysparm_action=SETAPPLICATION&sysparm_Language=#{sysparm_language}"

    uri = URI.parse(server)
    RequestLogSession.request_log_instance.log_uri(uri)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    http.read_timeout = 125
    request = Net::HTTP::Post.new(url)
    request.add_field('Content-Type', 'application/json')
    request.add_field('Cache-Control', 'no-cache')

    request.body = prepare_request(params)
    
    
    Rails.logger.debug 'PA:REQUEST>> '+ request.body.to_s

    response = begin
      RequestLogSession.send_and_log(http, request)
    rescue StandardError => e
      raise NetworkingError, e
    end

    Rails.logger.debug 'PA:RESPONSE>> ' + response.to_s
    Rails.logger.debug 'PA:RESPONSE>> ' + response.body.to_s

    raise "HTTP Error: #{response.body}" unless response.code == "200"

    parse_response(response.body).merge(request: request.body, response: response.body)
  end

  def self.prepare_request(params)
    body = params.map do |k,v|
      # TODO escape?
      "<#{k}>#{v}</#{k}>"
    end.join
    return {
      "ApplicationData" => PREFIX + body + POSTFIX
    }.to_json
  end

  # sample response = "\"<RESPONSE><APPLICATIONID>27042</APPLICATIONID><APPLICATIONDATE>Aug 12 2016  8:37AM</APPLICATIONDATE><SIGNATURE>Submitted with Uploaded Signature</SIGNATURE><ERROR></ERROR></RESPONSE>\""

  def self.parse_response(response)
    r = response.scan %r(<RESPONSE><APPLICATIONID>(.*)</APPLICATIONID><APPLICATIONDATE>(.*)</APPLICATIONDATE><SIGNATURE>(.*)</SIGNATURE><ERROR>(.*)</ERROR></RESPONSE>)
    raise "Invalid response: #{response}" unless r && r.length == 1 && r[0].length == 4
    application_id = r[0][0]
    application_id = 0 if application_id.empty?
    application_date = r[0][1]
    signature = r[0][2]
    error = r[0][3]
    
    { id: application_id, date: application_date, signature: signature, error: error}
  end
end
