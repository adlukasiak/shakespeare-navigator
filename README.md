# Shakespeare Navigator

This project is a demonstration of several web backend and frontend tools that enable interactive visualization of information from a relational database.  The data set used for this demonstration is a collection of Shakespeare's complete works, sourced from http://www.opensourceshakespeare.org/.

Some of the technologies used here are:

* coffescript (used instead of JavaScript for client-side development)

* d3.js for JavaScript visualizations
* matplotlib for server-side rendering
* vincent/vega for visualizations that start as pandas DataFrames and get rendered using JavaScript
* Flask web microframework
* SQLAlchemy ORM for access to a Postgres database
* REST APIs (via Flask-Restless)
* Heroku (a PaaS for deployment)
* Heroku Postgres (a cloud-based Postgres service)

## Local Installation

### Clone github projects

First, clone opensourceshakespeare and shakespeare-navigator repo:

    git clone https://github.com/tlukasiak/shakespeare-navigator
    git clone https://github.com/catherinedevlin/opensourceshakespeare

### Postgres
#### Postgres on Debian/Ubuntu
Development on Debian/Ubuntu allows access to the apt-get system. Alternative software management systems exists for other environments. Use apt-get to install these packages:
* postgresql
* python-pip

Set up a local Postgres database with the following settings: postgres:postgres@localhost/shakespeare.

#### Postgres on Mac OS X:

