# Tensorflow

## Tensorflow

_Tensorflow Filter_ allows running Machine Learning inference tasks on the records of data coming from input plugins or stream processor. This filter uses [Tensorflow Lite](https://www.tensorflow.org/lite/) as the inference engine, and **requires Tensorflow Lite shared library to be present during build and at runtime**.

Tensorflow Lite is a lightweight open-source deep learning framework that is used for mobile and IoT applications. Tensorflow Lite only handles inference \(not training\), therefore, it loads pre-trained models \(`.tflite` files\) that are converted into Tensorflow Lite format \(`FlatBuffer`\). You can read more on converting Tensorflow models [here](https://www.tensorflow.org/lite/convert)

### Configuration Parameters

The plugin supports the following configuration parameters:

| Key | Description | Default |
| :--- | :--- | :--- |
| input\_field | Specify the name of the field in the record to apply inference on. |  |
| model\_file | Path to the model file \(`.tflite`\) to be loaded by Tensorflow Lite. |  |
| include\_input\_fields | Include all input filed in filter's output | True |
| normalization\_value | Divide input values to normalization\_value |  |

### Creating Tensorflow Lite shared library

Clone [Tensorflow repository](https://github.com/tensorflow/tensorflow), install bazel package manager, and run the following command in order to create the shared library:

```bash
$ bazel build -c opt //tensorflow/lite/c:tensorflowlite_c  # see https://github.com/tensorflow/tensorflow/tree/master/tensorflow/lite/c
```

The script creates the shared library `bazel-bin/tensorflow/lite/c/libtensorflowlite_c.so`. You need to copy the library to a location \(such as `/usr/lib`\) that can be used by Fluent Bit.

### Building Fluent Bit with Tensorflow filter plugin

Tensorflow filter plugin is disabled by default. You need to build Fluent Bit with Tensorflow plugin enabled. In addition, it requires access to Tensorflow Lite header files to compile. Therefore, you also need to pass the address of the Tensorflow source code on your machine to the [build script](https://github.com/fluent/fluent-bit#build-from-scratch):

```bash
cmake -DFLB_FILTER_TENSORFLOW=On -DTensorflow_DIR=<AddressOfTensorflowSourceCode> ...
```

#### Command line

If Tensorflow plugin initializes correctly, it reports successful creation of the interpreter, and prints a summary of model's input/output types and dimensions.

```bash
$ bin/fluent-bit -i mqtt -p 'tag=mqtt.data' -F tensorflow -m '*' -p 'input_field=image' -p 'model_file=/home/user/model.tflite' -p 'include_input_fields=false' -p 'normalization_value=255' -o stdout
[2020/08/04 20:00:00] [ info] Tensorflow Lite interpreter created!
[2020/08/04 20:00:00] [ info] [tensorflow] ===== input #1 =====
[2020/08/04 20:00:00] [ info] [tensorflow] type: FLOAT32  dimensions: {1, 224, 224, 3}
[2020/08/04 20:00:00] [ info] [tensorflow] ===== output #1 ====
[2020/08/04 20:00:00] [ info] [tensorflow] type: FLOAT32  dimensions: {1, 2}
```

#### Configuration File

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

## Limitations

1. Currently supports single-input models
2. Uses Tensorflow 2.3 header files

