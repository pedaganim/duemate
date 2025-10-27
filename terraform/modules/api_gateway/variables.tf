variable "api_name" {
  description = "Name of the API Gateway"
  type        = string
}

variable "stage_name" {
  description = "Stage name for deployment"
  type        = string
  default     = "prod"
}

variable "cognito_user_pool_arn" {
  description = "ARN of Cognito user pool for authorization"
  type        = string
}

variable "enable_logging" {
  description = "Enable CloudWatch logging"
  type        = bool
  default     = true
}

variable "throttle_burst_limit" {
  description = "Throttle burst limit"
  type        = number
  default     = 5000
}

variable "throttle_rate_limit" {
  description = "Throttle rate limit"
  type        = number
  default     = 10000
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
