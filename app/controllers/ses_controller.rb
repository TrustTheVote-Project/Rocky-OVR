class SesController < ApplicationController
  skip_before_filter :authenticate_everything
  
  def bounce
    json = params
    begin     
      json = JSON.parse(request.raw_post)
    rescue
    end
    SesNotification.create(request_params: json)
    #logger.info "bounce callback from AWS with #{json}"
    aws_needs_url_confirmed = json['SubscribeURL']
    if aws_needs_url_confirmed
      logger.info "AWS is requesting confirmation of the bounce handler URL"
      uri = URI.parse(aws_needs_url_confirmed)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http.get(uri.request_uri)
    else
      # Process bounces
      json['bounce']['bouncedRecipients'].each do |recipient|
        #logger.info "AWS SES received a bounce on an email send attempt to #{recipient['emailAddress']}"
        e = EmailAddress.find_or_create_by(email_address: recipient['emailAddress'].to_s.strip)
        e.blacklisted = true
        e.save
      end
    end
    render nothing: true, status: 200
  end
  
end