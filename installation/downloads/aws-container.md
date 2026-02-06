# Containers on AWS

AWS maintains a distribution of Fluent Bit that combines the latest official release with a set of Go Plugins for sending logs to AWS services. AWS and Fluent Bit are working together to rewrite their plugins for inclusion in the official Fluent Bit distribution.

## Plugins

The [AWS for Fluent Bit](https://github.com/aws/aws-for-fluent-bit) image contains Go Plugins for:

- Amazon CloudWatch as `cloudwatch_logs`. See the
  [Fluent Bit docs](../../pipeline/outputs/cloudwatch) or the
  [Plugin repository](https://github.com/aws/amazon-cloudwatch-logs-for-fluent-bit).
- Amazon Kinesis Data Firehose as `kinesis_firehose`. See the
  [Fluent Bit docs](../../pipeline/outputs/firehose) or the
  [Plugin repository](https://github.com/aws/amazon-kinesis-firehose-for-fluent-bit).
- Amazon Kinesis Data Streams as `kinesis_streams`. See the
  [Fluent Bit docs](../../pipeline/outputs/kinesis) or the
  [Plugin repository](https://github.com/aws/amazon-kinesis-streams-for-fluent-bit).

These plugins are higher performance than Go plugins.

Also, Fluent Bit includes an S3 output plugin named `s3`.

- [Amazon S3](../../pipeline/outputs/s3)

## Versions and regional repositories

AWS vends their container image using [Docker Hub](https://hub.docker.com/r/amazon/aws-for-fluent-bit), and a set of highly available regional Amazon ECR repositories. For more information, see the [AWS for Fluent Bit GitHub repository](https://github.com/aws/aws-for-fluent-bit#public-images).

The AWS for Fluent Bit image uses a custom versioning scheme because it contains multiple projects. To see what each release contains, see the [release notes on GitHub](https://github.com/aws/aws-for-fluent-bit/releases).

## SSM public parameters

AWS vends SSM public parameters with the regional repository link for each image. These parameters can be queried by any AWS account.

To see a list of available version tags in a given region, run the following command:

```shell
aws ssm get-parameters-by-path --region eu-central-1 --path /aws/service/aws-for-fluent-bit/ --query 'Parameters[*].Name'
```

To see the ECR repository URI for a given image tag in a given region, run the following:

```shell
aws ssm get-parameter --region ap-northeast-1 --name /aws/service/aws-for-fluent-bit/2.0.0
```

You can use these SSM public parameters as parameters in your CloudFormation templates:

```text
Parameters:
  FireLensImage:
    Description: Fluent Bit image for the FireLens Container
    Type: AWS::SSM::Parameter::Value<String>
    Default: /aws/service/aws-for-fluent-bit/latest
```
