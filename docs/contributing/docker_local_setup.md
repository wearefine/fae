# Docker Local Setup

## Setup DB
1. Start a bash shell inside container
    ```
    docker-compose run app bash
    ```
2. Move into the dummy app
    ```
    cd spec/dummy
    ```
3. Create and seed db
    ```
    rake db:create db:migrate
    rake fae:seed_db
    ```
4. Create test db
    ```
    RAILS_ENV=test rake db:create db:migrate
    ```
<br>

## Running tests on dummy app gemset

1. Update Dockerfile to pull in x-server lib. This is required for running a headless browser on a linux instance
    ```
    # place immediately after FROM definition
    RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
    RUN apt-get update && apt-get install xvfb -y 
    ```

2. comment out the command key in docker-compose
3. Run from root folder to rebuild image
    ``` 
    docker build . 
    ```
4. Start a bash shell inside container
    ```
    docker-compose run app bash
    ```
5. Run tests while inside container shell
    ```
    RAILS_ENV=test xvfb-run -a bundle exec rspec spec/
    ```
<br>

## Running tests using Appraisal

1. Start a bash shell inside container
    ```
    docker-compose run app bash
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


