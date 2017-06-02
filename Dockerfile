FROM ruby:2.4.1-alpine

MAINTAINER dogwood008

WORKDIR /bot

RUN echo "@edge https://nl.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories \
      && apk -U upgrade \
      && apk add -t build-dependencies \
      build-base \
      && apk add \
      ca-certificates \
      file \
      git \
      su-exec \
      tini \
      bash \
      && update-ca-certificates \
      && rm -rf /tmp/* /var/cache/apk/*

COPY Gemfile Gemfile.lock /bot/
COPY . /bot

RUN bundle install
VOLUME /bot/source

CMD ["ruby", "./fxdon_bot/bot.rb"]
