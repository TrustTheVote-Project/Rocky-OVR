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
      if !registrant.mailing_unit.blank?
        send_address1 += " #{registrant.mailing_unit}"
      end
      #send_address2 = registrant.mailing_unit
      send_city = registrant.mailing_city
      send_state = registrant.mailing_state_abbrev
      send_zipcode = registrant.mailing_zip_code
    else
      send_address1 = registrant.home_address
      if !registrant.home_unit.blank?
        send_address1 += " #{registrant.home_unit}"
      end
      #send_address2 = registrant.home_unit
      send_city = registrant.home_city
      send_state = registrant.home_state_abbrev
      send_zipcode = registrant.home_zip_code
    end

    delivery_lines = registrant.state_registrar_address.split(/<br\s*\/?>/)
    reply_city_state_zip = delivery_lines.last
    reply_city_state_zip_parts = reply_city_state_zip.split(", ")    
    reply_city = ""
    reply_state = ""
    reply_zip = ""
    if reply_city_state_zip_parts.length == 3
      reply_city = reply_city_state_zip_parts[0]
      reply_state = reply_city_state_zip_parts[1]
      reply_zip = reply_city_state_zip_parts[2]
    else
      reply_city = reply_city_state_zip_parts[0]
      reply_state_zip = reply_city_state_zip_parts[1].split(" ")
      reply_state = reply_state_zip[0]
      reply_zip = reply_state_zip[1]
    end

    reply_address_1 = delivery_lines[delivery_lines.length - 2]
    reply_name = delivery_lines[0]
    if delivery_lines.length == 4
      reply_name += " " + delivery_lines[1]
    end


    RequestLogSession.make_call_with_logging(registrant: registrant, client_id: 'postalmethods') do
      pdf_delivery.delivery_attempts ||= 0
      pdf_delivery.delivery_attempts += 1
      pdf_delivery.save(validate: false)
      response = PostalmethodsClient.send_letter_with_address(url: nil, 
        delivery_id: "#{Rails.env}-#{pdf_delivery.id}::#{pdf_delivery.delivery_attempts}",
        pdf_url: registrant.pdf_url.strip,
        description: "#{registrant.first_name} #{registrant.last_name}, UID: #{registrant.uid}, Partner: #{registrant.partner_id}",
        #send_to: registrant.full_name.strip,
        send_address1: send_address1.strip,
        send_address2: "", #send_address2.strip,
        send_city: send_city.strip,
        send_state: send_state.strip,
        send_zipcode: send_zipcode.strip,
        # return_to: return_to.strip, 
        # return_address1: return_address1.strip,
        # return_address2: return_address2.strip,
        # return_city: return_city.strip,
        # return_state: return_state.strip,
        # return_zipcode: return_zipcode.strip,
        reply_address_name: reply_name,
        reply_address1: reply_address_1,
        reply_address2: "",
        reply_address_city: reply_city,
        reply_address_state: reply_state,
        reply_address_zipcode: reply_zip,
      )
      # assuming now error thrown from response, if response is good
      if response && response["success"]
        pdf_delivery.api_vendor_id = response["result"] && response["result"]["id"]
        if response["result"] && response["result"]["description"]
          response["result"]["description"] = response["result"]["description"].to_s.force_encoding("UTF-8")
        end
        pdf_delivery.api_vendor_response = response
        pdf_delivery.deliverd_to_printer = true
        pdf_delivery.save(validate: false)
      else
        # Log and/or notify?
      end
      
    end
  end
  
end
  