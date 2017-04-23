(require [siringa.macros [*]])
(import functools)
(import [siringa.invoke [invoke]])

(defn inject-cls [cont cls]
  "Decorates a class object for dependency injection instrumentation."
  (setv func (getattr cls "__init__"))
  #@((functools.wraps func)
  (defn wrapper [self &rest args &kwargs kwargs]
    (apply invoke (+ (, cont func self) args) kwargs)))
  (setattr cls "__init__" wrapper) cls)

(defn inject [cont callable]
  "Instruments by decoration a given callable object enabling
  lazy dependency injection capabilities."
  (cond
    [(cls? callable)
      (inject-cls cont callable)]
    [(fn? callable)
      #@((functools.wraps callable)
      (defn wrapper [&rest args &kwargs kwargs]
        (apply invoke (+ (, cont callable) args) kwargs)))]
    [True (raise (TypeError "only can inject dependencies into classes, functions or methods"))]))
