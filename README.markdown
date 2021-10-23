# SciRate

[![Build Status](https://github.com/scirate/scirate/actions/workflows/ci.yaml/badge.svg)](https://github.com/scirate/scirate/actions/workflows/ci.yaml)
[![Coverage Status](https://coveralls.io/repos/scirate/scirate/badge.svg?branch=master)](https://coveralls.io/r/scirate/scirate?branch=master)

[SciRate](https://scirate.com/) is an open source rating and commenting system
for [arXiv](http://arxiv.org/) preprints. Papers are upvoted and discussed by
the community, and we sometimes play host to more [in depth peer
review](https://scirate.com/tqc-2014-program-committee).

Bug reports and feature requests should be submitted as [GitHub
issues](https://github.com/scirate/scirate/issues).

## Setting up for development

Development is best done locally using [docker-compose](https://docs.docker.com/compose/install/):

```
docker-compose build
```

In order to run the app, you will need a `local_settings.rb` file, and a
`config/database.yml` file. You can copy these from the CI versions:

```
cp local_settings.rb.ci local_settings.rb
cp config/database.yml.ci config/database.yml
```

Then, you can run the pre-reqs like so:

```
rake db:setup
rake es:migrate
```

From there, you can run the tests:

```
docker-compose exec web rspec
```

After that, you can sync to arXiv.org and then play around with the system
locally:

```
docker-compose run rake arxiv:feed_import
docker-compose run rake arxiv:oai_update
```

Then, spin up the rails server:

```
docker-compose up -d
```

and visit <http://localhost:3000> and you will be looking at SciRate!


## Testing

There is a fairly comprehensive series of unit and integration tests in
`spec`. Running `docker-compose exec web rspec`, if the entire docker-compose
system is up, will run them.


## Acknowledgements

- Maintained by [Noon van der Silk](https://github.com/silky)
- Original website by [Dave Bacon](http://dabacon.org)
- [Bill Rosgen](http://intractable.ca/bill/)
- [Aram Harrow](http://www.mit.edu/~aram/)
- [Draftable](https://draftable.com/)
