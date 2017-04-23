Tutorial
========

Installation
------------

Please, see installation_ section.


Import it
---------

.. code-block:: python

    import siringa


Register a dependency
---------------------

Name based dependency registering:

.. code-block:: python

    siringa.register('foo', foo)

Decorator based dependency registering:

.. code-block:: python

    # Dependency name will be inferred via function name
    @siringa.register
    def foo():
        pass

    # Or registering a class
    @siringa.register
    class foo():
        pass

Decorator based dependency registering with custom alias:

.. code-block:: python

    @siringa.register('foo')
    def foo():
        pass


Create a new dependencies container
-----------------------------------

.. code-block:: python

    layer = siringa.layer()

    layer.register('foo', foo)
