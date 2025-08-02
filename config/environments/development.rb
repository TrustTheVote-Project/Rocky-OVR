Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local = true
  
  if Rails.root.join('tmp', 'caching-dev.txt').exist?
    config.action_controller.perform_caching = true
      
    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false
  
    config.cache_store = :null_store
  end

  config.active_storage.service = :local

  ### uncomment to use DelayedJob in development.
  ### you must set config.cache_classes = true
  ### rake jobs:work  # to run the jobs
    # config.cache_classes = true
    # config.after_initialize do
    #   I18n.reload!
    #   Registrant.handle_asynchronously :wrap_up
    # end

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_caching = false
  config.action_mailer.delivery_method = :test


  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  config.active_record.migration_error = :page_load
  config.active_record.verbose_query_logs = true

  # Raise exception on mass assignment protection for Active Record models
  # config.active_record.mass_assignment_sanitizer = :strict

  # Do not compress assets
  config.assets.debug = true
  
  # Expands the lines which load the assets
  config.assets.quiet = true
  config.eager_load = true

  config.file_watcher = ActiveSupport::EventedFileUpdateChecker
end
