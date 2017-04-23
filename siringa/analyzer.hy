(require [siringa.macros [*]])
(require [hy.contrib.multi [defmulti defmethod]])
(import inspect)
(import [siringa.annotation [Annotation]])

(defn signature [obj]
  ((. inspect signature) obj))

(defn signature-values [obj]
  ((. (. (signature obj) parameters) values)))

(defn keyword-args [obj]
  (list (filter (fn [param] (not (= (. param default) (. param empty))))
                (signature-values obj))))

(defn annotation? [param]
  (and param (has? param "annotation")))

(defn take-annotations [params]
  (map (fn [param]
        (if (and (injectable? (. param annotation))
                 (= 1 (len (. param annotation))))
             (+ "!" (. param name))
             (. param annotation)))
       (filter annotation? params)))

(defn injectable? [expr]
  (and (str? expr) (= (get expr 0) "!")))

(defn valid? [annotation]
  (or (and (and (str? annotation)
                (> (len annotation) 0))
           (injectable? annotation))
      (instance? Annotation annotation)))

(defmulti filter-params [args]
  (:origin args))

(defmethod filter-params "argument" [args]
  (valid? (:param args)))

(defmethod filter-params "attribute" [args]
  (setv param (:param args))
  (or (and (str? param)
           (> (len param) 0))
      (instance? Annotation param)))

(defn extract [annotation]
  (cut annotation 1))

(defn annotate [annotation]
  (cond [(injectable? annotation) (Annotation (extract annotation))]
        [True annotation]))

(defn map-params [param]
  (cond [(str? param) (annotate param)]
        [True param]))

(defn params [params &optional [origin "argument"]]
  (list (map map-params
             (filter
               (fn [param]
                  (filter-params {:origin origin :param param})) params))))

(defn attribute [obj]
  (params (getattr obj "__inject__" (list)) "attribute"))

(defn arguments [obj]
  (params (take-annotations (signature-values obj))))

(defn kind [obj]
  (cond [(cls? obj) :class]
        [(fn? obj) :function]))

(defn analyzer [obj kind]
  (cond [(= kind :class) (attribute obj)]
        [(= kind :function) (arguments obj)]
        [True (list)]))

(defn analyze [obj]
  "Takes an object and dynamically infers its type in order
  to analyze dependency injection annotations."
  (analyzer obj (kind obj)))
