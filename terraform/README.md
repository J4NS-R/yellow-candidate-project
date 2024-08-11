# Terraform for this project

## Manual resources

- S3 bucket backend (already exists): `yellow-sandbox-s3-terraform-state`
- Identity Provider - GitHub: `arn:aws:iam::334550036524:oidc-provider/token.actions.githubusercontent.com`
- IAM Role for GitHub actions: `arn:aws:iam::334550036524:role/github-actions-jans-candidate-project`
- Terraform secrets: `arn:aws:secretsmanager:eu-west-1:334550036524:secret:jans-candidate-proj-terrasecrets-3YT8rq`

## Run

See [GH Action](../.github/workflows/terraform.yaml)

## Good to know

- Manually created resources are tagged with `Created-By: Jans`
- Terraform-created resources are tagged with `Project: jans-candidate-proj`
