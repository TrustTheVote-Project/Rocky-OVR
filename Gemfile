ruby "2.4.1"

source 'http://rubygems.org'

gem "rake", "12.3.3"
gem "excon", ">= 0.71.0"

gem "figaro"
gem "config"

gem "rails", "= 4.2.11.3"

gem 'protected_attributes'

gem "aasm", "= 4.12.3"

gem 'twilio-ruby', '~> 4.11.1'

gem 'will_paginate'

#gem 'utf8-cleaner'
gem 'rack-robustness'

gem "authlogic", "= 4.3.0"
gem 'daemons', '~> 1.1.9'
gem "paperclip", "~> 5.3.0"
gem 'mysql2', '~> 0.3.18'

gem 'distribute_reads'

gem 'google-authenticator-rails'


gem "rubyzip", '~> 1.3.0'
gem 'zip-zip'

gem "dotenv-rails", '~> 0.7.0'

gem "haml"

gem "rails-i18n", '~> 0.7.3'
gem 'jquery-rails', '~> 4.4.0'

gem 'dalli'

gem 'jwt'

group :pdf do
  gem 'wkhtmltopdf-binary', :git=>"https://github.com/amekelburg/wkhtmltopdf-binary", branch: "add-newer-osx"
  gem 'wicked_pdf', '0.9.6'
  gem 'formfiller', git: "https://github.com/cwulfman/FormFiller", branch: "master"   
end

gem 'rest-client'
gem 'diffy'
gem 'asset_sync'
gem 'aws-sdk'
gem 'fog-aws'

group :development do
  gem 'rack-mini-profiler'
end

group :development, :test do
  #gem 'pry'
  gem 'spring-commands-rspec'
  gem "spring-commands-cucumber"
  gem "rspec-rails", "~> 3.9"
  gem 'rspec-collection_matchers'
  gem 'rspec-activemodel-mocks'
  gem 'capybara'
  
  gem "rr", "= 0.10.11"
  
  gem "cucumber-rails", "1.4.2", :require=>false
  gem "webrat"
  gem "factory_girl_rails", :require=>false
  gem "database_cleaner"
  gem "shoulda"
  gem 'simplecov', :require => false
  gem 'webdrivers'
  
  #gem "treetop", "= 1.4.10"
  # gem "selenium-client", "= 1.2.16"


  # gem "capistrano", "= 2.15.5", :require=>false
  # gem "rvm-capistrano"
  
  # Pito:
  # gem "hpricot", "0.8.6"
  gem "sqlite3", "= 1.3.13"
  
  gem "assert_difference"
  
end

group :staging2, :staging, :production do
  gem 'passenger', "= 5.3.4"
end

group :test do
  gem "timecop"
  #gem "capybara-webkit", "~> 1.15.1"
  gem "webmock"
end

  gem 'therubyracer'
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier'

gem "nokogiri", ">= 1.10.8"

gem "mechanize", "= 2.7.1"
gem "ledermann-rails-settings", "~> 2.4", :require => "rails-settings"

gem 'json'

gem "delayed_job_active_record", "~> 4.1"
gem 'delayed_cron_job'

gem 'exception_notification'