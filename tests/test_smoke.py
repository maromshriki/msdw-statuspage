import pytest
from django.urls import reverse
from django.test import Client

@pytest.mark.django_db
def test_homepage_available():
    c = Client()
    # try common endpoints; adjust if project uses different urls
    resp = c.get('/')
    # Accept 200 or 302 (redirects) as a sign server is up
    assert resp.status_code in (200, 302)

@pytest.mark.django_db
def test_admin_login_page():
    c = Client()
    resp = c.get('/admin/login/')
    assert resp.status_code in (200, 302)
