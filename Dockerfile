FROM 335883679137.dkr.ecr.us-west-2.amazonaws.com/wearefine/base_ruby:2.3.1

# RUN apt-get install libqtwebkit4
ENV app /app
ENV BUNDLE_PATH /gems
ENV GEM_HOME /gems

COPY Gemfile* $app/

ENV PATH="$PATH:$BUNDLE_PATH/bin"

COPY . $app/




