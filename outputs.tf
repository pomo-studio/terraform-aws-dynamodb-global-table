output "table_name_primary" {
  description = "Primary-region DynamoDB table name."
  value       = aws_dynamodb_table.primary.name
}

output "table_arn_primary" {
  description = "Primary-region DynamoDB table ARN."
  value       = aws_dynamodb_table.primary.arn
}

output "table_stream_arn_primary" {
  description = "Primary-region DynamoDB stream ARN. Null when streams are disabled."
  value       = aws_dynamodb_table.primary.stream_arn
}

output "table_id_primary" {
  description = "Primary-region DynamoDB table ID."
  value       = aws_dynamodb_table.primary.id
}

output "replica_enabled" {
  description = "Whether DR replica is enabled."
  value       = var.enable_dr
}

output "replica_region_table_name" {
  description = "Replica table name in DR region (same as primary). Null when DR disabled."
  value       = var.enable_dr ? aws_dynamodb_table.primary.name : null
}
