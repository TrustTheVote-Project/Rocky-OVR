#!/bin/bash

# curl http://169.254.169.254/latest/meta-data/ ?
IFS='_' read -ra ENV_ROLE <<< "$DEPLOYMENT_GROUP_NAME"
RAILS_ENV="${ENV_ROLE[0]}"
SERVER_ROLE="${ENV_ROLE[1]}"

cd /var/www/rocky
source /etc/profile.d/rvm.sh
#rvm install 2.4.1
rvm use ruby-2.4.1@rocky8 --create
gem install bundler -v 1.16.3
# Make sure JAVA envs are loaded
. /home/ec2-user/.bash_profile    
bundle install --without development test

# Make sure we have the config files downloaded
aws s3 cp s3://rocky-cloudformation-assets/database.$RAILS_ENV.yml config/database.yml --region us-west-2
aws s3 cp s3://rocky-cloudformation-assets/.env.$RAILS_ENV .env.$RAILS_ENV --region us-west-2
cat /home/ec2-user/aws_env_vars.txt >> .env.$RAILS_ENV

NUM_PDF_WORKERS=3
NUM_UTIL_WORKERS=1
if [ $RAILS_ENV == 'staging' ]; then
    NUM_PDF_WORKERS=2
fi
if [ $RAILS_ENV == 'staging2' ]; then
    NUM_PDF_WORKERS=2
fi


if [ $SERVER_ROLE == 'util' ]; then
    echo "I'm a util server"
    
    # Crontab is for UTIL only
    cd ~
    aws s3 cp s3://rocky-cloudformation-assets/crontab . --region us-west-2
    sed -i 's/RAILS_ENV/'"$RAILS_ENV"'/' ./crontab
    
    # Make sure the cron scripts are executable
    chmod u+x /var/www/rocky/script/cron_mail_reminders
    chmod u+x /var/www/rocky/script/cron_timeout_stale_registrations
    chmod u+x /var/www/rocky/script/cron_deactivate_stale_partners
    chmod u+x /var/www/rocky/script/generate_rtv_reports
    
    crontab -r
    # Cat the crontab contents into the crontab editor
    (crontab -l 2>/dev/null; cat ./crontab) | crontab -
        
    cd /var/www/rocky
    RAILS_ENV=$RAILS_ENV bundle exec rake db:migrate

    # Only run once!!
    # RAILS_ENV=$RAILS_ENV bundle exec rake db:bootstrap
    RAILS_ENV=$RAILS_ENV bundle exec rake import:states

    RAILS_ENV=$RAILS_ENV bundle exec rake assets:precompile

    RAILS_ENV=$RAILS_ENV bundle exec rake pdf:generate_abr_cover_pages

    
    # ensure the file structure exists
    cd /var/www/rocky
    mkdir -p tmp/pids
    # make sure the script is executable
    chmod u+x script/*worker
    
    # enable and start the regular jobs worker (for report generation and API registrations)
    RAILS_ENV=$RAILS_ENV bundle exec ruby script/rocky_runner stop
    sleep 5
    for run in $(seq 1 $NUM_UTIL_WORKERS)
    do
        RAILS_ENV=$RAILS_ENV bundle exec ruby script/rocky_runner start
    done

    # enable and start the cloudwatch queue reporter (for PDFs autoscaling)
    RAILS_ENV=$RAILS_ENV bundle exec ruby script/rocky_cloudwatch_runner stop
    sleep 5
    RAILS_ENV=$RAILS_ENV bundle exec ruby script/rocky_cloudwatch_runner start

    
    # restart the PDF workers    
    RAILS_ENV=$RAILS_ENV TZ=:/etc/localtime bundle exec ruby script/rocky_pdf_runner stop --no_wait
    sleep 10    
    RAILS_ENV=$RAILS_ENV TZ=:/etc/localtime bundle exec ruby script/rocky_pdf_runner stop --force
    sleep 3
    for run in $(seq 1 $NUM_PDF_WORKERS)
    do
        RAILS_ENV=$RAILS_ENV TZ=:/etc/localtime bundle exec ruby script/rocky_pdf_runner start
    done
    
    
    
    # make sure there's a place for translation files
    mkdir -p tmp/translation_files
    
    
fi

if [ $SERVER_ROLE == 'web' ]; then
    echo "I'm a web server"
    RAILS_ENV=$RAILS_ENV bundle exec rake assets:precompile
    
    touch tmp/restart.txt
    
    # Passenger monitoring Crontab is for WEB only
    cd ~
    aws s3 cp s3://rocky-cloudformation-assets/web-crontab . --region us-west-2
    sed -i 's/RAILS_ENV/'"$RAILS_ENV"'/' ./web-crontab
    
    # Make sure the cron scripts are executable
    chmod u+x /var/www/rocky/script/cron_cleanup_processes
    
    crontab -r
    # Cat the crontab contents into the crontab editor
    (crontab -l 2>/dev/null; cat ./web-crontab) | crontab -
    
fi

if [ $SERVER_ROLE == 'pdf' ]; then
    echo "I'm a PDF server"
    # ensure the file structure exists
    cd /var/www/rocky
    RAILS_ENV=$RAILS_ENV bundle exec rake assets:precompile
    RAILS_ENV=$RAILS_ENV bundle exec rake pdf:generate_abr_cover_pages

    
    mkdir -p tmp/pids
    # make sure the script is executable
    chmod u+x script/*worker
    
    # enable and start the regular jobs worker (for report generation and API registrations)
    RAILS_ENV=$RAILS_ENV bundle exec ruby script/rocky_runner stop
    sleep 5
    for run in $(seq 1 $NUM_UTIL_WORKERS)
    do
        RAILS_ENV=$RAILS_ENV bundle exec ruby script/rocky_runner start
    done
    
    # restart the PDF workers
    RAILS_ENV=$RAILS_ENV TZ=:/etc/localtime bundle exec ruby script/rocky_pdf_runner stop --no_wait
    sleep 10
    RAILS_ENV=$RAILS_ENV TZ=:/etc/localtime bundle exec ruby script/rocky_pdf_runner stop --force
    sleep 3
    for run in $(seq 1 $NUM_PDF_WORKERS)
    do
        RAILS_ENV=$RAILS_ENV TZ=:/etc/localtime bundle exec ruby script/rocky_pdf_runner start
    done    
fi

echo Finished rails set up at:
date

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