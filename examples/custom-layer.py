import siringa

# Create a custom dependency layer
layer = siringa.Layer('app')

# Then you can use the standard API
layer.register('print', print)


# Then you can use the standard API
@layer.inject
def mul2(x, print: '!'):
    print('Argument:', x)
    return x * 2


print('Result:', mul2(2))
