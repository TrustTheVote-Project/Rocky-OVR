#!/bin/bash

# curl http://169.254.169.254/latest/meta-data/ ?
IFS='_' read -ra ENV_ROLE <<< "$DEPLOYMENT_GROUP_NAME"
RAILS_ENV="${ENV_ROLE[0]}"
SERVER_ROLE="${ENV_ROLE[1]}"

cd /var/www/rocky
source /etc/profile.d/rvm.sh
rvm install 1.9.3-p551
rvm use ruby-1.9.3-p551@rocky6 --create
gem install bundler
bundle install --without development test

# Make sure we have the config files downloaded
aws s3 cp s3://rocky-$RAILS_ENV-codedeploy/database.yml config/database.yml --region us-west-2
aws s3 cp s3://rocky-$RAILS_ENV-codedeploy/.env.$RAILS_ENV .env.$RAILS_ENV --region us-west-2

if [ $SERVER_ROLE == 'util' ]; then
    echo "I'm a util server"
    # TODO: get these to use a standard environment variable?
    RAILS_ENV=$RAILS_ENV bundle exec rake db:migrate
    # TODO: Only run once!!
    RAILS_ENV=$RAILS_ENV bundle exec rake db:bootstrap
    RAILS_ENV=$RAILS_ENV bundle exec rake import:states
    RAILS_ENV=$RAILS_ENV bundle exec rake assets:precompile

    # restart the PDF workers
fi

if [ $SERVER_ROLE == 'web' ]; then
    echo "I'm a web server"
    RAILS_ENV=$RAILS_ENV bundle exec rake assets:precompile
    touch tmp/restart.txt
fi

if [ $SERVER_ROLE == 'pdf' ]; then
    # restart the PDF workers
    echo "I'm a PDF server"
fi


# echo $LIFECYCLE_EVENT
# echo $DEPLOYMENT_ID
# echo $APPLICATION_NAME
# echo $DEPLOYMENT_GROUP_NAME
# echo $DEPLOYMENT_GROUP_ID

# [2016-06-04 19:05:29.180] [d-0WNIF2G0G][stdout]AfterInstall
# [2016-06-04 19:05:29.180] [d-0WNIF2G0G][stdout]d-0WNIF2G0G
# [2016-06-04 19:05:29.180] [d-0WNIF2G0G][stdout]rocky
# [2016-06-04 19:05:29.180] [d-0WNIF2G0G][stdout]staging2
# [2016-06-04 19:05:29.180] [d-0WNIF2G0G][stdout]1324e2a4-7ad8-46ad-be04-720a4c523899