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
class Admin::RequestLogsController < Admin::BaseController
  helper_method :try_format_json, :add_postfix, :truncate

  def index
    @request_logs = RequestLog.paginate(:page => params[:page], :per_page => 100)
  end

  def show
    @request_log = RequestLog.find(params[:id])
  end

  private

  def init_nav_class
    @nav_class = {request_logs: :current}
  end

  def try_format_json(text)
    return 'Empty' if text.blank?
    json = JSON.parse(text)
    JSON.pretty_generate(json)
  rescue JSON::ParserError
    text
  end

  def add_postfix(value, postfix)
    if value.present?
      "#{value} #{postfix}"
    else
      value
    end
  end

  def truncate(value, size)
    if value.present? && value.respond_to?(:size)
      return "#{value[0, size]}..." if value.size > size
    end
    value
  end
end
