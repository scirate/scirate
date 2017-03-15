# SciRate

[![Build Status](https://travis-ci.org/scirate/scirate.svg?branch=master)](https://travis-ci.org/scirate/scirate)
[![Coverage Status](https://coveralls.io/repos/scirate/scirate/badge.svg?branch=master)](https://coveralls.io/r/scirate/scirate?branch=master)

[SciRate](https://scirate.com/) is an open source rating and commenting system for [arXiv](http://arxiv.org/) preprints. Papers are upvoted and discussed by the community, and we sometimes play host to more [in depth peer review](https://scirate.com/tqc-2014-program-committee).

Bug reports and feature requests should be submitted as [GitHub issues](https://github.com/scirate/scirate/issues).

## Setting up for development

SciRate runs on [Ubuntu 14.04](http://releases.ubuntu.com/14.04/) in production. Development in other environments is possible, but this guide will assume you are running some variant of Debian.

We currently use Ruby 2.2.1 and Rails 4.2. To install this version of Ruby and [RVM](https://rvm.io/):

```shell
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
\curl -sSL https://get.rvm.io | bash -s stable --ruby=2.2.1
rvm use 2.2.1 --default
```

You will also need some native packages:

```shell
sudo apt-get install git postgresql libpq-dev libxml2-dev libxslt-dev nodejs libodbc1 libqt4-dev openjdk-6-jre libqt5webkit5-dev
```

Our backend depends on [Elasticsearch](http://www.elasticsearch.org/overview/elkdownloads/) to sort through all the papers:

```shell
wget -O /tmp/elasticsearch.deb https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.5.1.deb
sudo dpkg -i /tmp/elasticsearch.deb
sudo update-rc.d elasticsearch defaults 95 10
sudo service elasticsearch start
```

Finally, clone the repository and install the Ruby gem dependencies:

```shell
git clone git@github.com:scirate/scirate
cd scirate
bundle install
```

SciRate is now set up for development! However, you'll also want a database with papers to fiddle with.

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

## Populating the database

```shell
rake arxiv:oai_update
```

When run for the first time, this will download and index paper metadata from the last day. Subsequent calls will download all metadata since the last time. The production server runs this task every day to keep the database in sync.

## Testing

There is a fairly comprehensive series of unit and integration tests in `spec`. Running `rspec` in the top-level directory will attempt all of them.

## Acknowledgements

- Original website by [Dave Bacon](http://dabacon.org)
- [Bill Rosgen](http://intractable.ca/bill/)
- [Aram Harrow](http://www.mit.edu/~aram/)
- [Draftable](https://draftable.com/)
