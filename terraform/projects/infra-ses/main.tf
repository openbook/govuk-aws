/**
* ## Module: projects/infra-ses
*
* Controls use of Amazon Simple Email Service
* including SMTP credentials.
*/

variable "aws_region" {
  type        = "string"
  description = "AWS region"
  default     = "eu-west-1"
}

variable "aws_environment" {
  type        = "string"
  description = "AWS Environment"
}

variable "stackname" {
  type        = "string"
  description = "Stackname"
  default     = ""
}

variable "email_send_domains" {
  type        = "list"
  description = "Domains we can send from"
}

# Resources
# --------------------------------------------------------------

terraform {
  backend          "s3"             {}
  required_version = "= 0.11.7"
}

provider "aws" {
  region  = "${var.aws_region}"
  version = "1.14.0"
}

resource "aws_ses_domain_identity" "email_send_domain" {
  count  = "${length(var.email_send_domains)}"
  domain = "${element(var.email_send_domains, count.index)}"
}

resource "aws_iam_user" "ses_smtp_send_user" {
  name = "ses_smtp_send_user"
}

resource "aws_iam_access_key" "ses_smtp_send_user_key" {
  user = "${aws_iam_user.ses_smtp_send_user.name}"
}

resource "aws_iam_user_policy" "ses_smtp_send_user_policy" {
  name = "test"
  user = "${aws_iam_user.ses_smtp_send_user.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ses:SendRawEmail"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

output "smtp_username" {
  value = "${aws_iam_access_key.ses_smtp_send_user_key.id}"
}

output "smtp_password" {
  value = "${aws_iam_access_key.ses_smtp_send_user_key.ses_smtp_password}"
}
