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
  
  def pa_no_registrant_error(registrant_id)
    mail(
      subject: "[ROCKY PA INTEGRATION] Error submitting to PA: No registrant found for id #{registrant_id}",
      body: "Registrant #{registrant_id} not found in the rocky database to submit to PA"
    )
  end
  
  def grommet_registration_error(error_list=[], registrant=nil)
    name = registrant ? "#{registrant.first_name} #{registrant.last_name}" : "(name not determined)"
    registrant_details = registrant ? "\nEvent Name: #{registrant.open_tracking_id}\nEvent Zip: #{registrant.tracking_id}\nCanvasser Namer: #{registrant.tracking_source}" : nil
    mail(
      subject:"[ROCKY GROMMET] Error validating request from grommet",
      body: "Registrant - #{name} - not registered due to validation error:#{registrant_details}\n\n#{error_list.join('\n')}"
    )
  end
  
  def pa_registration_error(registrant, error_list)
    
    mail(
      subject: "[ROCKY PA INTEGRATION] Error submitting registration #{registrant.id} to PA",
      body: "PA system returned the error:\n\n #{error_list.join("\n")}"
    )
  end
  
end