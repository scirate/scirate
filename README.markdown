# SciRate 3

A rewrite of [Dave Bacon's](http://dabacon.org) SciRate in Ruby on Rails, previously developed by Dave Bacon, [Bill Rosgen](http://intractable.ca/bill/) and [Aram Harrow](http://www.mit.edu/~aram/). Currently being expanded upon by [Draftable](https://draftable.com/).

The older production site is deployed at [https://scirate3.herokuapp.com/](https://scirate3.herokuapp.com/). A more recent testing version can be found at [http://scirate-dev.draftable.com/](https://scirate-dev.draftable.com/).

## Contributing

We encourage contributions!

* You can submit a bug report [here](https://github.com/draftable/scirate3/issues).

* You can contribute to the code by sending a pull request on Github to the [canonical repository](https://github.com/draftable/scirate3).

* You can talk about scirate on our [mailing list](https://groups.google.com/forum/?fromgroups=#!forum/scirate) and about scirate development on the [development mailing list](https://groups.google.com/forum/?fromgroups=#!forum/scirate-dev).

## Dependencies

Scirate is based on [Ruby 2.1.0+](http://rvm.io/) and [Rails 4](http://rubyonrails.org/). Under Ubuntu 12.04 (our current deployment environment) the following native packages are needed:

```shell
sudo apt-get install postgresql libpq-dev libxml2-dev libxslt-dev nodejs libodbc1 libmysqlclient-dev
```

You will also need to download and install [sphinxsearch 2.1.4](http://sphinxsearch.com/downloads/release/). Bundler should take care of the rest.

```shell
git clone git@github.com:draftable/scirate3
cd scirate3
bundle install
```

## Setting up the database

If you've just installed postgres, you'll need a new database user:

```shell
sudo -u postgres createuser --superuser --pwprompt scirate
```

Note that the 'peer' auth method of postgres is incompatible with sphinxsearch, so you do need a password. Copy the example database and Sphinx configuration files:

```
cp config/database.yml.example config/database.yml
cp config/thinking_sphinx.yml.example config/thinking_sphinx.yml
```

Edit the former file and enter your auth details for the development database. Then initialize the database and sphinx, and download the basic feed layout:

```shell
rake db:setup
rake ts:index
rake arxiv:feed_import
rails server
```

And start the server and delayed_job instance which updates the search index.

```shell
./bin/delayed_job start
rails server
```

You should now have a working local copy of SciRate! However, you'll also want some papers to fiddle with.

## Populating the database

```shell
rake arxiv:oai_update
```

When run for the first time, this will download and index paper metadata from the last day. Subsequent calls will download all metadata since the last time. The production server runs this task every day to keep the database in sync.

## Testing

There is a fairly comprehensive series of unit and integration tests in `spec`. Running `rspec` in the top-level directory will attempt all of them.
