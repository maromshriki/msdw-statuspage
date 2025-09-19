import pytest
from django.apps import apps

@pytest.mark.parametrize('app_label', [
    'statuspage',  # try a known app label; adjust if your project has different app names
])
def test_app_models_exist(app_label):
    # assert that app is installed and has at least one model
    app = apps.get_app_config(app_label)
    models = app.get_models()
    assert any(True for _ in models), f'No models found for app {app_label}'
