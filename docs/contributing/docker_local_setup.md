# Docker Local Setup

1. Update Dockerfile to pull in an x-server lib. This is required for running a headless browser on a linux instance and is needed for running tests
    ```
    # place immediately after FROM definition
    RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
    RUN apt-get update && apt-get install xvfb -y
    ```

## Setup DB
1. Create the db's
    ```
    # create dummy app db
    docker-compose run app rake db:create db:migrate

    # create test db
    docker-compose run -e 'RAILS_ENV=test' app rake db:create db:migrate
    ```
3. Seed db
    ```
    docker-compose run app rake fae:seed_db
    ```
<br>

## Running tests on dummy app gemset.
1. Start a bash shell in containers /app directory
    ```
    docker-compose run -w /app app /bin/bash
    ```
2. Run tests while inside container shell
    ```
    RAILS_ENV=test xvfb-run -a bundle exec rspec
    ```
<br>

## Running tests using Appraisal

1. Start a bash shell in containers /app directory
    ```
    docker-compose run -w /app app /bin/bash
    ```
2. Download gems for appraisal versions
    ```
    appraisal install
    ```
3. If you need to update any gems for a specific appraisal gemset
    ```
    bundle update --gemfile='/app/gemfiles/rails_5_2.gemfile'

    # change to use whichever gemfile.lock you need updated
    ```
4. Run tests against an appraisal gemset. Omit the appraisal name to run tests against all versions
    ```
    RAILS_ENV=test appraisal rails_5_2 xvfb-run -a rspec
    ```


