import javascript
import DataFlow::PathGraph

class Configuration extends TaintTracking::Configuration {
  Configuration() { this = "Configuration" }

  override predicate isSource(DataFlow::Node source) { 
    exists(FileSystemReadAccess src | source = src.getADataNode())
  }

  override predicate isSink(DataFlow::Node sink) { 
    exists(SystemCommandExecution shell | sink = shell.getACommandArgument()) 
  }
}

class FlowToRead extends TaintTracking::Configuration{
  FlowToRead(){ this = "FlowToRead" }

  override predicate isSource(DataFlow::Node source) { 
    exists(DataFlow::SourceNode src | source = src)
  }

  override predicate isSink(DataFlow::Node sink) { 
    exists(FileSystemReadAccess read | sink = read.getAPathArgument()) 
  }

}

from 
Configuration cfg, 
FlowToRead flowToRead,
DataFlow::PathNode flow_source, 
DataFlow::PathNode flow_sink,
DataFlow::PathNode read_source,
DataFlow::PathNode read_sink,
FileSystemReadAccess read


where 
cfg.hasFlowPath(flow_source, flow_sink)
and
flowToRead.hasFlowPath(read_source, read_sink)
and
not flow_source.getNode() = flow_sink.getNode()
and
read.getAPathArgument() = read_sink.getNode()
and
read = flow_source.getNode()

select 
read_sink.getNode(), read_source, read_sink, "shell command depends on $@. $@. $@", 
read_source.getNode(), "read source", 
flow_source.getNode(), "file",
flow_sink.getNode(), "shell"
