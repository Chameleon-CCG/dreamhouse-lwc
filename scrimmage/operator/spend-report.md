# Dreamhouse Scrimmage Spend Report

This is how to produce a run's model spend from the platform's own cost data:

- per CHIT
- per stage within a CHIT
- per release bundle
- per run

It also gives the one-off reconciliation against GCP billing.

Use the **Chameleon Cloud Staging** connector only. Tokens are as in `runbook.md` section 0.5.
Save every answer under `scrimmage/operator/runs/run-<run>/evidence/spend-<tool>-<what>.json`.
Write the result into `runs/run-<run>/spend.md` using the tables in section 6, and copy the totals
to the scorecard (section 2.8).

## 1. The cost tools and what they can and cannot do

| Tool | What it gives | Limits |
|---|---|---|
| `cost_rollup(dimension, tenant_id, days, source, chit_id, skill_id, model_id, limit)` | Model spend from the cost records, broken down by `tenant`, `chit`, `user`, `model`, `skill` or `trigger_source`. Each bucket has `total_cost_usd`, tokens, `call_count`, `price_missing_call_count` and `models`. The answer also has `total_cost_usd` over every bucket and `price_missing_calls`. | `days` is at most 31, counted back from now. At most 50 buckets. The gateway reads only the filter that matches the dimension: `chit_id` works only with `dimension="chit"`, `skill_id` only with `dimension="skill"`. A filter for another dimension is ignored, not refused. |
| `reports_spend(tenant_id, days, grain, group_by, limit, per_point)` | Spend by day, week or month, optionally by model or Skill, over up to a year. `per_point=true` adds spend per delivered point. | Reads the export, which trails `cost_rollup` by minutes. No CHIT dimension. |
| `skills_history(tenant_id, limit, status, skill_id)` | Recent Skill runs with the CHIT or Artifact each served. | No cost. Use it to map Skills to CHITs and stages. |
| `budget_status(tenant_id)` | This month's spend against the monthly dollar cap, whether calls are blocked, and the release points budget. | Month to date only. |
| `reports_budget_burn(tenant_id)` | Month-to-date spend, daily averages and the month-end projection. | Month level only. |
| `budget_history(tenant_id, limit, entry_type)` | The **release points** budget: points each release used, and adjustments. | Points, not dollars. It is not model spend. Use it only for the points line in section 6. |
| `llm_prices(model_id, limit)` | The unit price every call is booked at. | Use it to explain any `price_missing_calls`. |

**G12 (Run 1: derive; FIX: bundle and stage attribution):** cost records have no stage and no
bundle dimension. The only calls that carry a bundle id are the release-audit calls, whose
`trigger_source` is `release-gate:<bundle_id>`. So Run 1 derives stage spend and bundle spend as
this file describes.

**G15 (verify in Run 1):** it is not yet known whether CD authoring cost records carry the
`chit_id`. Section 2.3 checks this. If they do not, per-CHIT spend is understated, and that is a
platform finding.

**Window rule:** `cost_rollup` reaches back at most 31 days. Take the final readings in section 4
within 31 days of the run's start. If a run lasts longer, use `reports_spend` with `grain="day"`
for the run total and say so in the report.

## 2. Per CHIT

### 2.1 Totals

- **Tool:** `cost_rollup(dimension="chit", tenant_id=<tenant_id>, days=31, source="all", limit=50)`.
- Each bucket's `dimension_key` is a `<chit_id>`. Match each to `run.json` (requirement or plant).
- For one CHIT in detail: `cost_rollup(dimension="chit", chit_id=<chit_id>, tenant_id=<tenant_id>, days=31)`.

### 2.2 Unattributed spend

- `records_without_dimension_value` in the `dimension="chit"` answer counts cost records with no
  CHIT. That spend is run-level work: audit, readout, proposal, documents, knowledge. Section 5
  splits it.

### 2.3 G15 check

- **Tool:** `cost_rollup(dimension="skill", tenant_id=<tenant_id>, days=31, limit=50)`.
- Find the CD authoring Skills (ids that start `cd_` and end `_development`). Use
  `skills_history(tenant_id=<tenant_id>, skill_id=<skill id>)` to see which CHITs they served.
- Compare the authoring Skills' spend with the per-CHIT totals. If authoring spend is large in the
  Skill view but the matching CHITs show little, the authoring records lack `chit_id`. Log G15 as
  confirmed.

## 3. Per stage within a CHIT (derived, G12)

The cost data has no stage field, and `cost_rollup` cannot filter a Skill breakdown to one CHIT.
So stage spend is measured as the **change in a CHIT's running total between gates**.

