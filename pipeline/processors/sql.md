# Structured Query Language (SQL)

The **sql** processor provides a simple interface to select content from Logs by also supporting conditional expressions.

<img referrerpolicy="no-referrer-when-downgrade" src="https://static.scarf.sh/a.png?x-pxid=6bd80893-c66f-4950-9e6d-c21358e9e8c9" />

Our SQL processor does not depend on a database or indexing; it runs everything on the fly (this is good). We don't have the concept of tables but you run the query on the STREAM.

Note that this processor differs from the "stream processor interface" that runs after the filters; this one can only be used in the processor's section of the input plugins when using YAML configuration mode.

## Configuration Parameters

| Key         | Description |
| :---------- | :--- |
| query | Define the SQL statement to run on top of the Logs stream; it must end with `;` . |



### Simple selection example

The following example generates a sample message with two keys called `key` and `http.url`. By using a simple SQL statement we will select only the key `http.url`. 

```yaml
pipeline:
  inputs:
    - name: dummy
      dummy: '{"key1": "123.4", "http.url": "https://fluentbit.io/search?q=docs"}'

      processors:
        logs:
          - name: sql
            query: "SELECT http.url FROM STREAM;"

  outputs:
    - name : stdout
      match: '*'
      format: json_lines
```

### Extract and select example

Similar to the example above, now we will extract the parts of `http.url` and only select the domain from the value, for that we will use together content-modifier and sql processors together:

```yaml
pipeline:
  inputs:
    - name: dummy
      dummy: '{"key1": "123.4", "http.url": "https://fluentbit.io/search?q=docs"}'

      processors:
        logs:
          - name: content_modifier
            action: extract
            key: "http.url"
            pattern: ^(?<http_protocol>https?):\/\/(?<http_domain>[^\/\?]+)(?<http_path>\/[^?]*)?(?:\?(?<http_query_params>.*))?

          - name: sql
            query: "SELECT http_domain FROM STREAM;"

  outputs:
    - name : stdout
      match: '*'
      format: json_lines
```

the expected output of this pipeline will be something like this:

```json
{
  "date": 1711059261.630668,
  "http_domain": "fluentbit.io"
}
```

