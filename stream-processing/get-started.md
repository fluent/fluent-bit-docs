# Get started

| Concept | Description |
| :--- | :--- |
| Stream | A stream is a single flow of data being ingested by an input plugin. By default, each stream name is the name of its input plugin plus a number (for example, `tail.0`). You can use the `alias` property to change this name. |
| Task | A single execution unit. For example, a SQL query. |
| Results | After a stream processor runs a SQL query, results are generated. You can re-ingest these results back into the main Fluent Bit pipeline or redirect them to the standard output interface for debugging purposes. |
| Tag | Fluent Bit groups records and assigns tags to them. These tags define routing rules and can be used to apply stream processors to specific tags that match a pattern. |
| Match | Matching rules can use a wildcard to match specific records associated with a tag. |
