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
  
  def self.delay
    Settings.grommet_delay.to_i
  rescue
    48    
  end
  
  def show
    @jobs = Delayed::Job.where(queue: GROMMET_QUEUE_NAME)
    @hours_delay = Admin::GrommetQueueController.delay
  end
  
  def flush
    Delayed::Job.where(queue: GROMMET_QUEUE_NAME).update_all(["run_at=?", DateTime.now])
    Settings.grommet_delay = 0
    redirect_to action: :show
  end
  
  def update_delay
    Settings.grommet_delay = params[:delay]
    redirect_to action: :show
  end

  def request_report
    respond_to do |format|
      format.csv { send_data GrommetRequest.request_results_report_csv, :filename => "grommet_requests.csv" }
    end     
  end
  
end
