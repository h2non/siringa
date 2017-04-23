import siringa


# Create parent dependency layer
parent = siringa.Layer('parent')

# Create child dependency layer that inherits from parent
child = siringa.Layer('child', parent)


# Register a sample dependency within parent container
@parent.register
def mul2(x):
    return x * 2


# Verify that the dependency is injectable from child layer
print('Is injectable from parent:', parent.is_injectable('mul2'))
print('Is injectable from child:', child.is_injectable('mul2'))


@child.inject
def compute(x, mul: '!mul2'):
    return mul(x)


print('Result:', compute(2))
