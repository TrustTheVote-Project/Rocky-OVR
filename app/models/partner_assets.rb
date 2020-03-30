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
module PartnerAssets

  APP_CSS = "application.css"
  REG_CSS = "registration.css"
  PART_CSS = "partner.css"
  PART2_CSS = "partner2.css"
  PART2_MOBILE_CSS = "partner2mobile.css"
  PDF_LOGO = "pdf_logo" #.jpeg, .jpg or .gif

  def self.extension(name)
    name =~ /\.(.+)$/
    return $1
  end

  def replace_system_css?(group=:live)
    self.replace_system_css[group]
  end
  def replace_system_css_live
    self.replace_system_css?(:live)
  end
  def replace_system_css_preview
    self.replace_system_css?(:preview)
  end
  def replace_system_css_live=(value)
    self.replace_system_css[:live]=!!(value && value != "0" && value.to_s.downcase != 'false')
  end
  def replace_system_css_preview=(value)
    self.replace_system_css[:preview]=!!(value && value != "0" && value.to_s.downcase != 'false')
  end

  def use_long_form?
    whitelabeled? && !partner2_css_present? && (application_css_present? || registration_css_present? || partner_css_present?)
  end

  def any_css_present?
    application_css_present? || registration_css_present? || partner_css_present? || partner2_css_present?
  end

  def application_css_present?
    folder.asset_file_exists?(APP_CSS)
    #File.exists?(self.absolute_application_css_path)
  end

  def registration_css_present?
    folder.asset_file_exists?(REG_CSS)
  end

  def partner_css_present?
    folder.asset_file_exists?(PART_CSS)
    #File.exists?(self.absolute_partner_css_path)
  end
  def partner2_css_present?(group=nil)
    folder.asset_file_exists?(PART2_CSS, group)
  end
  def partner2_mobile_css_present?(group=nil)
    folder.asset_file_exists?(PART2_MOBILE_CSS, group)
  end
  
  def pdf_logo_present?(group = nil)
    pdf_logo_ext(group).present?
  end

  def pdf_logo_ext(group = nil)
    %w(gif jpg jpeg).find do |ext|
      folder.asset_file("#{PDF_LOGO}.#{ext}", group)
    end
  end
    
  # def pdf_logo_url(ext=nil)
  #   ext ||= pdf_logo_ext || "gif"
  #   "#{assets_url}/#{PDF_LOGO}.#{ext}"
  # end

  # Assuming always the case of shared/symlinked FS across partner upload server and PDF gen servers
  def absolute_pdf_logo_path(group = nil)
    ext = pdf_logo_ext(group) || "gif"
    folder.asset_url("#{PDF_LOGO}.#{ext}", group)
  end


  def assets_root
    if Rails.env.test?
      "#{Rails.root}/public/TEST"
    else
      "#{Rails.root}/public"
    end
  end

  # def assets_url
  #   "//#{partner_assets_host}#{partner_path}"
  # end
  
  def partner_assets_bucket
    self.class.partner_assets_bucket
  end
  
  def folder
    @paf ||= PartnerAssetsFolder.new(self)
  end
  
  # def partner_pdf_assets_host
  #   if Rails.env.staging?
  #     "rtvstaging.osuosl.org"
  #   elsif Rails.env.staging2?
  #     "rtvstaging2.osuosl.org"
  #   elsif Rails.env.development? || Rails.env.test? || Rails.env.cucumber?
  #     "localhost:3000"
  #   else
  #     "register.rockthevote.com"
  #   end
  # end

  def partner_root
    "partners"
  end

  def partner_path
    File.join(partner_root, self.id.to_s)
  end

  def assets_path
    #"#{assets_root}#{partner_path}"
    partner_path
  end

  def application_css_url(group = nil)
    folder.asset_url(APP_CSS, group)
  end
  
  def application_css_path(group = nil)
    File.join(partner_path, group.to_s, APP_CSS)
  end

  def registration_css_url(group = nil)
    folder.asset_url(REG_CSS, group)
  end
  def registration_css_path(group = nil)
    File.join(partner_path, group.to_s, REG_CSS)
  end

  def partner_css_url(group = nil)
    folder.asset_url(PART_CSS, group)
  end
  def partner2_css_url(group = nil)
    folder.asset_url(PART2_CSS, group)
  end
  def partner2_mobile_css_url(group = nil)
    folder.asset_url(PART2_MOBILE_CSS, group)
  end

  def partner_css_path(group = nil)
    File.join(partner_path, group.to_s, PART_CSS)
  end
  def partner2_css_path(group = nil)
    File.join(partner_path, group.to_s, PART2_CSS)
  end
  def partner2_mobile_css_path(group = nil)
    File.join(partner_path, group.to_s, PART2_MOBILE_CSS)
  end

  def absolute_old_assets_path
    "#{assets_path}/old"
  end

  # def absolute_application_css_path
  #   "#{assets_root}#{application_css_path}"
  # end
  #
  # def absolute_registration_css_path
  #   "#{assets_root}#{registration_css_path}"
  # end
  #
  # def absolute_partner_css_path
  #   "#{assets_root}#{partner_css_path}"
  # end

  def preview_custom_assets_link
    Rails.application.routes.url_helpers.new_registrant_path(preview_custom_assets: '', partner: self.id)
  end

  # returns one of:
  # :not_set - preview and root assets are empty
  # :not_changed - preview and root assets are equal (count and content)
  # :updated - preview and root assets are changed (count or content)
  def preview_assets_status
    preview = folder.files_by_folder('preview')
    root = folder.files_by_folder('')
    comparator = -> do
      (preview.keys + root.keys).uniq.any? do |key|
        preview[key] != root[key]
      end
    end
    case
      when preview.empty? && root.empty?
        :not_set
      when preview.size != root.size || comparator.call
        :updated
      else
        :not_changed
    end
  end

end