### 3.1 Readings during the run

In runbook stages 8 and 9, each time Claude sees a CHIT change state, it takes one reading:

- `cost_rollup(dimension="chit", chit_id=<chit_id>, tenant_id=<tenant_id>, days=31)`.
- Record in `run.json`, for that CHIT: the UTC time, the new state, and the bucket's
  `total_cost_usd` and `call_count`.

### 3.2 Stages

| Stage | From reading | To reading |
|---|---|---|
| Triage and clarification | CHIT created (first reading, normally 0) | enters `blocked-on-approval` |
| Design | enters `blocked-on-approval` | design gate decided (enters `in-flight`) |
| Authoring, dev deploy and self-heal | enters `in-flight` | enters `awaiting-review` |
| Review (CA review and PR gate) | enters `awaiting-review` | enters `in-testing` |
| Testing and QA | enters `in-testing` | enters `ready-for-release` |
| After release-ready | enters `ready-for-release` | final reading (section 4) |

A stage's spend is the "to" total minus the "from" total. If Jim sends a CHIT back, the CHIT
re-enters an earlier state. Add each pass to the stage it belongs to, and note the rework.

### 3.3 Accuracy

- A reading is only as exact as the time Claude took it. Spend that lands between a state change
  and the next reading is counted in the next stage. Note the polling interval in the report.
- **Cross-check:** group the tenant's Skill spend (`cost_rollup(dimension="skill", ...)`) into the
  same stages by Skill family (enrichment and triage, design, `cd_*_development`, CA review, CT
  testing). The stage totals summed across all CHITs should be close to the Skill-family totals.
  Report the difference.

## 4. Per release bundle (derived, G12)

Take these readings after the prod promote (runbook 10.7), and again at close-out (12.2).

1. **Member CHITs:** the sum of the section 2.1 totals for every CHIT in the bundle
   (`release_bundles_get(bundle_id=<bundle_id>, tenant_id=<tenant_id>)` lists them).
2. **Release gate:** `cost_rollup(dimension="trigger_source", tenant_id=<tenant_id>, days=31, limit=50)`.
   Take the bucket whose `dimension_key` is `release-gate:<bundle_id>`.
3. **Bundle spend** = member CHITs + release gate.

Release notes and the admin and user guides are written by the platform during the release. If
their spend has no CHIT and no `release-gate` cause, it falls in run-level spend (section 5). Say
which in the report.

Also record the points the release used: `budget_history(tenant_id=<tenant_id>, entry_type="consumption")`
(the entry whose `release_id` is this bundle).

## 5. Per run

Each run has its own fresh tenant, so the tenant's spend is the run's spend.

1. **Run total:** `cost_rollup(dimension="tenant", tenant_id=<tenant_id>, days=31)`.
   Cross-check with `reports_spend(tenant_id=<tenant_id>, days=31, grain="day")` (wait a few
   minutes after the last call, because the export trails).
2. **By cause:** `cost_rollup(dimension="trigger_source", tenant_id=<tenant_id>, days=31, limit=50)`.
3. **By Skill:** `cost_rollup(dimension="skill", tenant_id=<tenant_id>, days=31, limit=50)`.
4. **By model:** `cost_rollup(dimension="model", tenant_id=<tenant_id>, days=31, limit=50)` and
   `reports_spend(tenant_id=<tenant_id>, days=31, grain="day", group_by="model")`.
5. **Run-level spend** (not tied to a CHIT or the release gate) = run total − all CHIT totals −
   release gate. Split it by Skill into: audit, documents (readout, proposal, application design,
   org health, QA summary, guides, weekly status), knowledge and intake, and other.
6. **Per point:** `reports_spend(tenant_id=<tenant_id>, days=31, grain="day", per_point=true)`.
7. **Budget:** `budget_status(tenant_id=<tenant_id>)` and `reports_budget_burn(tenant_id=<tenant_id>)`.
8. **Unpriced calls:** if any answer has `price_missing_calls` above zero, the totals leave real
   spend out. Run `llm_prices(model_id=<model id>)` for each model in those buckets, and log a
   platform finding.

## 6. Report tables

### 6.1 Run

| Item | USD | Calls | Unpriced calls |
|---|---|---|---|
| Run total (`cost_rollup` tenant) | | | |
| Run total (`reports_spend`) | | | |
| All CHITs | | | |
| Release gate | | | |
| Run-level: audit | | | |
| Run-level: documents | | | |
| Run-level: knowledge and intake | | | |
| Run-level: other | | | |
| Points used by the release | (points) | | |
| Spend per delivered point | | | |

