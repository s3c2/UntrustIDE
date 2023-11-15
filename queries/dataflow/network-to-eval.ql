import javascript
import DataFlow::PathGraph

import workspaceConfig

class UntrustedURL extends TaintTracking::Configuration{
  UntrustedURL() { this = "UntrustedURL" }

  override predicate isSource(DataFlow::Node source){
    exists(FileSystemReadAccess src | source = src.getADataNode().getALocalSource())
    or
    exists(ClientRequest r | source = r.getAResponseDataNode())
    or
    exists(Http::RouteHandler rh | source = rh.getARequestNode())
    or
    exists(VSCodeWorkspaceConfig config, DataFlow::SourceNode src | 
      src.getFile() = config.getFile() and src.getStartLine() = config.getStartLine() |
      source = src)
  }

  override predicate isSink(DataFlow::Node sink){
    exists( ClientRequest r | sink = r.getHost() or sink = r.getUrl() )
  }
}

class HttpURL extends TaintTracking::Configuration{
  HttpURL() { this = "HttpURL" }

  override predicate isSource(DataFlow::Node source){
    exists( StringLiteral str| str.getStringValue().matches("%http://%") |source = str.flow())
    or
    exists( StringOps::Concatenation str | str.getAnOperand().getStringValue().matches("%http://%") | source = str)
  }

  override predicate isSink(DataFlow::Node sink){
    exists( ClientRequest r | sink = r.getHost() or sink = r.getUrl() )

  }
}

class Configuration extends TaintTracking::Configuration {
  Configuration() { this = "Configuration" }

  override predicate isSource(DataFlow::Node source) { 
    source = any(ClientRequest r).getAResponseDataNode()
  }

  override predicate isSink(DataFlow::Node sink) { 
    exists(DirectEval eval | sink.getAstNode() = eval.getAChild())  
  }
}

from 
Configuration cfg, 
DataFlow::PathNode response_source, 
DataFlow::PathNode eval_sink,
UntrustedURL untrustedURL,
HttpURL httpURL,
DataFlow::PathNode url_source,
DataFlow::PathNode url_sink,
ClientRequest req

where 
cfg.hasFlowPath(response_source, eval_sink)
and
not response_source.getNode() = eval_sink.getNode()
and
(
  untrustedURL.hasFlowPath(url_source, url_sink)
  or
  httpURL.hasFlowPath(url_source, url_sink)
)
and
(req.getHost() = url_sink.getNode() or req.getUrl() = url_sink.getNode())
and
req.getAResponseDataNode() = response_source.getNode()

select 
eval_sink.getNode(), response_source, eval_sink, "eval depends on $@. $@. $@.", 
response_source.getNode(), "network response",
url_source, url_source.toString(),
// url_source.getNode().getStringValue(),
url_sink, "url sink"