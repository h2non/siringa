from siringa import analyzer, A


def stringify(items):
    return [str(item) for item in items]


def test_analyze_invalid():
    assert analyzer.analyze(None) == []
    assert analyzer.analyze(str) == []
    assert analyzer.analyze(object) == []
    assert analyzer.analyze(list()) == []
    assert analyzer.analyze(tuple()) == []


def test_analyze_function():
    def fn0():
        return True
    assert analyzer.analyze(fn0) == []

    def fn1(x: '!foo'):
        return True
    assert stringify(analyzer.analyze(fn1)) == ['foo']

    def fn2(x: '!foo', y: '!bar'):
        return True
    assert stringify(analyzer.analyze(fn2)) == ['foo', 'bar']

    def fn3(x: 'foo', y: '!Bar'):
        return True
    assert stringify(analyzer.analyze(fn3)) == ['Bar']

    def fn4(x: str, y: '!bar'):
        return True
    assert stringify(analyzer.analyze(fn4)) == ['bar']


def test_analyze_function_inject_flag():
    def fn1(x: '!'):
        return True
    assert stringify(analyzer.analyze(fn1)) == ['x']

    def fn2(x: '!', y: '!bar'):
        return True
    assert stringify(analyzer.analyze(fn2)) == ['x', 'bar']

    def fn3(x: '!', y: '!'):
        return True
    assert stringify(analyzer.analyze(fn3)) == ['x', 'y']

    def fn4(x: str, foo: '!'):
        return True
    assert stringify(analyzer.analyze(fn4)) == ['foo']


def test_analyze_class():
    class Foo1(object):
        pass
    assert analyzer.analyze(Foo1) == []

    class Foo2(object):
        __inject__ = ['foo', 'bar']
    assert stringify(analyzer.analyze(Foo2)) == ['foo', 'bar']


def test_analyze_type_annotations():
    def fn0(x: A('foo')):
        return True
    assert stringify(analyzer.analyze(fn0)) == ['foo']
