# Import Configuration for Existing Resources
#
# This file contains import blocks to automatically import existing AWS resources
# into Terraform state. This prevents "resource already exists" errors when running
# terraform apply on infrastructure that was previously created.
#
# Import blocks are supported in Terraform 1.5.0+
#
# When you run `terraform plan` or `terraform apply`, Terraform will automatically
# import these resources if they exist in AWS but not in the state file.

# Data source to get current AWS account ID
data "aws_caller_identity" "current" {}

# IAM Role - Lambda Execution
import {
  to = aws_iam_role.lambda_execution
  id = "${local.name_prefix}-lambda-execution"
}

# IAM Policy - Lambda DynamoDB Access
import {
  to = aws_iam_policy.lambda_dynamodb
  id = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${local.name_prefix}-lambda-dynamodb"
}

# IAM Policy - Lambda S3 Access
import {
  to = aws_iam_policy.lambda_s3
  id = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${local.name_prefix}-lambda-s3"
}

# IAM Policy - Lambda SQS Access
import {
  to = aws_iam_policy.lambda_sqs
  id = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${local.name_prefix}-lambda-sqs"
}

# IAM Policy - Lambda SES Access
import {
  to = aws_iam_policy.lambda_ses
  id = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${local.name_prefix}-lambda-ses"
}

# IAM Policy - Lambda Secrets Manager Access
import {
  to = aws_iam_policy.lambda_secrets
  id = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${local.name_prefix}-lambda-secrets"
}

# IAM Role - API Gateway CloudWatch (conditional - only if manage_account_settings is true)
# Note: This import block will only be active if the resource is created (count = 1)
import {
  to = module.api_gateway.aws_iam_role.api_gateway_cloudwatch[0]
  id = "${local.name_prefix}-api-cloudwatch-role"
}

# CloudWatch Log Group - API Gateway
import {
  to = module.api_gateway.aws_cloudwatch_log_group.api_gateway[0]
  id = "/aws/apigateway/${local.name_prefix}-api"
}

# Cognito User Pool Domain
import {
  to = module.cognito.aws_cognito_user_pool_domain.main
  id = "${local.name_prefix}-users"
}

# DynamoDB Table
import {
  to = module.dynamodb.aws_dynamodb_table.main
  id = "${local.name_prefix}-main"
}

# S3 Bucket - Frontend
import {
  to = module.s3.aws_s3_bucket.frontend
  id = "${local.name_prefix}-frontend"
}

# S3 Bucket - Invoices
import {
  to = module.s3.aws_s3_bucket.invoices
  id = "${local.name_prefix}-invoices"
}

# S3 Bucket - Assets
import {
  to = module.s3.aws_s3_bucket.assets
  id = "${local.name_prefix}-assets"
}

# Lambda Function - Invoice Create
import {
  to = module.lambda_functions.aws_lambda_function.invoice_create
  id = "${local.name_prefix}-invoice-create"
}

# CloudWatch Log Group - Invoice Create
import {
  to = module.lambda_functions.aws_cloudwatch_log_group.invoice_create
  id = "/aws/lambda/${local.name_prefix}-invoice-create"
}

# Lambda Function - Invoice Get
import {
  to = module.lambda_functions.aws_lambda_function.invoice_get
  id = "${local.name_prefix}-invoice-get"
}

# CloudWatch Log Group - Invoice Get
import {
  to = module.lambda_functions.aws_cloudwatch_log_group.invoice_get
  id = "/aws/lambda/${local.name_prefix}-invoice-get"
}

# Lambda Function - Reminder Check
import {
  to = module.lambda_functions.aws_lambda_function.reminder_check
  id = "${local.name_prefix}-reminder-check"
}

# CloudWatch Log Group - Reminder Check
import {
  to = module.lambda_functions.aws_cloudwatch_log_group.reminder_check
  id = "/aws/lambda/${local.name_prefix}-reminder-check"
}

# Lambda Function - Notification Send
import {
  to = module.lambda_functions.aws_lambda_function.notification_send
  id = "${local.name_prefix}-notification-send"
}

# CloudWatch Log Group - Notification Send
import {
  to = module.lambda_functions.aws_cloudwatch_log_group.notification_send
  id = "/aws/lambda/${local.name_prefix}-notification-send"
}
