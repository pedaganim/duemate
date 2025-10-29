# Local variables for resource naming
locals {
  name_prefix = var.customer_name != null ? "${var.project_name}-${var.customer_name}-${var.environment}" : "${var.project_name}-${var.environment}"
  common_tags = merge(
    var.additional_tags,
    {
      Project     = var.project_name
      Environment = var.environment
      Customer    = var.customer_name != null ? var.customer_name : "default"
    }
  )
}

# DynamoDB Table
module "dynamodb" {
  source = "./modules/dynamodb"

  table_name        = "${local.name_prefix}-main"
  billing_mode      = var.dynamodb_billing_mode
  read_capacity     = var.dynamodb_read_capacity
  write_capacity    = var.dynamodb_write_capacity
  enable_pitr       = var.enable_dynamodb_pitr
  enable_encryption = var.enable_dynamodb_encryption
  tags              = local.common_tags
}

# Cognito User Pool
module "cognito" {
  source = "./modules/cognito"

  user_pool_name      = "${local.name_prefix}-users"
  password_min_length = var.cognito_password_minimum_length
  mfa_configuration   = var.enable_cognito_mfa
  tags                = local.common_tags
}

# S3 Buckets
module "s3" {
  source = "./modules/s3"

  project_name      = local.name_prefix
  enable_versioning = var.enable_s3_versioning
  tags              = local.common_tags
}

# CloudFront Distribution
module "cloudfront" {
  source = "./modules/cloudfront"
  count  = var.enable_cloudfront ? 1 : 0

  frontend_bucket_id              = module.s3.frontend_bucket_id
  frontend_bucket_regional_domain = module.s3.frontend_bucket_regional_domain_name
  price_class                     = var.cloudfront_price_class
  custom_domain                   = var.custom_domain
  tags                            = local.common_tags
}

# SQS Queues
module "sqs" {
  source = "./modules/sqs"

  queue_name_prefix          = local.name_prefix
  message_retention_seconds  = var.sqs_message_retention_seconds
  visibility_timeout_seconds = var.sqs_visibility_timeout_seconds
  tags                       = local.common_tags
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_execution" {
  name = "${local.name_prefix}-lambda-execution"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags

  lifecycle {
    ignore_changes = [name]
  }
}

# Lambda Basic Execution Policy
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda DynamoDB Access Policy
resource "aws_iam_policy" "lambda_dynamodb" {
  name        = "${local.name_prefix}-lambda-dynamodb"
  description = "Allow Lambda functions to access DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:BatchGetItem",
          "dynamodb:BatchWriteItem"
        ]
        Resource = [
          module.dynamodb.table_arn,
          "${module.dynamodb.table_arn}/index/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb" {
  role       = aws_iam_role.lambda_execution.name
  policy_arn = aws_iam_policy.lambda_dynamodb.arn
}

# Lambda S3 Access Policy
resource "aws_iam_policy" "lambda_s3" {
  name        = "${local.name_prefix}-lambda-s3"
  description = "Allow Lambda functions to access S3 buckets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          module.s3.invoices_bucket_arn,
          "${module.s3.invoices_bucket_arn}/*",
          module.s3.assets_bucket_arn,
          "${module.s3.assets_bucket_arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_s3" {
  role       = aws_iam_role.lambda_execution.name
  policy_arn = aws_iam_policy.lambda_s3.arn
}

# Lambda SQS Access Policy
resource "aws_iam_policy" "lambda_sqs" {
  name        = "${local.name_prefix}-lambda-sqs"
  description = "Allow Lambda functions to access SQS queues"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = [
          module.sqs.notification_queue_arn,
          module.sqs.notification_dlq_arn
        ]
      }
    ]
  })

  lifecycle {
    ignore_changes = [name]
  }
}

resource "aws_iam_role_policy_attachment" "lambda_sqs" {
  role       = aws_iam_role.lambda_execution.name
  policy_arn = aws_iam_policy.lambda_sqs.arn
}

# Lambda SES Access Policy (for email sending)
resource "aws_iam_policy" "lambda_ses" {
  name        = "${local.name_prefix}-lambda-ses"
  description = "Allow Lambda functions to send emails via SES"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ]
        Resource = "*"
      }
    ]
  })

  lifecycle {
    ignore_changes = [name]
  }
}

resource "aws_iam_role_policy_attachment" "lambda_ses" {
  role       = aws_iam_role.lambda_execution.name
  policy_arn = aws_iam_policy.lambda_ses.arn
}

