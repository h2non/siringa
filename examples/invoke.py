import siringa


@siringa.register
def mul2(x):
    return x * 2


# Note that the function was not instrumented yet!
def compute(x, mul: '!mul2'):
    return mul(x)


# Invoke function
print('Result:', siringa.invoke(compute, 2))
