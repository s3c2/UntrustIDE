/////////////////////////////////
// this query requires preprocessing to identify a workspace configuration node
/////////////////////////////////import javascript

import javascript
import DataFlow::PathGraph

class Configuration extends TaintTracking::Configuration {
  Configuration() { this = "Configuration" }

  override predicate isSource(DataFlow::Node source) { any() }

  override predicate isSink(DataFlow::Node sink) { 
    exists(SystemCommandExecution shell | sink = shell.getACommandArgument()) 
  }
}

from 
Configuration cfg, 
DataFlow::PathNode source, 
DataFlow::PathNode sink

////////////////////////////////////////////////////////////
// if preprocessing identified a workspace configuration node
// the fileName can be replaced by the file where node was identified
// the getConfiguration_node can be replaced by the line where node was identified
////////////////////////////////////////////////////////////
where 
source.getNode().getFile().getStem().toString().matches("%fileName%")
and
source.getNode().getStartLine() = ${getConfiguration_node}
and
source.getNode().toString().matches("%vscode%")
and
cfg.hasFlowPath(source, sink)

select 
sink.getNode(), source, sink, "shell command depends on $@.", 
source.getNode(), "config"