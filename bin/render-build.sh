#!/usr/bin/env bash
# exit on error
set -o errexit

gem install bundler:1.17.3
# Build commands
bundle install
bundle exec rake assets:precompile
bundle exec rake assets:clean
bundle exec rake db:migrate