output "frontend_bucket_id" {
  description = "ID of the frontend S3 bucket"
  value       = aws_s3_bucket.frontend.id
}

output "frontend_bucket_arn" {
  description = "ARN of the frontend S3 bucket"
  value       = aws_s3_bucket.frontend.arn
}

output "frontend_bucket_regional_domain_name" {
  description = "Regional domain name of the frontend S3 bucket"
  value       = aws_s3_bucket.frontend.bucket_regional_domain_name
}

output "frontend_bucket_website_endpoint" {
  description = "Website endpoint of the frontend S3 bucket"
  value       = aws_s3_bucket_website_configuration.frontend.website_endpoint
}

output "invoices_bucket_id" {
  description = "ID of the invoices S3 bucket"
  value       = aws_s3_bucket.invoices.id
}

output "invoices_bucket_arn" {
  description = "ARN of the invoices S3 bucket"
  value       = aws_s3_bucket.invoices.arn
}

output "assets_bucket_id" {
  description = "ID of the assets S3 bucket"
  value       = aws_s3_bucket.assets.id
}

output "assets_bucket_arn" {
  description = "ARN of the assets S3 bucket"
  value       = aws_s3_bucket.assets.arn
}
