from flask import Flask, render_template, Response, make_response, request
from sqlalchemy import Column, Integer, Unicode
# from sqlalchemy import ForeignKey
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
# from sqlalchemy.orm import backref, relationship
from sqlalchemy.orm import scoped_session
import flask.ext.restless
from flask_cake import Cake
import numpy as np
import vincent
import pandas as pd
from vincent import PropertySet, ValueRef, AxisProperties

import os
import StringIO
from matplotlib.backends.backend_agg import FigureCanvasAgg as FigureCanvas
from matplotlib.figure import Figure

from flask.ext.compress import Compress

# from flask.ext.cache import Cache

app = Flask(__name__)
app.config.from_pyfile('shakespeare.cfg')

cake = Cake(app)
# cake = Cake(app, ["build", "minify"])

compress = Compress(app)
# compress.init_app(app)
# Compress(app) # for gzip compression
app.config['COMPRESS_MIMETYPES'].append('image/svg+xml') # make sure SVG are gzipped
app.config['COMPRESS_MIN_SIZE'] = 1 # effectively gzip everything
app.config['COMPRESS_DEBUG'] = True
print app.config['COMPRESS_MIMETYPES']

# We'll read from the shakespeare.cfg file instead
# cache = Cache(config={'CACHE_TYPE': 'simple'})
# cache.init_app(app)

# app.config['CACHE_TYPE'] = 'simple'

# Disable cache for heroku deployment
# cache = Cache(app)


# SQLite can be used instead of POstgreSQL
# engine = create_engine('sqlite:////tmp/testdb.sqlite', convert_unicode=True)

# We need to change the URL to be SQLAlchemy-friendly
db_url = os.environ['DATABASE_URL'].replace('postgres://', 'postgresql+psycopg2://')

#print 'db_url', db_url

engine = create_engine(db_url, isolation_level="READ UNCOMMITTED", echo=False, convert_unicode=True)

Session = sessionmaker(autocommit=False, autoflush=False, bind=engine)
mysession = scoped_session(Session)

Base = declarative_base()
Base.metadata.bind = engine

class Work(Base):
    __tablename__ = 'work'
    work_id = Column('workid', Unicode, primary_key=True)
    title = Column(Unicode)
    long_title = Column('longtitle', Unicode)
    year = Column(Integer)
    genre_type = Column('genretype', Unicode(1))
    notes = Column(Unicode)
    source = Column(Unicode)
    total_words = Column('totalwords', Integer)
    total_paragraphs = Column('totalparagraphs', Integer)
    # paragraphs = relationship('Paragraph',
    #                          backref=backref('work'))

class Paragraph(Base):
    __tablename__ = 'paragraph'
    paragraph_id = Column('paragraphid', Integer, primary_key=True)
    paragraph_num = Column('paragraphnum', Integer)
    char_id = Column('charid', Unicode)
    plain_text = Column('plaintext', Unicode)
    phonetic_text = Column('phonetictext', Unicode)
    stem_text = Column('stemtext', Unicode)
    paragraph_type = Column('paragraphtype', Unicode)
    section = Column(Integer)
    chapter = Column(Integer)
    char_count = Column('charcount', Integer)
    word_count = Column('wordcount', Integer)
    # work_id = Column('workid', Unicode, ForeignKey('work.workid'))
    work_id = Column('workid', Unicode)

Base.metadata.create_all(engine, checkfirst=True)

# Create the Flask-Restless API manager.
manager = flask.ext.restless.APIManager(app, session=mysession)

# Create API endpoints, which will be available at /api/<tablename> by
# default. Allowed HTTP methods can be specified as well.
# manager.create_api(Person, methods=['GET', 'POST', 'DELETE'])
# manager.create_api(Person, methods=['GET', 'POST', 'DELETE'])
# manager.create_api(Computer, methods=['GET'])
manager.create_api(Work, methods=['GET'], results_per_page=-1)
manager.create_api(Paragraph, methods=['GET'], results_per_page=-1)


@app.route('/', methods=['GET'])
def index():
    return render_template('chart.html')

@app.route('/api/hist/<work_id>.<extension>', methods=['GET'])
# @cache.cached(timeout=50)  # disable memcached for heroku deployment
def histogram(work_id, extension):
    print 'request.path', request.path
    print extension 
    # import ipdb; ipdb.set_trace()

    work = mysession.query(Work).filter(Work.work_id == work_id).one()
    print "work", work.long_title

    word_counts = []
    for paragraph in mysession.query(Paragraph).filter(Paragraph.work_id == work_id):
        word_counts.append(paragraph.word_count)

    (counts, bins) = np.histogram(word_counts, bins = 20)

    df = pd.DataFrame(counts, index=bins[0:-1])

    if extension == 'json':
        # print "counts", counts
        # print "bins", bins

        # bar = vincent.Bar(list(counts))
        bar = vincent.Bar(df)
        # bar.axes.extend([vincent.Axis(type='y', scale='y'), vincent.Axis(type='x', scale='x')])

        # FIXME this is probably caused by a new vincent API
	# vincent 0.3.0 works great!
        #props = vincent.AxisProperties(labels=ValueRef(value='left'))
        props = vincent.AxisProperties(labels=PropertySet(
                         align = ValueRef(value='left'),
                         angle = ValueRef(value=90),
                         baseline = ValueRef(value='middle'),
                         font_size = ValueRef(value=9)))
        bar.axes[0].properties = props

	bar.axes[1].properties = vincent.AxisProperties(labels=PropertySet(font_size = ValueRef(value=9)))
      
	bar.axes[1].title_offset = 40
        bar.axes[0].title_offset = 40
	bar.axes[0].format = ".0f"
        bar.height = 150
        bar.width = 170
      # "height": 400,
      # "width": 500,

        bar.axis_titles(x='Bins', y='Frequency')
	#bar.axes.extend([Axis(type='x', ), Axis(type='y', )])

        j = bar.to_json()
        # return the histogram of word frequency per paragraph for a given work_id 
        # return 'work_id %s' % work_id

        resp = Response(j, status=200, mimetype='application/json')    
        return resp

    elif extension == 'png':

        fig = Figure(figsize = (8, 6))
        axis = fig.add_subplot(1, 1, 1)
        
        axis.hist(word_counts, bins=20)
        # axis = df.hist()
        canvas = FigureCanvas(fig)
        output = StringIO.StringIO()
        canvas.print_png(output)
        response = make_response(output.getvalue())
        response.mimetype = 'image/png'
        return response

    elif extension == 'svg':

        fig = Figure(figsize = (8, 6))
        axis = fig.add_subplot(1, 1, 1)
        axis.set_ylabel("Frequency")
        axis.set_xlabel("Bins")
        axis.hist(word_counts, bins=20)
        # axis = df.hist()
        canvas = FigureCanvas(fig)
        output = StringIO.StringIO()
        canvas.print_svg(output)
        response = make_response(output.getvalue())
        response.mimetype = 'image/svg+xml'
        return response

    else:
        return "Resource not found"

if __name__ == '__main__':
    # start the flask loop
    app.run(debug=True)
