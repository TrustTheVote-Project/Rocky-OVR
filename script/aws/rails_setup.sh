#!/bin/bash
cd /var/www/rocky
source /home/ec2-user/.rvm/scripts/rvm 
rvm use ruby-1.9.3-p551@rocky6
# Make sure we have the config files downloaded
bundle install --without development test
# bundle exec rake db:migrate
# bundle exec rake import:states

# touch tmp/restart.txt