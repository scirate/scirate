# SciRate

[![Build Status](https://travis-ci.org/scirate/scirate.svg?branch=master)](https://travis-ci.org/scirate/scirate)
[![Coverage Status](https://coveralls.io/repos/scirate/scirate/badge.png?branch=master)](https://coveralls.io/r/scirate/scirate?branch=master)
[![Code Climate](https://codeclimate.com/github/scirate/scirate.png)](https://codeclimate.com/github/scirate/scirate)

A rewrite of [Dave Bacon's](http://dabacon.org) SciRate in Ruby on Rails, previously developed by Dave Bacon, [Bill Rosgen](http://intractable.ca/bill/) and [Aram Harrow](http://www.mit.edu/~aram/). Currently being expanded upon by [Draftable](https://draftable.com/).

The production site is deployed at [https://scirate.com/](https://scirate.com/).

## Contributing

We encourage contributions!

* You can submit a bug report [here](https://github.com/scirate/scirate/issues).

* You can contribute to the code by sending a pull request on Github to the [canonical repository](https://github.com/scirate/scirate).

* You can talk about SciRate on our [mailing list](https://groups.google.com/forum/?fromgroups=#!forum/scirate) and about SciRate development on the [development mailing list](https://groups.google.com/forum/?fromgroups=#!forum/scirate-dev).

## Dependencies

SciRate is based on [Ruby 2.1.0+](http://rvm.io/) and [Rails 4](http://rubyonrails.org/). Under Ubuntu 12.04 (our current deployment environment) the following native packages are needed:

```shell
sudo apt-get install git postgresql libpq-dev libxml2-dev libxslt-dev nodejs libodbc1 libqt4-dev openjdk-6-jre
```

You will also need to download and install [Elasticsearch](http://www.elasticsearch.org/overview/elkdownloads/). Note that if you're on Ubuntu and install Elasticsearch via the `.deb` package, it won't start automatically. Follow the instructions [here](http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/setup-service.html). Bundler should take care of the rest.

```shell
git clone git@github.com:scirate/scirate
cd scirate
bundle install
```

## Setting up the database

If you've just installed postgres, it'll be easiest to use the default 'peer' authentication method.  Create a postgres role for your user account:

```shell
sudo -u postgres createuser --superuser $USER
```

Copy the example database configuration file (:

```
cp config/database.yml.example config/database.yml
```

If using peer authentication, you won't need to edit this file.

Then:

```shell
rake db:setup
rake es:migrate
rake arxiv:feed_import
rails server
```
This will initialize the database and Elasticsearch, download the basic feed layout, and start the server.

You should now have a working local copy of SciRate! However, you'll also want some papers to fiddle with.

## Populating the database

```shell
rake arxiv:oai_update
```

When run for the first time, this will download and index paper metadata from the last day. Subsequent calls will download all metadata since the last time. The production server runs this task every day to keep the database in sync.

## Testing

There is a fairly comprehensive series of unit and integration tests in `spec`. Running `rspec` in the top-level directory will attempt all of them.
