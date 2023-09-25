import javascript
import DataFlow::PathGraph

class Configuration extends TaintTracking::Configuration {
  Configuration() { this = "Configuration" }

  override predicate isSource(DataFlow::Node source) { 
   source = any(Http::RouteHandler rh).getARequestNode()
  }

  override predicate isSink(DataFlow::Node sink) { 
   exists(FileSystemWriteAccess write | sink = write.getADataNode()) 
  }
}

from 
Configuration cfg, 
DataFlow::PathNode source, 
DataFlow::PathNode sink

where 
cfg.hasFlowPath(source, sink)
and
not source.getNode() = sink.getNode()

select 
sink.getNode(), source, sink, "file write depends on $@.", 
source.getNode(), "route handler"