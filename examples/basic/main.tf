provider "aws" {
  alias  = "primary"
  region = "us-east-1"
}

provider "aws" {
  alias  = "dr"
  region = "us-west-2"
}

module "table" {
  source = "../.."

  providers = {
    aws.primary = aws.primary
    aws.dr      = aws.dr
  }

  name      = "example-global-table"
  hash_key  = "PK"
  range_key = "SK"

  attributes = [
    { name = "PK", type = "S" },
    { name = "SK", type = "S" }
  ]

  enable_dr = true

  tags = {
    Project = "example"
  }
}
