namespace :utility do
  desc "Go through UI registrants and submit stale records to the core system and delete records for transfered data"
  task :process_ui_records => :environment do
    ActiveSupport::Deprecation.silenced
    Registrant.process_ui_records
  end
  
  desc "Stop any passenger processes that use too much memory"
  task :cleanup_processes => :environment do
    ActiveSupport::Deprecation.silenced
    PassengerMonitor.cleanup
  end
  
  desc "Mark all stale registrations as abandoned and redact sensitive data"
  task :timeout_stale_registrations => :environment do
    ActiveSupport::Deprecation.silenced
    Registrant.remove_fake_records
    Registrant.abandon_stale_records
    Abr.abandon_stale_records  
  end
  
  desc "Remove pdf directories that are past the expiration date"
  task :remove_buckets => :environment do
    ActiveSupport::Deprecation.silenced
    BucketRemover.new.remove_buckets!
  end
  
  desc "Deliver reminder emails"
  task :deliver_reminders => :environment do
    ActiveSupport::Deprecation.silenced
    ReminderMailer.new.deliver_reminders!
  end
  
  desc "Generate Reports for RTV"
  task :generate_rtv_reports, [:hours]  => [:environment] do |t, args|
    ActiveSupport::Deprecation.silenced
    ReportGenerator.send("generate_#{args[:hours]}")
  end
  
  desc "Deactivate partners without recent registrations"
  task :deactivate_stale_partners => :environment do
    ActiveSupport::Deprecation.silenced
    Partner.deactivate_stale_partners!
  end
  
end
