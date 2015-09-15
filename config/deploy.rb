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

require 'dotenv'
Dotenv.load




set :application, "rocky"
set :repository,  "git@github.com:trustthevote-project/Rocky-OVR.git"

# If you have previously been relying upon the code to start, stop
# and restart your mongrel application, or if you rely on the database
# migration code, please uncomment the lines you require below

# If you are deploying a rails app you probably need these:

# load 'ext/rails-database-migrations.rb'
# load 'ext/rails-shared-directories.rb'

# There are also new utility libaries shipped with the core these
# include the following, please see individual files for more
# documentation, or run `cap -vT` with the following lines commented
# out to see what they make available.

# load 'ext/spinner.rb'              # Designed for use with script/spin
# load 'ext/passenger-mod-rails.rb'  # Restart task for use with mod_rails
# load 'ext/web-disable-enable.rb'   # Gives you web:disable and web:enable


set :deploy_to, ENV['DEPLOY_TO']

set :stages, Dir["config/deploy/*"].map {|stage| File.basename(stage, '.rb')}
set :default_stage, "production"
require 'capistrano/ext/multistage'

set :scm, "git"
set :user, "rocky"
set :deploy_via, :remote_cache
set :branch, (rev rescue "master")    # cap deploy -Srev=[branch|tag|SHA1]

set :group_writable, false
set :use_sudo, false

set :assets_role, [:web, :util, :pdf]


set :rvm_ruby_string, :local        # use the same ruby as used locally for deployment
set :rvm_autolibs_flag, "enable"
set :rvm_install_with_sudo, true 

set :sync_assets, fetch(:sync_assets, true)


before 'deploy:setup', 'rvm:install_rvm'   # install RVM
before 'deploy:setup', 'rvm:install_ruby' 
before 'deploy:setup', 'rvm:install_passenger' 
before 'deploy:setup', 'rvm:setup_passenger' 
before 'deploy:setup', 'rvm:install_bundler'

# this shouldn't be automatic ?
# after 'deploy:setup', 'heroku:setup'

before 'deploy', 'rvm:install_ruby' # install Ruby and create gemset (both if missing)

require "rvm/capistrano"


load 'deploy/assets'




after "deploy:update_code", "deploy:symlink_web_pdf", "deploy:symlink_csv", "deploy:symlink_partners",  "deploy:migrate"
after "deploy:finalize_update", "deploy:symlink_system"
# , "deploy:symlink_util_pdf", 

set :rake, 'bundle exec rake'


before "deploy:restart", "deploy:import_states_yml"   # runs after migrations when migrating
after "deploy:restart", "deploy:run_pdf_workers", "deploy:run_workers"
after "deploy", "deploy:cleanup"

# this should not be automatic 
# after "deploy", "heroku:deploy"

namespace :admin do
  desc "reset admin password and display"
  task :reset_password, :roles => [:app] do
    run <<-CMD
      cd #{latest_release} &&
      RAILS_ENV=#{rails_env} bundle exec rake admin:reset_password
    CMD
  end
end




namespace :rvm do
  
  desc "Install passenger"
  task :install_passenger, :roles => :web do
    run "gem install passenger --version=3.0.19", :shell => fetch(:rvm_shell)
  end
  
  desc "Install and setup RVM Passenger"
  task :setup_passenger, :roles => :web do
    run "passenger-install-apache2-module --auto", :shell => fetch(:rvm_shell)    
  end
  
  desc "Install bundler in gemset"
  task :install_bundler, :roles => [:web, :util, :pdf] do
    run 'rvm use ruby-1.9.3-p125@rocky4 && gem install bundler', :shell => fetch(:rvm_shell)
  end
  
end



