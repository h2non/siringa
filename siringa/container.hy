(require [siringa.macros [*]])
(import [collections [MutableMapping]])
(import [siringa.dependency [wrap]])
(import [siringa.errors [DuplicatedDependencyError]])

(defclass Container [MutableMapping]
  "Dependencies container store that support optional
  parent container hierarchies and inheritance."

  (defn --init-- [self &optional parent]
    (setv (. self store) (dict))
    (setv (. self mocks) (dict))
    (setv (. self parent) (if (instance? Container parent) parent (dict))))

  (defn --getitem-- [self name]
    (cond [(in name (. self mocks)) (get (. self mocks) name)]
          [(and (has? (. self parent) "mocks")
                (in name (. self mocks))) (get (. (. self parent) mocks) name)]
          [(in name (. self store)) (get (. self store) name)]
          [(in name (. self parent)) (get (. self parent) name)]))

  (defn --setitem-- [self name value]
    (setv dependency (wrap value))
    (cond [(.mock? dependency)
            (assoc (. self mocks) name dependency)]
          [(not (in name (. self store)))
            (assoc (. self store) name dependency)]
          [True
            (raise (DuplicatedDependencyError
              ((. "dependency '{}' already registered within the container" format) name)))]))

  (defn --contains-- [self name]
    (or (in name (. self store)) (in name (. self parent))))

  (defn pop [self name]
    (if (in name (. self store))
      ((. (. self store) pop) name)))

  (defn pop-mock [self name]
    (if (in name (. self mocks))
      (.pop (. self mocks) name)))

  (defn --delitem-- [self name]
    ((. self pop) name))

  (defn clear [self]
    (.clear (. self store)))

  (defn clear-mocks [self]
    (.clear (. self mocks)))

  (defn --iter-- [self]
    (iter (. self store)))

  (defn --len-- [self]
    (+ (len (. self store)) (len (. self parent))))

  (defn --repr-- [self]
    ((. "siringa.Container(dependencies={}, mocks={})" format)
        (. self store)
        (. self mocks)))

  (defn --hash-- [self]
    (hash (str self))))
