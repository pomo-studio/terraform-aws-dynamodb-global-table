locals {
  common_tags = var.tags
}

resource "aws_dynamodb_table" "primary" {
  provider = aws.primary

  name         = var.name
  billing_mode = var.billing_mode
  hash_key     = var.hash_key
  range_key    = var.range_key
  table_class  = var.table_class

  read_capacity  = var.billing_mode == "PROVISIONED" ? var.read_capacity : null
  write_capacity = var.billing_mode == "PROVISIONED" ? var.write_capacity : null

  stream_enabled   = var.enable_streams
  stream_view_type = var.enable_streams ? var.stream_view_type : null

  deletion_protection_enabled = var.enable_deletion_protection

  dynamic "attribute" {
    for_each = var.attributes
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  dynamic "global_secondary_index" {
    for_each = var.global_secondary_indexes
    content {
      name               = global_secondary_index.value.name
      hash_key           = global_secondary_index.value.hash_key
      range_key          = try(global_secondary_index.value.range_key, null)
      projection_type    = try(global_secondary_index.value.projection_type, "ALL")
      non_key_attributes = try(global_secondary_index.value.non_key_attributes, [])
      read_capacity      = var.billing_mode == "PROVISIONED" ? try(global_secondary_index.value.read_capacity, null) : null
      write_capacity     = var.billing_mode == "PROVISIONED" ? try(global_secondary_index.value.write_capacity, null) : null
    }
  }

  dynamic "ttl" {
    for_each = var.enable_ttl ? [1] : []
    content {
      attribute_name = var.ttl_attribute_name
      enabled        = true
    }
  }

  dynamic "point_in_time_recovery" {
    for_each = var.enable_pitr ? [1] : []
    content {
      enabled = true
    }
  }

  dynamic "server_side_encryption" {
    for_each = var.enable_sse ? [1] : []
    content {
      enabled     = true
      kms_key_arn = var.kms_key_arn
    }
  }

  lifecycle {
    ignore_changes = [replica]

    precondition {
      condition     = var.billing_mode != "PROVISIONED" || (var.read_capacity != null && var.write_capacity != null)
      error_message = "read_capacity and write_capacity are required when billing_mode = PROVISIONED."
    }

    precondition {
      condition     = !var.enable_ttl || var.ttl_attribute_name != null
      error_message = "ttl_attribute_name is required when enable_ttl = true."
    }

    precondition {
      condition     = !var.enable_dr || var.enable_streams
      error_message = "enable_dr requires enable_streams = true."
    }
  }

  tags = local.common_tags
}

resource "aws_dynamodb_table_replica" "dr" {
  count    = var.enable_dr ? 1 : 0
  provider = aws.dr

  global_table_arn = aws_dynamodb_table.primary.arn

  kms_key_arn            = var.replica_kms_key_arn
  point_in_time_recovery = var.enable_pitr

  tags = local.common_tags
}
