# Slack

The Slack output plugin delivers records or messages to your preferred Slack channel. It formats the outgoing content in JSON format for readability.

This connector uses Slack [incoming webhooks](https://docs.slack.dev/messaging/sending-messages-using-incoming-webhooks) to post messages to Slack channels. Using this plugin in conjunction with the Stream Processor is a good combination for alerting.

## Slack webhook

Before configuring this plugin, set up your incoming webhook. For help, see the [Slack documentation](https://docs.slack.dev/messaging/sending-messages-using-incoming-webhooks).

After you have obtained the Webhook address you can place it in the configuration.

## Configuration parameters

This plugin supports the following parameters:

| Key     | Description | Default |
|:--------|:------------|:--------|
| `webhook` | Absolute address of the webhook provided by Slack. | _none_ |
| `workers` | The number of [workers](../../administration/multithreading.md#outputs) to perform flush operations for this output. | `0` |

### Configuration file

Get started with this configuration file:

{% tabs %}
{% tab title="fluent-bit.yaml" %}

```yaml
pipeline:

  outputs:
    - name: slack
      match: '*'
      webhook: https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX
```

{% endtab %}
{% tab title="fluent-bit.conf" %}

```text
[OUTPUT]
    name                 slack
    match                *
    webhook              https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX
```

{% endtab %}
{% endtabs %}
