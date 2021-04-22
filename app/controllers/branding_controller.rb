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
  before_action :require_partner
  before_action :set_partner, only: [:show, :css, :emails]

  MAX_MB = 5.0

  def show
  end
  def css
  end
  def emails
  end


  def update
    @partner = current_partner
    @partner.update_attributes(params[:partner])
    # remove assets before uploading new ones
    params[:remove].try(:each) do |filename, _|
      assets_folder.delete_asset(filename, :preview)
    end

    update_custom_css(params[:css_files])

    upload_custom_asset(params.try(:[], :file))

    update_email_templates(params[:template])

    update_email_template_subjects(params[:template_subject])

    redirect_to :back
  end

  protected

  def set_partner
    @partner = current_partner
  end

  def upload_custom_asset(asset_file)
    return unless asset_file
    if check_validity(asset_file)
      name = asset_file.original_filename
      assets_folder.update_asset(name, asset_file, :preview)
    end
  end

  def update_custom_css(css_files)
    (css_files || {}).each do |name, data|
      if !is_css?(data)
        flash[:warning]="Custom CSS must be a .css file"
      end
      assets_folder.update_css(name, data, :preview)
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
    @partner.folder
  end
  
  def check_validity(file)
    if !(is_font?(file) || is_image?(file))
      flash[:warning]="#{file.original_filename} must be an image or font file"
      return false
    end
    if file.size > MAX_MB * 1024000
      flash[:warning]="#{file.original_filename} must be less than #{MAX_MB} MB"
      return false
    end
    return true
  end
  
  def is_image?(file)
    %w(jpg jpeg gif png).include?(extension(file))
  end

  def is_font?(file)
    %w(ttf otf woff woff2 svg eot).include?(extension(file))
  end
  
  def is_css?(file)
    extension(file) == 'css'
  end
  
  def extension(file)
    file.original_filename.to_s.split('.').last.downcase.strip
  end
  
    
end
