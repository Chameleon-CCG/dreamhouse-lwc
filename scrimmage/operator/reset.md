# Dreamhouse Scrimmage Reset

Reset takes the platform and the orgs back to a clean slate after a run. It has two parts:

1. Platform teardown through the MCP: the run's tenant, its channels, tunnels and project
   artefacts.
2. Scratch orgs: delete the run's four orgs. The next run creates four fresh ones.

Run a reset only when Jim says so. Use the **Chameleon Cloud Staging** connector only
(`mcp__claude_ai_Chameleon_Cloud_Staging__<tool>`). Conventions, tokens and the
preview-then-confirm pattern are as in `runbook.md` section 0.

## 1. Safety rules

These rules come before every other step.

- **Never touch the Xyla tenant (`tenant-7df2ceb8`) or any customer tenant.** Do not pass that id to
  any tool, not even a read.
- Act only on a tenant recorded in `scrimmage/operator/runs/run-<run>/run.json`.
- Every destructive call passes `tenant_id` explicitly.
- Do not delete the customer `dreamhouse-homes`. Every run reuses it, and there is no delete tool.
- If any guard check below fails, stop. Do not tear anything down. Tell Jim.

## 2. Guard check

- **Actor:** Claude.
- **Read** `run.json` for `<tenant_id>`, the Jira key, the repository URL and the four org aliases
  and usernames.
- **Tools:** `tenants_get(tenant_id=<tenant_id>)` and `projects_inspect(tenant_id=<tenant_id>)`.
- **All of these must be true:**
  1. `<tenant_id>` is not `tenant-7df2ceb8`.
  2. The tenant name is `Dreamhouse Homes`.
  3. The Jira project key is `DHR<run>`, the same as in `run.json`.
  4. The GitHub repository is `client-dreamhouse-homes-r<run>`, the same as in `run.json`.
  5. `channels_list(tenant_id=<tenant_id>)` lists only the internal and joint channels this run
     provisioned, with the channel ids in `run.json`.
- **Evidence:** save each answer as `runs/run-<run>/evidence/reset-guard-<tool>.json`.

## 3. Inventory (read only)

- **Actor:** Claude.
- **Tools:**
  - `tunnels_status(tenant_id=<tenant_id>)`
  - `release_bundles_list(tenant_id=<tenant_id>)`
  - `chits_list(tenant_id=<tenant_id>, limit=100)`
  - `audits_list_runs(tenant_id=<tenant_id>)`
  - `documents_list(tenant_id=<tenant_id>)`
  - `opportunities_list(customer_id="dreamhouse-homes")`
- **Evidence:** save each answer. This is the record of what the run left behind.

## 4. Platform teardown

Do the steps in this order. Archive must come before the channel archive, because the gateway
archives channels only for an archived test project.

### 4.1 Stop running work

- **Bundles:** for each bundle not in a final state,
  `release_bundles_cancel(bundle_id=<bundle_id>, reason="Scrimmage run <run> reset", tenant_id=<tenant_id>)` (confirm).
- **Audits:** for each running audit,
  `audits_cancel(run_id=<audit_run_id>, tenant_id=<tenant_id>)` (confirm).
- **Expect:** nothing is moving. Check with `release_bundles_list` and
  `audits_status(tenant_id=<tenant_id>)`.

### 4.2 Close the opportunity

- `opportunities_change(opportunity_id=<opportunity_id>, status="archived", reason="Scrimmage run <run> reset", tenant_id=<tenant_id>)` (confirm).
- **Expect:** the opportunity is archived. The next run creates a new one.

### 4.3 Archive the tenant

- **Actor:** Claude, as Jim (Owner).
- `tenants_archive(tenant_id=<tenant_id>, reason="Scrimmage run <run> reset: disposable test tenant")` (confirm).
- It archives the GitHub repository, moves the Jira project to the Jira trash, deletes the
  Salesforce Connected Apps, revokes the tunnel credentials and marks the tenant archived. It can
  take minutes. Do not run it twice at once.
