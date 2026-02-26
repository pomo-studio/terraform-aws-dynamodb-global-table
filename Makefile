.PHONY: validate test

validate:
	printf '%s\n' \
	'provider "aws" {' \
	'  alias                       = "primary"' \
	'  region                      = "us-east-1"' \
	'  skip_credentials_validation = true' \
	'  skip_requesting_account_id  = true' \
	'  skip_metadata_api_check     = true' \
	'  access_key                  = "mock"' \
	'  secret_key                  = "mock"' \
	'}' \
	'provider "aws" {' \
	'  alias                       = "dr"' \
	'  region                      = "us-west-2"' \
	'  skip_credentials_validation = true' \
	'  skip_requesting_account_id  = true' \
	'  skip_metadata_api_check     = true' \
	'  access_key                  = "mock"' \
	'  secret_key                  = "mock"' \
	'}' > ci_providers.tf
	terraform init -backend=false
	terraform validate
	rm -f ci_providers.tf
	cd examples/basic && terraform init -backend=false && terraform validate

test:
	terraform test
