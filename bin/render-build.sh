#!/usr/bin/env bash
# exit on error
set -o errexit

ls -la
cd spec/dummy
bundle install
echo 'try this'
ENV['DATABASE_URL']
bundle exec bin/rails db:migrate RAILS_ENV=production
echo 'after'
bundle exec rake assets:precompile
bundle exec rake assets:clean
