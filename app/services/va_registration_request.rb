class VARegistrationRequest

  require 'net/http'

  # def self.get_localities
  #   url = "https://publicapi.elections.virginia.gov/V1/Locality/All"
  #   # uri = URI.parse(url)
  #   # http = Net::HTTP.new(uri.host, uri.port)
  #   # http.use_ssl = true
  #   # http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  #   # http.read_timeout = 15
  #   # request = Net::HTTP::Post.new(url)
  #   # request.add_field('Content-Type', 'application/json')
  #   # request.add_field('Cache-Control', 'no-cache')
  #
  #   response = RestClient.get(url)
  #   raise response.to_s
  #
  # end

  def self.send_request(params)
    # print 'PA:REQUEST>> ', params, "\n"
    server = RockyConf.ovr_states.VA.api_settings.api_url # 'https://paovrwebapi.votespa.com'
    api_key = RockyConf.ovr_states.VA.api_settings.api_key
    url = "/SureOVRWebAPI/api/ovr?JSONv2&sysparm_AuthKey=#{api_key}&sysparm_action=SETAPPLICATION&sysparm_Language=0"

    uri = URI.parse(server)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    http.read_timeout = 125
    request = Net::HTTP::Post.new(url)
    request.add_field('Content-Type', 'application/json')
    request.add_field('Cache-Control', 'no-cache')

    request.body = prepare_request(params)
    Rails.logger.debug 'PA:REQUEST>> '+ request.body.to_s

    response = http.request(request)

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
    PREFIX + body + POSTFIX
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
