import javascript

class VSCodeWorkspaceConfig extends DataFlow::Node{
  VSCodeWorkspaceConfig(){
    exists( 
      DataFlow::ModuleImportNode mod, DataFlow::Node node, AstNode ast, Token ast_parent_token | 
      mod.getPath() = "vscode" and
      mod.flowsTo(node) and
      ast = node.getAstNode().getParent() and
      ast_parent_token = ast.getParent().getAToken()
      and ast_parent_token.toString().matches("%getConfiguration%") | 
      this = node)
  }
}