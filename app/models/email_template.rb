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
class EmailTemplate < ActiveRecord::Base

  def self.display_name(type)
    type == 'thank_you_external' ? 'State OVR Responder' : type.humanize
  end
  
  EMAIL_TYPES = %w(confirmation reminder final_reminder chaser thank_you_external)
  TEMPLATE_NAMES = EMAIL_TYPES.inject([]){|result,t| result + I18n.available_locales.collect{|l| ["#{t}.#{l}", "#{display_name(t)} #{l.upcase}"]} }
  PREVIEW_NAME_MAPPING = TEMPLATE_NAMES.map { |name, label| ["preview_#{name}", name, label]}

  
  # [ [ 'confirmation.en', 'Confirmation EN' ], [ 'confirmation.es', 'Confirmation ES' ],
  #      [ 'reminder.en', 'Reminder EN' ], [ 'reminder.es', 'Reminder ES' ] ]

  belongs_to :partner, optional: true

  validates :partner, presence: true
  validates :name, uniqueness: {:scope => :partner_id}, presence: true

  

  # Sets the template body (creates or updates as necessary)
  def self.set(partner, name, body)
    return unless partner
    tmpl = EmailTemplate.find_or_initialize_by(partner_id: partner.id, name: name)

    # don't save default values # + some browsers add \r to \n
    body = "" if body.gsub("\r", "") == default(name)
    tmpl.body = body
    tmpl.save!
  end

  def self.set_subject(partner, name, subject)
    return unless partner
    tmpl = EmailTemplate.find_or_initialize_by(partner_id: partner.id, name: name)
    subject = "" if subject == default_subject(name)
    tmpl.subject = subject
    tmpl.save!    
  end

  # Returns the template body
  def self.get(partner, name)
    return nil unless partner
    body = EmailTemplate.find_by_partner_id_and_name(partner.id, name).try(:body)
    body.presence || default(name)
  end

  def self.get_subject(partner, name)
    return nil unless partner
    EmailTemplate.find_by_partner_id_and_name(partner.id, name).try(:subject).presence || default_subject(name)
  end

  # Returns TRUE if the partner email template with this name is non-empty
  def self.present?(partner, name)
    get(partner, name).present?
  end

  def self.publish_templates(partner)
    PREVIEW_NAME_MAPPING.each do |preview_name, production_name, _|
      subject = get_subject(partner, preview_name)
      body = get(partner, preview_name)
      set(partner, production_name, body)
      set_subject(partner, production_name, subject)
    end
  end

  def self.default(name)
    match = name.scan(/\A(preview_)?(.+)\.(.+)\z/)[0]
    return nil if match.nil?

    type = match[1]
    locale = match[2]

    # To replace I18n.t with its not interpolated translation
    # $1 - entire ERB ruby injection
    # $2 - extracted KEY
    regexp_i18n = /(<%=\s*I18n.t\(['"]([^'"]+)['"]((?!%>).)+%>)/m

    # To fix interpolation to be erb-compatible and use system variables
    regexp_interpolation = /%{([^}]+)}/

    source = File.read(File.join(Rails.root, 'app', 'views', 'notifier', "#{type}.html.erb"))
    translation = source.gsub(regexp_i18n) { I18n.t($2, locale: locale) }

    translation.gsub(regexp_interpolation) { "<%= @#{$1} %>" }
  end

  def self.default_subject(name)
    match = name.scan(/\Apreview_?(.+)\.(.+)\z/)[0] || nil
    match ? I18n.t("email.#{match[0]}.subject", locale: match[1]) : nil
  end
end
