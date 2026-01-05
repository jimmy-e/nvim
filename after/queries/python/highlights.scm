; -----------------------------
; Python extra highlighting
; Make more identifiers get captures so they aren’t plain white
; -----------------------------

; LHS of assignments: router = ...
(assignment
  left: (identifier) @variable)

; Unpacking: a, b = ...
(assignment
  left: (pattern_list (identifier) @variable))

; Function definitions
(function_definition
  name: (identifier) @function)

; Class definitions
(class_definition
  name: (identifier) @type)

; Function calls: APIRouter(...)
(call
  function: (identifier) @function.call)

; Attribute calls: router.get(...)
(call
  function: (attribute
    attribute: (identifier) @method.call))

; Attributes: router.prefix
(attribute
  attribute: (identifier) @property)

; Decorators (often already captured, but keep it explicit)
(decorator
  (identifier) @attribute)
(decorator
  (attribute attribute: (identifier) @attribute))

; Parameters (helps with function signatures)
(parameters (identifier) @parameter)

; Common constant style: ALL_CAPS
((identifier) @constant
  (#match? @constant "^[A-Z][A-Z0-9_]+$"))
