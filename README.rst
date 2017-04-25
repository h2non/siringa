.. image:: http://i.imgur.com/sbWr5Xv.png
   :width: 100%
   :alt: siringa logo
   :align: center


|Build Status| |PyPI| |Coverage Status| |Documentation Status| |Stability| |Versions| |SayThanks|

About
-----

``siringa`` (meaning ``syringe`` in Italian) is a minimalist, idiomatic `dependency injection`_ and `inversion of control`_ library
for Python_, implemented in Hy_, a homoiconic Lisp dialect for Python.

To get started, take a look to the `documentation`_, `API`_, `tutorial`_ and `examples`_.

**Note**: still beta quality software.

Features
--------

-  Simple, idiomatic and versatile `programmatic API`_.
-  Annotation based dependency injection that is `PEP 3017`_ and `PEP 0484`_ friendly.
-  First-class decorator driven dependency injection and registering.
-  Ability to create multiple dependency containers.
-  Hierarchical dependency containers based on inheritance.
-  Dependency inference based on pattern-matching techniques.
-  First-class support for dependency mocking for better testing.
-  Detects cyclic dependencies (work in progress).
-  Small and (almost) dependency-free library.
-  Works with CPython 3+.

Design philosophy
-----------------

-  Code instrumentation should be non-intrusive and idiomatic.
-  Explicitness over implicitness: dependencies and injections much be explicitly defined.
-  Python idiomatic: embrace decorators and type annotations.
-  Minimalism: less enables more.
-  Uniformity: there is only one way to declare and consume dependencies.
-  Predictability: developer intentions must persist based on explicitly defined intention.
-  Domain agnostic: do not enforce any domain-specific pattern.

Installation
------------

Using ``pip`` package manager:

.. code-block:: bash

    pip install --upgrade siringa

Or install the latest sources from Github:

.. code-block:: bash

    pip install -e git+git://github.com/h2non/siringa.git#egg=siringa


Tutorial
--------

Importing siringa
^^^^^^^^^^^^^^^^^

.. code-block:: python

    import siringa

Instrumenting dependencies
^^^^^^^^^^^^^^^^^^^^^^^^^^

``siringa`` embraces type hints/arguments annotation Python syntax for
dependency inference and pattern matching.

.. code-block:: python

    @siringa.inject
    def task(x, y, logger: '!Logger'):
        logger.info('task called with arguments: {}, {}'.format(x, y))
        return x * y


You can optionally annotate dependencies via ``siringa`` type annotations:

.. code-block:: python

    from siringa import A

    @siringa.inject
    def task(x, y, logger: A('Logger')):
        logger.info('task called with arguments: {}, {}'.format(x, y))
        return x * y


Finally, for a DRYer approach you can simply annotate dependencies with ``!`` annotation flag.

In this case, the argument name expression will be used for dependency inference.

.. code-block:: python

    from siringa import A

    @siringa.inject
    def task(x, y, Logger: '!'):
        Logger.info('task called with arguments: {}, {}'.format(x, y))
        return x * y


Registering dependencies
^^^^^^^^^^^^^^^^^^^^^^^^

``siringa`` allows you to rely on decorators for idiomatic dependencies registering.

Dependency name is dynamically inferred at registration time based on ``class`` or ``function`` name.

.. code-block:: python

    @siringa.register
    class Logger(object):
        logger = logging.getLogger('siringa')

        @staticmethod
        def info(msg, *args, **kw):
            logger.info(msg, *args, **kw)


However, you can define a custom dependency name by simply passing a ``string`` as first argument:

.. code-block:: python

    @siringa.register('MyCustomLogger')
    class Logger(object):
        ...

Finally, you can register dependencies with a traditional function call, such as:

.. code-block:: python

    class Logger(object):
        pass

    siringa.register('MyCustomLogger', Logger)

    class compute(x, y):
        return x * y

    siringa.register('multiply', compute)


Invocation
^^^^^^^^^^

``siringa`` wraps callable object in the transparent and frictionless way abstracting things for developers.

You can invoke or instantiate any dependency injection instrumented object
as you do traditionally in raw Python code and ``siringa`` will do the rest for you inferring and pattern-matching
required dependencies accordingly for you.

Below is an example of how simple it is:

