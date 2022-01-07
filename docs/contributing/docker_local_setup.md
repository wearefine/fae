# Docker Local Setup

## Running tests

1. Update Dockerfile to pull in x-server lib. This is required for running a headless browser on a linux instance
```
# place immediately after FROM definition
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN apt-get update && apt-get install xvfb -y 
```

2. comment out the command definition in docker-compose
3. run from root folder
    ``` 
    docker build . 
    ```
4. run for shell inside container
    ```
    docker-compose run app bash
    ```
5. run tests while inside container shell
    ```
    RAILS_ENV=test xvfb-run -a bundle exec rspec spec/
    ```
