/**
 * @name VSCodeInsecureNetworkResponse
 * @description exists insecure network response
 * @id js/my-vscode-url
 * @kind problem
 * @tags vscodeAPI
 */

import javascript

class VSCodeWorkspaceConfig extends DataFlow::Node{
  VSCodeWorkspaceConfig(){
    exists( 
      DataFlow::ModuleImportNode mod, DataFlow::Node node, AstNode ast, Token ast_parent_token 
      | 
      mod.getPath() = "vscode" and
      mod.flowsTo(node) and
      ast = node.getAstNode().getParent() and
      ast_parent_token = ast.getParent().getAToken()
      and
      (
        (
          ast_parent_token.toString().matches("%fs%")
          and
          ast.getParent().getParent().getAToken().toString().matches("%readFile%")
        )
        or
        ast_parent_token.toString().matches("%getConfiguration%")
      )
      | 
      this = node)
  }
}

class URLToNetwork extends TaintTracking::Configuration {
  URLToNetwork() { this = "URLToNetwork" }

  override predicate isSource(DataFlow::Node source) {
    exists(FileSystemReadAccess src | source = src.getADataNode().getALocalSource())
    or
    exists(ClientRequest r | source = r.getAResponseDataNode())
    or
    exists(Http::RouteHandler rh | source = rh.getARequestNode())
    or
    exists(VSCodeWorkspaceConfig config, DataFlow::SourceNode src | 
      src.getFile() = config.getFile() and src.getStartLine() = config.getStartLine() |
      source = src)
    or
    exists(StringLiteral str | str.getStringValue().matches("%http://%") | source = str.flow())
    or
    exists(StringOps::Concatenation str | str.getAnOperand().getStringValue().matches("%http://%") |
      source = str
    )
  }

  override predicate isSink(DataFlow::Node sink) {
    exists(ClientRequest r | sink = r.getHost() or sink = r.getUrl())
  }
}

from 
URLToNetwork url,
DataFlow::PathNode source, 
DataFlow::PathNode sink

where
url.hasFlowPath(source, sink)

select sink, "network response source"


// check this on an extension that has this node