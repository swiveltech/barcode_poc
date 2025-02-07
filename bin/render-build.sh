#!/usr/bin/env bash
# exit on error
set -o errexit

echo "==> Debug: Starting build process"
echo "==> Debug: Current Ruby version (before install)"
ruby -v

# Install rbenv
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(~/.rbenv/bin/rbenv init -)"

# Install Ruby
echo "==> Debug: Installing Ruby 2.6.6"
rbenv install 2.6.6
rbenv global 2.6.6

echo "==> Debug: Ruby version after rbenv install"
ruby -v
which ruby

# Install bundler
echo "==> Debug: Installing bundler"
gem install bundler -v '1.17.3'

echo "==> Debug: Bundler version"
bundle -v

# Build commands
bundle install
bundle exec rake assets:precompile
bundle exec rake assets:clean
bundle exec rake db:migrate