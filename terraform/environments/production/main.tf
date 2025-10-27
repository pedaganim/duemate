# Use the root module
module "duemate" {
  source = "../.."

  # Project Configuration
  project_name = "duemate"
  environment  = "production"
  aws_region   = var.aws_region
  
  # Customer/Tenant (if whitelabel deployment)
  customer_name = var.customer_name
  custom_domain = var.custom_domain

  # DynamoDB Configuration
  dynamodb_billing_mode      = "PAY_PER_REQUEST"
  enable_dynamodb_pitr       = true
  enable_dynamodb_encryption = true

  # Lambda Configuration
  lambda_runtime          = "nodejs20.x"
  lambda_memory_size      = 1536  # Higher for production performance
  lambda_timeout          = 60
  lambda_log_retention_days = 30  # Longer retention for compliance

  # API Gateway Configuration
  api_gateway_stage_name           = "prod"
  enable_api_gateway_logging       = true
  api_gateway_throttle_burst_limit = 5000
  api_gateway_throttle_rate_limit  = 10000

  # Cognito Configuration
  cognito_password_minimum_length = 12
  enable_cognito_mfa             = "ON"  # Required for production

  # S3 and CloudFront Configuration
  enable_cloudfront     = true
  cloudfront_price_class = "PriceClass_All"  # Global distribution
  enable_s3_versioning  = true

  # Monitoring Configuration
  enable_monitoring = true
  alarm_email      = var.alarm_email

  # EventBridge Configuration
  reminder_check_schedule = "rate(15 minutes)"  # Frequent checks for production

  # SQS Configuration
  sqs_message_retention_seconds  = 1209600  # 14 days
  sqs_visibility_timeout_seconds = 300

  # VPC Configuration (recommended for production)
  enable_vpc = var.enable_vpc

  # Third-party Integration Secrets
  stripe_api_key     = var.stripe_api_key
  twilio_account_sid = var.twilio_account_sid
  twilio_auth_token  = var.twilio_auth_token
  plaid_client_id    = var.plaid_client_id
  plaid_secret       = var.plaid_secret

  # Email Configuration
  email_from_address = var.email_from_address
  email_from_name    = var.email_from_name

  # Additional tags
  additional_tags = {
    CostCenter   = "Production"
    Owner        = "DevOps"
    Backup       = "Required"
    Compliance   = "Required"
    DataSensitivity = "High"
  }
}
