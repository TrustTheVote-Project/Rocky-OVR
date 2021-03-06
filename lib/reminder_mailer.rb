#!/usr/bin/env ruby

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
class ReminderMailer

  def deliver_reminders!
    deliver_final_reminders
    deliver_reminders(reg_ids(1, second_reminder_time))
    deliver_abr_reminders(abr_ids(1, second_reminder_time))
    deliver_reminders(reg_ids(2, first_reminder_time))
    deliver_abr_reminders(abr_ids(2, first_reminder_time))
  end

  def deliver_final_reminders
    Registrant.where(["reminders_left=0 AND pdf_downloaded = ? AND updated_at < ? AND final_reminder_delivered = ? AND pdf_ready=?", false, final_reminder_time, false, true]).find_each(batch_size: 500) do |reg|
      reg.deliver_final_reminder_email
    end
    Abr.where(["reminders_left=0 AND pdf_downloaded = ? AND updated_at < ? AND final_reminder_delivered = ? AND pdf_ready=?", false, final_reminder_time, false, true]).find_each(batch_size: 500) do |reg|
      reg.deliver_final_reminder_email
    end
  end

  def reg_ids(count, time)
    Registrant.where("reminders_left = ? AND updated_at < ?", count, time).pluck(:id)
  end
  def abr_ids(count, time)
    Abr.where("reminders_left = ? AND updated_at < ?", count, time).pluck(:id)
  end

  def final_reminder_time
    Time.now - AppConfig.hours_between_second_and_final_reminder.to_i
  end

  def second_reminder_time
    Time.now - AppConfig.hours_between_first_and_second_reminder.to_i
  end
  
  def first_reminder_time
    Time.now - AppConfig.hours_before_first_reminder.to_i
  end

  def deliver_reminders(registrant_ids)
    Registrant.where(["id in (?)", registrant_ids]).find_each(:batch_size=>500) do |reg|
      reg.deliver_reminder_email
    end
  end
  def deliver_abr_reminders(abr_ids)
    Abr.where(["id in (?)", abr_ids]).find_each(:batch_size=>500) do |abr|
      abr.deliver_reminder_email
    end
  end
end