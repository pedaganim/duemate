variable "aws_region" {
  description = "AWS region for production environment"
  type        = string
  default     = "us-east-1"
}

variable "customer_name" {
  description = "Customer name for whitelabel deployments"
  type        = string
  default     = null
}

variable "custom_domain" {
  description = "Custom domain name"
  type        = string
  default     = null
}

variable "alarm_email" {
  description = "Email address for CloudWatch alarm notifications"
  type        = string
  default     = null
}

# Third-party integration variables
variable "stripe_api_key" {
  description = "Stripe API key"
  type        = string
  default     = null
  sensitive   = true
}

variable "twilio_account_sid" {
  description = "Twilio Account SID"
  type        = string
  default     = null
  sensitive   = true
}

variable "twilio_auth_token" {
  description = "Twilio Auth Token"
  type        = string
  default     = null
  sensitive   = true
}

variable "plaid_client_id" {
  description = "Plaid Client ID"
  type        = string
  default     = null
  sensitive   = true
}

variable "plaid_secret" {
  description = "Plaid Secret"
  type        = string
  default     = null
  sensitive   = true
}

variable "email_from_address" {
  description = "Email address for sending notifications"
  type        = string
  default     = null
}

variable "email_from_name" {
  description = "Name for email sender"
  type        = string
  default     = "DueMate"
}
