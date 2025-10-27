variable "queue_name_prefix" {
  description = "Prefix for SQS queue names"
  type        = string
}

variable "message_retention_seconds" {
  description = "Message retention period in seconds"
  type        = number
  default     = 345600
}

variable "visibility_timeout_seconds" {
  description = "Visibility timeout in seconds"
  type        = number
  default     = 300
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
