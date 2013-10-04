# Shakespeare Navigator

This project is meant to be a starting point to hack around with various web backend and frontend tools that enable interactive visualization of information from a relational database.

Some of the technologies used here are:

* coffescript (used instead of JavaScript for client-side development)
* Flask web microframework
* SQLAlchemy ORM for access to a Postgres database
* REST APIs (via Flask-Restless)
* Heroku (a PaaS for deployment)
* Heroku Postgres (a cloud-based Postgres service)


In this project, the source of the data is: (https://github.com/catherinedevlin/opensourceshakespeare). It's based on the Open Source Shakespeare site (http://www.opensourceshakespeare.org/) which a collection of Shakespeare's complete works.


### Local Installation

## Installing

First, clone this repo:

    git clone ...

I'm using Ubuntu, which has the apt-get system. Alternative software management systems exists for other environments. Use apt-get to install these packages:
* postgresql
* memchached

Use virtualenv to create an isolated Python environment, and activate it before installing any Python packages. 

There are a number of Python packages needed to run this web app. Use pip to install these packages:

    pip install -r ./requirements.txt

## Running

    python shakespeare.py 

### Heroku Deployment

Follow these tutorials (https://devcenter.heroku.com/articles/quickstart) to get hands-on experience first.

There are a few Heroku-specific files in the repo.
* Procfile is used for dispatching Heroku dynos
* requirements.txt is a list of pip-installable Python packages required to run the app. Use the following command to 
    pip freeze > requirements.txt

Deploying the latest matplotlib on Heroku (as of the time this document was written) is a little tricky. I followed the directions outlined here (http://stackoverflow.com/questions/18173104/deploy-matplotlib-on-heroku-failed-how-to-do-this-correctly)

Install an sklearn buildpack with this command

    heroku config:set BUILDPACK_URL=https://github.com/dbrgn/heroku-buildpack-python-sklearn/

In requirements.txt, the matplotlib version was specified explicitly

    matplotlib==1.1.0

There Heroku add-ons that provide a service similar to memcached. However, for the time being, the Flask-Cache capability is disabled when deployed on Heroku.


### Heroku Postgres (postgres.heroku.com)

Heroku Postgres is a service that allows for running a cloud-based Postgres server. Follow the Heroku devcenter article (https://devcenter.heroku.com/articles/heroku-postgresql) to get familiar with the service.  You can start with a local Postgres database, and then migrate to an online Heroku Postgres database.  There are a couple of documented ways to transmit a local database to a Heroku Postgres database. 


#### pg:push and pg:pull 
An article on the Heroku devcenter (https://devcenter.heroku.com/articles/heroku-postgresql#local-setup) suggests using pg:push and 
pg:pull

However, pg:push and pg:pull (https://github.com/heroku/heroku-pg-extras) have been reported to be stubborn (e.g. http://stackoverflow.com/questions/11126652/heroku-dbpush-problems)

#### pg:transfer
Following this article (http://www.higherorderheroku.com/articles/pgtransfer-is-the-new-taps/) has worked for me.

#### pgbackups:restore
pgbackups:restore (https://devcenter.heroku.com/articles/heroku-postgres-import-export#import) seems to be the new recommended way of importing a local database into Heroku Postgres.  However, it requires the database to be available at an HTTP-accessible URL like S3.

#### Other notes
The pgAdminIII GUI frontend can be used to view the Heroku Postgres database just as easily as connecting to a local database. Follow http://stackoverflow.com/questions/11769860/connect-to-a-heroku-database-with-pgadmin for some tips on the setup.

The shakespeare database contains 67,895 rows, exceeding the Heroku free Dev plan limit of 10,000. INSERT privileges to the database will be automatically revoked at some point. This will cause service failures in most applications dependent on this database.


---

Buildpacks (https://devcenter.heroku.com/articles/buildpacks)

https://github.com/ddollar/heroku-buildpack-multi

.builpacks holds the buidpacks used
https://github.com/dbrgn/heroku-buildpack-python-sklearn
https://github.com/fivethreeo/heroku-buildpack-python-nodejs
