#!/bin/bash
cd /home/ec2-user
gpg2 --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 && \
    curl -sSL https://get.rvm.io | /bin/bash -s stable && \
    source /home/ec2-user/.rvm/scripts/rvm && \
    rvm install 1.9.3-p551 && \
    rvm use ruby-1.9.3-p551@rocky6 && \
    gem install passenger --version=3.0.19 && \
    passenger-install-apache2-module --auto && \
    rvm use ruby-1.9.3-p551@rocky6 && gem install bundler