#!/bin/bash

## refs:
# https://coderwall.com/p/xlkwtq/how-to-install-rvm-for-root
# https://www.digitalocean.com/community/tutorials/how-to-install-ruby-on-rails-on-centos-6-with-rvm

echo "$(date): bootstrapping rvm"

## install rvm package dependencies
yum install -y gcc-c++ patch readline readline-devel zlib zlib-devel libyaml-devel libffi-devel openssl-devel make bzip2 autoconf automake libtool bison

gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
#echo 'export rvm_prefix="$HOME"'     > /root/.rvmrc
#echo 'export rvm_path="$HOME/.rvm"' >> /root/.rvmrc

## install rvm
#curl -L get.rvm.io |rvm_path=/opt/rvm bash -s stable
curl -L get.rvm.io | bash -s stable
source /etc/profile.d/rvm.sh

## add vagrant to the rvm group
usermod -a -G rvm vagrant

## install ruby
rvm install 2.1.6

## install required gems
gem install --no-ri --no-rdoc bundler -v 1.10.5
gem install --no-ri --no-rdoc ruby-augeas -v 0.5.0
gem install --no-ri --no-rdoc highline
gem install --no-ri --no-rdoc hiera-eyaml hiera-gpg

echo "$(date): rvm bootstrap done"