.. code-block:: python

    # Call our previously declared function in this tutorial.
    # Here, siringa will transparently inject required dependencies accordingly,
    # respecting the invokation arguments and order.
    task(2, 2) # => 4

Let's demostrate this with a featured example:

.. code-block:: python

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

    compute(2) # => 16


You can also use the invocation API in case that the target object
was not properly instrumented as dependency:

.. code-block:: python

    @siringa.register
    def mul2(x):
        return x * 2

    # Note that the function was not instrumented yet!
    def compute(x, mul: '!mul2'):
        return mul(x)

    siringa.invoke(compute, 2)


Create a new dependency container
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

``siringa`` provides a built-in global dependency container for usability purposes,
but you can create as much containers as you want.

In the ``siringa`` idioms, this means creating a new dependency layer which provides its
own container and dependency injection API, pretty much as the global package API.

You can create a new dependencies ``layer`` such as:

.. code-block:: python

    layer = siringa.Layer('app')

    # Then you can use the standard API
    layer.register('print', print)

    # Then you can use the standard API
    @layer.inject
    def mul2(x, print: '!'):
        print('Argument:', x)
        return x * 2

    mul2(x)

A dependency layer can inherit from a parent dependency layer.

This is particularly useful in order to create a hierarchy of dependency layers
where you can consume and inject dependencies from a parent container.

.. code-block:: python

    parent = siringa.Layer('parent')
    child = siringa.Layer('child', parent)

    # Register a sample dependency within parent
    @parent.register
    def mul2(x):
        return x * 2

    # Verify that the dependency is injectable from child layer
    parent.is_injectable('mul2') # True
    child.is_injectable('mul2') # True

    @child.inject
    def compute(x, mul: '!mul2'):
        return mul(x)

    compute(2) # => 2

Mocking dependencies
^^^^^^^^^^^^^^^^^^^^

``siringa`` allows you to define mocks for dependencies, which is particularly useful during testing:

.. code-block:: python

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

    # Once done, clear all the mocks
    siringa.unregister_mock('DB')

    # Or alternatively clear all the registed mocks within the container
    siringa.clear_mocks()

    # Test read call
    assert run('SELECT name FROM foo') == ['john', 'mike']


.. _Python: http://python.org
.. _Hy: http://docs.hylang.org/en/latest/
.. _`dependency injection`: https://en.wikipedia.org/wiki/Dependency_injection
.. _`inversion of control`: https://en.wikipedia.org/wiki/Inversion_of_control
.. _`documentation`: http://siringa.readthedocs.io
.. _`examples`: http://siringa.readthedocs.io/en/latest/examples.html
.. _`API`: http://siringa.readthedocs.io/en/latest/api.html
.. _`programmatic API`: http://siringa.readthedocs.io/en/latest/api.html
.. _`tutorial`: http://siringa.readthedocs.io/en/latest/index.html#tutorial
.. _`PEP 3017`: https://www.python.org/dev/peps/pep-3107/
.. _`PEP 0484`: https://www.python.org/dev/peps/pep-0484/

.. |Build Status| image:: https://travis-ci.org/h2non/siringa.svg?branch=master
   :target: https://travis-ci.org/h2non/siringa
.. |PyPI| image:: https://img.shields.io/pypi/v/siringa.svg?maxAge=2592000?style=flat-square
   :target: https://pypi.python.org/pypi/siringa
.. |Coverage Status| image:: https://coveralls.io/repos/github/h2non/siringa/badge.svg?branch=master
   :target: https://coveralls.io/github/h2non/siringa?branch=master
.. |Documentation Status| image:: https://readthedocs.org/projects/siringa/badge/?version=latest
   :target: http://siringa.readthedocs.io/en/latest/?badge=latest
.. |Stability| image:: https://img.shields.io/pypi/status/siringa.svg
   :target: https://pypi.python.org/pypi/siringa
   :alt: Stability
.. |Versions| image:: https://img.shields.io/pypi/pyversions/siringa.svg
   :target: https://pypi.python.org/pypi/siringa
   :alt: Python Versions
.. |SayThanks| image:: https://img.shields.io/badge/Say%20Thanks!-%F0%9F%A6%89-1EAEDB.svg
   :target: https://saythanks.io/to/h2non
   :alt: Say Thanks
