(import [siringa.errors [SiringaError
                         MissingDependencyError
                         DuplicatedDependencyError
                         InvalidDependencyTypeError]])

(defn test-errors []
  (assert (instance? (SiringaError) Exception))
  (assert (instance? (MissingDependencyError) SiringaError))
  (assert (instance? (DuplicatedDependencyError) SiringaError))
  (assert (instance? (InvalidDependencyTypeError) SiringaError)))
