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
require "#{Rails.root}/app/services/v5"
class Api::V5::CanvassingShiftsController < Api::V5::BaseController

  # Creates the record and returns the URL to the PDF file or
  # the error message with optional invalid field name.
  def create
    required_params = [:partner_id, :canvasser_first_name, :canvasser_last_name, :canvasser_email, :canvasser_phone, :device_id]
    optional_params = [:shift_location]
    
    required_params_response = handle_required_params(required_params)
    return required_params_response if required_params_response

    data = build_attrs_from_param_names([required_params, optional_params])
    
    c = CanvassingShift.new(data.merge({
      shift_source: CanvassingShift::SOURCE_GROMMET        
    }))
    
    c.generate_shift_external_id if c.shift_external_id.blank?
    c.save!
    jsonp({
      shift_id: c.shift_external_id
    })
  end
  
  def update
    required_params = [:clock_in_datetime, :clock_out_datetime, :abandoned_registrations, :completed_registrations, :notes]
    
    required_params_response = handle_required_params(required_params)
    return required_params_response if required_params_response
    
    data = build_attrs_from_param_names(required_params)
    c = CanvassingShift.find_by(shift_external_id: (params[:id] || params[:shift_id]))
    if c
      c.update_attributes(data)
      jsonp({errors: []})
    else
      jsonp({
        errors: ["Shift with ID #{params[:id]} not found"]
      }, status: 404)
    end    
  end
  
  def complete
    c = CanvassingShift.find_by(shift_external_id: (params[:id] || params[:shift_id]))
    if c
      c.complete!
      c.set_defaults!
      jsonp({errors: []})
    else
      jsonp({
        errors: ["Shift with ID #{params[:id]} not found"]
      }, status: 404)
    end 
  end

end
