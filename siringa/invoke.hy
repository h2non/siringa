(require [siringa.macros [*]])
(import [siringa.dependency [injectable?]])
(import [siringa.errors [MissingDependencyError]])
(import [siringa.analyzer [analyze signature-values annotate
                           valid? annotation? keyword-args]])

(defn resolve [cont param]
  "Returns a dependency annotation for a given param."
  (setv name (str (annotate (. param annotation))))
  (setv dependency (.get cont name))
  (unless dependency
    (raise
      (MissingDependencyError
        (.format "dependency \"{}\" cannot be satisfied" name))))
        (. dependency value))

(defn match-args [cont params args]
  "Returns a tuple of argument values with intermediate required
  dependencies resolved by annotations pattern-matching for
  callable invokation."
  (setv -args (iter args))
  (setv buf (* [None] (len params)))
  (for [(, pos param) (enumerate params)]
    (if (and (annotation? param)
             (valid? (. param annotation)))
      (assoc buf pos (resolve cont param))
      (try
        (assoc buf pos (next -args))
        (except [e StopIteration])))) buf)

(defn invoke [cont func &rest args &kwargs kwargs]
  "Invokes a given callable object with specific variadic arguments.
  Relies on type annotation pattern matching for transparent
  dependency injection."
  (unless (injectable? func)
    (raise (TypeError "only can invoke classes, functions or methods")))
  (setv kwlen (len (keyword-args func)))
  (setv signature (signature-values func))
  (setv pending (- (- (len signature)
                      (len (analyze func)))
                   (+ (len args)
                      (len kwargs))))
  (if (method? func)
    (setv pending (dec pending)))
  (unless (or (= pending 0)
              (< (- pending kwlen) 1))
    (raise (TypeError
      ((. "{}() missing {} required positional arguments" format)
        (. func --name--) pending))))
  (apply func (match-args cont signature args) kwargs))
