# Use the root module
module "duemate" {
  source = "../.."

  # Project Configuration
  project_name = "duemate"
  environment  = "dev"
  aws_region   = var.aws_region

  # DynamoDB Configuration
  dynamodb_billing_mode      = "PAY_PER_REQUEST"
  enable_dynamodb_pitr       = true
  enable_dynamodb_encryption = true

  # Lambda Configuration
  lambda_runtime            = "nodejs20.x"
  lambda_memory_size        = 512
  lambda_timeout            = 30
  lambda_log_retention_days = 7

  # API Gateway Configuration
  api_gateway_stage_name           = "dev"
  enable_api_gateway_logging       = true
  api_gateway_throttle_burst_limit = 1000
  api_gateway_throttle_rate_limit  = 500

  # Cognito Configuration
  cognito_password_minimum_length = 12
  enable_cognito_mfa              = "OPTIONAL"

  # S3 and CloudFront Configuration
  enable_cloudfront      = true
  cloudfront_price_class = "PriceClass_100"
  enable_s3_versioning   = false # Disabled for dev to save costs

  # Monitoring Configuration
  enable_monitoring = true
  # alarm_email     = var.alarm_email  # Optional

  # EventBridge Configuration
  reminder_check_schedule = "rate(1 hour)"

  # SQS Configuration
  sqs_message_retention_seconds  = 345600 # 4 days
  sqs_visibility_timeout_seconds = 300    # 5 minutes

  # VPC Configuration (disabled for dev)
  enable_vpc = false

  # Additional tags
  additional_tags = {
    CostCenter = "Development"
    Owner      = "DevOps"
  }
}
