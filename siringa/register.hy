(require [siringa.macros [*]])
(import functools)
(import [siringa.inject [inject]])
(import [siringa.dependency [Dependency injectable?]])
(import [siringa.errors [InvalidDependencyTypeError]])

(defn infer-name [obj]
  (if (or (cls? obj)
          (fn? obj)) (. obj __name__)))

(defn registrator [cont obj name &optional mock]
  (unless name
    (raise (InvalidDependencyTypeError
              "empty dependency name")))
  (unless (instance? str name)
    (raise (InvalidDependencyTypeError
              "dependency name must be a string")))
  (if (none? obj)
    (raise (InvalidDependencyTypeError
              "cannot register None object")))
  (setv value
    (if (injectable? obj) (inject cont obj) obj))
  (assoc cont name
    (Dependency value mock)) value)

(defn register-partial [cont &optional name mock]
  (cond [(none? name)
          (fn [target] (register-partial cont target mock))]
        [(str? name)
          (fn [obj] (registrator cont obj name mock))]
        [(injectable? name)
          (registrator cont name (infer-name name) mock)]
        [True
          (raise
            (InvalidDependencyTypeError
              "register decorator must be used with classes, methods or functions"))]))

(defn register
  "Registers a dependency in the given container.
  Function is overloaded and behavior is defined by arguments arity."
  ([cont] (register-partial cont))
  ([cont name] (register-partial cont name))
  ([cont name obj] (registrator cont obj name)))

(defn register-mock
  "Registers a mock dependency in the given container.
  Function is overloaded and behavior is defined by arguments arity."
  ([cont] (register-partial cont :mock True))
  ([cont name] (register-partial cont name :mock True))
  ([cont name obj] (registrator cont obj name :mock True)))

(defn unregister [cont name]
  "Unregisters a dependency by name in the given container."
  (.pop cont name))

(defn unregister-mock [cont name]
  "Unregisters a dependency mock by name in the given container."
  (.pop-mock cont name))
