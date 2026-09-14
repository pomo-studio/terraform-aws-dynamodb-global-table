# Migration Evidence Template

## Metadata

- Date:
- Repo:
- Workspace:
- Operator:
- Commit SHA:
- Module version:

## Preconditions

- [ ] moved/import mappings prepared
- [ ] backup branch/tag created
- [ ] target workspace lock status clear

## Plan Evidence

- `terraform plan` summary:
- `check-no-destroy.sh` output:
- Unexpected destroys detected: yes/no

## Apply Evidence

- Run ID:
- Run status:
- Start/end time:

## Post-apply Verification

- App health endpoint:
- DynamoDB read/write smoke:
- DR parity check (if applicable):

## Decision

- [ ] Proceed to next workspace
- [ ] Stop and remediate

## Notes

-
