variable "frontend_bucket_id" {
  description = "ID of the S3 bucket for frontend"
  type        = string
}

variable "frontend_bucket_regional_domain" {
  description = "Regional domain name of the frontend S3 bucket"
  type        = string
}

variable "price_class" {
  description = "CloudFront price class"
  type        = string
  default     = "PriceClass_100"
}

variable "custom_domain" {
  description = "Custom domain name (optional)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
