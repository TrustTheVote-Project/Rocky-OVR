namespace :utility do
  desc "Go through UI registrants and submit stale records to the core system and delete records for transfered data"
  task :process_ui_records => :environment do
    Registrant.process_ui_records
  end
  
  desc "Stop any passenger processes that use too much memory"
  task :cleanup_processes => :environment do
    PassengerMonitor.cleanup
  end
  
  desc "Mark all stale registrations as abandoned and redact sensitive data"
  task :timeout_stale_registrations => :environment do
    Registrant.remove_fake_records
    Registrant.abandon_stale_records
    Abr.abandon_stale_records  
  end
  
  desc "Remove pdf directories that are past the expiration date"
  task :remove_buckets => :environment do
    BucketRemover.new.remove_buckets!
  end
  
  desc "Deliver reminder emails"
  task :deliver_reminders => :environment do
    ReminderMailer.new.deliver_reminders!
  end
  
  desc "Generate Reports for RTV"
  task :generate_rtv_reports, [:hours]  => [:environment] do |t, args|
    ReportGenerator.send("generate_#{args[:hours]}")
  end
  
  desc "Deactivate partners without recent registrations"
  task :deactivate_stale_partners => :environment do
    Partner.deactivate_stale_partners!
  end
  
end
