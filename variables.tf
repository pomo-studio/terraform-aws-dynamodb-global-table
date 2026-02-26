variable "name" {
  description = "DynamoDB table name. Must be unique in account+region."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9_.-]{3,255}$", var.name))
    error_message = "Table name must be 3-255 chars: alphanumeric, dot, underscore, hyphen."
  }
}

variable "hash_key" {
  description = "Primary partition key name."
  type        = string
}

variable "range_key" {
  description = "Primary sort key name. Null for hash-only table."
  type        = string
  default     = null
}

variable "attributes" {
  description = "Attribute definitions used by table keys and GSIs."
  type = list(object({
    name = string
    type = string
  }))

  validation {
    condition     = length(var.attributes) > 0
    error_message = "At least one attribute definition is required."
  }
}

variable "billing_mode" {
  description = "PAY_PER_REQUEST or PROVISIONED."
  type        = string
  default     = "PAY_PER_REQUEST"

  validation {
    condition     = contains(["PAY_PER_REQUEST", "PROVISIONED"], var.billing_mode)
    error_message = "billing_mode must be PAY_PER_REQUEST or PROVISIONED."
  }
}

variable "read_capacity" {
  description = "Table read capacity when billing_mode = PROVISIONED."
  type        = number
  default     = null
}

variable "write_capacity" {
  description = "Table write capacity when billing_mode = PROVISIONED."
  type        = number
  default     = null
}

variable "global_secondary_indexes" {
  description = "Optional GSI definitions."
  type = list(object({
    name               = string
    hash_key           = string
    range_key          = optional(string)
    projection_type    = optional(string, "ALL")
    non_key_attributes = optional(list(string), [])
    read_capacity      = optional(number)
    write_capacity     = optional(number)
  }))
  default = []
}

variable "table_class" {
  description = "DynamoDB table class."
  type        = string
  default     = "STANDARD"

  validation {
    condition     = contains(["STANDARD", "STANDARD_INFREQUENT_ACCESS"], var.table_class)
    error_message = "table_class must be STANDARD or STANDARD_INFREQUENT_ACCESS."
  }
}

variable "enable_dr" {
  description = "Create a table replica in the DR region (aws.dr provider)."
  type        = bool
  default     = true
}

variable "enable_streams" {
  description = "Enable DynamoDB streams on primary table. Required for global table replication."
  type        = bool
  default     = true
}

variable "stream_view_type" {
  description = "DynamoDB stream view type when streams are enabled."
  type        = string
  default     = "NEW_AND_OLD_IMAGES"

  validation {
    condition = contains([
      "KEYS_ONLY",
      "NEW_IMAGE",
      "OLD_IMAGE",
      "NEW_AND_OLD_IMAGES"
    ], var.stream_view_type)
    error_message = "stream_view_type must be one of KEYS_ONLY, NEW_IMAGE, OLD_IMAGE, NEW_AND_OLD_IMAGES."
  }
}

variable "enable_pitr" {
  description = "Enable point-in-time recovery for table and replica."
  type        = bool
  default     = true
}

variable "enable_ttl" {
  description = "Enable TTL on the table."
  type        = bool
  default     = false
}

variable "ttl_attribute_name" {
  description = "TTL attribute name when enable_ttl = true."
  type        = string
  default     = null
}

variable "enable_sse" {
  description = "Enable server-side encryption."
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "Primary-region KMS key ARN for table encryption. Null uses AWS-owned key."
  type        = string
  default     = null
}

variable "replica_kms_key_arn" {
  description = "DR-region KMS key ARN for replica encryption. Null uses default."
  type        = string
  default     = null
}

variable "enable_deletion_protection" {
  description = "Enable DynamoDB deletion protection."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
