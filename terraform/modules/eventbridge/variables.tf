variable "rule_name_prefix" {
  description = "Prefix for EventBridge rule names"
  type        = string
}

variable "reminder_check_schedule" {
  description = "Schedule expression for reminder checks"
  type        = string
  default     = "rate(1 hour)"
}

variable "reminder_lambda_arn" {
  description = "ARN of the reminder check Lambda function"
  type        = string
}

variable "reminder_lambda_name" {
  description = "Name of the reminder check Lambda function"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
