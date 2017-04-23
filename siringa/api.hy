(require [siringa.macros [*]])
(import [siringa.layer [Layer]])

;; Public API layer symbols to export
(def --all-- (, "layer" "register" "inject" "mock"
                "clear" "clear_mocks" "lookup"
                "unregister" "unregister_mock"
                "is_injectable" "Annotation" "A"
                "lookup_mock" "mocks" "parent" "container"))

;; Default built-in dependency layer
(def layer (Layer "default"))

;; Macro for DRYer function delegation via code generation
(defmacro defdelegator [name &optional [getter? False]]
  `(defn ~name [&rest args &kwargs kwargs]
      (setv member (getattr layer (. ~name __name__)))
      (if ~getter? member (apply member args kwargs))))

;; Public API functions that delegates to default built-in layer
(defdelegator register)
(defdelegator mock)
(defdelegator inject)
(defdelegator Annotation)
(defdelegator A) ;; Shortcut to "Annotation"
(defdelegator unregister)
(defdelegator unregister-mock)
(defdelegator clear)
(defdelegator clear-mocks)
(defdelegator lookup)
(defdelegator lookup-mock)
(defdelegator injectable?)
(defdelegator mocks True)
(defdelegator parent True)
(defdelegator container True)
