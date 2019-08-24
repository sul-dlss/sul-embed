FROM phusion/passenger-customizable:latest

RUN /usr/local/rvm/bin/rvm remove 2.5.5
RUN /pd_build/nodejs.sh
RUN /pd_build/ruby-2.6.*.sh

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt-get update && apt-get upgrade -y -o Dpkg::Options::="--force-confold" && apt-get install -y tzdata yarn && apt-get clean


RUN rm -f /etc/service/nginx/down
RUN rm /etc/nginx/sites-enabled/default

ADD docker/webapp.conf /etc/nginx/sites-enabled/webapp.conf

RUN mkdir /home/app/webapp
RUN chown app:app /home/app/webapp
COPY --chown=app:app . /home/app/webapp

WORKDIR /home/app/webapp
USER app

RUN bundle install --deployment
RUN yarn install --check-files
RUN bundle exec rake assets:precompile SECRET_KEY_BASE=asdf

USER root