- **Check:** `tenants_overview(query="dreamhouse", status="archived")` lists the tenant, and
  `tunnels_status(tenant_id=<tenant_id>)` shows no live tunnel.

### 4.4 Archive the Slack channels

- `channels_provision(change="archive", tenant_id=<tenant_id>, reason="Scrimmage run <run> reset")` (confirm).
- This works only because step 1.9 of the runbook provisioned them with `test_environment=true`.
  If it answers `not_a_test_environment`, stop and log a config finding. Do not archive the
  channels by hand.
- **Expect:** both channels archived, none failed.

### 4.5 Tear down the project

- **Actor:** Claude, as Jim (Owner).
- `projects_teardown(tenant_id=<tenant_id>, reason="Scrimmage run <run> reset: disposable test project")` (confirm).
- It deletes the GitHub repository, trashes the Jira project and Drive folder, unbinds the Slack
  channels and deletes the tenant record. It cannot be undone.
- **If it refuses an archived tenant,** stop. The tenant stays archived, which is a safe end state.
  Log a platform finding with the refusal text.
- **Expect:** `status` is `torn_down`. `failed_resources` is empty, or lists only the Jira project,
  which step 4.3 already moved to the trash.

### 4.6 Not used: erase

`tenants_erase` permanently erases the tenant's corpus, Firestore data, storage buckets and tunnel
secrets. Reset does not call it. It is not known whether erase before teardown would stop teardown
from finding the tenant record. Jim decides whether to add it. Until then, the archived corpus and
buckets of a scrimmage tenant stay on staging.

### 4.7 Confirm the platform slate

- `tenants_overview(query="dreamhouse")`: no active Dreamhouse tenant.
- `opportunities_list(customer_id="dreamhouse-homes")`: no open opportunity.
- `customers_list(limit=100)`: `dreamhouse-homes` is still active.
- **Evidence:** all three answers.

## 5. Scratch orgs

### 5.1 Delete this run's four orgs

- **Actor:** Claude (PowerShell), from `C:\Users\jh\Applications\chameleon-cloud` on main.
- For each slot, delete the org only while its alias still names the org this run created:
  `powershell.exe -Command "python -c \"import sys; sys.path.insert(0, 'scripts/e2e'); import scratch_org; print(scratch_org.delete_if_owned('dh-r<run>-dev', '<admin_username>'))\""`
- **Expect:** `True` for each of `dh-r<run>-dev`, `dh-r<run>-qa`, `dh-r<run>-uat` and
  `dh-r<run>-prod`. `False` means the alias no longer names that org: log it and do not delete
  anything else by hand.

### 5.2 Older orgs

- `powershell.exe -Command "sf org list --json"`.
- Orgs from earlier runs expire after their 14 days. If an earlier run's org is still live, delete
  it the same way, using that run's `run.json` for the alias and username.
- **Never delete** an org whose alias does not start with `dh-r`, a `chameleon-pool-*` org, or any
  org another machine created on `C360`. Never act on a customer Dev Hub.

### 5.3 Local files

- Delete the run's public certificate files `dh-r<run>-<slot>.pem` from the scratchpad.
- Keep `runs/run-<run>/`. It is the run's record.

### 5.4 Fresh orgs for the next run

The next run creates its four fresh orgs in `runbook.md` steps 1.2 to 1.4, at the start of that
run, so their lifetime starts with the run. Never reuse a pool org or an org from an earlier run.

## 6. Clean-slate checklist

Tick each line in `runs/run-<run>/scorecard.md` under "Reset".

- [ ] Guard check passed and was saved
- [ ] No bundle or audit still running
- [ ] Opportunity archived
- [ ] Tenant archived, tunnels revoked
- [ ] Both Slack channels archived
- [ ] Project torn down, or the refusal logged as a finding
- [ ] No active Dreamhouse tenant on staging
- [ ] `dreamhouse-homes` customer still active
- [ ] The run's four scratch orgs deleted
- [ ] Certificate files deleted from the scratchpad
- [ ] Commit: `docs(scrimmage): record run <run> reset`
