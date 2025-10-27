# Project Configuration
variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "duemate"
}

variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be one of: dev, staging, production"
  }
}

variable "aws_region" {
  description = "AWS region for resource deployment"
  type        = string
  default     = "us-east-1"
}

# Customer/Tenant Configuration
variable "customer_name" {
  description = "Customer name for whitelabel deployments (optional)"
  type        = string
  default     = null
}

variable "custom_domain" {
  description = "Custom domain name for the application (optional)"
  type        = string
  default     = null
}

# DynamoDB Configuration
variable "dynamodb_billing_mode" {
  description = "DynamoDB billing mode (PROVISIONED or PAY_PER_REQUEST)"
  type        = string
  default     = "PAY_PER_REQUEST"

  validation {
    condition     = contains(["PROVISIONED", "PAY_PER_REQUEST"], var.dynamodb_billing_mode)
    error_message = "Billing mode must be either PROVISIONED or PAY_PER_REQUEST"
  }
}

variable "dynamodb_read_capacity" {
  description = "DynamoDB read capacity units (only used if billing_mode is PROVISIONED)"
  type        = number
  default     = 5
}

variable "dynamodb_write_capacity" {
  description = "DynamoDB write capacity units (only used if billing_mode is PROVISIONED)"
  type        = number
  default     = 5
}

variable "enable_dynamodb_pitr" {
  description = "Enable point-in-time recovery for DynamoDB"
  type        = bool
  default     = true
}

variable "enable_dynamodb_encryption" {
  description = "Enable server-side encryption for DynamoDB"
  type        = bool
  default     = true
}

# Lambda Configuration
variable "lambda_runtime" {
  description = "Lambda runtime version"
  type        = string
  default     = "nodejs20.x"
}

variable "lambda_memory_size" {
  description = "Lambda function memory size in MB"
  type        = number
  default     = 512

  validation {
    condition     = var.lambda_memory_size >= 128 && var.lambda_memory_size <= 10240
    error_message = "Lambda memory must be between 128 and 10240 MB"
  }
}

variable "lambda_timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 30

  validation {
    condition     = var.lambda_timeout >= 1 && var.lambda_timeout <= 900
    error_message = "Lambda timeout must be between 1 and 900 seconds"
  }
}

variable "lambda_log_retention_days" {
  description = "CloudWatch log retention period for Lambda functions in days"
  type        = number
  default     = 7

  validation {
    condition = contains([
      1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653
    ], var.lambda_log_retention_days)
    error_message = "Log retention must be a valid CloudWatch retention period"
  }
}

# VPC Configuration
variable "enable_vpc" {
  description = "Deploy Lambda functions in VPC"
  type        = bool
  default     = false
}

variable "vpc_cidr" {
  description = "VPC CIDR block (only used if enable_vpc is true)"
  type        = string
  default     = "10.0.0.0/16"
}

# API Gateway Configuration
variable "api_gateway_stage_name" {
  description = "API Gateway stage name"
  type        = string
  default     = "prod"
}

variable "enable_api_gateway_logging" {
  description = "Enable CloudWatch logging for API Gateway"
  type        = bool
  default     = true
}

variable "api_gateway_throttle_burst_limit" {
  description = "API Gateway throttle burst limit"
  type        = number
  default     = 5000
}

variable "api_gateway_throttle_rate_limit" {
  description = "API Gateway throttle rate limit (requests per second)"
  type        = number
  default     = 10000
}

# Cognito Configuration
variable "cognito_password_minimum_length" {
  description = "Minimum password length for Cognito"
  type        = number
  default     = 12
}

variable "enable_cognito_mfa" {
  description = "Enable MFA for Cognito (OPTIONAL or ON)"
  type        = string
  default     = "OPTIONAL"

  validation {
    condition     = contains(["OFF", "OPTIONAL", "ON"], var.enable_cognito_mfa)
    error_message = "MFA setting must be OFF, OPTIONAL, or ON"
  }
}

# S3 and CloudFront Configuration
variable "enable_cloudfront" {
  description = "Enable CloudFront distribution for frontend"
  type        = bool
  default     = true
}

variable "cloudfront_price_class" {
  description = "CloudFront price class (PriceClass_All, PriceClass_200, PriceClass_100)"
  type        = string
  default     = "PriceClass_100"

  validation {
    condition     = contains(["PriceClass_All", "PriceClass_200", "PriceClass_100"], var.cloudfront_price_class)
    error_message = "Price class must be PriceClass_All, PriceClass_200, or PriceClass_100"
  }
}

variable "enable_s3_versioning" {
  description = "Enable S3 bucket versioning"
  type        = bool
  default     = true
}

# Monitoring Configuration
variable "enable_monitoring" {
  description = "Enable CloudWatch dashboards and alarms"
  type        = bool
  default     = true
}

variable "alarm_email" {
  description = "Email address for CloudWatch alarm notifications"
  type        = string
  default     = null
}

# EventBridge Configuration
variable "reminder_check_schedule" {
  description = "EventBridge schedule expression for reminder checks (cron format)"
  type        = string
  default     = "rate(1 hour)"
}

# SQS Configuration
variable "sqs_message_retention_seconds" {
  description = "SQS message retention period in seconds"
  type        = number
  default     = 345600 # 4 days

  validation {
    condition     = var.sqs_message_retention_seconds >= 60 && var.sqs_message_retention_seconds <= 1209600
    error_message = "Message retention must be between 60 seconds and 14 days"
  }
}

variable "sqs_visibility_timeout_seconds" {
  description = "SQS visibility timeout in seconds"
  type        = number
  default     = 300 # 5 minutes

  validation {
    condition     = var.sqs_visibility_timeout_seconds >= 0 && var.sqs_visibility_timeout_seconds <= 43200
    error_message = "Visibility timeout must be between 0 and 12 hours"
  }
}

# Third-party Integration Configuration
variable "stripe_api_key" {
  description = "Stripe API key (stored in Secrets Manager)"
  type        = string
  default     = null
  sensitive   = true
}

variable "twilio_account_sid" {
  description = "Twilio Account SID (stored in Secrets Manager)"
  type        = string
  default     = null
  sensitive   = true
}

variable "twilio_auth_token" {
  description = "Twilio Auth Token (stored in Secrets Manager)"
  type        = string
  default     = null
  sensitive   = true
}

variable "plaid_client_id" {
  description = "Plaid Client ID (stored in Secrets Manager)"
  type        = string
  default     = null
  sensitive   = true
}

variable "plaid_secret" {
  description = "Plaid Secret (stored in Secrets Manager)"
  type        = string
  default     = null
  sensitive   = true
}

# Email Configuration
variable "email_from_address" {
  description = "Email address for sending notifications (must be verified in SES)"
  type        = string
  default     = null
}

variable "email_from_name" {
  description = "Name for email sender"
  type        = string
  default     = "DueMate"
}

# Tags
variable "additional_tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
