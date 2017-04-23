Frequently Asked Questions
==========================

Can I use ``siringa`` with any web framework?
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Yes, you can. ``siringa`` is fully framework agnostic, minimalist library that fits everywhere.


I saw it is implemented in Hy. How does this affects my program?
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Actually, almost nothing. It only implies a small overhead at modules import time when you Python
program is bootstrapping since the Hy interpreted should be loaded and parse Hy modules in order
to bind the generated Python AST to the Python compiler.

At runtime level your program won't be expose to any performance overhead,
it's just like running any other Python library.
