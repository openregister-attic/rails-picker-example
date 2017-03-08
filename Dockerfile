FROM ruby:2.4
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
RUN mkdir /location-picker-rails-app
WORKDIR /location-picker-rails-app
ADD . /location-picker-rails-app
RUN bundle install
