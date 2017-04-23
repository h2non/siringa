import pytest
from siringa.inject import inject
from siringa.annotation import Annotation as A
from siringa.errors import MissingDependencyError


def test_injector_function(cont):
    cont['mul2'] = lambda x: x * 2
    assert 'mul2' in cont

    def foo(x, p: '!mul2', y, z=None):
        return x + p(2) + y + (z or 0)

    assert inject(cont, foo)(2, 2) == 8
    assert inject(cont, foo)(2, 2, 2) == 10


def test_injector_annotation(cont):
    cont['power'] = lambda x: x ** x
    assert 'power' in cont

    def foo(x, p: A('power'), y):
        return x + p(2) + y

    assert inject(cont, foo)(2, 2) == 8
    assert inject(cont, foo)(2, 4) == 10


def test_index_function_multiple(cont):
    def bar(x, p: '!mul2', y: '!plus3', z=None):
        return x + p(2) + y(2) + (z or 0)

    cont['plus3'] = lambda x: x + 3
    assert 'plus3' in cont

    assert inject(cont, bar)(2, 2) == 13
    assert inject(cont, bar)(2, 2, 2) == 13


def test_injector_function_args_position(cont):
    cont['mul4'] = lambda x: x * 4
    assert 'mul4' in cont

    def foo(p: '!mul4', x):
        return p(2) + x

    assert inject(cont, foo)(2) == 10
    assert inject(cont, foo)(5) == 13


def test_injector_class(cont):
    cont['foo'] = 2
    assert 'foo' in cont

    def _inject(target):
        return inject(cont, target)

    @_inject
    class Foo(object):
        def __init__(self, x: '!foo', y):
            self.x = x
            self.y = y

    foo = Foo(4)
    assert foo.x == 2
    assert foo.y == 4

    class Bar(object):
        @_inject
        def __init__(self, x: '!foo', y):
            self.x = x
            self.y = y

    bar = Bar(4)
    assert bar.x == 2
    assert bar.y == 4


def test_injector_missing_dependency(cont):
    def foo(x: '!invalid'):
        return x * 2

    with pytest.raises(MissingDependencyError):
        inject(cont, foo)()
