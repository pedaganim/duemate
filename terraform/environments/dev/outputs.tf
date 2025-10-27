# Pass through outputs from the root module
output "deployment_summary" {
  description = "Summary of the development deployment"
  value       = module.duemate.deployment_summary
}

output "api_gateway_endpoint" {
  description = "API Gateway endpoint URL"
  value       = module.duemate.api_gateway_endpoint
}

output "frontend_url" {
  description = "Frontend application URL"
  value       = module.duemate.frontend_url
}

output "cognito_user_pool_id" {
  description = "Cognito User Pool ID"
  value       = module.duemate.cognito_user_pool_id
}

output "dynamodb_table_name" {
  description = "DynamoDB table name"
  value       = module.duemate.dynamodb_table_name
}

output "cloudwatch_dashboard_name" {
  description = "CloudWatch dashboard name"
  value       = module.duemate.cloudwatch_dashboard_name
}
