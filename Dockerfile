# syntax = docker/dockerfile:experimental
ARG RUBY_VERSION=3.1.1
ARG VARIANT=jemalloc-slim
FROM quay.io/evl.ms/fullstaq-ruby:${RUBY_VERSION}-${VARIANT} as base

ENV DOCKER_BUILDKIT=1

ARG NODE_VERSION=16
ARG BUNDLER_VERSION=2.3.9

ARG RAILS_ENV=production
ENV RAILS_ENV=${RAILS_ENV}

ENV RAILS_SERVE_STATIC_FILES true
ENV RAILS_LOG_TO_STDOUT true

ARG BUNDLE_WITHOUT=development:test
ARG BUNDLE_PATH=vendor/bundle
ENV BUNDLE_PATH ${BUNDLE_PATH}
ENV BUNDLE_WITHOUT ${BUNDLE_WITHOUT}

RUN mkdir -p /app/spec/dummy/tmp/pids
WORKDIR /app
# RUN touch tmp/pids/.keep
RUN touch /app/spec/dummy/tmp/pids/server.pid

SHELL ["/bin/bash", "-c"]

RUN curl https://get.volta.sh | bash

ENV BASH_ENV ~/.bashrc
ENV VOLTA_HOME /root/.volta
ENV PATH $VOLTA_HOME/bin:/usr/local/bin:$PATH

RUN volta install node@${NODE_VERSION} && volta install yarn

FROM base as build_deps

ARG DEV_PACKAGES="git build-essential libpq-dev wget vim curl gzip xz-utils libsqlite3-dev imagemagick libmagickcore-dev libmagickwand-dev"
ENV DEV_PACKAGES ${DEV_PACKAGES}

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y ${DEV_PACKAGES} \
    && rm -rf /var/lib/apt/lists /var/cache/apt/archives

FROM build_deps as gems

RUN gem install -N bundler -v 2.3.9

COPY Gemfile* ./
COPY fae.gemspec* ./
RUN bundle install &&  rm -rf vendor/bundle/ruby/*/cache

FROM build_deps as node_modules

# COPY package*json ./
# COPY yarn.* ./

RUN if [ -f "yarn.lock" ]; then \
    yarn install; \
    elif [ -f "package-lock.json" ]; then \
    npm install; \
    else \
    mkdir node_modules; \
    fi

FROM base

ARG PROD_PACKAGES="postgresql-client file vim curl gzip libsqlite3-0 imagemagick libmagickcore-dev libmagickwand-dev"
ENV PROD_PACKAGES=${PROD_PACKAGES}

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    ${PROD_PACKAGES} \
    && rm -rf /var/lib/apt/lists /var/cache/apt/archives

COPY --from=gems /app /app
COPY --from=node_modules /app/node_modules /app/node_modules

ENV SECRET_KEY_BASE 1

COPY . .

# WORKDIR /app/spec/dummy

RUN bundle exec rails assets:precompile
# RUN cd spec/dummy && bundle exec rails assets:precompile

ENV PORT 8080

WORKDIR /app/spec/dummy

ARG SERVER_COMMAND="bundle exec puma -C config/puma.rb"
ENV SERVER_COMMAND ${SERVER_COMMAND}
CMD ${SERVER_COMMAND}