To install Postgres on Mac OS X, follow [installation instructions](http://postgresapp.com/).

Setup a local Postgres databse and load with data from the [OpenShakespeare site](https://github.com/catherinedevlin/opensourceshakespeare):

Connect with `psql` to create a new database

````
CREATE DATABASE shakespeare;
````

Load the data by running on command line

````
psql shakespeare < opensourceshakespeare/shakespeare.sql
````

##### Note
The owner in the shakespeare.sql is 'catherine' and 'postgres'.  Replace 'catherine' and 'postgres' with your own group role in the shakespeare.sql before loading the data.

### Create isolated Python environment

#### Create isolated environment on Debian/Ubuntu

Use virtualenv to create an isolated Python environment, and activate it before installing any Python packages.
    
    pip install virtualenv (if it doesn't exist on your system) 
    virtualenv venv
    source venv/bin/activate

There are a number of Python packages needed to run this web app. Use pip to install these packages:

    pip install -r ./requirements.txt

#### Create isolated environment on Mac OS X:

    conda install -n venv pip
    source $HOME/anaconda/bin/activate ~/anaconda/envs/venv/

There are a number of Python packages needed to run this web app. Use pip to install these packages:

    pip install -r ./requirements.txt

During the matplotlib installation you may be asked to install X11.  In OS X Mountain Lion (10.8), X11 is no longer installed by default, and you need to install [XQuartz](support.apple.com/kb/HT5293).

If the matplotlib installation failes with this error about freetype2 and libpng:


````
BUILDING MATPLOTLIB
                matplotlib: 1.1.0
                    python: 2.7.5 |Continuum Analytics, Inc.| (default, Jun 28
                            2013, 22:20:13)  [GCC 4.0.1 (Apple Inc. build 5493)]
                  platform: darwin
    
    REQUIRED DEPENDENCIES
                     numpy: 1.7.1
                 freetype2: found, but unknown version (no pkg-config)
                            * WARNING: Could not find 'freetype2' headers in any
                            * of '.', './freetype2'.
    
    OPTIONAL BACKEND DEPENDENCIES
                    libpng: found, but unknown version (no pkg-config)
                            * Could not find 'libpng' headers in any of '.'
````

it's because freetype and libpng are installed in non-canonical locations by XCode, in /usr/X11 instead of /usr or /usr/local.  To address it, install pkg-config:

    brew install pkg-config

Export PKG_CONFIG_PATH to pickup the correct dependencies (libpng, freetype) from XQuartz via pkg-config:

    export PKG_CONFIG_PATH=/opt/X11/lib/pkgconfig

Try to install matplotlib again

    pip install matplotlib==1.1.0 

#### Installing and Compiling Coffee Script

Install Node.js from http://nodejs.org/ and coffee compiler from http://coffeescript.org/.  Once you have installed the node.js, you can use nmp to install coffee script:
````
npm install -g coffee-script
````
To create .js files, compile your coffee script.  Copy the .js file into ../js:
````
coffee -c /path/to/histogram.coffee
coffee -c /path/to/shakespeare.coffee
cp histogram.js shakespeare.js ../js
````

## Running Web Server Locally

In your virutal environment:

    export DATABASE_URL=postgres://postgres:postgres@localhost/shakespeare
    python shakespeare.py 

Now check your browser at localhost:5000

    http://localhost:5000

#### Common runtime issues on Mac OS X

If you can't load any of the Postgres libraries, set DYLD_LIBRARY_PATH environment variable:

    export DYLD_LIBRARY_PATH=/Applications/Postgres.app/Contents/MacOS/lib

Depending on how Postgres was intalled, you may need to create postgres role:

    > psql shakespeare
    psql (9.3.0)
    Type "help" for help.

    alukasiak=# create role postgres;
    CREATE ROLE
    alukasiak=# \q

 If you have issues with symbolic links, follow [those instructions](https://lists.macosforge.org/pipermail/macports-users/2010-November/022663.html):
````
dyld: Symbol not found: __cg_jpeg_resync_to_restart
  Referenced from: /System/Library/Frameworks/ImageIO.framework/Versions/A/ImageIO
  Expected in: /Applications/Postgres.app/Contents/MacOS/lib/libJPEG.dylib
 in /System/Library/Frameworks/ImageIO.framework/Versions/A/ImageIO
````
````
 > ls -ltr
rwxr-xr-x@ 1 alukasiak  staff  15 Oct  8 22:09 /Applications/Postgres.app/Contents/MacOS/lib/libJPEG.dylib -> libjpeg.8.dylib
> nm -g libJPEG.dylib | grep resync
0000000000026270 T _jpeg_resync_to_restart

> sudo ln -sf /System/Library/Frameworks/ApplicationServices.framework/Versions/A/Frameworks/ImageIO.framework/Versions/A/Resources/libJPEG.dylib /Applications/Postgres.app/Contents/MacOS/lib/libJPEG.dylib

> nm -g /Applications/Postgres.app/Contents/MacOS/lib/libJPEG.dylib | grep resync
0000000000018060 T __cg_jpeg_resync_to_restart
````

 If you need to find where the logs for postgres are:

````
    SELECT 
        * 
    FROM 
        pg_settings 
    WHERE 
        category IN( 'Reporting and Logging / Where to Log' , 'File Locations')
    ORDER BY 
        category,
        name;
````

If you are getting this error when trying to connect to postgress:
````
    ERROR:  permission denied for relation work
````
you will need to add permissions for all tables to postgres.  You can do it from psql -U YOURADMIN_LOGIN shakespeare:
````
    GRANT SELECT ON ALL TABLES IN SCHEMA public TO postgres
````

## Heroku Deployment

Follow these tutorials (https://devcenter.heroku.com/articles/quickstart) to get hands-on experience first. 

There are a few Heroku-specific files in the repo.
* Procfile is used for dispatching Heroku dynos
* requirements.txt is a list of pip-installable Python packages required to run the app

To run the app locally in the Heroku framework, use foreman

    foreman start

#### Notes

Deploying the latest matplotlib on Heroku (as of the time this document was written) is a little tricky. Some hints are outlined here (http://stackoverflow.com/questions/18173104/deploy-matplotlib-on-heroku-failed-how-to-do-this-correctly). This article calls for using a python-sklearn buildpack. Buildpacks are explained here: (https://devcenter.heroku.com/articles/buildpacks). However, the cake and coffee binaries are needed to compile CoffeeScript to JavaScript, so the multi-buildpack was used (https://github.com/ddollar/heroku-buildpack-multi). The contents of the .buildfile are

    https://github.com/dbrgn/heroku-buildpack-python-sklearn
    https://github.com/fivethreeo/heroku-buildpack-python-nodejs

In requirements.txt, the matplotlib version was specified explicitly

    matplotlib==1.1.0

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

