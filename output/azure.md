# Azure Log Analytics

Azure output plugin allows to ingest your records into [Azure Log Analytics](https://azure.microsoft.com/en-us/services/log-analytics/) service.

To get more details about how to setup the Azure Log Analytics please refer to the following documentation: [Azure Log Analytics](https://docs.microsoft.com/en-us/azure/log-analytics/)

## Configuration Parameters

| Key         | Description                                                  | default   |
| ----------- | ------------------------------------------------------------ | --------- |
| Customer_ID | Customer ID or WorkspaceID string.                           |           |
| Shared_Key  | The primary or the secondary Connected Sources client authentication key. |           |
| Log_Type    | The name of the event type.                                  | fluentbit |

## Getting Started

In order to insert records into a Azure, you can run the plugin from the command line or through the configuration file:

### Command Line

The **azure** plugin, can read the parameters from the command line in two ways, through the **-p** argument (property), e.g:

```
$ fluent-bit -i cpu -o azure -p customer_id=abc -p shared_key=def -m '*' -f 1
```

### Configuration File

In your main configuration file append the following *Input* & *Output* sections:

```
[INPUT]
    Name  cpu

[OUTPUT]
    Name        azure
    Match       *
    Customer_ID abc
    Shared_Key  def
    
```
