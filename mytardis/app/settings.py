import os
from default_settings import *

# Turn on Django debug mode
DEBUG = os.getenv('DJANGO_DEBUG', 'True')

DATABASES['default']['ENGINE'] = 'django.db.backends.postgresql_psycopg2'
DATABASES['default']['NAME'] = os.getenv('POSTGRES_DB', 'postgres')
DATABASES['default']['USER'] = os.getenv('POSTGRES_USER', 'postgres')
DATABASES['default']['HOST'] = 'db'
DATABASES['default']['PORT'] = 5432
#DATABASES['default']['PASSWORD'] = os.getenv('POSTGRES_PASSWORD')

# Repositry
DEFAULT_STORAGE_BASE_DIR = os.getenv('MYTARDIS_DEFAULT_STORAGE_BASE_DIR', '/srv/mytardis/var/store')
STAGING_PATH = os.getenv('MYTARDIS_STAGING_PATH', '/srv/mytardis/staging')
REQUIRE_DATAFILE_CHECKSUMS = os.getenv('MYTARDIS_REQUIRE_DATAFILE_CHECKSUMS', 'True')
REQUIRE_DATAFILE_SIZES = os.getenv('MYTARDIS_REQUIRE_DATAFILE_SIZES', 'True')
REQUIRE_VALIDATION_ON_INGESTION = os.getenv('MYTARDIS_REQUIRE_VALIDATION_ON_INGESTION', 'True')

# Static files
STATIC_ROOT = os.getenv('MYTARDIS_STATIC_ROOT', '/srv/mytardis/static')
STATIC_URL = os.getenv('MYTARDIS_STATIC_URL', '/static/')

# Email Configuration
EMAIL_PORT = os.getenv('MYTARDIS_EMAIL_PORT', 587) 
EMAIL_HOST = os.getenv('MYTARDIS_EMAIL_HOST', 'smtp.gmail.com')
EMAIL_HOST_USER = os.getenv('MYTARDIS_EMAIL_HOST_USER', '')
EMAIL_HOST_PASSWORD = os.getenv('MYTARDIS_EMAIL_HOST_PASSWORD', '')
EMAIL_USE_TLS = os.getenv('MYTARDIS_EMAIL_USE_TLS', 'True')
SECRET_KEY="^*!%^kr(&lbnufh35r*%e\e9pd4bmrzs(+_k8)%98ngwk@5+6="  # generated from build.sh
