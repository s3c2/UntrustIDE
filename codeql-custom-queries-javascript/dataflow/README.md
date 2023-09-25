# Dataflow Queries

The dataflow queries identify data flows from taint sources to taint sinks.  

Files are named as: [source]-to-[sink].ql  

The four taint sources are  
- workspace settings (config)
- file reads (fileRead)
- network responses (network)
- web servers (webServer)  

The three taint sinks are  
- shell commands (shell)
- eval (eval)
- file writes (fileWrite)

## Filters

The filters for the following are integrated into the corresponding queries.  
- file reads
- network response
- eval

Filters for the taint sink *file write* are implemented separately in [filter-file-write](./filter-file-write/). They identify flows to the filepath and content argument of a file write. Files are named as: [filepath]-[content].ql
