#!/usr/bin/env bash
# exit on error
set -o errexit

ls -la
cd spec/dummy
bundle install
bundle exec rake assets:precompile
bundle exec rake assets:clean
echo 'try this'
bundle exec rake db:migrate
echo 'after'