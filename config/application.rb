require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  unless ENV['NO_PDF']
    Bundler.require(:pdf)
  end
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end




module Rocky
  class Application < Rails::Application

    require 'dotenv'
    Dotenv.load

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)
    config.autoload_paths += %W( #{Rails.root}/app/services
      #{Rails.root}/app/presenters
      #{Rails.root}/lib
      #{Rails.root}/app/models/state_customizations
    )

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    config.time_zone = 'UTC'


    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '*', '*.{rb,yml}').to_s]

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password, :state_id_number, :password_confirmation, :id_number]


    config.middleware.use ::Rack::Robustness do |g|
      g.no_catch_all
      g.on(ArgumentError) { |ex| 400 }
      g.content_type 'text/plain'
      g.body{ |ex| ex.message }
      g.ensure(true) { |ex| env['rack.errors'].write(ex.message) }
    end
    
    config.middleware.insert_before ActionDispatch::ParamsParser, "CatchJsonParseErrors"

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Enforce whitelist mode for mass assignment.
    # This will create an empty whitelist of attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
    # parameters by using an attr_accessible or attr_protected declaration.
    config.active_record.whitelist_attributes = false

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    config.assets.paths << Rails.root.join("app", "assets", "fonts")

    config.assets.precompile += %w( admin.css partner.css jquery.qtip.min.css qtip-custom.css registration.css reset.css rocky.css nvra.css state_configuration.css )
    config.assets.precompile += %w( admin.js registration.js rocky.js state_configuration.js jquery.js jquery_ujs.js jquery.qtip.min.js )
    config.assets.precompile += ["locales/*.css"]
    config.assets.precompile += ["nvra/locales/*.css"]
    config.assets.precompile << /\.(?:svg|eot|woff|ttf)$/

    config.assets.initialize_on_precompile = false
    
    config.action_controller.allow_forgery_protection = false

    config.i18n.available_locales = [:en, :es, :zh, :"zh-tw", :hi, :ur, :bn, :ja, :ko, :tl, :ilo, :th, :vi, :km]

    config.i18n.fallbacks =[:en]

    I18n.enforce_available_locales = false
  end
end
