# Scirate 3

A rewrite of [Dave Bacon's](http://dabacon.org) Scirate in Ruby on Rails, previously developed by Dave Bacon and [Bill Rosgen](http://intractable.ca/bill/).

Currently deployed [here](https://scirate3.herokuapp.com/), with a testing version at [http://scirate3-dev.herokuapp.com/](http://scirate3-dev.herokuapp.com/).

## Contributing

We encourage contributions!

* You can submit a bug report [here](https://github.com/draftable/scirate3/issues).

* You can contribute to the code by sending a pull request on Github to the [canonical repository](https://github.com/draftable/scirate3).

* You can talk about scirate on our [mailing list](https://groups.google.com/forum/?fromgroups=#!forum/scirate) and about scirate development on the [development mailing list](https://groups.google.com/forum/?fromgroups=#!forum/scirate-dev).

## Setting up for development

You will need [Ruby 1.9.3](http://www.ruby-lang.org/en/) and a UNIX environment of some kind. Familiarity with [Rails 3](http://rubyonrails.org/) is recommended.

```shell
git clone git@github.com:draftable/scirate3
cd scirate3
bundle install
cp config/database.yml.example config/database.yml
```

Edit config/database.yml and enter your auth details for the development database.

```shell
rake db:setup
rake db:add_feeds
rails server
```

You should now have a working local copy of Scirate! However, you'll also want some papers to fiddle with.

## Populating the database

```shell
rake db:arxiv_update
```

This will read the arXiv's daily RSS feeds for each category and grab the metadata associated with each paper. The production server runs this task every day to keep the database in sync.

## Testing

There is a fairly comprehensive series of unit and integration tests in `spec`. Running `rspec` in the top-level directory will attempt all of them.
