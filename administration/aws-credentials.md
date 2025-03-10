# AWS Credentials

Plugins that interact with AWS services fetch credentials from the following providers
in order. Only the first provider that provides credentials is used.

- [Environment variables](#environment-variables)
- [Shared configuration and credentials files](#shared-configuration-and-credentials-files)
- [EKS Web Identity Token (OIDC)](#eks-web-identity-token-oidc)
- [ECS HTTP credentials endpoint](#ecs-http-credentials-endpoint)
- [EC2 Instance Profile Credentials (IMDS)](#ec2-instance-profile-credentials-imds)

All AWS plugins additionally support a `role_arn` (or `AWS_ROLE_ARN`, for
[Elasticsearch](../pipeline/outputs/elasticsearch.md)) configuration parameter. If
specified, the fetched credentials are used to assume the given role.

## Environment variables

Plugins use the `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` (and optionally
`AWS_SESSION_TOKEN`) environment variables if set.

## Shared configuration and credentials files

Plugins read the shared `config` file at `$AWS_CONFIG_FILE` (or `$HOME/.aws/config`),
and the shared credentials file at `$AWS_SHARED_CREDENTIALS_FILE` (or
`$HOME/.aws/credentials`)  to fetch the credentials for the profile named
`$AWS_PROFILE` or `$AWS_DEFAULT_PROFILE` (or "default"). See
[Configuration and credential file settings in the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html).

The shared settings evaluate in the following order:

| Setting | File | Description |
|---|---|---|
| `credential_process` | `config` | Linux only. See [Sourcing credentials with an external process in the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sourcing-external.html). |
| `aws_access_key_id`<br />`aws_secret_access_key`<br />`aws_session_token` | `credentials` | Access key ID and secret key to use to authenticate. The session token must be set for temporary credentials. |

No other settings are supported.

## EKS Web Identity Token (OIDC)

Credentials are fetched using a signed web identity token for a Kubernetes service account.
See [IAM roles for service accounts](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html).

## ECS HTTP credentials endpoint

Credentials are fetched for the ECS task's role. See
[Amazon ECS task IAM role](https://docs.aws.amazon.com/AmazonECS/latest/userguide/task-iam-roles.html).

## EKS Pod Identity credentials

Credentials are fetched using  a pod identity endpoint. See
[Learn how EKS Pod Identity grants pods access to AWS services](https://docs.aws.amazon.com/eks/latest/userguide/pod-identities.html).

## EC2 instance profile credentials (IMDS)

Fetches credentials for the EC2 instance profile's role. See
[IAM roles for Amazon EC2](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/iam-roles-for-amazon-ec2.html).
As of Fluent Bit version 1.8.8, IMDSv2 is used by default and IMDSv1 might be disabled.
Prior versions of Fluent Bit require enabling IMDSv1 on EC2.
