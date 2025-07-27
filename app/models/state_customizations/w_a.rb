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

#CTW:  Not sure how online url and using the API will work together

class WA < StateCustomization
  ROOT_URL = "https://olvr.votewa.gov/default.aspx"
  
  def online_reg_url(registrant)
    root_url = ROOT_URL
    return root_url if registrant.nil?
    fn = CGI.escape registrant.first_name.to_s
    ln = CGI.escape registrant.last_name.to_s
    dob= CGI.escape registrant.form_date_of_birth.to_s.gsub('-','/')
    lang= registrant.locale
    "#{root_url}?language=#{lang}&Org=RocktheVote&firstname=#{fn}&lastname=#{ln}&DOB=#{dob}"
  end

  def use_state_flow?(registrant)
    return false if ovr_settings.blank?
    
    lang_list = ovr_settings["languages"]
 

    return true if lang_list.blank? || lang_list.empty?
    return lang_list.include?(registrant.locale)    

  end

  def self.permitted_attributes
    attrs = self.column_names - self.protected_attributes
    return [attrs, 
      :issue_date_mm,
      :issue_date_dd,
      :issue_date_yyyy,
      :covr_token,
      :covr_success,
      :ca_disclosures,
      :query_parameters,
      VOTER_SIGNATURE_ATTRIBUTES
    ].flatten
  end

  def enabled_for_language?(locale, reg=nil)
    # This is for transitions to onine state registration vs direct API calls
    false
  end

end