# DynamoDB Outputs
output "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  value       = module.dynamodb.table_name
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table"
  value       = module.dynamodb.table_arn
}

# Cognito Outputs
output "cognito_user_pool_id" {
  description = "ID of the Cognito user pool"
  value       = module.cognito.user_pool_id
}

output "cognito_user_pool_arn" {
  description = "ARN of the Cognito user pool"
  value       = module.cognito.user_pool_arn
}

output "cognito_user_pool_client_id" {
  description = "ID of the Cognito user pool client"
  value       = module.cognito.user_pool_client_id
  sensitive   = true
}

# S3 Outputs
output "frontend_bucket_name" {
  description = "Name of the S3 bucket for frontend hosting"
  value       = module.s3.frontend_bucket_id
}

output "frontend_bucket_website_endpoint" {
  description = "Website endpoint of the frontend S3 bucket"
  value       = module.s3.frontend_bucket_website_endpoint
}

output "invoices_bucket_name" {
  description = "Name of the S3 bucket for invoice storage"
  value       = module.s3.invoices_bucket_id
}

output "assets_bucket_name" {
  description = "Name of the S3 bucket for assets storage"
  value       = module.s3.assets_bucket_id
}

# CloudFront Outputs
output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = var.enable_cloudfront ? module.cloudfront[0].distribution_id : null
}

output "cloudfront_domain_name" {
  description = "Domain name of the CloudFront distribution"
  value       = var.enable_cloudfront ? module.cloudfront[0].distribution_domain_name : null
}

output "frontend_url" {
  description = "URL to access the frontend application"
  value       = var.enable_cloudfront ? "https://${module.cloudfront[0].distribution_domain_name}" : module.s3.frontend_bucket_website_endpoint
}

# API Gateway Outputs
output "api_gateway_id" {
  description = "ID of the API Gateway REST API"
  value       = module.api_gateway.api_id
}

output "api_gateway_endpoint" {
  description = "Endpoint URL of the API Gateway"
  value       = module.api_gateway.api_endpoint
}

output "api_gateway_stage" {
  description = "Stage name of the API Gateway deployment"
  value       = var.api_gateway_stage_name
}

# Lambda Outputs
output "lambda_function_names" {
  description = "Names of all Lambda functions"
  value       = module.lambda_functions.function_names
}

output "lambda_function_arns" {
  description = "ARNs of all Lambda functions"
  value       = module.lambda_functions.function_arns
}

# SQS Outputs
output "notification_queue_url" {
  description = "URL of the notification SQS queue"
  value       = module.sqs.notification_queue_url
}

output "notification_queue_arn" {
  description = "ARN of the notification SQS queue"
  value       = module.sqs.notification_queue_arn
}

output "notification_dlq_url" {
  description = "URL of the notification dead letter queue"
  value       = module.sqs.notification_dlq_url
}

# EventBridge Outputs
output "eventbridge_rule_name" {
  description = "Name of the EventBridge rule for reminder checks"
  value       = module.eventbridge.reminder_check_rule_name
}

# CloudWatch Outputs
output "cloudwatch_dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  value       = var.enable_monitoring ? module.monitoring[0].dashboard_name : null
}

# Secrets Manager Outputs
output "stripe_secret_arn" {
  description = "ARN of the Stripe secret in Secrets Manager"
  value       = var.stripe_api_key != null ? aws_secretsmanager_secret.stripe[0].arn : null
  sensitive   = true
}

output "twilio_secret_arn" {
  description = "ARN of the Twilio secret in Secrets Manager"
  value       = var.twilio_account_sid != null && var.twilio_auth_token != null ? aws_secretsmanager_secret.twilio[0].arn : null
  sensitive   = true
}

output "plaid_secret_arn" {
  description = "ARN of the Plaid secret in Secrets Manager"
  value       = var.plaid_client_id != null && var.plaid_secret != null ? aws_secretsmanager_secret.plaid[0].arn : null
  sensitive   = true
}

# General Deployment Info
output "deployment_summary" {
  description = "Summary of the deployment"
  value = {
    project_name   = var.project_name
    environment    = var.environment
    customer_name  = var.customer_name
    aws_region     = var.aws_region
    custom_domain  = var.custom_domain
    api_endpoint   = module.api_gateway.api_endpoint
    frontend_url   = var.enable_cloudfront ? "https://${module.cloudfront[0].distribution_domain_name}" : module.s3.frontend_bucket_website_endpoint
    dynamodb_table = module.dynamodb.table_name
    user_pool_id   = module.cognito.user_pool_id
  }
}
