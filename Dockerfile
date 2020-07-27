FROM ruby:2.7.0

ENV APP_ROOT /opt/app

ENV LANG C.UTF-8

RUN apt-get update && apt-get install -y build-essential libpq-dev vim apt-transport-https graphviz mecab mecab-ipadic-utf8

RUN gem install bundler

RUN mkdir -p $APP_ROOT
WORKDIR $APP_ROOT
COPY Gemfile $APP_ROOT
COPY Gemfile.lock $APP_ROOT

COPY . $APP_ROOT

RUN bundle install --jobs=4 --retry=3

EXPOSE 4000
