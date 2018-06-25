## Module: projects/infra-ses

Controls use of Amazon Simple Email Service
including SMTP credentials.


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| aws_environment | AWS Environment | string | - | yes |
| aws_region | AWS region | string | `eu-west-1` | no |
| email_send_domains | Domains we can send from | list | - | yes |
| stackname | Stackname | string | `` | no |

## Outputs

| Name | Description |
|------|-------------|
| smtp_password |  |
| smtp_username |  |

