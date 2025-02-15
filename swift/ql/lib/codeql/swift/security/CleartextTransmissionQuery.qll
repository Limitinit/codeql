/**
 * Provides a taint-tracking configuration for reasoning about cleartext
 * transmission vulnerabilities.
 */

import swift
import codeql.swift.security.SensitiveExprs
import codeql.swift.dataflow.DataFlow
import codeql.swift.dataflow.TaintTracking
import codeql.swift.security.CleartextTransmissionExtensions

/**
 * A taint configuration from sensitive information to expressions that are
 * transmitted over a network.
 */
deprecated class CleartextTransmissionConfig extends TaintTracking::Configuration {
  CleartextTransmissionConfig() { this = "CleartextTransmissionConfig" }

  override predicate isSource(DataFlow::Node node) { node.asExpr() instanceof SensitiveExpr }

  override predicate isSink(DataFlow::Node node) { node instanceof CleartextTransmissionSink }

  override predicate isSanitizer(DataFlow::Node sanitizer) {
    sanitizer instanceof CleartextTransmissionSanitizer
  }

  override predicate isAdditionalTaintStep(DataFlow::Node nodeFrom, DataFlow::Node nodeTo) {
    any(CleartextTransmissionAdditionalTaintStep s).step(nodeFrom, nodeTo)
  }

  override predicate isSanitizerIn(DataFlow::Node node) {
    // make sources barriers so that we only report the closest instance
    isSource(node)
  }
}

/**
 * A taint configuration from sensitive information to expressions that are
 * transmitted over a network.
 */
module CleartextTransmissionConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node node) { node.asExpr() instanceof SensitiveExpr }

  predicate isSink(DataFlow::Node node) { node instanceof CleartextTransmissionSink }

  predicate isBarrier(DataFlow::Node sanitizer) {
    sanitizer instanceof CleartextTransmissionSanitizer
  }

  predicate isAdditionalFlowStep(DataFlow::Node nodeFrom, DataFlow::Node nodeTo) {
    any(CleartextTransmissionAdditionalTaintStep s).step(nodeFrom, nodeTo)
  }

  predicate isBarrierIn(DataFlow::Node node) {
    // make sources barriers so that we only report the closest instance
    isSource(node)
  }
}

/**
 * Detect taint flow of sensitive information to expressions that are transmitted over
 * a network.
 */
module CleartextTransmissionFlow = TaintTracking::Global<CleartextTransmissionConfig>;
