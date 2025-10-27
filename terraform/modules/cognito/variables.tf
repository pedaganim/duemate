variable "user_pool_name" {
  description = "Name of the Cognito user pool"
  type        = string
}

variable "password_min_length" {
  description = "Minimum password length"
  type        = number
  default     = 12
}

variable "mfa_configuration" {
  description = "MFA configuration (OFF, OPTIONAL, ON)"
  type        = string
  default     = "OPTIONAL"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
