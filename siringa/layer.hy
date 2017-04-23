(require [siringa.macros [*]])
(import [siringa.container [Container]])
(import [siringa.annotation [Annotation :as -Annotation]])
(import [siringa.inject [inject :as -inject]])
(import [siringa.invoke [invoke :as -invoke]])
(import [siringa.register [register :as -register
                           register-mock :as -register-mock
                           unregister :as -unregister
                           unregister-mock :as -unregister-mock]])

(defclass Layer [object]
  "Layer represents a dependency injection layer with its own container.
  Layer can optionally inherit from a parent layer, implicitly inheriting
  its container dependencies."

  (defn --init-- [self name &optional parent]
    (setv (. self name) name)
    (setv (. self parent) parent)
    (setv (. self cont) (Container (if (instance? Layer parent) (. parent cont)))))

  (defn register [self &rest args &kwargs kwargs]
    (apply -register (+ (, (. self cont)) args) kwargs))

  (defn mock [self &rest args &kwargs kwargs]
    (apply -register-mock (+ (, (. self cont)) args) kwargs))

  (defn unregister [self name]
    (-unregister name))

  (defn unregister-mock [self name]
    (-unregister-mock (. self cont) name))

  (defn inject [self &rest args &kwargs kwargs]
    (apply -inject (+ (, (. self cont)) args) kwargs))

  (defn invoke [self &rest args &kwargs kwargs]
    (apply -invoke (+ (, (. self cont)) args) kwargs))

  (defn A [self name &optional resolver]
    (-Annotation name resolver (. self cont)))

  (defn Annotation [self name &optional resolver]
    (-Annotation name resolver (. self cont)))

  (defn injectable? [self name]
    (in name (. self cont)))

  (defn clear [self]
    (.clear (. self cont)))

  (defn clear-mocks [self]
    (.clear-mocks (. self cont)))

  (defn lookup [self name &optional defaults]
    ((. self cont get) name defaults))

  (defn lookup-mock [self name &optional defaults]
    ((.get (. (. self cont) mocks) name defaults)))

  #@(property (defn mocks [self]
    (. (. self cont) mocks)))

  #@(property (defn container [self]
    (. self cont)))

  (defn --len-- [self]
    (len (. self cont)))

  (defn --repr-- [self]
    ((. "siringa.Layer(name={}, parent={}, container={})" format)
        (if (. self parent) (. (. self parent) name) None)
        (. self name)
        (. self cont))))
