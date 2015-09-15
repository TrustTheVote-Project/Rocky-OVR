#!/bin/bash
CURRENT_DIR=/var/www/register.rockthevote.com/rocky/current
RVM_ENV_DIR=/home/rocky/.rvm/environments/
RUBY_VERSION=`cat $CURRENT_DIR/.ruby-version`
GEMSET=`cat $CURRENT_DIR/.ruby-gemset`

source /home/rocky/.rvm/environments/$RUBY_VERSION@$GEMSET && cd $CURRENT_DIR && bundle exec rake admin:reset_password RAILS_ENV=loadtest