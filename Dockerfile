FROM ruby:2.3

RUN apt-get update -qq && apt-get install -y nodejs

ENV APP_HOME /mitc
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD Gemfile* $APP_HOME/
RUN bundle install

ADD . $APP_HOME

