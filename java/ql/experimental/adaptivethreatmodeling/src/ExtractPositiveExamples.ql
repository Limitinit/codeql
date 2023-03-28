/**
 * Surfaces endpoints are sinks with high confidence, for use as positive examples in the prompt.
 *
 * @name Positive examples (experimental)
 * @kind problem
 * @id java/ml-powered/known-sink
 * @tags experimental security
 */

private import java
import semmle.code.java.dataflow.TaintTracking
private import semmle.code.java.security.ExternalAPIs as ExternalAPIs
private import experimental.adaptivethreatmodeling.EndpointCharacteristics as EndpointCharacteristics
private import experimental.adaptivethreatmodeling.EndpointTypes
private import experimental.adaptivethreatmodeling.ATMConfigs as ATMConfigs

/*
 * ****** WARNING: ******
 * Before calling this query, make sure there's no codex-generated data extension file in `java/ql/lib/ext`. Otherwise,
 * the ML-gnerarated, noisy sinks will end up poluting the positive examples used in the prompt!
 */

from DataFlow::Node sink, SinkType sinkType, string message
where
  // Exclude endpoints that have contradictory endpoint characteristics, because we only want examples we're highly
  // certain about in the prompt.
  not EndpointCharacteristics::erroneousEndpoints(sink, _, _, _, _, false) and
  // Extract positive examples of sinks belonging to the existing ATM query configurations.
  (
    EndpointCharacteristics::isKnownSink(sink, sinkType) and
    // It's valid for a node to satisfy the logic for both `isSink` and `isSanitizer`, but in that case it will be
    // treated by the actual query as a sanitizer, since the final logic is something like
    // `isSink(n) and not isSanitizer(n)`. We don't want to include such nodes as positive examples in the prompt.
    not ATMConfigs::isBarrier(sink) and
    // Include only sinks that are arguments to an external API call, because these are the sinks we are most interested
    // in.
    sink instanceof ExternalAPIs::ExternalApiDataNode and
    // If there are _any_ erroneous endpoints, return an error message for all rows. This will prevent us from
    // accidentally running this query when there's a codex-generated data extension file in `java/ql/lib/ext`.
    if not EndpointCharacteristics::erroneousEndpoints(_, _, _, _, _, true)
    then
      message =
        sinkType + "\n" +
          // Extract the needed metadata for this endpoint.
          any(string metadata | EndpointCharacteristics::hasMetadata(sink, metadata))
    else
      message =
        "Error: There are erroneous endpoints! Please check whether there's a codex-generated data extension file in `java/ql/lib/ext`."
  )
select sink, message
