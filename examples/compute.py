import siringa


@siringa.register
def mul(x, y):
    return x * y


@siringa.register
def mul2(x, mul: '!mul'):
    return mul(x, 2)


@siringa.register
def pow2(x):
    return x ** 2


@siringa.inject
def compute(x, pow: '!pow2', mul: '!mul2'):
    return pow(mul(x))


print('Result:', compute(2))  # => 16
