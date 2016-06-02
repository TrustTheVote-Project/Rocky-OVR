#!/bin/bash
cd /var/www/rocky
# Make sure we have the config files downloaded
bundle install
# bundle exec rake db:migrate
# bundle exec rake import:states

# touch tmp/restart.txt