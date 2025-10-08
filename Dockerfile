# syntax = docker/dockerfile:1

FROM ruby:3.2-slim-bookworm AS base

LABEL org.opencontainers.image.source="https://github.com/bfpi/klarschiff-backoffice"
LABEL org.opencontainers.image.authors="BFPI GmbH"

ARG RAILS_ENV=production

WORKDIR /rails

ENV RAILS_ENV=${RAILS_ENV} \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"

# Throw-away build stage to reduce size of final image
FROM base AS build

# Install application node modules
COPY .nvmrc .yarnrc.yml package.json yarn.lock .
COPY .yarn .yarn

# Install packages needed to build gems and node modules
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential curl git gnupg pkg-config libpq-dev libpq5 libyaml-dev vim wkhtmltopdf

RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor > /usr/share/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$(sed -E 's/^v?([0-9]+).*/\1/' .nvmrc).x nodistro main" > /etc/apt/sources.list.d/nodesource.list && \
    curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor > /usr/share/keyrings/yarnkey.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" > /etc/apt/sources.list.d/yarn.list && \
    apt-get update -qq && \
    apt-get install --no-install-recommends -y nodejs yarn && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

RUN --mount=type=cache,id=yarn,target=/rails/.cache/yarn YARN_CACHE_FOLDER=/rails/.cache/yarn \
   yarn install --immutable

# Install application gems
COPY Gemfile Gemfile.lock ./

RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

COPY config/database.sample.yml config/database.yml
COPY config/storage.sample.yml config/storage.yml

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

# Start the server by default, this can be overwritten at runtime
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
