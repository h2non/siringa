(require [siringa.macros [*]])
(import functools)
(import [siringa.invoke [invoke]])

(defn inject-cls [cont cls]
  "Decorates a class object for dependency injection instrumentation."
  (setv func (getattr cls "__init__"))
  (unless (is func (getattr object "__init__"))
    #@((functools.wraps func)
    (defn wrapper [self &rest args &kwargs kwargs]
      (apply invoke (+ (, cont func self) args) kwargs)))
    (setattr cls "__init__" wrapper)) cls)

(defn inject [cont target]
  "Instruments by decoration a given callable object enabling
  lazy dependency injection capabilities."
  (cond
    [(cls? target)
      (inject-cls cont target)]
    [(fn? target)
      #@((functools.wraps target)
      (defn wrapper [&rest args &kwargs kwargs]
        (apply invoke (+ (, cont target) args) kwargs)))]
    [True (raise (TypeError "only can inject dependencies into classes, functions or methods"))]))
