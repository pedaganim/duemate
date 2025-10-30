output "function_names" {
  description = "Names of all Lambda functions"
  value = [
    aws_lambda_function.invoice_create.function_name,
    aws_lambda_function.invoice_list.function_name,
    aws_lambda_function.invoice_get.function_name,
    aws_lambda_function.invoice_update.function_name,
    aws_lambda_function.invoice_delete.function_name,
    aws_lambda_function.invoice_pdf.function_name,
    aws_lambda_function.client_create.function_name,
    aws_lambda_function.client_list.function_name,
    aws_lambda_function.client_get.function_name,
    aws_lambda_function.client_update.function_name,
    aws_lambda_function.client_delete.function_name,
    aws_lambda_function.reminder_create.function_name,
    aws_lambda_function.reminder_check.function_name,
    aws_lambda_function.reminder_send.function_name,
    aws_lambda_function.notification_worker.function_name
  ]
}

output "function_arns" {
  description = "ARNs of all Lambda functions"
  value = [
    aws_lambda_function.invoice_create.arn,
    aws_lambda_function.invoice_list.arn,
    aws_lambda_function.invoice_get.arn,
    aws_lambda_function.invoice_update.arn,
    aws_lambda_function.invoice_delete.arn,
    aws_lambda_function.invoice_pdf.arn,
    aws_lambda_function.client_create.arn,
    aws_lambda_function.client_list.arn,
    aws_lambda_function.client_get.arn,
    aws_lambda_function.client_update.arn,
    aws_lambda_function.client_delete.arn,
    aws_lambda_function.reminder_create.arn,
    aws_lambda_function.reminder_check.arn,
    aws_lambda_function.reminder_send.arn,
    aws_lambda_function.notification_worker.arn
  ]
}

output "reminder_check_function_arn" {
  description = "ARN of the reminder check function"
  value       = aws_lambda_function.reminder_check.arn
}

output "reminder_check_function_name" {
  description = "Name of the reminder check function"
  value       = aws_lambda_function.reminder_check.function_name
}

output "notification_worker_function_arn" {
  description = "ARN of the notification worker function"
  value       = aws_lambda_function.notification_worker.arn
}
