# AWS credentials

Plugins that interact with AWS services fetch credentials from the following providers in order. Only the first provider that provides credentials is used.

- [Environment variables](#environment-variables)
- [Shared configuration and credentials files](#shared-configuration-and-credentials-files)
- [EKS Web Identity Token (OIDC)](#eks-web-identity-token-oidc)
- HTTP credentials endpoint, which serves the [ECS](#ecs-http-credentials-endpoint), [EKS Pod Identity](#eks-pod-identity-credentials), and [`AWS Greengrass`](#aws-greengrass-credentials) credentials. See [HTTP credentials endpoint addresses](#http-credentials-endpoint-addresses).
- [EC2 Instance Profile Credentials (IMDS)](#ec2-instance-profile-credentials-imds)

All AWS plugins additionally support a `role_arn` (or `AWS_ROLE_ARN`, for [Elasticsearch](../pipeline/outputs/elasticsearch.md)) configuration parameter. If specified, the fetched credentials are used to assume the given role.

## Environment variables

Plugins use the `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` (and optionally `AWS_SESSION_TOKEN`) environment variables if set.

## Shared configuration and credentials files

Plugins read the shared `config` file at `$AWS_CONFIG_FILE` (or `$HOME/.aws/config`), and the shared credentials file at `$AWS_SHARED_CREDENTIALS_FILE` (or `$HOME/.aws/credentials`)  to fetch the credentials for the profile named `$AWS_PROFILE` or `$AWS_DEFAULT_PROFILE` (or "default"). See [Configuration and credential file settings in the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html).

The shared settings evaluate in the following order:

| Setting | File | Description |
| --- | --- | --- |
| `credential_process` | `config` | Linux only. See [Sourcing credentials with an external process in the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sourcing-external.html). |
| `aws_access_key_id`, `aws_secret_access_key`, `aws_session_token` | `credentials` | Access key ID and secret key to use to authenticate. The session token must be set for temporary credentials. |

No other settings are supported.

## EKS web identity token (OIDC)

Credentials are fetched using a signed web identity token for a Kubernetes service account. See [IAM roles for service accounts](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html).

## ECS HTTP credentials endpoint

Credentials are fetched for the ECS task's role. See [Amazon ECS task IAM role](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-iam-roles.html).

## EKS Pod Identity credentials

Credentials are fetched using  a pod identity endpoint. See [Learn how EKS Pod Identity grants pods access to AWS services](https://docs.aws.amazon.com/eks/latest/userguide/pod-identities.html).

## EC2 instance profile credentials (IMDS)

Fetches credentials for the EC2 instance profile's role. See [IAM roles for Amazon EC2](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/iam-roles-for-amazon-ec2.html). As of Fluent Bit version 1.8.8, IMDSv2 is used by default and IMDSv1 might be disabled. Prior versions of Fluent Bit require enabling IMDSv1 on EC2.

## `AWS Greengrass` credentials

Fluent Bit fetches credentials from a localhost endpoint provided by the AWS IoT `Greengrass` token exchange service. The token exchange service runs as a local server on `Greengrass` core devices and provides AWS credentials through the `AWS_CONTAINER_CREDENTIALS_FULL_URI` and `AWS_CONTAINER_AUTHORIZATION_TOKEN` environment variables. For more information, see the AWS documentation about [Token exchange service](https://docs.aws.amazon.com/greengrass/v2/developerguide/token-exchange-service-component.html).

## HTTP credentials endpoint addresses

The [ECS](#ecs-http-credentials-endpoint), [EKS Pod Identity](#eks-pod-identity-credentials), and [`Greengrass`](#aws-greengrass-credentials) providers fetch credentials from an HTTP endpoint set in an environment variable. If `AWS_CONTAINER_CREDENTIALS_RELATIVE_URI` is set, Fluent Bit requests that path over HTTP from the ECS endpoint `169.254.170.2` on port `80`, and ignores `AWS_CONTAINER_CREDENTIALS_FULL_URI`. Otherwise, Fluent Bit uses the address in `AWS_CONTAINER_CREDENTIALS_FULL_URI`.

In v5.2 or later, Fluent Bit accepts `AWS_CONTAINER_CREDENTIALS_FULL_URI` only if it matches one of the following. The scheme must be lowercase.

- An `https` address with any host.
- An `http` address whose host is one of these IP addresses:
  - An IPv4 loopback address in `127.0.0.0/8`, or the IPv6 loopback address `::1`.
  - The ECS endpoint `169.254.170.2`.
  - The EKS Pod Identity endpoint `169.254.170.23` or `fd00:ec2::23`.
  - An IPv6 link-local address in `fe80::/10`, without a zone ID such as `%eth0`.
- An `http` address with the lowercase host `localhost` and exactly the path `/2016-11-01/credentialprovider/`, without a query string, which the `Greengrass` token exchange service uses. Fluent Bit connects to `127.0.0.1` so that `localhost` can't resolve to a different address.

Write IPv6 addresses in brackets, for example `[fd00:ec2::23]`. IPv4-mapped IPv6 addresses such as `::ffff:127.0.0.1` aren't accepted.

When the address isn't accepted, Fluent Bit skips this provider. In most cases, it logs an error that starts with `[aws credentials] AWS_CONTAINER_CREDENTIALS_FULL_URI must be set to an https:// address`, but an address that can't be parsed, such as an uppercase scheme without a port, is skipped without an error.

After skipping this provider, Fluent Bit continues to the [EC2 instance profile](#ec2-instance-profile-credentials-imds) provider, so on EC2 it can use the instance role instead of the task or pod role. Fluent Bit doesn't log which provider it uses at the default log level. After you change this variable, set `log_level` to `debug` and check for `Initialized ECS Provider in standard chain` to confirm that the HTTP provider is used. To prevent the fallback, restrict access to the instance metadata service from containers, for example by setting the IMDSv2 hop limit to `1`.

### Upgrade to v5.2

Versions before v5.2 checked only whether the host started with or contained an allowed address, so hosts such as `127.example.com` or `169.254.170.2.example.com`, IPv6 addresses with zone IDs, and short forms such as `127.1` were accepted. These addresses are rejected in v5.2 or later. If `AWS_CONTAINER_CREDENTIALS_FULL_URI` uses one of them, change it to an allowed IP address before you upgrade.

The default configurations of ECS (`AWS_CONTAINER_CREDENTIALS_RELATIVE_URI`), EKS Pod Identity (`169.254.170.23` or `[fd00:ec2::23]`), and the `Greengrass` token exchange service use accepted addresses and aren't affected.
