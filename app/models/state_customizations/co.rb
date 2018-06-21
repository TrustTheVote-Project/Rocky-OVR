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

class CO < StateCustomization

  def online_reg_url(registrant)
    root_url = state.online_registration_url
    return root_url if registrant.nil?
    if registrant && registrant.state_ovr_data && registrant.state_ovr_data[:is_mobile]
      "https://www.sos.state.co.us/voter-mobile/"
    else     
      partner = registrant.partner ? registrant.partner.organization : nil
      if partner
        return "#{root_url}?campaign=#{CGI.escape(partner)}"
      else
        return root_url
      end
    end
  end
  
  def has_ovr_pre_check?(registrant)
    true
  end
  
  def ovr_pre_check(registrant=nil, controller=nil)
    if registrant
      registrant.state_ovr_data ||= {}
      registrant.state_ovr_data[:is_mobile] = MobileConfig.is_mobile_request?(controller.request)
      registrant.save
    end
  end
  
end
