output "function_names" {
  description = "Names of all Lambda functions"
  value = [
    aws_lambda_function.invoice_create.function_name,
    aws_lambda_function.invoice_get.function_name,
    aws_lambda_function.reminder_check.function_name,
    aws_lambda_function.notification_send.function_name
  ]
}

output "function_arns" {
  description = "ARNs of all Lambda functions"
  value = [
    aws_lambda_function.invoice_create.arn,
    aws_lambda_function.invoice_get.arn,
    aws_lambda_function.reminder_check.arn,
    aws_lambda_function.notification_send.arn
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

output "notification_send_function_arn" {
  description = "ARN of the notification send function"
  value       = aws_lambda_function.notification_send.arn
}
