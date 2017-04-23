import siringa


@siringa.register
class DB(object):
    def query(self, sql):
        return ['john', 'mike']


@siringa.mock('DB')
class DBMock(object):
    def query(self, sql):
        return ['foo', 'bar']


@siringa.inject
def run(sql, db: '!DB'):
    return db().query(sql)


# Test mock call
assert run('SELECT name FROM foo') == ['foo', 'bar']

# Once done, clear the mock
siringa.unregister_mock('DB')

# Or alternatively clear all the registed mocks within the container
siringa.clear_mocks()

# Test read call
assert run('SELECT name FROM foo') == ['john', 'mike']
