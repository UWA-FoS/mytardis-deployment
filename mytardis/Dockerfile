FROM ubuntu:14.04
MAINTAINER Dean Taylor <dean.taylor@uwa.edu.au>
# Port to expose
EXPOSE 8000

ENV PYTHONUNBUFFERED 1
ENV DJANGO_DEBUG=True

# Local directory with project source
ENV DOCKYARD_SRC=src
# Directory in container for all project files
ENV DOCKYARD_SRVHOME=/srv
# Directory in container for project source files
ENV DOCKYARD_SRVPROJ=/srv/mytardis

RUN apt-get update && apt-get -y upgrade
RUN apt-get -y install \
  python \
  python-pip
RUN pip install -U pip

RUN apt-get -y install \
  git ipython libldap2-dev libsasl2-dev \
  libssl-dev libxml2-dev libxslt1-dev python-anyjson \
  python-billiard python-bs4 python-crypto python-dateutil \
  python-dev python-feedparser python-flexmock python-html5lib \
  python-httplib2 python-pip python-psycopg2 python-pystache \
  python-virtualenv python-wand python-yaml virtualenvwrapper \
  zlib1g-dev libfreetype6-dev libjpeg-dev

# Create application subdirectories
RUN mkdir -p $DOCKYARD_SRVHOME
WORKDIR $DOCKYARD_SRVHOME
RUN mkdir logs media static
VOLUME ["$DOCKYARD_SRVHOME/logs/", "$DOCKYARD_SRVHOME/media/", "$DOCKYARD_SRVHOME/static/"]

WORKDIR $DOCKYARD_SRVPROJ

# Copy application source code to SRCDIR
#ADD requirements.txt $DOCKYARD_SRVPROJ
COPY $DOCKYARD_SRC/mytardis $DOCKYARD_SRVPROJ
# add link so that standard Django script will work as expected
RUN test -L manage.py || ln -s mytardis.py manage.py

# Install Python dependencies
RUN pip install -r ${DOCKYARD_SRVPROJ}/requirements.txt

# mytardis-app-mydata
# https://github.com/mytardis/mytardis-app-mydata
COPY $DOCKYARD_SRC/mydata $DOCKYARD_SRVPROJ/tardis/apps/mydata
RUN pip install -r $DOCKYARD_SRVPROJ/tardis/apps/mydata/requirements.txt

# Bioformats
# https://github.com/keithschulze/mytardisbf
RUN pip install -U numpy
RUN apt-get -y install \
  openjdk-7-jdk
RUN pip install -e git+https://github.com/keithschulze/mytardisbf.git@0.1.1#egg=mytardisbf

ENV MYTARDIS_ALLOWED_HOSTS='*'
# Database settings
# Repository settings
ENV MYTARDIS_DEFAULT_STORAGE_BASE_DIR=${DOCKYARD_SRVPROJ}/var/store
ENV MYTARDIS_STAGING_PATH=${DOCKYARD_SRVPROJ}/var/staging
ENV MYTARDIS_REQUIRE_DATAFILE_CHECKSUMS=True
ENV MYTARDIS_REQUIRE_DATAFILE_SIZES=True
ENV MYTARDIS_REQUIRE_VALIDATION_ON_INGESTION=True
# Static files
ENV MYTARDIS_STATIC_ROOT=${DOCKYARD_SRVPROJ}/static
ENV MYTARDIS_STATIC_URL=/static/
# Filters
ENV MYTARDIS_ENABLE_FILTER_BIOFORMATS='False'

# Copy Dockerized setting.py file into the project folder
COPY ./settings.py $DOCKYARD_SRVPROJ/tardis/

# Copy entrypoint script into the image
COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
