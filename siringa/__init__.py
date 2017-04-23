# -*- coding: utf-8 -*
"""
`siringa` is a minimalist dependency injection library.

Usage example::

    import siringa

    @siringa.register
    class MyUtilityClass(object):
        pass

    @siringa.inject
    def fn(foo, MyUtilityClass: '!'):
        return MyUtilityClass(foo)

"""

# Required import to load the Hy <> Python AST transformer
import hy  # noqa

from .api import *  # noqa
from .api import __all__ as api_symbols
from .layer import Layer
from .analyzer import analyze
from .container import Container
from .dependency import Dependency
from .errors import (SiringaError,
                     MissingDependencyError,
                     DuplicatedDependencyError,
                     InvalidDependencyTypeError)

# Export public package API symbols
__all__ = (
    'Layer', 'analyze', 'Container',
    'SiringaError', 'Dependency',
    'MissingDependencyError',
    'DuplicatedDependencyError',
    'InvalidDependencyTypeError'
) + api_symbols

# Package metadata
__author__ = 'Tomas Aparicio'
__license__ = 'MIT'

# Current package version
__version__ = '0.1.0'
