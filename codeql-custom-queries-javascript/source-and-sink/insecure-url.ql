/**
 * @name VSCodeInsecureURL
 * @description exists insecure URL
 * @id js/my-vscode-url
 * @kind problem
 * @tags vscodeAPI
 */

import javascript


from 
DataFlow::Node source,
StringLiteral strlit, 
StringOps::Concatenation strconcat

where 
(strlit.getStringValue().matches("%http://%") and source = strlit.flow())
or
(strconcat.getAnOperand().getStringValue().matches("%http://%") and source = strconcat)

select
source, "source"