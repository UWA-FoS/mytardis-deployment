FROM ubuntu:14.04
MAINTAINER Dean Taylor <dean.taylor@uwa.edu.au>
# Port to expose
EXPOSE 8000

ENV PYTHONUNBUFFERED 1

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

# Copy entrypoint script into the image
WORKDIR $DOCKYARD_SRVPROJ
COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

# Copy application source code to SRCDIR
#ADD requirements.txt $DOCKYARD_SRVPROJ
COPY $DOCKYARD_SRC $DOCKYARD_SRVPROJ
# add link so that standard Django script will work as expected
RUN test -L manage.py || ln -s mytardis.py manage.py

# Install Python dependencies
RUN pip install -r ${DOCKYARD_SRVPROJ}/requirements.txt

