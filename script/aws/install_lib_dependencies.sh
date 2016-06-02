#!/bin/bash
aws s3 cp s3://rocky-staging2-codedeploy/RPM-GPG-KEY-CentOS-6 /etc/pki/rpm-pkg/ --region us-west-2
aws s3 cp s3://rocky-staging2-codedeploy/centos-base.repo /etc/yum.repos.d/ --region us-west-2

yum install -y git-all httpd apr-devel apr-util-devel gcc-c++ httpd-devel ImageMagick-devel libcurl-devel libxslt-devel libyaml-devel mysql-devel perl-DBD-MySQL perl-DBI perl-XML-Simple zlib-devel openssl-devel mod_ssl


yum install -y thai-scalable-fonts-common thai-scalable-garuda-fonts thai-scalable-kinnari-fonts thai-scalable-loma-fonts thai-scalable-norasi-fonts thai-scalable-purisa-fonts thai-scalable-sawasdee-fonts thai-scalable-tlwgmono-fonts thai-scalable-tlwgtypewriter-fonts thai-scalable-tlwgtypist-fonts thai-scalable-tlwgtypo-fonts thai-scalable-umpush-fonts thai-scalable-waree-fonts 

yum install -y baekmuk-ttf-batang-fonts baekmuk-ttf-dotum-fonts baekmuk-ttf-fonts-common

yum install -y  khmeros-base-fonts khmeros-battambang-fonts khmeros-bokor-fonts khmeros-fonts-common khmeros-handwritten-fonts khmeros-metal-chrieng-fonts khmeros-muol-fonts khmeros-siemreap-fonts

yum install -y  lohit-bengali-fonts lohit-devanagari-fonts samyak-devanagari-fonts samyak-fonts-common


aws s3 cp s3://rocky-staging2-codedeploy/httpd-staging2.conf /etc/httpd/conf/httpd.conf --region us-west-2
