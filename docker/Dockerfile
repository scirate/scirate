FROM ruby:2.6.9-buster

# Add this before apt-get update
RUN sed -i 's|deb.debian.org/debian|archive.debian.org/debian|g' /etc/apt/sources.list && \
    sed -i 's|security.debian.org/debian-security|archive.debian.org/debian-security|g' /etc/apt/sources.list && \
    apt-get update -qq && \
    apt-get install -y \
      nodejs \
      postgresql-client \
      g++ \
      qt5-default \
      libqt5webkit5-dev \
      gstreamer1.0-plugins-base \
      gstreamer1.0-tools gstreamer1.0-x

# TODO: It's crazy that we need qt5 (and gstreamer?!)
run   apt-get update -qq && \
      apt-get install -y \
        nodejs \
        postgresql-client \
        g++ \
        qt5-default \
        libqt5webkit5-dev \
        gstreamer1.0-plugins-base \
        gstreamer1.0-tools gstreamer1.0-x

workdir /app

copy Gemfile /app/Gemfile
copy Gemfile.lock /app/Gemfile.lock

run gem update --system 3.4.22
run gem install bundler
run bundle install

copy docker/entrypoint.sh /usr/bin/
run  chmod +x /usr/bin/entrypoint.sh
cmd  entrypoint.sh

expose 3000
