#!/bin/sh

set -ex

rake db:setup
rake es:migrate

bundle exec rails s -p 3000 -b '0.0.0.0'
