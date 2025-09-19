import os
import django
from django.conf import settings

# Configure Django settings for pytest if needed
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "statuspage.settings")
django.setup()
