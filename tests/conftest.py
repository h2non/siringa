# flake8: noqa

# Required import to load the Hy <> Python AST transformer
import hy
import pytest

from siringa.api import layer
from siringa.container import Container

# Explicitly load Hy based test modules
from . import errors_test


@pytest.fixture(scope='module')
def cont():
    return Container()


@pytest.fixture(scope='module')
def layer():
    return layer
