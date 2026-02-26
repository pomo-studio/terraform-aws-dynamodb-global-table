mock_provider "aws" {
  alias = "primary"

  mock_resource "aws_dynamodb_table" {
    defaults = {
      arn        = "arn:aws:dynamodb:us-east-1:123456789012:table/test-table"
      id         = "test-table"
      name       = "test-table"
      stream_arn = "arn:aws:dynamodb:us-east-1:123456789012:table/test-table/stream/2026-01-01T00:00:00.000"
    }
  }
}

mock_provider "aws" {
  alias = "dr"

  mock_resource "aws_dynamodb_table_replica" {
    defaults = {}
  }
}

run "basic_defaults" {
  command = plan

  variables {
    name      = "test-table"
    hash_key  = "PK"
    range_key = "SK"

    attributes = [
      { name = "PK", type = "S" },
      { name = "SK", type = "S" }
    ]
  }

  assert {
    condition     = aws_dynamodb_table.primary.name == "test-table"
    error_message = "table name should match input"
  }

  assert {
    condition     = length(aws_dynamodb_table_replica.dr) == 1
    error_message = "replica should be created by default"
  }

  assert {
    condition     = output.replica_enabled == true
    error_message = "replica_enabled should be true by default"
  }
}

run "dr_disabled" {
  command = plan

  variables {
    name      = "test-table"
    hash_key  = "PK"
    range_key = "SK"
    enable_dr = false

    attributes = [
      { name = "PK", type = "S" },
      { name = "SK", type = "S" }
    ]
  }

  assert {
    condition     = length(aws_dynamodb_table_replica.dr) == 0
    error_message = "replica should not be created when enable_dr = false"
  }

  assert {
    condition     = output.replica_region_table_name == null
    error_message = "replica output should be null when DR is disabled"
  }
}

run "ttl_requires_attribute" {
  command = plan

  expect_failures = [aws_dynamodb_table.primary]

  variables {
    name       = "test-table"
    hash_key   = "PK"
    range_key  = "SK"
    enable_ttl = true

    attributes = [
      { name = "PK", type = "S" },
      { name = "SK", type = "S" }
    ]
  }
}