### 6.2 Per CHIT and stage

| CHIT | Source | Triage | Design | Authoring and dev deploy | Review | Testing and QA | After ready | Total | Reworks |
|---|---|---|---|---|---|---|---|---|---|
| | | | | | | | | | |

### 6.3 Bundle

| Bundle | Member CHITs | Release gate | Total | Points |
|---|---|---|---|---|
| | | | | |

### 6.4 By model

| Model | USD | Input tokens | Output tokens | Cached tokens | Calls |
|---|---|---|---|---|---|
| | | | | | |

## 7. One-off reconciliation against GCP billing

Do this once, on Run 1, after the billing export has caught up (at least two days after the run
ends). It checks that the platform's cost records agree with what Google bills.

### 7.1 What the billing export holds

- The export lands in BigQuery dataset `lithe-bazaar-493713-p3:google_cloud_billing` (Terraform:
  `infra/terraform/shared/google_cloud_billing.tf`). Google writes it daily.
- The staging and production gateways run in the same GCP project, `lithe-bazaar-493713-p3`. So
  project-level billing mixes both environments and every tenant.
- Only model calls served through **Vertex AI** appear in GCP billing. A model the platform calls
  through Anthropic directly is billed by Anthropic and must be checked against the Anthropic
  Console usage report instead.

### 7.2 Steps (read only)

All commands only read. They run on Jim's machine with his gcloud identity.

1. **Find the table.** `powershell.exe -Command "bq ls lithe-bazaar-493713-p3:google_cloud_billing"`.
   Use the table whose name starts with `gcp_billing_export_v1_`. Write its full name into this
   file in a commit, so later reconciliations reuse it:
   `docs(scrimmage): record the billing export table`.
2. **Check for a tenant label.**
   ```sql
   SELECT l.key, COUNT(*) AS rows_with_key
   FROM `lithe-bazaar-493713-p3.google_cloud_billing.<export table from step 1>`, UNNEST(labels) AS l
   WHERE service.description = 'Vertex AI'
     AND usage_start_time >= TIMESTAMP('<run started_at>')
   GROUP BY l.key
   ```
3. **Billing for the run window.**
   ```sql
   SELECT DATE(usage_start_time) AS usage_day,
          sku.description AS sku,
          SUM(cost) AS cost_usd,
          SUM(IFNULL((SELECT SUM(c.amount) FROM UNNEST(credits) AS c), 0)) AS credits_usd
   FROM `lithe-bazaar-493713-p3.google_cloud_billing.<export table from step 1>`
   WHERE service.description = 'Vertex AI'
     AND project.id = 'lithe-bazaar-493713-p3'
     AND usage_start_time >= TIMESTAMP('<run started_at>')
     AND usage_start_time <  TIMESTAMP('<run ended_at>')
   GROUP BY usage_day, sku
   ORDER BY usage_day, sku
   ```
   Run it with `bq query --use_legacy_sql=false` through PowerShell.
4. **Platform side for the same window.**
   - If step 2 found a label that carries the tenant id, add `AND EXISTS (SELECT 1 FROM UNNEST(labels) l WHERE l.value = '<tenant_id>')`
     to step 3 and compare with the run total from section 5 (Vertex models only).
   - If not, billing cannot be split by tenant, and the comparison has to be at project level:
     every staging tenant plus every production tenant. The scrimmage never calls a production
     tool, and production totals include customer tenants. So **stop and ask Jim** to choose:
     1. Jim reads the production platform's total spend for the window himself and gives Claude
        the number, and Claude adds the staging total
        (`cost_rollup(dimension="tenant", days=<run length in days>)` on the Staging connector).
     2. Skip project level, and compare only the run's staging total with billing on the days
        when this run was the only staging activity. Name that limit in the report.
     3. Defer the reconciliation until the gateway labels Vertex calls with the tenant id, and log
        that as a FIX finding.
5. **Compare** by day and by model: platform USD against billing `cost_usd + credits_usd`.

### 7.3 Pass threshold (DRAFT, Jim to approve)

- The platform total is within 5% of the billed Vertex AI model cost for the same window, after
  removing `price_missing_calls` and any Anthropic-direct models.
- Expected sources of difference, to be named in the report: unit prices out of date
  (`llm_prices`), unpriced calls, non-model Vertex SKUs, billing lag, and the UTC day boundary.
- A larger gap is a platform finding (classification: platform) with both query results attached.
