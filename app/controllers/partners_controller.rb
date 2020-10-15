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
class PartnersController < PartnerBase
  layout "partners"
  before_filter :require_partner, :except => [:new, :create]

  ### public access

  def new
    if current_partner
      force_logout
      redirect_to new_partner_url
    else
      @partner = Partner.new
    end
  end

  def create
    @partner = Partner.new(params[:partner])
    if @partner.save
      flash[:success] = "Registered!"
      redirect_to partner_url
    else
      render "new"
    end
  end

  ### require login

  def edit
    @partner = current_partner
  end

  def update
    @partner = current_partner
    if @partner.update_attributes(params[:partner])
      flash[:success] = "You have updated your profile."
      redirect_to partner_url
    else
      render "edit"
    end
  end

  def show
    @partner = current_partner
    @stats_by_completion_date = @partner.registration_stats_completion_date
  end

  def embed_codes
    @partner = current_partner
    @text_link_html = %Q[<a href="https://#{RockyConf.ui_url_host}#{root_path(:partner => partner_id)}">Register to Vote Here</a>]
    @text_link_html_b = %Q[<a href="https://register2.rockthevote.com#{root_path(:partner => partner_id)}">Register to Vote Here</a>]

    @image_link_html =
<<-HTML
<a href="https://#{RockyConf.ui_url_host}#{root_path(:partner => partner_id, :source => "embed-#{@partner.widget_image_name}")}">
  <img src="#{partner_widget_url}" />
</a>
HTML
    @image_link_html_b =
<<-HTML
<a href="https://register2.rockthevote.com#{root_path(:partner => partner_id, :source => "embed-#{@partner.widget_image_name}")}">
  <img src="#{partner_widget_url}" />
</a>
HTML

    @floatbox_options = "width:618 height:max scrolling:yes"
    @image_overlay_html =
<<-HTML
<a href="https://#{RockyConf.ui_url_host}#{root_path(:partner => partner_id, :source => "embed-#{@partner.widget_image_name}")}" class="floatbox" data-fb-options="#{@floatbox_options}">
  <img src="#{partner_widget_url}" />
</a>
<script type="text/javascript" src="#{AppConfig.widget_loader_url}"></script>
HTML
    @image_overlay_html_b =
<<-HTML
<a href="https://register2.rockthevote.com#{root_path(:partner => partner_id, :source => "embed-#{@partner.widget_image_name}")}" class="floatbox" data-fb-options="#{@floatbox_options}">
  <img src="#{partner_widget_url}" />
</a>
<script type="text/javascript" src="https://register2.rockthevote.com#{widget_loader_path}"></script>
HTML
    @js_src_tag = "<script type=\"text/javascript\"  src=\"https://#{RockyConf.ui_url_host}/assets/rtv-iframe.js\"></script>"
    @js_script =
<<-SCRIPT
<script type="text/javascript">
    RtvIframe.init({
      partner: #{partner_id}
    })
