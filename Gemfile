ruby "2.7.2"

source 'http://rubygems.org'

gem "rake"

gem "figaro"
gem "config"

gem "rails", "= 5.2.8.1"


gem "aasm" #, "= 4.12.3"

gem 'twilio-ruby' #, '~> 4.11.1'

gem 'will_paginate'

#gem 'utf8-cleaner'
gem 'rack-robustness'

gem "authlogic" #, "= 4.3.0"
gem 'scrypt'
gem 'daemons', '~> 1.1.9'
gem "paperclip" #, "~> 5.3.0"
gem 'mysql2' #, '~> 0.3.18'

gem 'distribute_reads'

gem 'google-authenticator-rails', '~> 3.4', '>= 3.4.2'


gem "rubyzip" #, '~> 1.3.0'
gem 'zip-zip'

gem "dotenv-rails", '~> 0.7.0'

gem "haml"

gem "rails-i18n" #, '~> 0.7.3'
gem 'jquery-rails' #, '~> 4.4.0'

gem 'dalli'

gem 'jwt'

group :pdf do
  gem 'wkhtmltopdf-binary', :git=>"https://github.com/amekelburg/wkhtmltopdf-binary", branch: "add-newer-osx"
  gem 'wicked_pdf', '2.1.0' #'0.9.6'
  gem 'formfiller', git: "https://github.com/TrustTheVote-Project/FormFiller", branch: "master"   
end

gem 'bootsnap', require: false

gem 'rest-client'
gem 'diffy'
gem 'asset_sync'
gem 'aws-sdk'
gem 'fog-aws'

group :development do
  gem 'rack-mini-profiler'
  gem 'listen'
end

group :development, :test do
  #gem 'pry'
  gem 'rails-controller-testing'
  gem 'spring-commands-rspec'
  gem "spring-commands-cucumber"
  gem "rspec-rails"
  gem 'rspec-collection_matchers'
  gem 'rspec-activemodel-mocks'
  gem 'capybara'
  
  gem "rr"# , "= 0.10.11"
  
  gem "cucumber-rails", :require=>false
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
  gem "sqlite3" #, "= 1.3.13"
  
  gem "assert_difference"
  
end

group :staging2, :staging, :production do
  gem 'passenger', "= 5.3.7"
end

group :test do
  gem "timecop"
  #gem "capybara-webkit", "~> 1.15.1"
  gem "webmock"
end

 # gem 'therubyracer'
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier'

gem "nokogiri" #, ">= 1.10.8"

gem "mechanize" #, "= 2.7.1"
gem "ledermann-rails-settings", "~> 2.4", :require => "rails-settings"

gem 'json'

gem "delayed_job_active_record" #, "~> 4.1"
gem 'delayed_cron_job'

gem 'exception_notification'
