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
class BrandingController < PartnerBase
  layout "partners"
  before_filter :require_partner


  def show
    @partner = current_partner
  end

  def update
    @partner = current_partner
    # remove assets before uploading new ones
    params[:remove].try(:each) do |filename, _|
      assets_folder.delete_asset(filename, :preview)
      try_delete_system_css if filename == "partner.css"
    end

    update_custom_css(params[:css_files], params[:replace_sys_css])

    upload_custom_asset(params[:partner].try(:[], :file))

    update_email_templates(params[:template])

    update_email_template_subjects(params[:template_subject])

    redirect_to partner_branding_path
  end

  protected

  def upload_custom_asset(asset_file)
    return unless asset_file
    name = asset_file.original_filename
    assets_folder.update_asset(name, asset_file, :preview)
  end

  def update_custom_css(css_files, replace_sys_css)
    if (replace_sys_css == "1") && css_files && css_files[:partner]
      css_files[:application] = StringIO.new("")
      css_files[:registration] = StringIO.new("")
    end

    (css_files || {}).each do |name, data|
      assets_folder.update_css(name, data, :preview)
    end
  end

  # when single partner.css is deleted - fake app.css or reg.css must be deleted
  def try_delete_system_css
    ["application", "registration"].each do |name|
      name += ".css"
      file = assets_folder.asset_file(name, :preview)
      next if file.nil? || file.content_length != 0
      assets_folder.delete_asset(name, :preview)
    end
  end

  def update_email_templates(templates)
    templates.try(:each) do |name, body|
      EmailTemplate.set(@partner, name, body)
    end
  end

  def update_email_template_subjects(subjects)
    subjects.try(:each) do |name, subject|
      EmailTemplate.set_subject(@partner, name, subject)
    end
  end

  def assets_folder
    @paf ||= PartnerAssetsFolder.new(@partner)
  end
end
