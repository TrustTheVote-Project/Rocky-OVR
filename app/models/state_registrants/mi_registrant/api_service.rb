module StateRegistrants::MIRegistrant::ApiService
  
  RESPONSE_FAILURE="RESPONSE_FAILURE".freeze
  RESPONSE_INVALID_DLN="RESPONSE_INVALID_DLN".freeze
  RESPONSE_SUCCESS="RESPONSE_SUCCESS".freeze
  RESPONSE_ALLOW_RETRY="RESPONSE_ALLOW_RETRY".freeze
  RESPONSE_BUSY="RESPONSE_BUSY".freeze
  RESPONSE_ADDRESS_AMBIGUOUS="RESPONSE_ADDRESS_AMBIGUOUS".freeze
  
  RESPONSE_OUTCOMES = [
    RESPONSE_FAILURE, #Go to paper, send error message notification
    RESPONSE_INVALID_DLN, #Go to paper, no error to send?
    RESPONSE_ADDRESS_AMBIGUOUS,
    RESPONSE_SUCCESS, #Success!
    RESPONSE_ALLOW_RETRY, #
    RESPONSE_BUSY, #requeue
  ]
  
  def response_outcome
    case self.mi_api_voter_status_id.to_s
    when "0.0", "5.0", "9.0", "12.0"
      return RESPONSE_FAILURE
    when "4.0"
      return RESPONSE_ADDRESS_AMBIGUOUS
    when "6.0"
      return RESPONSE_INVALID_DLN
    when "1.0", "2.0", "3.0"
      return RESPONSE_SUCCESS
    when "7.0", "8.0"
      return RESPONSE_ALLOW_RETRY
    when "10.0", "11.0"
      return RESPONSE_BUSY
    else
      return RESPONSE_FAILURE
    end      
  end
  
  #response codes
  # GO to paper
  # 0.0: Error message attached
  # 4.0: Failure: Address update failed ? (ambiguous)
  # 5.0: Underage Voter
  # 9.0: Adressed matched ?
  # 12.0: Ineligible

  # 6.0: Expired License, send to paper with note
  def custom_state_flow_error_message
    if self.mi_api_voter_status_id.to_s == "6.0"
      return I18n.t('states.custom.mi.custom_errors.dln_is_expired',  url: skip_state_flow_registrant_path) 
    else
      return I18n.t("states.custom.mi.custom_errors.mi_api_error",  url: skip_state_flow_registrant_path)
    end
  end
  

  # 1.0: Success: New Registration
  # 2.0: Success: Already Registrered at this address
  # 3.0: Success: Address updated
  def mi_api_voter_status_success_type
    return "new" if self.mi_api_voter_status_id.to_s == "1.0"
    return "existing" if self.mi_api_voter_status_id.to_s == "2.0"
    return "updated" if self.mi_api_voter_status_id.to_s == "3.0"
  end
  
  # 10.0: RECORD NOT PROCESSED, busy queue for retry
  # 11.0: Error while processing, busy queue for retry
  
  # 7.0: License not found - try again  
  # 8.0: Address not found - try again
  
  def dln_not_found?
    self.mi_api_voter_status_id.to_s == "7.0"
  end
  def address_not_found?
    self.mi_api_voter_status_id.to_s == "8.0"
  end
  
  def submitted?
    self.mi_submission_complete?
  end
  
  def async_submit_to_online_reg_url
    self.mi_submission_complete = false
    self.mi_api_voter_status_id = nil
    self.submission_attempts = 0 # This is only triggered by a user resubmitting, so reset attempts
    self.save
    self.delay.submit_to_online_reg_url
  end
  
  def handle_api_error
    # self.mi_submission_complete = true
    # Depending on error type, send notification?
    # self.registrant.skip_state_flow!
  ensure
    AdminMailer.mi_registration_error(self, self.response_outcome, "Registrant Switched to paper").deliver
    self.save(validate: false)
  end
  
  def address_match_select_index
    nil
  end

  def address_match_select_index=(val)
    # Set user-entered address to matched address idx
    matches = begin
      JSON.parse(self.registration_address_matches) || []
    rescue
      []
    end
    match = matches[val.to_i]
    set_address_from_match(match)
  end
  
  def set_address_from_match(match)
    self.registration_address_street_name = [match["StreetPrefix"], match["StreetName"]].compact.join(" ")
    self.registration_address_street_type = match["StreetType"]
    self.registration_address_post_directional = match["StreetSuffix"]
    self.registration_city = match["City"]
    self.registration_zip_code = match["ZipCode"]
    self.mi_submission_complete = false
    self.mi_api_voter_status_id = nil
    self.registration_address_matches = nil
    self.submission_attempts = 0 # This is only triggered by a user resubmitting, so reset attempts
    self.save    
  end
  
  def check_address
    RequestLogSession.make_call_with_logging(registrant: self, client_id: 'mi_client') do
      response = MiClient.street_match(sender_name: "RockTheVote", address_line_1: self.registration_address_line_1, city: self.registration_city, zip_code: self.registration_zip_code)
      if response["HasMatch"] && response["MatchingStreets"] && response["MatchingStreets"].length > 0
        if response["MatchingStreets"].length > 1
          self.registration_address_matches = response["MatchingStreets"].to_json
          self.save(validate: false)
        else
          self.set_address_from_match(response["MatchingStreets"][0])
          self.async_submit_to_online_reg_url
          # Set address from single match
        end
      else
        handle_api_error
      end
    end
  rescue
    handle_api_error
  end
  
  def registration_address_match_list
    matches = begin
      JSON.parse(self.registration_address_matches) || []
    rescue
      []
    end
    matches.collect do |m|
      line_1 = ["StreetPrefix", "StreetName", "StreetType", "StreetSuffix"].collect{|k| m[k]}.collect{|v| v.blank? ? nil : v}.compact.join(" ")
      OpenStruct.new({
        address_line_1: "#{self.registration_address_number} #{line_1}",
        address_line_2: "#{self.registration_unit_number}",
        city: m["City"],
        zip_code: m["ZipCode"]
      })
    end
  end
  
  def submit_to_online_reg_url
    RequestLogSession.make_call_with_logging(registrant: self, client_id: 'mi_client', censor: MICensor) do
      begin 
        self.submission_attempts ||= 0
        self.submission_attempts += 1    
        self.save(validate: false)
        response = MiClient.post_voter_nist(self.to_nist_format)
        self.mi_api_voter_status_id = response["VoterStatusId"] || "-1" #ensure non-nil value
        outcome = self.response_outcome
        if outcome == RESPONSE_FAILURE
          handle_api_error
        elsif outcome == RESPONSE_INVALID_DLN
          self.save(validate: false)
        elsif outcome == RESPONSE_SUCCESS
          mi_id = begin
            response["VoterErrors"]["SenderRecordId"]
          rescue
            nil
          end
          self.mi_transaction_id = mi_id || self.uid
          self.mi_submission_complete = true
          self.registrant.complete_registration_with_state!
          self.save(validate: false)
        elsif outcome == RESPONSE_ALLOW_RETRY
          self.mi_submission_complete = false
          self.save(validate: false)
        elsif outcome == RESPONSE_ADDRESS_AMBIGUOUS
          # Get potential matches
          self.delay.check_address
          self.mi_submission_complete = false
          self.save(validate: false)
        elsif outcome == RESPONSE_BUSY
          self.mi_submission_complete = false
          # DONT run async_submit_to_online_reg_url which resets # attempts
          if self.submission_attempts < 2
            self.mi_api_voter_status_id = nil
            self.save(validate: false)
            self.delay(run_at: 5.seconds.from_now).submit_to_online_reg_url
          else
            #Let user finish with paper
            handle_api_error
          end
        end
      rescue Exception => e
        # unhandled exception, try again
        RequestLogSession.request_log_instance.log_error(e)
        if self.submission_attempts < 2
          self.delay(run_at: 5.seconds.from_now).submit_to_online_reg_url
        else
          # Go to paper
          self.mi_api_voter_status_id ||= "-1"
          handle_api_error
        end
      end
    end
  end
  
  
  def to_nist_format
    {
      "AdditionalInfo"=> [
        {
          "Name"=> "EyeColor",
          "StringValue"=> "#{self.eye_color_code}"
        }
      ],
      "Form"=> "other",
      "FormSpecified"=> true,
      "GeneratedDate"=> self.created_at&.iso8601(7), #"2020-02-18T12:52:05.9622405-05:00",
      "Issuer"=> "RockTheVote",
      "OtherForm"=> "MI Form ED 121",
      "Subject"=> {
        "ContactMethod"=> [
          {
            "Type"=> "phone", #1,
            "Value"=> "#{self.phone.to_s.gsub(/[^\d]/,'')}"
          },
          {
            "Type"=> "email", #0,
            "Value"=> "#{self.email}"
          }
        ],
        "DateOfBirth"=> self.date_of_birth ? "#{self.date_of_birth.iso8601}T00:00:00" : nil,
        "DateOfBirthSpecified"=> true,
        "Name" => {
            "FirstName": nil,
            "LastName": self.full_name,
            "MiddleName": [],
            "Prefix": nil,
            "Suffix": nil
        },        
        "ResidenceAddress"=> {
          "NumberedThoroughfareAddress_type"=> {
            "CompleteAddressNumber"=> {
              "AddressNumber"=> self.registration_address_number
            },
            "CompleteStreetName"=> {
              "StreetNamePreModifier"=> {
                "Value"=> nil
              },
              "StreetNamePreDirectional"=> {
                "Value"=> nil
              },
              "StreetNamePreType"=> {
                "Value"=> nil
              },
              "StreetName"=> self.registration_address_street_name,
              "StreetNamePostType"=> {
                "Value"=> self.street_type_code
              },
              "StreetNamePostDirectional"=> {
                "Value"=> self.registration_address_post_directional
              },
              "StreetNamePostModifier"=> {
                "Value"=> nil
              }
            },
            "CompletePlaceName"=> {
              "PlaceName"=> [
                {
                  "PlaceNameType"=> "MunicipalJurisdiction", #1
                  "PlaceNameTypeSpecified"=> true,
                  "Value"=> "#{self.registration_city}"
                }
              ]
            },
            "StateName"=> "MI",
            "ZipCode"=> "#{self.registration_zip_code}",
            "CountryName"=> "USA"
          }.merge(nist_registration_unit_number)
        },
        "ResidenceAddressIsMailingAddress"=> !self.has_mailing_address,
        "VoterClassification"=> [
          {
            "Assertion" => self.confirm_will_be_18 ? 1 : 0,
            "OtherAssertion"=> nil,
            "OtherType"=> nil,
            "Type"=> "eighteenonelectionday" #8
          },
          {
            "Assertion"=> self.confirm_us_citizen ? 1 : 0,
            "OtherAssertion"=> nil,
            "OtherType"=> nil,
            "Type"=> "unitedstatescitizen" #13
          },
    	    {
            "Assertion"=> self.updated_dln_recently  ? 1 : 0,
            "OtherAssertion"=> nil,
            "OtherType"=> "DLNAddressUpdate",
            "Type"=> "other" # 14
          },
    	    {
            "Assertion"=> self.requested_duplicate_dln_today ? 1 : 0,
            "OtherAssertion"=> nil,
            "OtherType"=> "DLNDuplicate",
            "Type"=> "other" # 14
          },
    	    {
            "Assertion"=> self.is_30_day_resident ? 1 : 0,
            "OtherAssertion"=> nil,
            "OtherType"=> "IsThirtyDayResident",
            "Type"=> "other" # 14
          },
    	    {
            "Assertion"=> self.registration_cancellation_authorized ? 1 : 0,
            "OtherAssertion"=> nil,
            "OtherType"=> "RegistrationCancellationAuthorized",
            "Type"=> "other" # 14
          },
    	    {
            "Assertion"=> self.digital_signature_authorized ? 1 : 0,
            "OtherAssertion"=> nil,
            "OtherType"=> "DigitalSignatureAuthorized",
            "Type"=> "other" # 14
          }
        ],
        "VoterId"=> [
          {
            "OtherType"=> "",
            "StringValue"=> "#{self.dln}",
            "Type"=> "driverslicense"# 0
          },
          {
            "OtherType"=> "",
            "StringValue"=> "#{self.ssn4}",
            "Type"=> "ssn4" #3
          }
        ]
      }.merge(nist_mailing_address),
      "TransactionId"=> "#{self.registrant_id}",
      "Type"=> [
        "registration"
      ],
      "VendorApplicationId"=> "TrustTheVote-Rocky v2020.3"
    }
    
  end
  
  def nist_registration_unit_number
    if self.registration_unit_number.blank?
      return {}
    else
      return {
        "CompleteSubaddress"=>  {
          "SubaddressType"=> "APT",
          "SubaddressIdentifier"=> "#{self.registration_unit_number}"
        } 
      }
    end
  end
  
  def nist_mailing_unit_number
    if self.mailing_address_unit_number.blank?
      return {}
    else
      return {
        "CompleteSubaddress"=>  {
          "SubaddressType"=> "APT",
          "SubaddressIdentifier"=> "#{self.mailing_address_unit_number}"
        } 
      }
    end
  end
  
  def nist_mailing_address
    return {} if !self.has_mailing_address?
    # TODO - flesh this out
    if self.mailing_address_type == StateRegistrants::MIRegistrant::MailingAddress::STANDARD_TYPE
      return {
        "MailingAddress"=> {
          "NumberedThoroughfareAddress_type"=> {
            "CompleteAddressNumber"=> {
              "AddressNumberPrefix"=> {
                "Value"=> nil
              },
              "AddressNumber"=> "#{self.mailing_address_number}",
              "AddressNumberSuffix"=> {
                "Value"=> nil
              }
            },
            "CompleteStreetName"=> {
              "StreetNamePreModifier"=> {
                "Value"=> nil
              },
              "StreetNamePreDirectional"=> {
                "Value"=> nil
              },
              "StreetNamePreType"=> {
                "Value"=> nil
              },
              "StreetName"=> "#{self.mailing_address_street_name}",
              "StreetNamePostType"=> {
                "Value"=> "#{self.mailing_address_street_type}"
              },
              "StreetNamePostDirectional"=> {
                "Value"=> nil
              },
              "StreetNamePostModifier"=> {
                "Value"=> nil
              }
            },
            "CompletePlaceName"=> {
              "PlaceName"=> [
                {
                  "PlaceNameType"=> "MunicipalJurisdiction", #1,
                  "PlaceNameTypeSpecified"=> true,
                  "Value"=> "#{self.mailing_city}"
                }
              ]
            },
            "StateName"=> "#{self.mailing_state}",
            "ZipCode"=> "#{self.mailing_zip_code}",
            "CountryName"=> "USA"
          }.merge(nist_mailing_unit_number)
        }
      }
    elsif self.mailing_address_type == StateRegistrants::MIRegistrant::MailingAddress::PO_BOX_TYPE
      return {
        "MailingAddress"=> {
          "USPSPostalDeliveryBox_type" => {
            "USPSBox"=> {
              "USPSBoxType"=> "PO BOX",
              "USPSBoxId" => "#{self.mailing_po_box_number}"
            },
            "CompletePlaceName"=> {
              "PlaceName"=> [
                {
                  "PlaceNameType"=> "MunicipalJurisdiction", #1,
                  "PlaceNameTypeSpecified"=> true,
                  "Value"=> "#{self.mailing_city}"
                }
              ]
            },
            "StateName"=> "#{self.mailing_state}",
            "ZipCode"=> "#{self.mailing_zip_code}",
            "CountryName"=> "USA"
          }
        }
      }
    elsif self.mailing_address_type == StateRegistrants::MIRegistrant::MailingAddress::MILITARY_TYPE
      return {
        "MailingAddress"=> {
          "USPSPostalDeliveryRoute_type" => {
            "USPSRoute"=> {
              "USPSBoxGroupType" => "#{self.mailing_military_group_type}", # User selected UNIT, CMR, or PSC
              "USPSBoxGroupId:" => "#{self.mailing_military_group_number}", # User provided numeric string
            },
            "USPSBox"=> {
              "USPSBoxType"=> "BOX",
              "USPSBoxId" => "#{self.mailing_military_box_number}"
            },
            "CompletePlaceName"=> "#{self.mailing_city}",
            "StateName"=> "#{self.mailing_state}",
            "ZipCode"=> "#{self.mailing_zip_code}",
            "CountryName"=> "USA"
          }
        }
      }
    elsif self.mailing_address_type == StateRegistrants::MIRegistrant::MailingAddress::INTERNATIONAL_TYPE
      return {
        "MailingAddress"=> {
          "GeneralAddressClass_type" => {
            "DeliveryAddress"=> "#{self.mailing_international_address}",
            "ZipCode"=> "#{self.mailing_zip_code}",
            "CountryName"=> "#{self.mailing_country}"
          }
        }
      }  
    end
  end
  
end