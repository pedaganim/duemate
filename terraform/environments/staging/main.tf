# Use the root module
module "duemate" {
  source = "../.."

  # Project Configuration
  project_name = "duemate"
  environment  = "staging"
  aws_region   = var.aws_region

  # DynamoDB Configuration
  dynamodb_billing_mode      = "PAY_PER_REQUEST"
  enable_dynamodb_pitr       = true
  enable_dynamodb_encryption = true

  # Lambda Configuration
  lambda_runtime          = "nodejs20.x"
  lambda_memory_size      = 1024  # Higher for staging
  lambda_timeout          = 60
  lambda_log_retention_days = 14  # Longer retention

  # API Gateway Configuration
  api_gateway_stage_name           = "staging"
  enable_api_gateway_logging       = true
  api_gateway_throttle_burst_limit = 2500
  api_gateway_throttle_rate_limit  = 2000

  # Cognito Configuration
  cognito_password_minimum_length = 12
  enable_cognito_mfa             = "OPTIONAL"

  # S3 and CloudFront Configuration
  enable_cloudfront     = true
  cloudfront_price_class = "PriceClass_200"
  enable_s3_versioning  = true

  # Monitoring Configuration
  enable_monitoring = true
  alarm_email      = var.alarm_email

  # EventBridge Configuration
  reminder_check_schedule = "rate(30 minutes)"  # More frequent checks

  # SQS Configuration
  sqs_message_retention_seconds  = 604800  # 7 days
  sqs_visibility_timeout_seconds = 300

  # VPC Configuration (optional)
  enable_vpc = false

  # Additional tags
  additional_tags = {
    CostCenter  = "Staging"
    Owner       = "DevOps"
  }
}
