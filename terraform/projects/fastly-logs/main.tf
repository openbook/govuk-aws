/**
* ## Project: fastly-logs
*
* Manages the Fastly logging data which is sent from Fastly to S3.
*/

variable "aws_environment" {
  type        = "string"
  description = "AWS Environment"
}

# Resources
# --------------------------------------------------------------
terraform {
  backend          "s3"             {}
  required_version = "= 0.11.7"
}

resource "aws_s3_bucket" "fastly_logs" {
  bucket = "fastly-logs-${var.aws_environment}"

  tags {
    Name            = "fastly-logs-${var.aws_environment}"
    aws_environment = "${var.aws_environment}"
  }

  logging {
    target_bucket = "${data.terraform_remote_state.infra_monitoring.aws_logging_bucket_id}"
    target_prefix = "s3/fastly-logs-${var.aws_environment}/"
  }
}

# We require a user for Fastly to write to S3 buckets
resource "aws_iam_user" "logs_writer" {
  name = "govuk-${var.aws_environment}-fastly-logs-writer"
}

resource "aws_iam_policy" "logs_writer" {
  name        = "fastly-logs-${var.aws_environment}-logs-writer-policy"
  policy      = "${data.template_file.logs_writer_policy_template.rendered}"
  description = "Allows writing to to the fastly-logs bucket"
}

resource "aws_iam_policy_attachment" "logs_writer" {
  name       = "logs-writer-policy-attachment"
  users      = ["${aws_iam_user.logs_writer.name}"]
  policy_arn = "${aws_iam_policy.logs_writer.arn}"
}

data "template_file" "logs_writer_policy_template" {
  template = "${file("${path.module}/../../policies/fastly_logs_writer_policy.tpl")}"

  vars {
    aws_environment = "${var.aws_environment}"
    govuk_bucket = "${aws_s3_bucket.fastly_logs.id}"
  }
}

resource "aws_glue_catalog_database" "fastly_logs" {
  name = "FastlyLogs"
}

resource "aws_iam_role" "glue" {
  name        = "AWSGlueServiceRole-fastly-logs"
  description = "Role to allow glue access to S3 for fastly logs"
  path        = "/service-role/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "glue.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "glue_service" {
    role = "${aws_iam_role.glue.id}"
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy" "fastly_logs_policy" {
  name = "fastly-logs-${var.aws_environment}-logs-glue-policy"
  role = "${aws_iam_role.glue.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "arn:aws:s3:::${aws_s3_bucket.fastly_logs.id}"
        "arn:aws:s3:::${aws_s3_bucket.fastly_logs.id}/*"
      ]
    }
  ]
}
EOF
}

resource "aws_glue_crawler" "govuk" {
  database_name = "${aws_glue_catalog_database.fastly_logs.name}"
  name          = "Fastly logs for GOV.UK"
  role          = "${aws_iam_role.fastly_logs.name}"
  schedule      = "30 0 * * ? *"

  s3_target {
    path = "s3://${aws_s3_bucket.fastly_govuk.bucket}/govuk"
  }
}

# Then similar crawlers for bouncer and assets

# Outputs
# --------------------------------------------------------------

output "logs_writer_bucket_policy_arn" {
  value       = "${aws_iam_policy.logs_writer.arn}"
  description = "ARN of the logs writer bucket policy"
}
