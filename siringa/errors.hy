;; Base error exception class used for any siringa raised error.
(defclass SiringaError [Exception])

;; Raised a dependency name cannot be satisfied in the current container.
(defclass MissingDependencyError [SiringaError])

;; Raised when a duplicated dependency is found within a container.
(defclass DuplicatedDependencyError [SiringaError])

;; Raised when an invalid dependency type is registered within a container.
(defclass InvalidDependencyTypeError [SiringaError])
