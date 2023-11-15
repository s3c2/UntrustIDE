/**
 * @name VSCodeFileRead
 * @description file read used to fetch data
 * @id js/my-vscode-file-read
 * @kind problem
 * @tags vscodeAPI
 */

import javascript

from 
FileSystemReadAccess read

select
read.getADataNode().getALocalSource(), "node"