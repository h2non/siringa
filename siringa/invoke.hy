(require [siringa.macros [*]])
(import [siringa.dependency [injectable?]])
(import [siringa.errors [MissingDependencyError]])
(import [siringa.analyzer [analyze signature-values annotate
                           take-param inferrable?
                           valid? annotation? keyword-args]])

(defn infer-name [param]
  "Infers injectable name based on param annotation or value expression."
  (str (if (inferrable? param)
           (annotate (take-param param))
           (annotate (. param annotation)))))

(defn resolve [cont param]
  "Returns a dependency annotation for a given param."
  (setv name (infer-name param))
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

(defn invoke [cont target &rest args &kwargs kwargs]
  "Invokes a given callable object with specific variadic arguments.
  Relies on type annotation pattern matching for transparent
  dependency injection."
  (unless (injectable? target)
    (raise
      (TypeError
        (.format "only can invoke classes, functions or methods, but got: {}" target))))
  (setv kwlen (len (keyword-args target)))
  (setv signature (signature-values target))
  (setv pending (- (- (len signature)
                      (len (analyze target)))
                   (+ (len args)
                      (len kwargs))))
  (if (method? target)
    (setv pending (dec pending)))
  (unless (or (= pending 0)
              (< (- pending kwlen) 1))
    (raise (TypeError
      ((. "{}() missing {} required positional arguments" format)
        (. target --name--) pending))))
  (apply target (match-args cont signature args) kwargs))
