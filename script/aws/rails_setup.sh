#!/bin/bash
cd /var/www/rocky
source /home/ec2-user/.rvm/scripts/rvm 
rvm use ruby-1.9.3-p551@rocky6
gem install bundler
bundle install --without development test

# Make sure we have the config files downloaded
aws s3 cp s3://rocky-staging2-codedeploy/database.yml config/database.yml --region us-west-2

# bundle exec rake db:migrate
# bundle exec rake import:states

# touch tmp/restart.txt