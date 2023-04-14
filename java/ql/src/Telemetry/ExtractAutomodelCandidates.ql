/**
 * Surfaces the endpoints that pass the endpoint filters and are not already known to be sinks, and are therefore used
 * as candidates for classification with an ML model.
 *
 * Note: This query does not actually classify the endpoints using the model.
 *
 * @name Automodel candidates
 * @description A query to extract automodel candidates.
 * @kind problem
 * @severity info
 * @id java/ml-powered/extract-automodel-candidates
 * @tags automodel candidates
 */

private import java

//range over method m, parameter p, comment c
from Method m, Parameter p, Javadoc doc
where
  m.isPublic() and
  m.getAParameter() = p and
  m.getDoc().getJavadoc() = doc
select p, "Candidate for automodeling. Context: method=$@, doc=$@", m, m.toString(), doc,
  "/** .. */"
