#!/usr/bin/env bash
# exit on error
set -o errexit

# Install and use specific Ruby version
curl -sSL https://get.rvm.io | bash -s stable
source /etc/profile.d/rvm.sh
rvm install 2.6.6
rvm use 2.6.6

# Install bundler
gem install bundler -v '1.17.3'

# Build commands
bundle install
bundle exec rake assets:precompile
bundle exec rake assets:clean
bundle exec rake db:migrate