namespace :deploy do

  # namespace :assets do
  #   task :precompile, :roles => :web, :except => { :no_release => true } do
  #     from = source.next_revision(current_revision)
  #     if capture("cd #{latest_release} && #{source.local.log(from)} vendor/assets/ app/assets/ | wc -l").to_i > 0
  #       run %Q{cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} #{asset_env} assets:precompile}
  #     else
  #       logger.info "Skipping asset pre-compilation because there were no asset changes"
  #     end
  #   end
  # end


  before "deploy:assets:precompile", "deploy:link_db", "deploy:symlink_configs"
  task :link_db do
    run "ln -s #{shared_path}/config/database.yml #{latest_release}/config/database.yml"
  end
  
  # after "deploy:assets:precompile", "deploy:asset_sync"
  # task :asset_sync, :roles => [:app] do
  #   if sync_assets != 0
  #     run <<-CMD
  #       cd #{latest_release} &&
  #       bundle exec rake assets:sync
  #     CMD
  #   end
  # end
  
  
  desc "import states.yml data"
  task :import_states_yml, :roles => [:app] do
    run <<-CMD
      cd #{latest_release} &&
      RAILS_ENV=#{rails_env} bundle exec rake import:states
    CMD
  end
  
  desc "import states.yml and zip code data"
  task :import_states_and_zips, :roles=>[:util] do
    run <<-CMD
      cd #{latest_release} &&
      RAILS_ENV=#{rails_env} bundle exec rake import:states_and_zips
    CMD
  end

  desc "Link the database.yml, .env.{environment} files, and newrelic.yml files into the current release path."
  task :symlink_configs, :roles => [:web, :util, :pdf], :except => {:no_release => true} do
    run <<-CMD
      cd #{latest_release} &&
      ln -nfs #{shared_path}/config/database.yml #{latest_release}/config/database.yml
    CMD
    run <<-CMD
      cd #{latest_release} &&
      ln -nfs #{shared_path}/config/newrelic.yml #{latest_release}/config/newrelic.yml
    CMD
    run <<-CMD
      cd #{latest_release} &&
      ln -nfs #{shared_path}/.env.#{rails_env} #{latest_release}/.env.#{rails_env}
    CMD
  end
  
  task :symlink_translations, :roles=>[:web], :except =>{:no_release => true} do
    run <<-CMD
      mkdir -p #{shared_path}/translation_files &&
      cd #{latest_release} &&
      rm -rf tmp/translation_files &&
      ln -nfs #{shared_path}/translation_files #{latest_release}/tmp/translation_files
    CMD
  end

  desc "Link the pdf dir to shared/pdfs"
  task :symlink_web_pdf, :roles => [:web, :util, :pdf], :except => {:no_release => true} do
    run <<-CMD
      mkdir -p #{ENV['SYMLINK_DATA_DIR']}/html/pdfs &&
      cd #{latest_release} &&
      rm -rf pdfs && 
      ln -nfs  #{ENV['SYMLINK_DATA_DIR']}/html/pdfs public/pdfs
    CMD
  end
  
  # desc "Link the pdf dir to /data/rocky/pdf"
  # task :symlink_util_pdf, :roles => [:util], :except => {:no_release => true} do
  #   run <<-CMD
  #     cd #{latest_release} &&
  #     rm -rf pdf &&
  #     ln -nfs  #{ENV['SYMLINK_DATA_DIR']}/html pdf
  #   CMD
  # end

  
  desc "Link the csv dir to /data/rocky/csv"
  task :symlink_csv, :roles => [:web, :util], :except => {:no_release => true} do
    run <<-CMD
      mkdir -p #{ENV['SYMLINK_DATA_DIR']}/html/partner_csv &&
      cd #{latest_release} &&
      rm -rf csv &&
      ln -nfs #{ENV['SYMLINK_DATA_DIR']}/html/partner_csv csv &&
      rm -rf public/csv &&
      ln -nfs #{ENV['SYMLINK_DATA_DIR']}/html/partner_csv #{latest_release}/public/csv
    CMD
  end


  desc "Link the public/partners dir to the shared path"
  task :symlink_partners, :roles=>[:web, :pdf, :util], :except => {:no_release => true} do
    run <<-CMD
      mkdir -p #{ENV['SYMLINK_DATA_DIR']}/html/partner_assets &&
      cd #{latest_release} &&
      ln -nfs #{ENV['SYMLINK_DATA_DIR']}/html/partner_assets #{latest_release}/public/partners
    CMD
  end  

  desc "Link the public/system dir to the shared path"
  task :symlink_system, :roles=>[:web, :pdf, :util], :except => {:no_release => true} do
    run <<-CMD
      mkdir -p #{ENV['SYMLINK_DATA_DIR']}/html/system_assets &&
      cd #{latest_release} &&
      rm -rf public/system && 
      ln -nfs #{ENV['SYMLINK_DATA_DIR']}/html/system_assets #{latest_release}/public/system
    CMD
  end

  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :web, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end

  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :web do ; end
  end

  desc "Run (or restart) worker processes on util server"
  task :run_workers, :roles => :util do
    run "cd #{latest_release} && RAILS_ENV=#{rails_env} bundle exec ruby script/rocky_runner stop"
    sleep 5
    run "cd #{latest_release} && RAILS_ENV=#{rails_env} bundle exec ruby script/rocky_runner start"
    unset(:latest_release)
  end

  desc "Stop worker processes on util server"
  task :stop_workers, :roles => :util do
    run "cd #{latest_release} && RAILS_ENV=#{rails_env} bundle exec ruby script/rocky_runner stop"
    # nasty hack to make sure it stops
    unset(:latest_release)
  end
  
  desc "Run (or restart) pdf worker processes on pdf server"
  task :run_pdf_workers, :roles => :pdf do
    run "cd #{latest_release} && RAILS_ENV=#{rails_env} bundle exec ruby script/rocky_pdf_runner stop"
    sleep 10
    2.times do
      run "cd #{latest_release} && RAILS_ENV=#{rails_env} TZ=:/etc/localtime bundle exec ruby script/rocky_pdf_runner start"
    end
  end

  desc "Stop worker pdf processes on pdf server"
  task :stop_pdf_workers, :roles => :pdf do
    run "cd #{latest_release} && RAILS_ENV=#{rails_env} bundle exec ruby script/rocky_pdf_runner stop"
  end
  
