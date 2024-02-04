# Konnect Control Plane Fargate Example

Consolidating control plane installations and deployments, with deployments on AWS Fargate.

## Setup Instructions

### 1. Konnect PAT

Create a Konnect [system account](https://docs.konghq.com/konnect/org-management/system-accounts/) with these roles:

* `Control Plane Admin`

Get its token, and store it in AWS Secrets Manager

### 2. GitHub Actions Runner IAM Permissions

#### Secrets

Give the GitHub Actions instance IAM Role these permissions on the new secret:

* `secretsmanager:GetSecretValue`

If your secrets are encrypted with a KMS key, give the instance IAM Role this permission on the key:

* `kms:Decrypt`

**If your secrets (and/or KMS keys) are in a different account, don't forget to update the on-resource policy to reflect this too.**

### 3. Settings

Inside the [plan.yml workflow](.github/workflows/plan.yml), and the [apply.yml workflow](.github/workflows/apply.yml), change the settings in the "env" section accordingly, like this example:

```yaml
env:
  AWS_REGION: eu-west-1
  KONNECT_PAT_SECRET_ARN: "arn:aws:secretsmanager:eu-west-1:123456789012:secret:jack/demos/cp-sync-token-vMFbyJ"  # if none is provided, KONNECT_TOKEN env var will be used.
  KONNECT_REGION: "eu"  # or "us" or "au"
```
