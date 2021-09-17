class PostalmethodsService


  def self.submit_pdf_delivery(pdf_delivery)
    registrant = pdf_delivery.registrant
    
    send_address1 = ''
    send_address2= ''
    send_city= ''
    send_state= ''
    send_zipcode= ''
    if registrant.has_mailing_address
      send_address1 = registrant.mailing_address
      send_address2 = registrant.mailing_unit
      send_city = registrant.mailing_city
      send_state = registrant.mailing_state
      send_zipcode = registrant.mailing_zip_code
    else
      send_address1 = registrant.home_address
      send_address2 = registrant.home_unit
      send_city = registrant.home_city
      send_state = registrant.home_state_abbrev
      send_zipcode = registrant.home_zip_code
    end


    RequestLogSession.make_call_with_logging(registrant: registrant, client_id: 'postalmethods') do
      pdf_delivery.delivery_attempts ||= 0
      pdf_delivery.delivery_attempts += 1
      pdf_delivery.save(validate: false)
      response = PostalmethodsClient.send_letter_with_address(url: nil, 
        delivery_id: "#{Rails.env}-#{pdf_delivery.id}::#{pdf_delivery.delivery_attempts}",
        pdf_url: registrant.pdf_url.strip,
        #send_to: registrant.full_name.strip,
        send_address1: send_address1.strip,
        send_address2: send_address2.strip,
        send_city: send_city.strip,
        send_state: send_state.strip,
        send_zipcode: send_zipcode.strip,
        # return_to: return_to.strip, 
        # return_address1: return_address1.strip,
        # return_address2: return_address2.strip,
        # return_city: return_city.strip,
        # return_state: return_state.strip,
        # return_zipcode: return_zipcode.strip,
      )
      # assuming now error thrown from response, if response is good
      if response && response["success"]
        pdf_delivery.api_vendor_id = response["result"] && response["result"]["id"]
        pdf_delivery.api_vendor_response = response
        pdf_delivery.deliverd_to_printer = true
        pdf_delivery.save(validate: false)
      else
        # Log and/or notify?
      end
      
    end
  end
  
end
  