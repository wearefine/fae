FROM 335883679137.dkr.ecr.us-west-2.amazonaws.com/wearefine/base_ruby:2.3.1

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN apt-get update && apt-get install xvfb -y

ENV app /app
ENV BUNDLE_PATH /gems
ENV GEM_HOME /gems

COPY Gemfile* $app/

ENV PATH="$PATH:$BUNDLE_PATH/bin"

COPY . $app/