# Lambda Secrets Manager Access Policy
resource "aws_iam_policy" "lambda_secrets" {
  name        = "${local.name_prefix}-lambda-secrets"
  description = "Allow Lambda functions to read secrets from Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = "arn:aws:secretsmanager:${var.aws_region}:*:secret:${local.name_prefix}/*"
      }
    ]
  })

  lifecycle {
    ignore_changes = [name]
  }
}

resource "aws_iam_role_policy_attachment" "lambda_secrets" {
  role       = aws_iam_role.lambda_execution.name
  policy_arn = aws_iam_policy.lambda_secrets.arn
}

# API Gateway
module "api_gateway" {
  source = "./modules/api_gateway"

  api_name              = "${local.name_prefix}-api"
  stage_name            = var.api_gateway_stage_name
  cognito_user_pool_arn = module.cognito.user_pool_arn
  enable_logging        = var.enable_api_gateway_logging
  throttle_burst_limit  = var.api_gateway_throttle_burst_limit
  throttle_rate_limit   = var.api_gateway_throttle_rate_limit
  tags                  = local.common_tags
}

# Lambda Functions Module
module "lambda_functions" {
  source = "./modules/lambda"

  function_name_prefix = local.name_prefix
  runtime              = var.lambda_runtime
  memory_size          = var.lambda_memory_size
  timeout              = var.lambda_timeout
  execution_role_arn   = aws_iam_role.lambda_execution.arn
  log_retention_days   = var.lambda_log_retention_days

  environment_variables = {
    TABLE_NAME         = module.dynamodb.table_name
    USER_POOL_ID       = module.cognito.user_pool_id
    INVOICES_BUCKET    = module.s3.invoices_bucket_id
    ASSETS_BUCKET      = module.s3.assets_bucket_id
    NOTIFICATION_QUEUE = module.sqs.notification_queue_url
    AWS_REGION_NAME    = var.aws_region
    ENVIRONMENT        = var.environment
    PROJECT_NAME       = var.project_name
    CUSTOMER_NAME      = var.customer_name != null ? var.customer_name : "default"
  }

  tags = local.common_tags
}

# EventBridge Rules for Scheduled Tasks
module "eventbridge" {
  source = "./modules/eventbridge"

  rule_name_prefix        = local.name_prefix
  reminder_check_schedule = var.reminder_check_schedule
  reminder_lambda_arn     = module.lambda_functions.reminder_check_function_arn
  reminder_lambda_name    = module.lambda_functions.reminder_check_function_name
  tags                    = local.common_tags
}

# CloudWatch Monitoring
module "monitoring" {
  source = "./modules/monitoring"
  count  = var.enable_monitoring ? 1 : 0

  dashboard_name        = "${local.name_prefix}-dashboard"
  api_gateway_id        = module.api_gateway.api_id
  api_gateway_stage     = var.api_gateway_stage_name
  dynamodb_table_name   = module.dynamodb.table_name
  lambda_function_names = module.lambda_functions.function_names
  sqs_queue_name        = module.sqs.notification_queue_name
  alarm_email           = var.alarm_email
  tags                  = local.common_tags
}

# Secrets Manager for Third-party API Keys
resource "aws_secretsmanager_secret" "stripe" {
  count = var.stripe_api_key != null ? 1 : 0

  name        = "${local.name_prefix}/stripe"
  description = "Stripe API credentials"

  tags = local.common_tags
}

resource "aws_secretsmanager_secret_version" "stripe" {
  count = var.stripe_api_key != null ? 1 : 0

  secret_id = aws_secretsmanager_secret.stripe[0].id
  secret_string = jsonencode({
    api_key = var.stripe_api_key
  })
}

resource "aws_secretsmanager_secret" "twilio" {
  count = var.twilio_account_sid != null && var.twilio_auth_token != null ? 1 : 0

  name        = "${local.name_prefix}/twilio"
  description = "Twilio API credentials"

  tags = local.common_tags
}

resource "aws_secretsmanager_secret_version" "twilio" {
  count = var.twilio_account_sid != null && var.twilio_auth_token != null ? 1 : 0

  secret_id = aws_secretsmanager_secret.twilio[0].id
  secret_string = jsonencode({
    account_sid = var.twilio_account_sid
    auth_token  = var.twilio_auth_token
  })
}

resource "aws_secretsmanager_secret" "plaid" {
  count = var.plaid_client_id != null && var.plaid_secret != null ? 1 : 0

  name        = "${local.name_prefix}/plaid"
  description = "Plaid API credentials"

  tags = local.common_tags
}

resource "aws_secretsmanager_secret_version" "plaid" {
  count = var.plaid_client_id != null && var.plaid_secret != null ? 1 : 0

  secret_id = aws_secretsmanager_secret.plaid[0].id
  secret_string = jsonencode({
    client_id = var.plaid_client_id
    secret    = var.plaid_secret
  })
}
