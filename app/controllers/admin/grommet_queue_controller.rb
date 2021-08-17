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
class Admin::GrommetQueueController < Admin::BaseController
  GROMMET_QUEUE_NAME = "grommet_queue".freeze
  MI_GROMMET_QUEUE_NAME = "mi_grommet_queue".freeze
  
  before_action :set_state

  def self.delay(state="PA")
    case state.to_s.downcase
    when "pa"
      return Settings.grommet_delay.to_i
    when "mi"
      return Settings.grommet_delay_mi.to_i
    end
  rescue
    48    
  end

  def self.set_delay(state="PA", value)
    case state.to_s.downcase
    when "pa"
      Settings.grommet_delay = value
    when "mi"
      Settings.grommet_delay_mi = value
    else
      Settings.grommet_delay = value
    end
  end
  
  def show
    @jobs = Delayed::Job.where(queue: queue)
    @hours_delay = Admin::GrommetQueueController.delay(state)
  end
  
  def flush
    Delayed::Job.where(queue: queue).update_all(["run_at=?", DateTime.now])
    Admin::GrommetQueueController.set_delay(state, 0)
    redirect_to action: :show, state: @state
  end
  
  def update_delay
    Admin::GrommetQueueController.set_delay(state, params[:delay])
    redirect_to action: :show, state: @state
  end

  def request_report
    Settings.send("grommet_csv_ready_#{state.downcase}=", false)
    GrommetRequest.delay.upload_request_results_report_csv(@state)
    redirect_to action: :show, state: @state
  end

  private

  def queue
    case state.downcase
    when "pa"
      return GROMMET_QUEUE_NAME
    when "mi"
      return MI_GROMMET_QUEUE_NAME
    end
    return GROMMET_QUEUE_NAME
  end

  def set_state
    @state = params[:state] || "PA"
  end
  
  def state
    @state
  end

  def init_nav_class
    @nav_class = {grommet_queue: :current}
  end  
end
