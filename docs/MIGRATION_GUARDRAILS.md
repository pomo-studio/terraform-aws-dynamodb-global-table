# Migration Guardrails

This checklist is step 1 of the non-destructive migration plan.

## Required policy

1. No unexpected destroy actions in plan.
2. Canary-first rollout (one workspace at a time).
3. Evidence capture for every migration run.

## Plan gate (no-destroy)

Run this before every migration apply:

```bash
terraform plan -out=tfplan
terraform show -json tfplan > tfplan.json
./scripts/check-no-destroy.sh tfplan.json
```

Expected result:

- `PASS: no destroy actions detected`

If the script fails, do not apply. Fix moved/import/state mapping first.

## Canary sequence

1. `serverless-ssr` internal migration in one workspace.
2. One consumer workspace (`pomo-dev` or `pomo-ssr`).
3. Remaining consumers only after canary passes.
4. `txwatch` last due to GSI and resolver coupling.

## Evidence requirements

For each migration run, store:

1. Commit SHA and module version.
2. Plan summary and no-destroy check output.
3. Apply run ID and status.
4. Post-apply health verification.

Use `docs/MIGRATION_EVIDENCE_TEMPLATE.md`.
