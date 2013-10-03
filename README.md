Database source is: https://github.com/catherinedevlin/opensourceshakespeare
The Open Source Shakespeare site (http://www.opensourceshakespeare.org/) is a collection of Shakespeare's complete works. This projects adapts its data for powerful open-source relational databases, beginning with PostgreSQL.


Requirements (Ubuntu)
postgresql
memchached


pip install Flask gunicorn
psycopg2 sqlalchemy flask-restless flask-cake numpy vincent matplotlib flask-compress flask-cache

Procfile is used for dispatching Heroku dynos

pip freeze > requirements.txt
