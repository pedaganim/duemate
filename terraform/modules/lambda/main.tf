# Placeholder Lambda function deployment package
data "archive_file" "lambda_placeholder" {
  type        = "zip"
  output_path = "${path.module}/lambda_placeholder.zip"

  source {
    content  = <<EOF
exports.handler = async (event) => {
    return {
        statusCode: 200,
        body: JSON.stringify({
            message: 'Placeholder Lambda function - deploy actual code',
            event: event
        })
    };
};
EOF
    filename = "index.js"
  }
}

# Lambda Function: Invoice Create
resource "aws_lambda_function" "invoice_create" {
  function_name    = "${var.function_name_prefix}-invoice-create"
  role             = var.execution_role_arn
  handler          = "index.handler"
  runtime          = var.runtime
  memory_size      = var.memory_size
  timeout          = var.timeout
  filename         = data.archive_file.lambda_placeholder.output_path
  source_code_hash = data.archive_file.lambda_placeholder.output_base64sha256

  environment {
    variables = var.environment_variables
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.function_name_prefix}-invoice-create"
    }
  )
}

resource "aws_cloudwatch_log_group" "invoice_create" {
  name              = "/aws/lambda/${aws_lambda_function.invoice_create.function_name}"
  retention_in_days = var.log_retention_days
  tags              = var.tags

  lifecycle {
    ignore_changes = [name]
  }
}

# Lambda Function: Invoice Get
resource "aws_lambda_function" "invoice_get" {
  function_name    = "${var.function_name_prefix}-invoice-get"
  role             = var.execution_role_arn
  handler          = "index.handler"
  runtime          = var.runtime
  memory_size      = var.memory_size
  timeout          = var.timeout
  filename         = data.archive_file.lambda_placeholder.output_path
  source_code_hash = data.archive_file.lambda_placeholder.output_base64sha256

  environment {
    variables = var.environment_variables
  }

  tags = merge(var.tags, { Name = "${var.function_name_prefix}-invoice-get" })
}

resource "aws_cloudwatch_log_group" "invoice_get" {
  name              = "/aws/lambda/${aws_lambda_function.invoice_get.function_name}"
  retention_in_days = var.log_retention_days
  tags              = var.tags

  lifecycle {
    ignore_changes = [name]
  }
}

# Lambda Function: Reminder Check
resource "aws_lambda_function" "reminder_check" {
  function_name    = "${var.function_name_prefix}-reminder-check"
  role             = var.execution_role_arn
  handler          = "index.handler"
  runtime          = var.runtime
  memory_size      = var.memory_size
  timeout          = var.timeout
  filename         = data.archive_file.lambda_placeholder.output_path
  source_code_hash = data.archive_file.lambda_placeholder.output_base64sha256

  environment {
    variables = var.environment_variables
  }

  tags = merge(var.tags, { Name = "${var.function_name_prefix}-reminder-check" })
}

resource "aws_cloudwatch_log_group" "reminder_check" {
  name              = "/aws/lambda/${aws_lambda_function.reminder_check.function_name}"
  retention_in_days = var.log_retention_days
  tags              = var.tags

  lifecycle {
    ignore_changes = [name]
  }
}

# Lambda Function: Notification Send
resource "aws_lambda_function" "notification_send" {
  function_name    = "${var.function_name_prefix}-notification-send"
  role             = var.execution_role_arn
  handler          = "index.handler"
  runtime          = var.runtime
  memory_size      = var.memory_size
  timeout          = var.timeout
  filename         = data.archive_file.lambda_placeholder.output_path
  source_code_hash = data.archive_file.lambda_placeholder.output_base64sha256

  environment {
    variables = var.environment_variables
  }

  tags = merge(var.tags, { Name = "${var.function_name_prefix}-notification-send" })
}

resource "aws_cloudwatch_log_group" "notification_send" {
  name              = "/aws/lambda/${aws_lambda_function.notification_send.function_name}"
  retention_in_days = var.log_retention_days
  tags              = var.tags

  lifecycle {
    ignore_changes = [name]
  }
}
