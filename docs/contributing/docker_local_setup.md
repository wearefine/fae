# Docker Local Setup

The dev image (`Dockerfile.dev`) runs Ruby 3.3 on Debian bookworm and includes Chromium, which [Cuprite](https://github.com/rubycdp/cuprite) runs headlessly for JS feature specs. After pulling changes to `Dockerfile.dev`, rebuild the image:

```
docker-compose build app
```

If the Ruby version changed, reinstall gems into the `gems` volume with `docker-compose run -w /app app bundle install`.

## Setup DB
1. Create the db's
    ```
    # create dummy app db
    docker-compose run app rake db:create db:migrate

    # create test db
    docker-compose run -e 'RAILS_ENV=test' app bundle exec rake db:drop db:create db:migrate
    ```
3. Seed db
    ```
    docker-compose run app rake fae:seed_db
    ```
<br>

## Running tests on dummy app gemset
1. Start a bash shell in containers /app directory
    ```
    docker-compose run -w /app app /bin/bash
    ```
2. Run tests while inside container shell
    ```
    RAILS_ENV=test bundle exec rspec
    ```
3. Optional environment variables for JS feature specs
    - `JS_ERRORS=true` fails specs on uncaught JavaScript exceptions
    - `HEADLESS=false` opens a visible browser window (outside docker only)
4. After changing SCSS in `app/stylesheets`, rebuild the committed CSS
    ```
    docker-compose run -w /app app bundle exec rake fae:css:build
    ```
<br>
