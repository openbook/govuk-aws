/**
* ## Project: app-elasticsearch5
*
* Managed Elasticsearch 5 cluster
*/
variable "aws_environment" {
  type        = "string"
  description = "AWS Environment"
}

variable "aws_region" {
  type        = "string"
  description = "AWS region"
  default     = "eu-west-1"
}

variable "stackname" {
  type        = "string"
  description = "Stackname"
}

variable "elasticsearch5_instance_type" {
  type        = "string"
  description = "The instance type of the individual ElasticSearch nodes, only instances which allow EBS volumes are supported"
  default     = "r4.large.elasticsearch"
}

variable "elasticsearch5_instance_count" {
  type        = "string"
  description = "The number of ElasticSearch nodes"
  default     = "3"
}

variable "elasticsearch5_dedicated_master_enabled" {
  type        = "string"
  description = "Indicates whether dedicated master nodes are enabled for the cluster"
  default     = "true"
}

variable "elasticsearch5_master_instance_type" {
  type        = "string"
  description = "Instance type of the dedicated master nodes in the cluster"
  default     = "c4.large.elasticsearch"
}

variable "elasticsearch5_master_instance_count" {
  type        = "string"
  description = "Number of dedicated master nodes in the cluster"
  default     = "3"
}

variable "elasticsearch5_ebs_encrypt" {
  type        = "string"
  description = "Whether to encrypt the EBS volume at rest"
}

variable "elasticsearch5_ebs_type" {
  type        = "string"
  description = "The type of EBS storage to attach"
  default     = "gp2"
}

variable "elasticsearch5_ebs_size" {
  type        = "string"
  description = "The amount of EBS storage to attach"
  default     = 32
}

variable "elasticsearch5_snapshot_start_hour" {
  type        = "string"
  description = "The hour in which the daily snapshot is taken"
  default     = 1
}

variable "elasticsearch_subnet_names" {
  type        = "list"
  description = "Names of the subnets to place the ElasticSearch domain in"
}

variable "cloudwatch_log_retention" {
  type        = "string"
  description = "Number of days to retain Cloudwatch logs for"
  default     = 90
}

# Resources
# --------------------------------------------------------------
terraform {
  backend          "s3"             {}
  required_version = "= 0.11.7"
}

