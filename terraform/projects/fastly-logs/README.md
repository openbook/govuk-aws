## Project: fastly-logs

Manages the Fastly logging data which is sent from Fastly to S3.


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| aws_environment | AWS Environment | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| logs_writer_bucket_policy_arn | ARN of the logs writer bucket policy |

