#***** BEGIN LICENSE BLOCK *****
#
#Version: RTV Public License 1.0
#
#The contents of this file are subject to the RTV Public License Version 1.0 (the
#"License"); you may not use this file except in compliance with the License. You
#may obtain a copy of the License at: http://www.osdv.org/license12b/
#
#Software distributed under the License is distributed on an "AS IS" basis,
#WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
#specific language governing rights and limitations under the License.
#
#The Original Code is the Online Voter Registration Assistant and Partner Portal.
#
#The Initial Developer of the Original Code is Rock The Vote. Portions created by
#RockTheVote are Copyright (C) RockTheVote. All Rights Reserved. The Original
#Code contains portions Copyright [2008] Open Source Digital Voting Foundation,
#and such portions are licensed to you under this license by Rock the Vote under
#permission of Open Source Digital Voting Foundation.  All Rights Reserved.
#
#Contributor(s): Open Source Digital Voting Foundation, RockTheVote,
#                Pivotal Labs, Oregon State University Open Source Lab.
#
#***** END LICENSE BLOCK *****
require "#{Rails.root}/app/services/v3"
class Api::V3::RegistrationsController < Api::V3::BaseController



  # Lists registrations
  def index
    jsonp({
      :deprecation_message=>"This report generation API is no longer available. Please use V4. https://rock-the-vote.github.io/Voter-Registration-Tool-API-Docs/"
    })
  rescue ArgumentError => e
    jsonp({ :message => e.message }, :status => 400)
  end

  def index_gpartner
    jsonp({
      :deprecation_message=>"This report generation API is no longer available. Please use V4. https://rock-the-vote.github.io/Voter-Registration-Tool-API-Docs/"
    })
  rescue ArgumentError => e
    jsonp({ :message => e.message }, :status => 400)
  end


  # Creates the record and returns the URL to the PDF file or
  # the error message with optional invalid field name.
  def create
    r = V3::RegistrationService.create_record(params[:registration])
    jsonp :pdfurl => "https://#{RockyConf.pdf_host_name}#{r.pdf_download_path}", :uid=>r.uid
  rescue V3::RegistrationService::ValidationError => e
    jsonp({ :field_name => e.field, :message => e.message }, :status => 400)
  rescue V3::RegistrationService::SurveyQuestionError => e
    jsonp({ :message => e.message }, :status=>400)
  rescue V3::UnsupportedLanguageError => e
    jsonp({ :message => e.message }, :status => 400)
  rescue ActiveRecord::UnknownAttributeError => e
    name = e.attribute
    jsonp({ :field_name => name, :message => "Invalid parameter type" }, :status => 400)
  end

  # Creates the record
  def create_finish_with_state
    result = V3::RegistrationService.create_record(params[:registration], true)
    jsonp :registrations => result.to_finish_with_state_array
  rescue V3::RegistrationService::ValidationError => e
    jsonp({ :field_name => e.field, :message => e.message }, :status => 400)
  rescue V3::UnsupportedLanguageError => e
    jsonp({ :message => e.message }, :status => 400)
  rescue ActiveRecord::UnknownAttributeError => e
    name = e.attribute
    jsonp({ :field_name => name, :message => "Invalid parameter type" }, :status => 400)
  end

  def clock_in
    data = params.deep_dup
    data.delete(:debug_info)
    data.delete(:format)
    data.delete(:controller)
    data.delete(:action)
    V3::RegistrationService.track_clock_in_event(data)
    jsonp({}, status: 200)
  rescue V3::RegistrationService::ValidationError => e
    jsonp({ :message => e.message }, status: 400)
  end

  def clock_out
    data = params.deep_dup
    data.delete(:debug_info)
    data.delete(:format)
    data.delete(:controller)
    data.delete(:action)
    V3::RegistrationService.track_clock_out_event(data)
    jsonp({}, status: 200)
  rescue V3::RegistrationService::ValidationError => e
    jsonp({ :message => e.message }, status: 400)
  end

  def create_pa
    registrant = nil
    params.delete(:debug_info)
    
    gr_id = nil
    begin
      gr = GrommetRequest.create(request_params: params)
      gr_id = gr ? gr.id : nil
      
      # Also save request headers
      headers = {}
      request.headers.each do |k,v|
        if !k.starts_with?('rack') && !k.starts_with?('action')
          headers[k] = v
        end
      end
      gr.request_headers = headers
      gr.save(validate: false)
      
      if gr.is_duplicate?
        # Send notification
        AdminMailer.grommet_duplication(gr).deliver
        return pa_success_result
      end
      
    rescue Exception=>e
      #raise e
    end
    
    # input request structure validation
    [:rocky_request, :voter_records_request, :voter_registration].tap do |keys|
      value = params
      keys.each do |key|
        unless (value = value[key.to_s])
          return pa_error_result("Invalid request: parameter #{keys.join('.')} not found")
        end
      end
    end

    # 1. Build a rocky registrant record based on all of the fields
    registrant = V3::RegistrationService.create_pa_registrant(params[:rocky_request])
    # 1a. do subsititutions for invalid chars
    registrant.basic_character_replacement!
    registrant.state_ovr_data["grommet_request_id"] = gr_id # lets store the original request for reference
    
    # 2.Check if the registrant is internally valid
    if registrant.valid?
      # If valid for rocky, ensure that it's valid for PA submissions
      pa_validation_errors = V3::RegistrationService.valid_for_pa_submission(registrant)
      if pa_validation_errors.any?
        pa_error_result(pa_validation_errors, registrant)
      else
        # If there are no errors, make the submission to PA
        # This will commit the registrant with the response code
        registrant.save!
        
        job = V3::RegistrationService.delay(run_at: (Admin::GrommetQueueController.delay).hours.from_now, queue: Admin::GrommetQueueController::GROMMET_QUEUE_NAME).async_register_with_pa(registrant.id)
        
        begin
          registrant.state_ovr_data["delayed_job_id"] = job.id
          registrant.save(validate: false)
        rescue
        end
        
        pa_success_result
      end
    else
      pa_error_result(registrant.errors.full_messages, registrant)
    end
  rescue StandardError => e
    #raise e
    pa_error_result("Error building registrant: #{e.message}", registrant)
  end

  def pa_success_result
    data = {
        registration_success: true,
        errors: []
    }
    jsonp(data)
  end

  def pa_error_result(errors, registrant=nil)
    if !errors.is_a?(Array)
      errors = [errors]
    end
    data = {
        registration_success: false,
        transaction_id: nil,
        errors: errors
    }

    Rails.logger.warn("Grommet Registration Error for params:\n#{params}\n\nErrors:\n#{errors}")
    AdminMailer.grommet_registration_error(errors, registrant).deliver

    jsonp(data, :status => 400)
  end

  def pdf_ready
    query = {
      :UID              => params[:UID]
    }

    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
    headers['Access-Control-Allow-Headers'] = '*'
    headers['Access-Control-Max-Age'] = "1728000"

    jsonp :pdf_ready => V3::RegistrationService.check_pdf_ready(query), :UID=>params[:UID]
  rescue Exception => e
    jsonp({ :message => e.message }, :status => 400)
  end

  def stop_reminders
    query = {
      :UID              => params[:UID]
    }

    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
    headers['Access-Control-Allow-Headers'] = '*'
    headers['Access-Control-Max-Age'] = "1728000"

    jsonp V3::RegistrationService.stop_reminders(query).merge(:UID=>params[:UID])
  rescue Exception => e
    jsonp({ :message => e.message }, :status => 400)
  end

  def bulk
    jsonp({
        :registrants_added=>V3::RegistrationService.bulk_create(params[:registrants], params[:partner_id], params[:partner_API_key])
    })
  rescue Exception => e
    jsonp({ :message => e.message }, :status => 400)
  end

end
