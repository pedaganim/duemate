# EventBridge Rule for Reminder Checks
resource "aws_cloudwatch_event_rule" "reminder_check" {
  name                = "${var.rule_name_prefix}-reminder-check"
  description         = "Trigger reminder check Lambda function on schedule"
  schedule_expression = var.reminder_check_schedule

  tags = merge(
    var.tags,
    {
      Name = "${var.rule_name_prefix}-reminder-check"
    }
  )
}

# EventBridge Target - Reminder Lambda
resource "aws_cloudwatch_event_target" "reminder_check" {
  rule      = aws_cloudwatch_event_rule.reminder_check.name
  target_id = "ReminderCheckLambda"
  arn       = var.reminder_lambda_arn
}

# Lambda Permission for EventBridge
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "${var.rule_name_prefix}-AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = var.reminder_lambda_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.reminder_check.arn
}
