import javascript
import DataFlow::PathGraph 

class FlowToWritePath extends TaintTracking::Configuration {
  FlowToWritePath() { this = "FlowToWritePath" }

  override predicate isSource(DataFlow::Node source) { 
    exists(Http::RouteHandler rh | source = rh.getARequestNode())
  }

  override predicate isSink(DataFlow::Node sink) { 
    exists(FileSystemWriteAccess write | sink = write.getAPathArgument()) 
  }
}
class FlowToWriteContent extends TaintTracking::Configuration {
  FlowToWriteContent() { this = "FlowToWriteContent" }

  override predicate isSource(DataFlow::Node source) { 
    exists(FileSystemReadAccess src | source = src.getADataNode().getALocalSource())
  }

  override predicate isSink(DataFlow::Node sink) { 
    exists(FileSystemWriteAccess write | sink = write.getADataNode()) 
  }
}


from 
FlowToWritePath writepath, FlowToWriteContent writecontent, 
DataFlow::PathNode source_path, DataFlow::PathNode source_content,
DataFlow::PathNode sink_path, DataFlow::PathNode sink_content,
FileSystemWriteAccess filewrite_func


where 
writepath.hasFlowPath(source_path, sink_path)
and
writecontent.hasFlowPath(source_content, sink_content)
and
filewrite_func.getADataNode() = sink_content.getNode()
and
filewrite_func.getAPathArgument() = sink_path.getNode()


select 
sink_path.getNode(), source_path, sink_path, "file read or write depends on $@. $@. $@.", 
source_path.getNode(), "path source",
source_content.getNode(), "content source",
sink_content.getNode(), "content sink"