end

before "heroku:setup", "heroku:set_config", "heroku:addons"
after "heroku:deploy", "heroku:import_states_yml"

namespace :heroku do
  
  
  
  desc "Deploy environement-specific branch to heroku remote"
  task :deploy do
    %x[git push #{heroku_remote} #{branch}:master]
  end
  
  desc "import states.yml data"
  task :import_states_yml, :roles => [:app] do
    Bundler.with_clean_env do
      system("heroku run bundle exec rake import:states --remote=#{heroku_remote}")
    end
  end
  
  
  task :setup do
    Bundler.with_clean_env do
      system("heroku run bundle exec rake db:migrate --remote=#{heroku_remote}")
      system("heroku run bundle exec rake db:bootstrap --remote=#{heroku_remote}")
    end
  end
    
  task :set_config do
    Dotenv.load(".env.#{rails_env}")
    ['AIRBRAKE_API_KEY',
     'SECRET_TOKEN',
     'AWS_ACCESS_KEY_ID',
     'AWS_SECRET_ACCESS_KEY',
     'ROCKY_CORE_API_KEY',
     'NEW_RELIC_LICENSE_KEY',
     'NEW_RELIC_APP_NAME'].each do |env_var|
       #%x[heroku config:get #{env_var} --remote=#{heroku_remote}]
       env_val = ENV[env_var]
       Bundler.with_clean_env do
         system("heroku config:set #{env_var}='#{env_val}' --remote=#{heroku_remote}")
       end       
     end
     Bundler.with_clean_env do
       system("heroku config:set ROCKY_ROLE=UI --remote=#{heroku_remote}")
       system("heroku config:set BUNDLE_WITHOUT=development:test:pdf --remote=#{heroku_remote}")
       system("heroku config:set RAILS_ENV=#{rails_env} --remote=#{heroku_remote}")
     end       
   
  end
  
  task :addons do
    Bundler.with_clean_env do
      #mysql DB
      system("heroku addons:add cleardb --remote=#{heroku_remote}")
      #sleep(5)
      clear_db_url = IO.popen("heroku config:get CLEARDB_DATABASE_URL --remote=#{heroku_remote}").read
      db_url = clear_db_url.gsub(/^mysql/,"mysql2").split(/[\r\n]+/).first
      system("heroku config:set DATABASE_URL=#{db_url} --remote=#{heroku_remote}")
      # MemCache
      system("heroku addons:add memcachier --remote=#{heroku_remote}")
      # outbound IP
      system("heroku addons:add proximo --remote=#{heroku_remote}")      
      # scehdueld tasks
      system("heroku addons:add scheduler --remote=#{heroku_remote}")      
    end
  end
end


require './config/boot'

require 'airbrake/capistrano'

require 'bundler/capistrano'