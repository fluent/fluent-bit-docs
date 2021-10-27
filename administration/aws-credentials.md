# AWS Credentials

Plugins that interact with AWS services will fetch credentials from various providers in the following order.
Only the first provider that is able to provide credentials will be used.

All AWS plugins additionally support a `role_arn` (or `AWS_ROLE_ARN`, for [Elasticsearch](../pipeline/outputs/elasticsearch.md)) configuration parameter. If specified, the fetched credentials will then be used to assume the given role.

## 1. Environment Variables

Uses the `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` (and optionally `AWS_SESSION_TOKEN`) environment variables if set.

## 2. Shared Configuration and Credentials Files

Reads the shared config file at `$AWS_CONFIG_FILE` (or `$HOME/.aws/config`) and the shared credentials file at `$AWS_SHARED_CREDENTIALS_FILE` (or `$HOME/.aws/credentials`) to fetch the credentials for the profile named `$AWS_PROFILE` or `$AWS_DEFAULT_PROFILE` (or "default"). See https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html.

The shared settings will be evaluated in the following order.

Setting|File|Description
---|---|---
`credential_process`|config| See https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sourcing-external.html.<br/>Supported on Linux only.
`aws_access_key_id`<br/>`aws_secret_access_key`<br/>*`aws_session_token`*|credentials|Access key ID and secret key to use to authenticate.<br/>The session token must be set for temporary credentials.

At this time, no other settings are supported.

## 3. EKS Web Identity Token (OIDC)

Fetches credentials via a signed web identity token for a Kubernetes service account.
See https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html.

## 4. ECS HTTP Credentials Endpoint

Fetches credentials for the ECS task's role.
See https://docs.aws.amazon.com/AmazonECS/latest/userguide/task-iam-roles.html.

## 5. EC2 Instance Profile Credentials (IMDS)

Fetches credentials for the EC2 instance profile's role.
See https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/iam-roles-for-amazon-ec2.html.
As of Fluent Bit version 1.8.8, IMDSv2 is used by default and IMDSv1 may be disabled. Prior versions of Fluent Bit require enabling IMDSv1 on EC2.