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

# Lambda Function: Invoice List
resource "aws_lambda_function" "invoice_list" {
  function_name    = "${var.function_name_prefix}-invoice-list"
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

  tags = merge(var.tags, { Name = "${var.function_name_prefix}-invoice-list" })
}

resource "aws_cloudwatch_log_group" "invoice_list" {
  name              = "/aws/lambda/${aws_lambda_function.invoice_list.function_name}"
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

# Lambda Function: Invoice Update
resource "aws_lambda_function" "invoice_update" {
  function_name    = "${var.function_name_prefix}-invoice-update"
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

  tags = merge(var.tags, { Name = "${var.function_name_prefix}-invoice-update" })
}

resource "aws_cloudwatch_log_group" "invoice_update" {
  name              = "/aws/lambda/${aws_lambda_function.invoice_update.function_name}"
  retention_in_days = var.log_retention_days
  tags              = var.tags

  lifecycle {
    ignore_changes = [name]
  }
}

# Lambda Function: Invoice Delete
resource "aws_lambda_function" "invoice_delete" {
  function_name    = "${var.function_name_prefix}-invoice-delete"
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

  tags = merge(var.tags, { Name = "${var.function_name_prefix}-invoice-delete" })
}

resource "aws_cloudwatch_log_group" "invoice_delete" {
  name              = "/aws/lambda/${aws_lambda_function.invoice_delete.function_name}"
  retention_in_days = var.log_retention_days
  tags              = var.tags

  lifecycle {
    ignore_changes = [name]
  }
}

# Lambda Function: Invoice PDF
resource "aws_lambda_function" "invoice_pdf" {
  function_name    = "${var.function_name_prefix}-invoice-pdf"
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

  tags = merge(var.tags, { Name = "${var.function_name_prefix}-invoice-pdf" })
}

resource "aws_cloudwatch_log_group" "invoice_pdf" {
  name              = "/aws/lambda/${aws_lambda_function.invoice_pdf.function_name}"
  retention_in_days = var.log_retention_days
  tags              = var.tags

  lifecycle {
    ignore_changes = [name]
  }
}

# Lambda Function: Client Create
resource "aws_lambda_function" "client_create" {
  function_name    = "${var.function_name_prefix}-client-create"
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

  tags = merge(var.tags, { Name = "${var.function_name_prefix}-client-create" })
}

resource "aws_cloudwatch_log_group" "client_create" {
  name              = "/aws/lambda/${aws_lambda_function.client_create.function_name}"
  retention_in_days = var.log_retention_days
  tags              = var.tags

  lifecycle {
    ignore_changes = [name]
  }
}

# Lambda Function: Client List
resource "aws_lambda_function" "client_list" {
  function_name    = "${var.function_name_prefix}-client-list"
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

  tags = merge(var.tags, { Name = "${var.function_name_prefix}-client-list" })
}

resource "aws_cloudwatch_log_group" "client_list" {
  name              = "/aws/lambda/${aws_lambda_function.client_list.function_name}"
  retention_in_days = var.log_retention_days
  tags              = var.tags

  lifecycle {
    ignore_changes = [name]
  }
}

# Lambda Function: Client Get
resource "aws_lambda_function" "client_get" {
  function_name    = "${var.function_name_prefix}-client-get"
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

  tags = merge(var.tags, { Name = "${var.function_name_prefix}-client-get" })
}

resource "aws_cloudwatch_log_group" "client_get" {
  name              = "/aws/lambda/${aws_lambda_function.client_get.function_name}"
  retention_in_days = var.log_retention_days
  tags              = var.tags

  lifecycle {
    ignore_changes = [name]
  }
}

# Lambda Function: Client Update
resource "aws_lambda_function" "client_update" {
  function_name    = "${var.function_name_prefix}-client-update"
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

  tags = merge(var.tags, { Name = "${var.function_name_prefix}-client-update" })
}

resource "aws_cloudwatch_log_group" "client_update" {
  name              = "/aws/lambda/${aws_lambda_function.client_update.function_name}"
  retention_in_days = var.log_retention_days
  tags              = var.tags

  lifecycle {
    ignore_changes = [name]
  }
}

# Lambda Function: Client Delete
resource "aws_lambda_function" "client_delete" {
  function_name    = "${var.function_name_prefix}-client-delete"
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

  tags = merge(var.tags, { Name = "${var.function_name_prefix}-client-delete" })
}

resource "aws_cloudwatch_log_group" "client_delete" {
  name              = "/aws/lambda/${aws_lambda_function.client_delete.function_name}"
  retention_in_days = var.log_retention_days
  tags              = var.tags

  lifecycle {
    ignore_changes = [name]
  }
}

# Lambda Function: Reminder Create
resource "aws_lambda_function" "reminder_create" {
  function_name    = "${var.function_name_prefix}-reminder-create"
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

  tags = merge(var.tags, { Name = "${var.function_name_prefix}-reminder-create" })
}

resource "aws_cloudwatch_log_group" "reminder_create" {
  name              = "/aws/lambda/${aws_lambda_function.reminder_create.function_name}"
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

# Lambda Function: Reminder Send
resource "aws_lambda_function" "reminder_send" {
  function_name    = "${var.function_name_prefix}-reminder-send"
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

  tags = merge(var.tags, { Name = "${var.function_name_prefix}-reminder-send" })
}

resource "aws_cloudwatch_log_group" "reminder_send" {
  name              = "/aws/lambda/${aws_lambda_function.reminder_send.function_name}"
  retention_in_days = var.log_retention_days
  tags              = var.tags

  lifecycle {
    ignore_changes = [name]
  }
}

# Lambda Function: Notification Worker
resource "aws_lambda_function" "notification_worker" {
  function_name    = "${var.function_name_prefix}-notification-worker"
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

  tags = merge(var.tags, { Name = "${var.function_name_prefix}-notification-worker" })
}

resource "aws_cloudwatch_log_group" "notification_worker" {
  name              = "/aws/lambda/${aws_lambda_function.notification_worker.function_name}"
  retention_in_days = var.log_retention_days
  tags              = var.tags

  lifecycle {
    ignore_changes = [name]
  }
}
