output "reminder_check_rule_name" {
  description = "Name of the reminder check EventBridge rule"
  value       = aws_cloudwatch_event_rule.reminder_check.name
}

output "reminder_check_rule_arn" {
  description = "ARN of the reminder check EventBridge rule"
  value       = aws_cloudwatch_event_rule.reminder_check.arn
}
