(require [siringa.macros [*]])

(defclass Annotation [object]
  "Dependency annotation used for dependency inference and pattern matching."

  (defn --init-- [self name &optional resolver container]
    (setv (. self name) name)
    (setv (. self resolver) resolver)
    (setv (. self container) container))

  (defn --repr-- [self]
    (.format "siringa.Annotation({})" (. self name)))

  (defn --str-- [self]
    (if (fn? (. self resolver))
      (.resolver self name)
      (. self name))))
