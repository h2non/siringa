import pytest
from siringa import InvalidDependencyTypeError
from siringa.register import register, register_mock as mock
from siringa.container import Container


def test_register_name_value():
    c = Container()
    assert register(c, 'x', True) is True
    assert 'x' in c
    assert c['x'] == True  # noqa


def test_register_decorator():
    c = Container()

    @register(c)
    def foo():
        return 'foo'

    assert 'foo' in c
    assert c['foo'].value() == 'foo'


def test_register_decorator_with_name():
    c = Container()

    @register(c, 'bar')
    def foo():
        return 'foo'

    assert 'bar' in c
    assert c['bar'].value() == 'foo'


def test_register_invalid_call():
    with pytest.raises(InvalidDependencyTypeError):
        register(Container(), None, "foo")

    with pytest.raises(InvalidDependencyTypeError):
        register(Container(), None, None)


def test_register_mock():
    c = Container()

    @register(c)
    def foo():
        return 'foo'

    @mock(c, 'foo')
    def foo_mock():
        return 'mock'

    assert 'foo' in c
    assert c['foo'].value() == 'mock'
