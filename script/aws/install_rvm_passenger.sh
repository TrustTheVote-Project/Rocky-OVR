#!/bin/bash
cd /home/ec2-user
RVM_INSTALLED=$(which rvm)
if [ $RVM_INSTALLED != '~/.rvm/bin/rvm']; then

    gpg2 --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
    # Most of the time gpg2 is not necessary, so keep going if it doesn't work
    # If it's a new setup and doesn't work, the rvm install will fail anyway
    curl -sSL https://get.rvm.io | /bin/bash -s stable && \
        source /home/ec2-user/.rvm/scripts/rvm && \
        rvm install 1.9.3-p551 && \
        rvm use ruby-1.9.3-p551@rocky6 --create
    
    RVM_INSTALLED=$(which rvm)
    if [ $RVM_INSTALLED == '~/.rvm/bin/rvm']; then
        PASSENGER_VERSION=$(passenger-config --version)
        if [ $PASSENGER_VERSION != '3.0.19' ]; then            
            gem install passenger --version=3.0.19 && \
                passenger-install-apache2-module --auto
        fi
    fi
fi