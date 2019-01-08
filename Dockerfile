FROM 335883679137.dkr.ecr.us-west-2.amazonaws.com/wearefine/base_ruby:2.3.1

ENV app /app/
ENV BUNDLE_PATH /gems
ENV GEM_HOME /gems

ADD Gemfile* $app
RUN bundle install

ENV PATH="$PATH:$BUNDLE_PATH/bin"

ADD . $app

CMD ["rails", "server", "--binding", "0.0.0.0"]