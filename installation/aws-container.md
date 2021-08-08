# Containers on AWS

AWS maintains a distribution of Fluent Bit combining the latest official release with a set of Go Plugins for sending logs to AWS services. AWS and Fluent Bit are working together to rewrite their plugins for inclusion in the official Fluent Bit distribution.

## Plugins
Currently, the [AWS for Fluent Bit](https://github.com/aws/aws-for-fluent-bit) image contains Go Plugins for:

* [Amazon CloudWatch Logs](https://github.com/aws/amazon-cloudwatch-logs-for-fluent-bit)
* [Amazon Kinesis Firehose](https://github.com/aws/amazon-kinesis-firehose-for-fluent-bit)
* [Amazon Kinesis Streams](https://github.com/aws/amazon-kinesis-streams-for-fluent-bit)

Fluent Bit includes Amazon CloudWatch Logs plugin named `cloudwatch_logs`, Amazon Kinesis Firehose plugin named `kinesis_firehose` and Amazon Kinesis Data Streams plugin named `kinesis_streams` which are higher performance than Go plugins.

* [Amazon CloudWatch](https://docs.fluentbit.io/manual/pipeline/outputs/cloudwatch)
* [Amazon Kinesis Data Firehose](https://docs.fluentbit.io/manual/pipeline/outputs/firehose)
* [Amazon Kinesis Data Streams](https://docs.fluentbit.io/manual/pipeline/outputs/kinesis)

Also, Fluent Bit includes S3 output plugin named `s3`.
* [Amazon S3](https://docs.fluentbit.io/manual/pipeline/outputs/s3)

## Versions and Regional Repositories

AWS vends their container image via [Docker Hub](https://hub.docker.com/r/amazon/aws-for-fluent-bit), and a set of highly available regional Amazon ECR repositories. For more information, see the [AWS for Fluent Bit GitHub repo](https://github.com/aws/aws-for-fluent-bit#public-images).

The AWS for Fluent Bit image uses a custom versioning scheme because it contains multiple projects. To see what each release contains, check out the [release notes on GitHub](https://github.com/aws/aws-for-fluent-bit/releases).

## SSM Public Parameters

AWS vends SSM Public Parameters with the regional repository link for each image. These parameters can be queried by any AWS account.

To see a list of available version tags in a given region, run the following command:

```text
aws ssm get-parameters-by-path --region eu-central-1 --path /aws/service/aws-for-fluent-bit/ --query 'Parameters[*].Name'
```

To see the ECR repository URI for a given image tag in a given region, run the following:

```text
$ aws ssm get-parameter --region ap-northeast-1 --name /aws/service/aws-for-fluent-bit/2.0.0
```

You can use these SSM public parameters as parameters in your CloudFormation templates:

```text
Parameters:
  FireLensImage:
    Description: Fluent Bit image for the FireLens Container
    Type: AWS::SSM::Parameter::Value<String>
    Default: /aws/service/aws-for-fluent-bit/latest
```

