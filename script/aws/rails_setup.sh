#!/bin/bash
cd /var/www/rocky
source /home/ec2-user/.rvm/scripts/rvm 
rvm use ruby-1.9.3-p551@rocky6
gem install bundler
bundle install --without development test

# Make sure we have the config files downloaded
aws s3 cp s3://rocky-staging2-codedeploy/database.yml config/database.yml --region us-west-2
aws s3 cp s3://rocky-staging2-codedeploy/.env.staging2 .env.staging2 --region us-west-2

# TODO: get these to use a standard environment variable?
RAILS_ENV=staging2 bundle exec rake db:migrate
# TODO: Only run once!!
RAILS_ENV=staging2 bundle exec rake db:bootstrap
RAILS_ENV=staging2 bundle exec rake import:states

touch tmp/restart.txt