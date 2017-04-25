(require [hy.contrib.multi [defn]]) ;; required macro for function overloading

(defmacro has? [x name]
  `(and name (hasattr ~x ~name)))

(defmacro str? [x]
  `(instance? str ~x))

(defmacro cls? [x]
  `(do
    (import inspect)
    (= (.isclass inspect ~x) True)))

(defmacro fn? [x]
  `(do
    (import inspect)
    (.isfunction inspect ~x)))

(defmacro method? [x]
  `(do
    (import inspect)
    (.ismethod inspect ~x)))

(defmacro delegate [obj method &rest args]
  `((getattr ~obj ~method) args kwargs))
