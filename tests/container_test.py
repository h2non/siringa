from siringa import Container


def test_container():
    c = Container()

    c['x'] = 1
    assert 'x' in c
    assert c['x'] == 1
    assert len(c) == 1

    del c['x']
    assert 'x' not in c
    assert len(c) == 0


def test_container_parent():
    parent = Container()
    parent['y'] = 1
    assert 'y' in parent
    assert parent['y'] == 1
    assert len(parent) == 1

    c = Container(parent)
    c['x'] = 1
    assert 'x' in c
    assert c['x'] == 1
    assert 'y' in c
    assert c['y'] == 1
    assert len(c) == 2

    del c['x']
    assert 'x' not in c

    assert 'y' in c
    assert len(c) == 1
