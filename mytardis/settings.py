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

# MyData
if os.path.isdir('/srv/mytardis/tardis/apps/mydata'):
    INSTALLED_APPS += ('tardis.apps.mydata',)

# Celery and RabbitMQ
BROKER_URL = os.getenv('MYTARDIS_BROKER_URL', 'pyamqp://guest@rabbit//')
CELERY_RESULT_BACKEND = os.getenv('MYTARDIS_CELERY_RESULT_BACKEND', 'rpc://')

# Bioformats
# https://github.com/keithschulze/mytardisbf
if os.getenv('MYTARDIS_ENABLE_FILTER_BIOFORMATS', 'False') == 'True':
    INSTALLED_APPS += ('mytardisbf',)
    MIDDLEWARE_CLASSES += ('tardis.tardis_portal.filters.FilterInitMiddleware',)
    FILTER_MIDDLEWARE = (("tardis.tardis_portal.filters", "FilterInitMiddleware"),)
    POST_SAVE_FILTERS = [
        ("mytardisbf.filters.metadata_filter.make_filter",
        ["BioformatsMetadata", "http://tardis.edu.au/schemas/bioformats/2"]),
    ]

SECRET_KEY = os.getenv('MYTARDIS_SECRET_KEY', 'Not_Set_^i$&vpqasibb%8o7%lr_#7$a$3ya3_80r1h%e6%5f(')

TIME_ZONE = os.getenv('MYTARDIS_TIME_ZONE', 'Australia/Perth')
SITE_TITLE = os.getenv('MYTARDIS_SITE_TITLE', 'MyTardis')

# LDAP authnz
if 'MYTARDIS_LDAP_URL' in os.environ:
    AUTH_PROVIDERS += (('ldap', 'LDAP Auth', 'tardis.tardis_portal.auth.ldap_auth.ldap_auth'),)
    LDAP_ADMIN_USER = os.getenv('MYTARDIS_LDAP_ADMIN_USER', '')
    LDAP_ADMIN_PASSWORD = os.getenv('MYTARDIS_LDAP_ADMIN_PASSWORD', '') 
    LDAP_TLS = os.getenv('MYTARDIS_LDAP_TLS', 'True')
    LDAP_URL = os.getenv('MYTARDIS_LDAP_URL')
    LDAP_USER_LOGIN_ATTR = os.getenv('MYTARDIS_LDAP_USER_LOGIN_ATTR', 'uid')
    LDAP_USER_ATTR_MAP = {"givenName": "display", "mail": "email", "sn": "last_name"}
    LDAP_GROUP_ID_ATTR = os.getenv('MYTARDIS_LDAP_GROUP_ID_ATTR', 'ou')
    LDAP_GROUP_ATTR_MAP = {"description": "display"}
    LDAP_BASE = os.getenv('MYTARDIS_LDAP_BASE', "DC=uwa,DC=edu,DC=au")
    LDAP_USER_BASE = os.getenv('MYTARDIS_LDAP_USER_BASE', "OU=People," + LDAP_BASE)
    LDAP_GROUP_BASE = os.getenv('MYTARDIS_LDAP_GROUP_BASE', ",".join(("OU=Groups", LDAP_BASE)))

