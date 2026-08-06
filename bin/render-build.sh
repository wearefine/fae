#!/usr/bin/env bash
# exit on error
set -o errexit

export RAILS_ENV=${RAILS_ENV:-production}
export NODE_ENV=${NODE_ENV:-production}

ls -la
cd spec/dummy

# Vite/Inertia assets require frontend dependencies during precompile.
npm ci

bundle install
bundle exec rake assets:precompile
bundle exec rake assets:clean
bundle exec rake db:migrate