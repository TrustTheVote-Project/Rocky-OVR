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
class AdminMailer < ActionMailer::Base
  default from: RockyConf.admin.from_address, to: RockyConf.admin.admin_recipients
  
  def invite_user(user, partner)
    @user = user
    @partner = partner
    mail(
      to: user.email,
      from: RockyConf.admin.branding_from,      
      subject: "You've been added to #{@partner.organization} on Rock The Vote"
    )
  end

  def deactivate_partners(partners)
    @partners = partners
    mail(
      to: RockyConf.admin.partner_status_to,
      subject: "[ROCKY#{environment_subject}] Inactive Parters Login Disabled"
    )
  end

  def deactivate_users(users)
    @users = users
    mail(
      to: RockyConf.admin.partner_status_to,
      subject: "[ROCKY#{environment_subject}] Inactive Users Login Disabled"
    )
  end
  
  def open_branding_request(branding_request)
    mail(
      from: RockyConf.admin.branding_from,
      to:  RockyConf.admin.branding_to,
      subject: "[ROCKY] Branding Request Opened by #{branding_request && branding_request.partner && branding_request.partner.id}",
      body: "New branding request submitted by\n\n Name: #{branding_request && branding_request.partner && branding_request.partner.name}\n\n Org: #{branding_request && branding_request.partner && branding_request.partner.organization}\n\nPartner ID: #{branding_request && branding_request.partner && branding_request.partner.id}\n\n #{requests_admin_whitelabel_url}"
    )
  end
  
  def approve_branding_request(branding_request)
    mail(
      subject: "Rock the Vote Branding Request Approved",
      from: RockyConf.admin.branding_from,
      to: branding_request.partner.email,
      body: "Hey there,\n\nWe wanted to let you know that your recent uploads to the Rock the Vote voter registration tool were approved!\n\n#{new_registrant_url(partner: branding_request.partner)}\n\nThanks\nRock the Vote"
    )
  end
  
  def reject_branding_request(branding_request)
    mail(
      subject: "Rock the Vote Branding Request Rejected",
      from: RockyConf.admin.branding_from,
      to: branding_request.partner.email,
      body: "Hey there,\n\nYour recent uploads to the Rock the Vote voter registration tool have been rejected. Please update and resubmit.\n\n#{partner_branding_url}\n\nThanks\nRock the Vote"
    )
  end
  
  def import_results(result_list, email)
    mail(
      subject: "Registrant Status Import Complete",
      to: email,
      body: "Results: \n\n#{result_list}"
    )
  end
  
  
  def pa_no_registrant_error(registrant_id)
    mail(
      subject: "[ROCKY PA INTEGRATION#{environment_subject}] Error submitting to PA: No registrant found for id #{registrant_id}",
      body: "Registrant #{registrant_id} not found in the rocky database to submit to PA"
    )
  end
  
  def grommet_duplication(grommet_request)
    mail(
      subject:"[ROCKY GROMMET#{environment_subject}] Ignoring duplicate request from grommet.",
      body: "Grommet Request for #{grommet_request.state} - #{grommet_request.id} - not processed due to duplicate request"
    )
  end
  
  def grommet_registration_error(error_list=[], registrant=nil)
    name = registrant ? "#{registrant.first_name} #{registrant.last_name}" : "(name not determined)"
    req_id = registrant ? " request ID #{registrant.grommet_request_id} " : " (no req ID found)"
    # TODO what data to include in email of reg details
    registrant_details = "" #registrant ? "\nEvent Name: #{registrant.open_tracking_id}\nEvent Zip: #{registrant.tracking_id}\nCanvasser Namer: #{registrant.tracking_source}" : nil
    mail(
      subject:"[ROCKY GROMMET#{environment_subject}] Error validating request from grommet. PID: #{registrant&.partner_id}",
      body: "Registrant - #{name}#{req_id} - not registered due to validation error:#{registrant_details}\n\n#{error_list.join('\n')}"
    )
  end
  
  def pa_registration_error(registrant, error_list, message='')
    mail(
      subject: "[ROCKY PA INTEGRATION#{environment_subject}] Error submitting registration #{registrant.class} #{registrant.id} #{registrant.uid} to PA. PID: #{registrant.partner_id}",
      body: "#{message}\n\nPA system returned the error:\n\n #{error_list.join("\n")}"
    )
  end

  def va_registration_error(registrant, error_list, message='')
    
    mail(
      subject: "[ROCKY VA INTEGRATION#{environment_subject}] Error submitting registration #{registrant.class} #{registrant.id} to VA. PID: #{registrant.partner_id}",
      body: "#{message}\n\nVA system returned the error:\n\n #{error_list.join("\n")}"
    )
  end
  
  def mi_registration_error(registrant, outcome, message='') 
    mail(
      subject: "[ROCKY MI INTEGRATION#{environment_subject}] Error submitting registration #{registrant.class} #{registrant.id} to MI. PID: #{registrant.partner_id}",
      body: "#{message}\n\nMI system returned:\n\n registrant_uid: #{registrant.uid}\noutcome: #{outcome}\nstatus_id:#{registrant.mi_api_voter_status_id.to_s}\n#{(registrant.mi_api_voter_status_id || '-1').to_i < 0 ? 'MI system did not respond successfully' : ''}"
    )
  end
  
  def pa_registration_warning(registrant, mod_list)
    
    mail(
      subject: "[ROCKY PA INTEGRATION#{environment_subject}] Data changed submitting registration #{registrant.class} #{registrant.id} to PA. PID: #{registrant.partner_id}",
      body: "The following modifications were made:\n\n #{mod_list.join("\n")}"
    )
  end

  def wa_registration_error(registrant, error_list, message='')
    
    mail(
      subject: "[ROCKY WA INTEGRATION#{environment_subject}] Error submitting registration #{registrant.class} #{registrant.id} to WA",
      body: "#{message}\n\nWA system returned the error:\n\n #{error_list.join("\n")}"
    )
  end

  def general_error(body_text)
    mail(
      subject: "[ROCKY NOTIFICATION#{environment_subject}]",
      body: body_text
    )
  end
  
  private
  
  def environment_subject
    return '' if Rails.env.production?
    return " - #{Rails.env}"
  end
  
end
