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

If you find this does not work, you may have more luck with the following:

```shell
sudo apt install gnupg2
gpg2 --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
cd /tmp
curl -sSL https://get.rvm.io -o rvm.sh
cat /tmp/rvm.sh | bash -s stable --ruby=2.2.1
source /home/<USERNAME>/.rvm/scripts/rvm
```

Source: [How To Install Ruby on Rails with RVM on Ubuntu 18.04](https://www.digitalocean.com/community/tutorials/how-to-install-ruby-on-rails-with-rvm-on-ubuntu-18-04)

You will also need some native packages:

```shell
sudo apt-get install git postgresql libpq-dev libxml2-dev libxslt-dev nodejs libodbc1 libqt4-dev openjdk-8-jre libqt5webkit5-dev
```

Our backend depends on [Elasticsearch](http://www.elasticsearch.org/) to sort through all the papers:

```shell
curl https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.10.1-amd64.deb -o elasticsearch.deb
sudo dpkg -i --force-confnew elasticsearch.deb
sudo chown -R elasticsearch:elasticsearch /etc/default/elasticsearch
sudo service elasticsearch restart
```

**Note**: You can run `sudo service elasticsearch status` to confirm elasticsearch is running.
If you are having issues running elastic search via the service, you can run it manually.
Find the binary location with `which elasticsearch` and run it from the location that is reported back to you.
e.g.

```shell
/usr/share/elasticsearch/bin/elasticsearch
```

Elasticsearch must be running for `rake es:migrate` and `rails server` commands to work.

Finally, clone the repository and install the Ruby gem dependencies:

```shell
git clone git@github.com:scirate/scirate
cd scirate
bundle install
```

**Note:** If you encounter issues with Capybara installing correctly, i.e. your computer complains `command qmake not available` you can do the following to ensure you have the correct dependencies:

```shell
sudo apt-get update
sudo apt-get install g++ qt5-default libqt5webkit5-dev gstreamer1.0-plugins-base gstreamer1.0-tools gstreamer1.0-x
```

**Note:** If the pg gem fails to install with the error message `Can't find the 'libpq-fe.h header` you can try the following (Debian/Ubuntu):

```shell
sudo apt-get install libpq-dev
```

Other OS specific solutions avaliable here: [Stack Overflow Link](https://stackoverflow.com/a/6040822/12848423)

SciRate is now set up for development! However, you'll also want a database with papers to fiddle with.

## Setting up the database

If you've just installed postgres, it'll be easiest to use the default 'peer' authentication method. Create a postgres role for your user account:

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

This will initialize the database and Elasticsearch, download the basic feed layout, and start the server. If es:migrate is not working check that it is running, as per the notes above.

## Populating the database

```shell
rake arxiv:oai_update
```

When run for the first time, this will download and index paper metadata from the last day. Subsequent calls will download all metadata since the last time. The production server runs this task every day to keep the database in sync.

## Testing

There is a fairly comprehensive series of unit and integration tests in `spec`. Running `rspec` in the top-level directory will attempt all of them.

## Acknowledgements

- Maintained by [Noon van der Silk](https://github.com/silky)
- Original website by [Dave Bacon](http://dabacon.org)
- [Bill Rosgen](http://intractable.ca/bill/)
- [Aram Harrow](http://www.mit.edu/~aram/)
- [Draftable](https://draftable.com/)