</script>
SCRIPT

    @iframe_html = "<iframe src=\"https://register.rockthevote.com/?partner=#{partner_id}&source=iframe\" width=\"100%\" height=\"1200\" marginheight=\"0\" frameborder=\"0\"></iframe>"
    
    @iframe_html_b = "<iframe src=\"https://register2.rockthevote.com/registrants/map/?source=iframe&partner=#{partner_id}\" width=\"100%\" height=\"1200\" marginheight=\"0\" frameborder=\"0\"></iframe>"

    @share_link_facebook = "https://www.facebook.com/sharer/sharer.php?u=https%3A//register.rockthevote.com/?partner=#{partner_id}%26source=fb-share"
    
    @share_link_facebook_b = "https://www.facebook.com/sharer/sharer.php?u=https%3A//register2.rockthevote.com/?partner=#{partner_id}%26source=fb-share"
    @share_link_twitter = "https://twitter.com/home?status=Register%20to%20Vote%20today%3A%20https%3A//register.rockthevote.com/?partner=#{partner_id}%26source=tw-share"
    @share_link_twitter_b = "https://twitter.com/home?status=Register%20to%20Vote%20today%3A%20https%3A//register2.rockthevote.com/?partner=#{partner_id}%26source=tw-share"
    @share_link_google = "https://plus.google.com/share?url=https%3A//register.rockthevote.com/?partner=#{partner_id}%26source=G%2B-share"
    @share_link_google_b = "https://plus.google.com/share?url=https%3A//register2.rockthevote.com/?partner=#{partner_id}%26source=G%2B-share"
        


  end

  def statistics
    @partner = current_partner
    @stats_by_state = @partner.registration_stats_state
    @stats_by_completion_date = @partner.registration_stats_completion_date
    #@stats_by_completion_date_finish_with_state = @partner.registration_stats_finish_with_state_completion_date
    #@stats_by_race = @partner.registration_stats_race
    #@stats_by_gender = @partner.registration_stats_gender
    #@stats_by_age = @partner.registration_stats_age
    #@stats_by_party = @partner.registration_stats_party
  end
  
  def reports
    @reports = Report.where(partner_id: current_partner.id).order("created_at DESC")
  end

  def registrations
    start_date = params[:start_date].blank? ? nil : Date.strptime(params[:start_date], '%m/%d/%Y')
    end_date = params[:end_date].blank? ? nil : Date.strptime(params[:end_date], '%m/%d/%Y')
    if  params[:generate_extended]=="1"
      current_partner.generate_registrants_extended_csv(start_date, end_date)
    else
      current_partner.generate_registrants_csv(start_date, end_date)
    end
    redirect_to reports_partner_url #download_csv_partner_url({"generate_grommet"=>params[:generate_grommet]})    
  end
  
  def canvassing_shift_report
    start_date = params[:start_date].blank? ? nil : Date.strptime(params[:start_date], '%m/%d/%Y')
    end_date = params[:end_date].blank? ? nil : Date.strptime(params[:end_date], '%m/%d/%Y')
    
    current_partner.generate_canvassing_shift_csv(start_date, end_date)
    redirect_to reports_partner_url
  end
  
  def grommet_registrant_report
    start_date = params[:start_date].blank? ? nil : Date.strptime(params[:start_date], '%m/%d/%Y')
    end_date = params[:end_date].blank? ? nil : Date.strptime(params[:end_date], '%m/%d/%Y')
        
    current_partner.generate_grommet_registrants_csv(start_date, end_date)
    redirect_to reports_partner_url
  end
  
  def grommet_shift_report
    start_date = params[:start_date].blank? ? nil : Date.strptime(params[:start_date], '%m/%d/%Y')
    end_date = params[:end_date].blank? ? nil : Date.strptime(params[:end_date], '%m/%d/%Y')
    
    current_partner.generate_grommet_shift_report(start_date, end_date)
    redirect_to reports_partner_url
  end

  def abr_report
    start_date = params[:start_date].blank? ? nil : Date.strptime(params[:start_date], '%m/%d/%Y')
    end_date = params[:end_date].blank? ? nil : Date.strptime(params[:end_date], '%m/%d/%Y')
    
    current_partner.generate_abr_report(start_date, end_date)
    redirect_to reports_partner_url
  end
  
  def download_csv
    report = Report.find_by_id(params[:report_id])
    if report.nil? || report.partner != current_partner
      flash[:warning] = "You don't have permissions to view that report"
      redirect_to reports_partner_url
    else
      send_data report.read, filename: report.download_file_name, type: "text/csv"
      # respond_to do |format|
      #   format.csv do
      #   end
      # end
    end
  end

  protected

  def partner_id
    current_partner && current_partner.to_param
  end

  def partner_widget_url
    "http://#{request.host}/images/widget/#{@partner.widget_image}"
  end

  helper_method :partner_widget_url
end
