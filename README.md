# terraform-aws-dynamodb-global-table

[![Terraform Validation](https://github.com/pomo-studio/terraform-aws-dynamodb-global-table/actions/workflows/terraform.yml/badge.svg)](https://github.com/pomo-studio/terraform-aws-dynamodb-global-table/actions/workflows/terraform.yml)
[![Terraform Registry](https://img.shields.io/badge/terraform-registry-844FBA?logo=terraform)](https://registry.terraform.io/modules/pomo-studio/dynamodb-global-table/aws)

- [Changelog](CHANGELOG.md)

Terraform module for creating DynamoDB tables with optional cross-region replica support.

- Primary table in `aws.primary`
- Optional DR replica in `aws.dr`
- Supports GSIs, streams, PITR, TTL, SSE/KMS, and deletion protection
- Designed for migration-safe adoption using `moved` + `import` workflows

## Usage

```hcl
provider "aws" {
  alias  = "primary"
  region = "us-east-1"
}

provider "aws" {
  alias  = "dr"
  region = "us-west-2"
}

module "transactions_table" {
  source  = "pomo-studio/dynamodb-global-table/aws"
  version = "~> 1.0"

  providers = {
    aws.primary = aws.primary
    aws.dr      = aws.dr
  }

  name      = "txwatch-transactions"
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
    Project   = "txwatch"
    ManagedBy = "terraform"
  }
}
```

## Migration Guidance (Non-Destructive)

When moving existing tables into this module:

1. Add module with matching table name/schema settings.
2. Add `moved` blocks for address changes where applicable.
3. Use `import` blocks (or `terraform import`) for pre-existing resources:
   - primary table -> `module.<name>.aws_dynamodb_table.primary`
   - replica -> `module.<name>.aws_dynamodb_table_replica.dr[0]`
4. Run `terraform plan` and require zero unexpected destroys.
5. Apply in one workspace at a time (canary-first), then continue rollout.

Operational guardrails and evidence templates:

- `docs/MIGRATION_GUARDRAILS.md`
- `docs/MIGRATION_EVIDENCE_TEMPLATE.md`

## Notes

- Enabling DR requires streams.
- For `PROVISIONED` billing mode, table read/write capacity must be provided.
- If using KMS, ensure role permissions include KMS decrypt/encrypt grants.