provider "aws" {
  region  = "${var.aws_region}"
  version = "1.40.0"
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "elasticsearch5_log_publishing_policy" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:PutLogEventsBatch",
    ]

    resources = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/aes/domains/${var.stackname}-elasticsearch5-domain/*"]

    principals {
      identifiers = ["es.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_service_linked_role" "role" {
  aws_service_name = "es.amazonaws.com"
}

resource "aws_cloudwatch_log_group" "elasticsearch5_application_log_group" {
  name              = "/aws/aes/domains/${var.stackname}-elasticsearch5-domain/application-logs"
  retention_in_days = "${var.cloudwatch_log_retention}"
}

resource "aws_cloudwatch_log_group" "elasticsearch5_search_log_group" {
  name              = "/aws/aes/domains/${var.stackname}-elasticsearch5-domain/search-logs"
  retention_in_days = "${var.cloudwatch_log_retention}"
}

resource "aws_cloudwatch_log_group" "elasticsearch5_index_log_group" {
  name              = "/aws/aes/domains/${var.stackname}-elasticsearch5-domain/index-logs"
  retention_in_days = "${var.cloudwatch_log_retention}"
}

resource "aws_cloudwatch_log_resource_policy" "elasticsearch5_log_resource_policy" {
  policy_name     = "elasticsearch5_log_resource_policy"
  policy_document = "${data.aws_iam_policy_document.elasticsearch5_log_publishing_policy.json}"
}

module "elasticsearch5_application_log_exporter" {
  source                       = "../../modules/aws/cloudwatch_log_exporter"
  log_group_name               = "${aws_cloudwatch_log_group.elasticsearch5_application_log_group.name}"
  firehose_role_arn            = "${data.terraform_remote_state.infra_monitoring.firehose_logs_role_arn}"
  firehose_bucket_arn          = "${data.terraform_remote_state.infra_monitoring.aws_logging_bucket_arn}"
  firehose_bucket_prefix       = "elasticsearch5/application-logs"
  lambda_filename              = "../../lambda/ElasticsearchLogsToFirehose/ElasticsearchLogsToFirehose.zip"
  lambda_role_arn              = "${data.terraform_remote_state.infra_monitoring.lambda_logs_role_arn}"
  lambda_log_retention_in_days = "${var.cloudwatch_log_retention}"
}

module "elasticsearch5_search_log_exporter" {
  source                       = "../../modules/aws/cloudwatch_log_exporter"
  log_group_name               = "${aws_cloudwatch_log_group.elasticsearch5_search_log_group.name}"
  firehose_role_arn            = "${data.terraform_remote_state.infra_monitoring.firehose_logs_role_arn}"
  firehose_bucket_arn          = "${data.terraform_remote_state.infra_monitoring.aws_logging_bucket_arn}"
  firehose_bucket_prefix       = "elasticsearch5/search-logs"
  lambda_filename              = "../../lambda/ElasticsearchLogsToFirehose/ElasticsearchLogsToFirehose.zip"
  lambda_role_arn              = "${data.terraform_remote_state.infra_monitoring.lambda_logs_role_arn}"
  lambda_log_retention_in_days = "${var.cloudwatch_log_retention}"
}

module "elasticsearch5_index_log_exporter" {
  source                       = "../../modules/aws/cloudwatch_log_exporter"
  log_group_name               = "${aws_cloudwatch_log_group.elasticsearch5_index_log_group.name}"
  firehose_role_arn            = "${data.terraform_remote_state.infra_monitoring.firehose_logs_role_arn}"
  firehose_bucket_arn          = "${data.terraform_remote_state.infra_monitoring.aws_logging_bucket_arn}"
  firehose_bucket_prefix       = "elasticsearch5/index-logs"
  lambda_filename              = "../../lambda/ElasticsearchLogsToFirehose/ElasticsearchLogsToFirehose.zip"
  lambda_role_arn              = "${data.terraform_remote_state.infra_monitoring.lambda_logs_role_arn}"
  lambda_log_retention_in_days = "${var.cloudwatch_log_retention}"
}

resource "aws_elasticsearch_domain" "elasticsearch5" {
  domain_name           = "${var.stackname}-elasticsearch5-domain"
  elasticsearch_version = "5.6"

  cluster_config {
    instance_type            = "${var.elasticsearch5_instance_type}"
    instance_count           = "${var.elasticsearch5_instance_count}"
    dedicated_master_enabled = "${var.elasticsearch5_dedicated_master_enabled}"
    dedicated_master_type    = "${var.elasticsearch5_master_instance_type}"
    dedicated_master_count   = "${var.elasticsearch5_master_instance_count}"
    zone_awareness_enabled   = true
  }

  ebs_options {
    ebs_enabled = true
    volume_type = "${var.elasticsearch5_ebs_type}"
    volume_size = "${var.elasticsearch5_ebs_size}"
  }

  encrypt_at_rest {
    enabled = "${var.elasticsearch5_ebs_encrypt}"
  }

  vpc_options {
    subnet_ids         = ["${matchkeys(values(data.terraform_remote_state.infra_networking.private_subnet_elasticsearch_names_ids_map), keys(data.terraform_remote_state.infra_networking.private_subnet_elasticsearch_names_ids_map), var.elasticsearch_subnet_names)}"]
    security_group_ids = ["${data.terraform_remote_state.infra_security_groups.sg_elasticsearch5_id}", "${data.terraform_remote_state.infra_security_groups.sg_management_id}"]
  }

  snapshot_options {
    automated_snapshot_start_hour = "${var.elasticsearch5_snapshot_start_hour}"
  }

  log_publishing_options {
    cloudwatch_log_group_arn = "${aws_cloudwatch_log_group.elasticsearch5_application_log_group.arn}"
    log_type                 = "ES_APPLICATION_LOGS"
  }

  log_publishing_options {
    cloudwatch_log_group_arn = "${aws_cloudwatch_log_group.elasticsearch5_search_log_group.arn}"
    log_type                 = "SEARCH_SLOW_LOGS"
  }

  log_publishing_options {
    cloudwatch_log_group_arn = "${aws_cloudwatch_log_group.elasticsearch5_index_log_group.arn}"
    log_type                 = "INDEX_SLOW_LOGS"
  }

  access_policies = <<CONFIG
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "*"
        ]
      },
      "Action": [
        "es:*"
      ],
      "Resource": "arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/${var.stackname}-elasticsearch5-domain/*"
    }
  ]
}
CONFIG

  tags {
    Name            = "${var.stackname}-elasticsearch5"
    Project         = "${var.stackname}"
    aws_stackname   = "${var.stackname}"
    aws_environment = "${var.aws_environment}"
  }

  depends_on = [
    "aws_iam_service_linked_role.role",
  ]
}

resource "aws_route53_record" "service_record" {
  zone_id = "${data.terraform_remote_state.infra_stack_dns_zones.internal_zone_id}"
  name    = "elasticsearch5.${data.terraform_remote_state.infra_stack_dns_zones.internal_domain_name}"
  type    = "CNAME"
  ttl     = 300
  records = ["${aws_elasticsearch_domain.elasticsearch5.endpoint}"]
}

# Outputs
# --------------------------------------------------------------

output "service_role_id" {
  value       = "${aws_iam_service_linked_role.role.id}"
  description = "Unique identifier for the service-linked role"
}

output "service_endpoint" {
  value       = "${aws_elasticsearch_domain.elasticsearch5.endpoint}"
  description = "Endpoint to submit index, search, and upload requests"
}

output "service_dns_name" {
  value       = "${aws_route53_record.service_record.fqdn}"
  description = "DNS name to access the Elasticsearch internal service"
}
