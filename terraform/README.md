# Terraform for this project

## Manual resources

- S3 bucket backend (already exists): `yellow-sandbox-s3-terraform-state`
- Identity Provider - GitHub: `arn:aws:iam::334550036524:oidc-provider/token.actions.githubusercontent.com`
- IAM Role for GitHub actions: `arn:aws:iam::334550036524:role/github-actions-jans-candidate-project`

## Run

```shell
tofu init
```
