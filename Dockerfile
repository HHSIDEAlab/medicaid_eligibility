FROM ruby:2.3

RUN apt-get update -qq && apt-get install -y nodejs

ENV APP_HOME /mitc
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD Gemfile* $APP_HOME/

ADD . $APP_HOME

ENV RAILS_ENV='production'
RUN bundle install
RUN bundle exec rake assets:precompile
