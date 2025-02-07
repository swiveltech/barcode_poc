#!/usr/bin/env bash
# exit on error
set -o errexit

# Install rbenv
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(~/.rbenv/bin/rbenv init -)"

# Install Ruby
rbenv install 2.6.6
rbenv global 2.6.6

# Install bundler
gem install bundler -v '1.17.3'

# Build commands
bundle install
bundle exec rake assets:precompile
bundle exec rake assets:clean
bundle exec rake db:migrate