import java
import semmle.code.java.dataflow.FlowSources
import DataFlow

/**
 * A taint-tracking configuration for disabling revocation checking.
 */
module DisabledRevocationCheckingConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) {
    source.asExpr().(BooleanLiteral).getBooleanValue() = false
  }

  predicate isSink(DataFlow::Node sink) { sink instanceof SetRevocationEnabledSink }
}

module DisabledRevocationCheckingFlow = TaintTracking::Global<DisabledRevocationCheckingConfig>;

/**
 * A sink that disables revocation checking,
 * i.e. calling `PKIXParameters.setRevocationEnabled(false)`
 * without setting a custom revocation checker in `PKIXParameters`.
 */
class SetRevocationEnabledSink extends DataFlow::ExprNode {
  SetRevocationEnabledSink() {
    exists(MethodAccess setRevocationEnabledCall |
      setRevocationEnabledCall.getMethod() instanceof SetRevocationEnabledMethod and
      setRevocationEnabledCall.getArgument(0) = getExpr() and
      not exists(MethodAccess ma, Method m | m = ma.getMethod() |
        (m instanceof AddCertPathCheckerMethod or m instanceof SetCertPathCheckersMethod) and
        ma.getQualifier().(VarAccess).getVariable() =
          setRevocationEnabledCall.getQualifier().(VarAccess).getVariable()
      )
    )
  }
}

class SetRevocationEnabledMethod extends Method {
  SetRevocationEnabledMethod() {
    getDeclaringType() instanceof PKIXParameters and
    hasName("setRevocationEnabled")
  }
}

class AddCertPathCheckerMethod extends Method {
  AddCertPathCheckerMethod() {
    getDeclaringType() instanceof PKIXParameters and
    hasName("addCertPathChecker")
  }
}

class SetCertPathCheckersMethod extends Method {
  SetCertPathCheckersMethod() {
    getDeclaringType() instanceof PKIXParameters and
    hasName("setCertPathCheckers")
  }
}

class PKIXParameters extends RefType {
  PKIXParameters() { hasQualifiedName("java.security.cert", "PKIXParameters") }
}
