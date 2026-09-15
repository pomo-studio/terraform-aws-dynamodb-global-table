# terraform-aws-dynamodb-global-table

[![Terraform Validation](https://github.com/pomo-studio/terraform-aws-dynamodb-global-table/actions/workflows/terraform.yml/badge.svg)](https://github.com/pomo-studio/terraform-aws-dynamodb-global-table/actions/workflows/terraform.yml)
[![Terraform Registry](https://img.shields.io/badge/terraform-registry-844FBA?logo=terraform)](https://registry.terraform.io/modules/pomo-studio/dynamodb-global-table/aws)

[Changelog](CHANGELOG.md)

A DynamoDB table with an optional cross-region replica, defined once.

## When to use it

Use this component when an application needs a DynamoDB table, and possibly the same table live in a second region for recovery. The table is created in the primary region, and `enable_dr` adds a replica in the DR region.

The module covers the pieces an application table usually needs: hash and range keys, global secondary indexes, streams, point-in-time recovery, TTL, KMS encryption, and deletion protection. Adopting an existing table is supported through `moved` and `import`, without destroying data.

## Quickstart

```hcl
module "transactions_table" {
  source  = "pomo-studio/dynamodb-global-table/aws"
  version = "~> 1.0"

  providers = {
    aws.primary = aws.primary
    aws.dr      = aws.dr
  }

  name      = "my-app-transactions"
  hash_key  = "PK"
  range_key = "SK"

  attributes = [
    { name = "PK", type = "S" },
    { name = "SK", type = "S" },
    { name = "entity_type", type = "S" },
    { name = "category", type = "S" },
    { name = "createdAt", type = "S" }
  ]

  global_secondary_indexes = [
    {
      name            = "AllTransactionsIndex"
      hash_key        = "entity_type"
      range_key       = "createdAt"
      projection_type = "ALL"
    },
    {
      name            = "CategoryTimestampIndex"
      hash_key        = "category"
      range_key       = "createdAt"
      projection_type = "ALL"
    }
  ]

  enable_dr = true

  tags = {
    Project   = "my-app"
    ManagedBy = "terraform"
  }
}
```

## What it creates

- The primary table, in `aws.primary`, with the keys and indexes you declare.
- An optional replica in `aws.dr` when `enable_dr` is true.
- Streams when DR is enabled, because replication requires them.
- Point-in-time recovery, TTL, SSE/KMS, and deletion protection, driven by their inputs.

## Design decisions

- **Primary plus optional replica.** One module call defines the table and its replica together, so the two cannot drift apart.
- **Streams are a prerequisite for DR.** Enabling a replica turns them on; there is no separate switch to forget.
- **Migration-safe by default.** Existing tables are adopted with `moved` and `import` blocks, followed by a plan that must show no unexpected destroys.
- **Capacity and encryption are your call.** `PROVISIONED` billing needs read and write capacity, and KMS encryption needs the calling role to have encrypt and decrypt grants.

## Migrating an existing table

1. Add the module with matching name and schema settings.
2. Add `moved` blocks for address changes.
3. Use `import` blocks (or `terraform import`) for existing resources, at `module.<name>.aws_dynamodb_table.primary` and `module.<name>.aws_dynamodb_table_replica.dr[0]`.
4. Run `terraform plan` and require zero unexpected destroys.
5. Apply in one workspace at a time, canary first.

Operational guardrails and an evidence template live in [`docs/migration-guardrails.md`](docs/migration-guardrails.md) and [`docs/migration-evidence-template.md`](docs/migration-evidence-template.md).

## Examples

- [Basic](examples/basic/)

## Reference

<details>
<summary>Reference</summary>

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0, < 7.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws.dr"></a> [aws.dr](#provider\_aws.dr) | 6.64.0 |
| <a name="provider_aws.primary"></a> [aws.primary](#provider\_aws.primary) | 6.64.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_dynamodb_table.primary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |
| [aws_dynamodb_table_replica.dr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table_replica) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_attributes"></a> [attributes](#input\_attributes) | Attribute definitions used by table keys and GSIs. | <pre>list(object({<br/>    name = string<br/>    type = string<br/>  }))</pre> | n/a | yes |
| <a name="input_billing_mode"></a> [billing\_mode](#input\_billing\_mode) | PAY\_PER\_REQUEST or PROVISIONED. | `string` | `"PAY_PER_REQUEST"` | no |
| <a name="input_enable_deletion_protection"></a> [enable\_deletion\_protection](#input\_enable\_deletion\_protection) | Enable DynamoDB deletion protection. | `bool` | `false` | no |
| <a name="input_enable_dr"></a> [enable\_dr](#input\_enable\_dr) | Create a table replica in the DR region (aws.dr provider). | `bool` | `true` | no |
| <a name="input_enable_pitr"></a> [enable\_pitr](#input\_enable\_pitr) | Enable point-in-time recovery for table and replica. | `bool` | `true` | no |
| <a name="input_enable_sse"></a> [enable\_sse](#input\_enable\_sse) | Enable server-side encryption. | `bool` | `true` | no |
| <a name="input_enable_streams"></a> [enable\_streams](#input\_enable\_streams) | Enable DynamoDB streams on primary table. Required for global table replication. | `bool` | `true` | no |
| <a name="input_enable_ttl"></a> [enable\_ttl](#input\_enable\_ttl) | Enable TTL on the table. | `bool` | `false` | no |
| <a name="input_global_secondary_indexes"></a> [global\_secondary\_indexes](#input\_global\_secondary\_indexes) | Optional GSI definitions. | <pre>list(object({<br/>    name               = string<br/>    hash_key           = string<br/>    range_key          = optional(string)<br/>    projection_type    = optional(string, "ALL")<br/>    non_key_attributes = optional(list(string), [])<br/>    read_capacity      = optional(number)<br/>    write_capacity     = optional(number)<br/>  }))</pre> | `[]` | no |
| <a name="input_hash_key"></a> [hash\_key](#input\_hash\_key) | Primary partition key name. | `string` | n/a | yes |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | Primary-region KMS key ARN for table encryption. Null uses AWS-owned key. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | DynamoDB table name. Must be unique in account+region. | `string` | n/a | yes |
| <a name="input_range_key"></a> [range\_key](#input\_range\_key) | Primary sort key name. Null for hash-only table. | `string` | `null` | no |
| <a name="input_read_capacity"></a> [read\_capacity](#input\_read\_capacity) | Table read capacity when billing\_mode = PROVISIONED. | `number` | `null` | no |
| <a name="input_replica_kms_key_arn"></a> [replica\_kms\_key\_arn](#input\_replica\_kms\_key\_arn) | DR-region KMS key ARN for replica encryption. Null uses default. | `string` | `null` | no |
| <a name="input_stream_view_type"></a> [stream\_view\_type](#input\_stream\_view\_type) | DynamoDB stream view type when streams are enabled. | `string` | `"NEW_AND_OLD_IMAGES"` | no |
| <a name="input_table_class"></a> [table\_class](#input\_table\_class) | DynamoDB table class. | `string` | `"STANDARD"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to all resources. | `map(string)` | `{}` | no |
| <a name="input_ttl_attribute_name"></a> [ttl\_attribute\_name](#input\_ttl\_attribute\_name) | TTL attribute name when enable\_ttl = true. | `string` | `null` | no |
| <a name="input_write_capacity"></a> [write\_capacity](#input\_write\_capacity) | Table write capacity when billing\_mode = PROVISIONED. | `number` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_replica_enabled"></a> [replica\_enabled](#output\_replica\_enabled) | Whether DR replica is enabled. |
| <a name="output_replica_region_table_name"></a> [replica\_region\_table\_name](#output\_replica\_region\_table\_name) | Replica table name in DR region (same as primary). Null when DR disabled. |
| <a name="output_table_arn_primary"></a> [table\_arn\_primary](#output\_table\_arn\_primary) | Primary-region DynamoDB table ARN. |
| <a name="output_table_id_primary"></a> [table\_id\_primary](#output\_table\_id\_primary) | Primary-region DynamoDB table ID. |
| <a name="output_table_name_primary"></a> [table\_name\_primary](#output\_table\_name\_primary) | Primary-region DynamoDB table name. |
| <a name="output_table_stream_arn_primary"></a> [table\_stream\_arn\_primary](#output\_table\_stream\_arn\_primary) | Primary-region DynamoDB stream ARN. Null when streams are disabled. |
<!-- END_TF_DOCS -->

</details>

## Support and license

Part of [postmodern.tf](https://pomo.dev), the open-source AWS infrastructure
collection created by [André Pitanga](https://pomo.studio). Regenerate the reference with `terraform-docs` v0.20.0 (`terraform-docs .`); CI fails on drift.

See the [contribution guide](https://github.com/pomo-studio/.github/blob/main/CONTRIBUTING.md) and [security policy](https://github.com/pomo-studio/.github/blob/main/SECURITY.md).

MIT licensed. See [LICENSE](LICENSE).
