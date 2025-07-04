# Content Modifier

The **content_modifier** processor allows you to manipulate the messages, metadata/attributes and content of Logs and Traces.

Similar to the functionality exposed by filters, this processor presents a unified mechanism to perform such operations for data manipulation. The most significant difference is that processors perform better than filters, and when chaining them, there are no encoding/decoding performance penalties.

{% hint style="info" %}

**Note:** Both processors and this specific component can be enabled only by using
the YAML configuration format. Classic mode configuration format doesn't support processors.

{% endhint %}

## Contexts

The processor, works on top of what we call a __context__, meaning _the place_ where the content modification will happen. We provide different contexts to manipulate the desired information, the following contexts are available:

| Context Name | Signal | Description |
| -- | -- | -- |
| `attributes` | Logs | Modify the attributes or metadata of a Log record. |
| `body` | Logs | Modify the content of a Log record. |
| `span_name` | Traces | Modify the name of a Span. |
| `span_kind` | Traces | Modify the kind of a Span. |
| `span_status` | Traces | Modify the status of a Span. |
| `span_attributes` | Traces | Modify the attributes of a Span. |


### OpenTelemetry Contexts

In addition, we provide special contexts to operate on data that follows an __OpenTelemetry Log Schema__, all of them operates on shared data across a group of records:

| Context Name | Signal | Description |
| -- | -- | -- |
| `otel_resource_attributes` | Logs | Modify the attributes of the Log Resource. |
| `otel_scope_name` | Logs | Modify the name of a Log Scope. |
| `otel_scope_version` | Logs | Modify version of a Log Scope. |
| `otel_scope_attributes` | Logs | Modify the attributes of a Log Scope. |

> TIP: if your data is not following the OpenTelemetry Log Schema and your backend or destination for your logs expects to be in an OpenTelemetry schema, take a look at the processor called OpenTelemetry Envelope that you can use in conjunbction with this processor to transform your data to be compatible with OpenTelemetry Log schema.

## Configuration Parameters

| Key         | Description |
| :---------- | :--- |
| context | Specify the context where the modifications will happen (more details above).The following contexts are available:  `attributes`, `body`, `span_name`, `span_kind`, `span_status`, `span_attributes`, `otel_resource_attributes`, `otel_scope_name`, `otel_scope_version`, `otel_scope_attributes`. |
| key | Specify the name of the key that will be used to apply the modification. |
| value | Based on the action type, `value` might required and represent different things. Check the detailed information for the specific actions. |
| pattern | Defines a regular expression pattern. This property is only used by the `extract` action. |
| converted_type | Define the data type to perform the conversion, the available options are: `string`, `boolean`, `int` and `double` . |

### Actions

The actions specify the type of operation to run on top of a specific key or content from a Log or a Trace. The following actions are available:

| Action  | Description                                                  |
| ------- | ------------------------------------------------------------ |
| `insert`  | Insert a new key with a value into the target context. The `key` and `value` parameters are required. |
| `upsert`  | Given a specific key with a value, the `upsert` operation will try to update the value of the key. If the key does not exist, the key will be created. The `key` and `value` parameters are required. |
| `delete`  | Delete a key from the target context. The `key` parameter is required. |
| `rename`  | Change the name of a key. The `value` set in the configuration will represent the new name. The `key` and `value` parameters are required. |
| `hash`    | Replace the key value with a hash generated by the SHA-256 algorithm, the binary value generated is finally set as an hex string representation. The `key` parameter is required. |
| `extract` | Allows to extact the value of a single key as a list of key/value pairs. This action needs the configuration of a regular expression in the  `pattern` property . The `key` and `pattern` parameters are required.  For more details check the examples below. |
| `convert` | Convert the data type of a key value. The `key` and `converted_type` parameters are required. |

#### Insert example

The following example appends the key `color` with the value `blue` to the log stream.

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
    inputs:
        - name: dummy
          dummy: '{"key1": "123.4"}'

          processors:
              logs:
                  - name: content_modifier
                    action: insert
                    key: "color"
                    value: "blue"
            
    outputs:
        - name : stdout
          match: '*'
          format: json_lines
```

{% endtab %}
{% endtabs %}

#### Upsert example

Update the value of `key1` and insert `key2`:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
    inputs:
        - name: dummy
          dummy: '{"key1": "123.4"}'

          processors:
              logs:
                  - name: content_modifier
                    action: upsert
                    key: "key1"
                    value: "5678"

                  - name: content_modifier
                    action: upsert
                    key: "key2"
                    value: "example"

    outputs:
        - name : stdout
          match: '*'
          format: json_lines
```

{% endtab %}
{% endtabs %}

#### Delete example

Delete `key2` from the stream:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
    inputs:
        - name: dummy
          dummy: '{"key1": "123.4", "key2": "example"}'

          processors:
              logs:
                  - name: content_modifier
                    action: delete
                    key: "key2"

    outputs:
        - name : stdout
          match: '*'
          format: json_lines
```

{% endtab %}
{% endtabs %}

#### Rename example

Change the name of `key2` to `test`:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
    inputs:
        - name: dummy
          dummy: '{"key1": "123.4", "key2": "example"}'

          processors:
              logs:
                  - name: content_modifier
                    action: rename
                    key: "key2"
                    value: "test"

    outputs:
        - name : stdout
          match: '*'
          format: json_lines
```

{% endtab %}
{% endtabs %}

#### Hash example

Apply the SHA-256 algorithm for the value of the key `password`:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
    inputs:
        - name: dummy
          dummy: '{"username": "bob", "password": "12345"}'

          processors:
              logs:
                  - name: content_modifier
                    action: hash
                    key: "password"

    outputs:
        - name : stdout
          match: '*'
          format: json_lines
```

{% endtab %}
{% endtabs %}

#### Extract example

By using a domain address, perform a extraction of the components of it as a list of key value pairs:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
    inputs:
        - name: dummy
          dummy: '{"http.url": "https://fluentbit.io/docs?q=example"}'

          processors:
              logs:
                  - name: content_modifier
                    action: extract
                    key: "http.url"
                    pattern: ^(?<http_protocol>https?):\/\/(?<http_domain>[^\/\?]+)(?<http_path>\/[^?]*)?(?:\?(?<http_query_params>.*))?

    outputs:
        - name : stdout
          match: '*'
          format: json_lines
```

{% endtab %}
{% endtabs %}

#### Convert example

Both keys in the example are strings. Convert the `key1` to a double/float type and `key2` to a boolean:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:
    inputs:
        - name: dummy
          dummy: '{"key1": "123.4", "key2": "true"}'

          processors:
              logs:
                  - name: content_modifier
                    action: convert
                    key: key1
                    converted_type: int

                  - name: content_modifier
                    action: convert
                    key: key2
                    converted_type: boolean

    outputs:
        - name : stdout
          match: '*'
          format: json_lines
```

{% endtab %}
{% endtabs %}