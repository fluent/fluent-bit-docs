# Tensorflow

The _Tensorflow_ filter plugin allows running machine learning inference tasks on the records of data coming from input plugins or stream processors. This filter uses [Tensorflow Lite](https://www.tensorflow.org/lite/) as the inference engine, and requires Tensorflow Lite shared library to be present during build and at runtime.

Tensorflow Lite is a lightweight open source deep learning framework used for mobile and IoT applications. Tensorflow Lite only handles inference, not training. It loads pre-trained models (`.tflite` files) that are converted into Tensorflow Lite format (`FlatBuffer`). You can read more on converting [Tensorflow models](https://www.tensorflow.org/lite/convert).

The Tensorflow plugin for Fluent Bit has the following limitations:

- Currently supports single-input models
- Uses Tensorflow 2.3 header files

## Configuration parameters

The plugin supports the following configuration parameters:

| Key | Description | Default |
| :--- | :--- | :--- |
| `input_field` | Specify the name of the field in the record to apply inference on. | _none_ |
| `model_file` | Path to the model file (`.tflite`) to be loaded by Tensorflow Lite. | _none_ |
| `include_input_fields` | Include all input filed in filter's output. | `True` |
| `normalization_value` | Divide input values to `normalization_value`. | _none_ |

## Creating a Tensorflow Lite shared library

To create a Tensorflow Lite shared library:

1. Clone the [Tensorflow repository](https://github.com/tensorflow/tensorflow).
1. Install the [Bazel](https://bazel.build/) package manager.
1. Run the following command to create the shared library:

   ```shell
   bazel build -c opt //tensorflow/lite/c:tensorflowlite_c  # see https://github.com/tensorflow/tensorflow/tree/master/tensorflow/lite/c
   ```

   The script creates the shared library
   `bazel-bin/tensorflow/lite/c/libtensorflowlite_c.so`.
1. Copy the library to a location such as `/usr/lib` that can be used by Fluent Bit.

## Building Fluent Bit with Tensorflow filter plugin

The Tensorflow filter plugin is disabled by default. You must build Fluent Bit with the Tensorflow plugin enabled. In addition, it requires access to Tensorflow Lite header files to compile. Therefore, you must pass the address of the Tensorflow source code on your machine to the [build script](https://github.com/fluent/fluent-bit#build-from-scratch):

```shell
cmake -DFLB_FILTER_TENSORFLOW=On -DTensorflow_DIR=<AddressOfTensorflowSourceCode> ...
```

### Command line

If the Tensorflow plugin initializes correctly, it reports successful creation of the interpreter, and prints a summary of model's input and output types and dimensions.

The command:

```shell
fluent-bit -i mqtt -p 'tag=mqtt.data' -F tensorflow -m '*' -p 'input_field=image' -p 'model_file=/home/user/model.tflite' -p
```

produces an output like:

```text
'include_input_fields=false' -p 'normalization_value=255' -o stdout
[2020/08/04 20:00:00] [ info] Tensorflow Lite interpreter created!
[2020/08/04 20:00:00] [ info] [tensorflow] ===== input #1 =====
[2020/08/04 20:00:00] [ info] [tensorflow] type: FLOAT32  dimensions: {1, 224, 224, 3}
[2020/08/04 20:00:00] [ info] [tensorflow] ===== output #1 ====
[2020/08/04 20:00:00] [ info] [tensorflow] type: FLOAT32  dimensions: {1, 2}
```

### Configuration file

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
service:
    flush: 1
    daemon: off
    log_level: info

pipeline:
    inputs:
        - name: mqtt
          tag: mqtt.data

    filters:
        - name: tensorflow
          match: mqtt.data
          input_field: image
          model_file: /home/m/model.tflite
          include_input_fields: false
          normalization_value: 255

    outputs:
        - name: stdout
          match: '*'
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[SERVICE]
    Flush        1
    Daemon       Off
    Log_Level    info

[INPUT]
    Name mqtt
    Tag mqtt.data

[FILTER]
    Name tensorflow
    Match mqtt.data
    input_field image
    model_file /home/m/model.tflite
    include_input_fields false
    normalization_value 255

[OUTPUT]
    Name stdout
    Match *
```

{% endtab %}
{% endtabs %}
