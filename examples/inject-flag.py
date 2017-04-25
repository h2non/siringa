import siringa


@siringa.register
def foo():
    return 'foo'


# Use '!' flag for DRYer dependency injection
# Argument name expression will be used for dependency pattern matching
@siringa.inject
def bar(foo: '!'):
    return foo()


assert bar() == foo()
print('Succeeded!')
