(require [siringa.macros [*]])
(import [siringa.analyzer [analyze]])

(defn dependency? [obj]
  (instance? Dependency obj))

(defn injectable? [obj]
  (or (cls? obj) (fn? obj)))

(defn wrap [value]
  "Wraps a given value as dependency, if needed."
  (if (dependency? value) value (Dependency value)))

(defclass Dependency [object]
  "Dependency represents an injectable dependency used across containers."

  (defn --init-- [self obj &optional [mock False]]
    (setv (. self value) obj)
    (setv (. self mock) (or mock False)))

  (defn injectable? [self]
    (injectable? (. self value)))

  (defn mock? [self]
    (= (. self mock) True))

  (defn dependencies [self]
    (analyze (. self value)))

  (defn --repr-- [self]
    ((. "siringa.Dependency({})" format) (. self value)))

  (defn --eq-- [self value]
    (= (. self value) value)))
