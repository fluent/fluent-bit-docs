# Azure

Azure output plugin allows to ingest your records into [Azure Log Analytics](https://azure.microsoft.com/en-us/services/log-analytics/) service.

To get more details about how to setup Azure Log Analytics, please refer to the following documentation: [Azure Log Analytics](https://docs.microsoft.com/en-us/azure/log-analytics/)

## Configuration Parameters

| Key | Description | default |
| :--- | :--- | :--- |
| Customer\_ID | Customer ID or WorkspaceID string. |  |
| Shared\_Key | The primary or the secondary Connected Sources client authentication key. |  |
| Log\_Type | The name of the event type. | fluentbit |
| Subscription\_ID | Azure Subscription ID (optional). | |
| Resource\_Group | Azure Resource Group Name (optional). | |
| Additional\_Providers | Additional Resource Providers (optional). | |

## Getting Started

In order to insert records into an Azure Log Analytics instance, you can run the plugin from the command line or through the configuration file:

### Command Line

The **azure** plugin, can read the parameters from the command line in two ways, through the **-p** argument \(property\), e.g:

```text
$ fluent-bit -i cpu -o azure -p customer_id=abc -p shared_key=def -m '*' -f 1
```

### Configuration File

In your main configuration file append the following _Input_ & _Output_ sections:

```text
[INPUT]
    Name  cpu

[OUTPUT]
    Name        azure
    Match       *
    Customer_ID abc
    Shared_Key  def
```

### Ressource Context Access Mode
To use this access mode you need to specifiy the subscription id, the resource group name , and if needed additional providers


```text
[INPUT]
    Name  cpu

[OUTPUT]
    Name        azure
    Match       *
    Customer_ID abc
    Shared_Key  def
    Subscription_ID 123-122-113
    Resource_Group test
```
Generated Resource ID
/subscriptions/123-122-113/resourcegroups/test 

```text
[INPUT]
    Name  cpu

[OUTPUT]
    Name        azure
    Match       *
    Customer_ID abc
    Shared_Key  def
    Subscription_ID 123-122-113
    Resource_Group test
    Addidtional_Providers providers/a/b
```
Generated Resource ID
/subscriptions/123-122-113/resourcegroups/test/providers/a/b 



For details see:
https://docs.microsoft.com/en-us/azure/azure-monitor/platform/design-logs-deployment#access-mode)
https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/template-functions-resource#resourceid


