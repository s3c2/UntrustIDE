/**
 * @name VSCodeWorkspaceSettingAPI
 * @description workspace setting api used to fetch data
 * @id js/my-vscode-workspace-setting
 * @kind problem
 * @tags vscodeAPI
 */

 import javascript


 from 
 DataFlow::ModuleImportNode mod,
 DataFlow::Node node,
 AstNode ast,
 Token ast_parent_token
 
 
 where 
 mod.getPath() = "vscode"
 and
 mod.flowsTo(node)
 and
 (
   node.getAstNode().getParent().getAToken().toString().matches("%workspace%")
   or
   node.getAstNode().getParent().getAToken().toString().matches("%tasks%")
 )
 and
 ast = node.getAstNode().getParent()
 and
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
 
 
 select 
 
 node, "vscode workspace setting api node"
 
 
 
 