/**
 * @name VSCodeFileWriteAPI
 * @description file write api used
 * @id js/my-vscode-filewrite
 * @kind problem
 * @tags vscodeAPI
 */

import javascript

from FileSystemWriteAccess write

select 
write.getAPathArgument(), "path",
write.getADataNode(), "content"