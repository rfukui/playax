FROM ruby:2.6.3
MAINTAINER Ricardo Fukui <r.fukui@gmail.com>
#solving problem with the lastest version of jessie
RUN printf "deb http://archive.debian.org/debian/ jessie main\ndeb-src http://archive.debian.org/debian/ jessie main\ndeb http://security.debian.org jessie/updates main\ndeb-src http://security.debian.org jessie/updates main"\
 > /etc/apt/sources.list
RUN apt-get update && \
    apt-get install -y net-tools

# Install gems
ENV APP_HOME /app
ENV HOME /root
RUN mkdir $APP_HOME
WORKDIR $APP_HOME
COPY Gemfile* $APP_HOME/
#RUN apt-get upgrade -y
# Upload source
COPY . $APP_HOME
RUN bundle install
RUN rspec
