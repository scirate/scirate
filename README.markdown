# SciRate

[![Build Status](https://github.com/scirate/scirate/actions/workflows/ci.yaml/badge.svg)](https://github.com/scirate/scirate/actions/workflows/ci.yaml)

[SciRate](https://scirate.com/) is an open source rating and commenting system
for [arXiv](http://arxiv.org/) preprints. Papers are upvoted and discussed by
the community, and we sometimes play host to more [in-depth peer
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

Then, spin up all the servers,

```
docker-compose up -d
```

From there, you can run the tests (note, you need to make sure elasticsearch
is fully up; it can take 10 seconds or so, you can verify with
`curl localhost:9200/_cat/health`, or `docker-compose logs -f search`
to see (the quite verbose) logs)):

```
docker-compose exec web rspec
```

After that, you can sync to arXiv.org and then play around with the system
locally:

```
docker-compose exec web rake arxiv:feed_import
docker-compose exec web rake arxiv:oai_update
```

and visit <http://localhost:3000> and you will be looking at SciRate!


## Testing

There is a fairly comprehensive series of unit and integration tests in
`spec`. Running `docker-compose exec web rspec`, if the entire docker-compose
system is up, will run them.

## Deploying

Locally, you can run `./deploy.rb`. You will need `ssh` access to the production server for this to run successfully.

## Automatic updates

The website updates automatically every hour with a `sync.sh` script in a crontab on the server. The crontab uses a file lock via `flock`.
* It first calls `arxiv_paper_sync.rake`. This checks if it's the right time to update, and if so, downloads new papers via `arxiv_oai_update.rake`. This uses the custom [arxivsync](https://github.com/scirate/arxivsync) package.
* Then it calls `arxiv_author_sync.rake`. This checks if it's the right time to update, and if so, links the arXiv author identifiers specified by users with the list of papers on arXiv.org via `arxiv_authorship_update.rake`.


## Moderating

In the database, each user (in `users`) has an `account_status` column. Change this to `admin` or `moderator` for extra powers on the site.

* Both admins and moderators can hide inflammatory recent comments.
* Admins can see a dashboard `https://scirate.com/admin`, set a global alert (i.e. for announcing upcoming site maintenance), and act as other users.
* A user can also have `account_status` set to `spam`.


## Acknowledgements

- Maintained by [Kunal Marwaha](https://kunalmarwaha.com/about)
- Previously maintained by [Noon van der Silk](https://github.com/silky)
- Original website by [Dave Bacon](http://dabacon.org)
- [Bill Rosgen](http://intractable.ca/bill/)
- [Aram Harrow](http://www.mit.edu/~aram/)
- [Draftable](https://draftable.com/)
