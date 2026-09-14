# Basic Global Table

Shows a DynamoDB global table replicated across two regions.

## What it creates

- A global table named `example-global-table` with `PK` and `SK` keys.
- A primary replica in `us-east-1` and a DR replica in `us-west-2`, with `enable_dr = true`.

## Before you start

- AWS provider v5 or later, with `primary` and `dr` aliased providers.
- Uses the local module source `../..`.

## Run it

```bash
terraform init
terraform plan
terraform apply
```

## Clean up

```bash
terraform destroy
```
