# Dreamhouse Scrimmage Scorecard

Every run is scored the same way. Copy section 2 (the template) to
`scrimmage/operator/runs/run-<run>/scorecard.md` at the start of a run and fill it in as the run
goes. Section 3 (the enterprise-grade bar) is scored at the end.

Step numbers (such as 1.14) refer to `runbook.md`. Gap numbers (G1 to G17) are from
PHASE-SCRIM-01; N1 to N4 are new gaps found while writing the runbook.

## 1. Definitions

- **Human touch:** one action by Jim, as architect or as the customer's voice: a gate decision, a
  Slack card click, a GitHub review, a customer line, a Slack modal, a Login-As session, a resume,
  a signature. Count each one.
- **Manual workaround:** anything a person did because the platform could not. Every workaround has
  a GCR ticket (`finding-log.md`). Human gates the process requires (architect approvals, QA
  sign-off, resume, signature) are human touches, not workarounds.
- **First-time-right CHIT:** a CHIT that passed every gate on the first try. It fails if any of
  these happened:
  - Jim chose `request_changes` at the design gate or the PR gate.
  - The dev deploy needed a self-heal attempt, or a redeploy.
  - Dev verification failed or never started.
  - A browser probe failed, or the QA sign-off needed `override` or `delivery_signoff_waiver`.
  - The CHIT was split, merged, re-enriched or re-driven after a stall.
  - Its bundle deploy failed for it in any environment.
  Source: `chits_history(chit_id=<chit_id>, tenant_id=<tenant_id>, limit=200)` and
  `delivery_state(chit_id=<chit_id>, tenant_id=<tenant_id>)` per CHIT. Cross-check the plan gate
  with `reports_review_loops(tenant_id=<tenant_id>, days=31)`.
- **First-time-right rate:** first-time-right CHITs divided by all CHITs that reached
  `ready-for-release`, as a percentage.
- **Defect:** a failure in delivered work found in an environment: a failed deploy, a failing Apex
  test, a failed probe, a failed human test, or a release-audit `critical`. Count it against the
  environment where it was found. Sources: `chits_failed_deploys`, `evidence_get` per environment,
  `release_bundles_deploy_results`, Jim's Login-As results, `audits_get_run` on the release audit.

## 2. Run template

### 2.1 Run header

| Field | Value |
|---|---|
| Run number | |
| Started (UTC) | |
| Ended (UTC) | |
| chameleon-cloud main SHA | |
| Kit revision (samples.py pin) | `43a53d14eff9a11acae8a42fd18f329ea417ebb0` |
| Tenant id | |
| Bundle id | |
| Furthest stage reached | |
| Reached production? | yes / no |

### 2.2 Capability matrix

One row per capability from the SCRIM-01 matrix. Mark each **PASS**, **FAIL**, **PARTIAL** or
**NOT EXERCISED**, with the evidence file and any GCR ticket.

| # | Capability | Tools | Pass criterion | Result | Evidence | GCR |
|---|---|---|---|---|---|---|
| M1 | Standup: customer and project | `customers_create`, `projects_create`, `tenants_standup` | Customer active; Jira, GitHub and Drive created; every standup step succeeded (1.5, 1.6) | | | |
| M2 | Standup: Slack channels | `channels_provision`, `channels_list` | Internal and joint channels bound, Jim in both (1.9) | | | |
| M3 | Standup: Slack Connect invite | `tenants_onboard`, `tenants_connect_invite_change` | NOT EXERCISED: G13 accepted | NOT EXERCISED | | |
| M4 | Standup: tunnels | `tunnels_create_cert`, `tunnels_connect`, `tunnels_set_primary`, `tunnels_test` | Four slots connected as sandbox, prod primary, uat user testing, all sign in (1.10 to 1.12) | | | |
| M5 | Source | `source_retrieve`, `source_index`, `source_data_dictionary`, `drift_report` | Complete retrieve; every kit component indexed (2.1 to 2.3) | | | |
| M6 | Drift promote | `drift_promote` | Exercised only if drift appears; otherwise NOT EXERCISED | | | |
| M7 | Audit | `audits_start`, `audits_status`, `audits_get_run` | Full audit of all eight dimensions succeeded (3.1) | | | |
| M8 | Audit detection | `audits_get_run` | Planted defects found, out of 9 (1, 2a, 2b, 3 to 8): record the count (3.2) | | | |
| M9 | Audit repair | `audits_set_dispositions`, `audits_execute` | No undecided finding; one repair CHIT per `fix` (3.3, 3.4) | | | |
| M10 | Opportunity | `opportunities_create` (G1) or Slack modal; `opportunities_change` | Opportunity open with home tenant set (4.1, 4.2). PARTIAL if the Slack modal was used | | | |
| M11 | Intake | `documents_real_folder`, `ingest_status`, `inbound_files`, `evidence_browse` | Every discovery-pack file read (5.2) | | | |
| M12 | Knowledge | `knowledge_list`, `knowledge_search`, `knowledge_proposal_apply`, `knowledge_conflicts` | R1 to R8 accepted (5.3) | | | |
| M13 | Documents: application design and org health | `documents_generate`, `documents_review` | Both drafts written (2.4, 3.5) | | | |
| M14 | Documents: readout | `documents_generate`, `documents_review`, `documents_decide`, `documents_share` | Approved by Jim, decided by the customer (6.1 to 6.3) | | | |
| M15 | Documents: proposal and decomposition | `documents_generate`, `documents_decide`, `opportunities_change(decompose_proposal_id)` | Approved; one CHIT per workstream; R1 to R8 traced (7.1 to 7.3) | | | |
| M16 | CHIT triage | `chits_runs`, `chits_get` | Every CHIT triaged with acceptance criteria (8.1) | | | |
| M17 | Clarifications over Slack | `clarifications_pending`, `clarifications_answer` | R2 clarification asked and answered in Slack; CHIT resumed (8.2) | | | |
| M18 | Design gate | `chits_gate_decision` or the Slack plan card | Every CHIT approved at the plan gate (8.3) | | | |
| M19 | Autonomous authoring and dev deploy with self-heal | `chits_get`, `delivery_state`, `chits_failed_deploys` | Every CHIT authored, deployed to dev and got a PR with no hand edits (8.4) | | | |
| M20 | PR gate | GitHub review or `chits_gate_decision`; `chits_pr_get` | Every PR reviewed by CA and approved (8.5) | | | |
| M21 | Dev verification | `delivery_state`, `evidence_get` | Every CHIT verified in dev, zero failing tests (8.6) | | | |
| M22 | Personas and Login-As readiness | `tunnel_org_users`, `tunnel_persona_set`, `tunnel_login_readiness`, `tunnels_add_web_scope` | 15 bindings; readiness green on dev, qa, uat (1.13, 1.14) | | | |
| M23 | Persona testing | `delivery_test_run`, `evidence_get` | Passing probes per persona in dev; qa and uat as N3 allows (9.1, 10.4, 10.5) | | | |
| M24 | Human Login-As test | `org_login_link` then Salesforce Login-As | Jim tested every persona in dev, qa, uat (9.2, 10.4, 10.5). PARTIAL while G9 is interim | | | |
| M25 | QA sign-off | `delivery_qa_signoff` | Every CHIT signed off with no override; PR squash-merged (9.3) | | | |
| M26 | Release: assemble and audit | `release_bundles_assemble`, `release_bundles_get`, `release_bundles_audit` | One bundle with every CHIT; stops qa, uat, prod; release audit gate met (10.1, 10.2) | | | |
| M27 | Release: sign and schedule | `release_bundles_schedule`, `release_bundles_sign` | Scheduled, then signed after UAT (10.3, 10.6) | | | |
| M28 | Release: promote dev to qa to uat to prod | `release_bundles_resume`, `release_bundles_deploy_results` | Each stop deployed clean with zero test failures (10.4, 10.5, 10.7) | | | |
| M29 | Documents: release notes, QA summary, guides, weekly status | `documents_list`, `documents_generate`, `documents_review`, `documents_decide`, `documents_share`, `release_bundles_notes_edit` | Each passes its quality gates and is approved (11.1 to 11.4) | | | |
| M30 | Slack interaction | Slack cards and channels | Customer lines answered in the joint channel; plan and document cards actioned from Slack; notifications and stall alerts landed (whole run, 12.1) | | | |
| M31 | Ops visibility | `attention_queue`, `work_notices`, `activity_feed`, `reports_throughput`, `reports_spend`, `budget_status` | Each shows the run's work accurately; queue empty at the end (12.1) | | | |

Totals: PASS ___ / FAIL ___ / PARTIAL ___ / NOT EXERCISED ___ out of 31.

### 2.3 Time per stage

Times come from `run.json`. Active time excludes waits on Jim; record waits separately.

| Stage | Start (UTC) | End (UTC) | Elapsed | Waiting on Jim | Notes |
|---|---|---|---|---|---|
| 1 Standup | | | | | |
| 2 Retrieve and index | | | | | |
| 3 Audit and repair CHITs | | | | | |
| 4 Opportunity | | | | | |
| 5 Intake | | | | | |
| 6 Readout | | | | | |
| 7 Proposal and decomposition | | | | | |
| 8 CHIT lifecycle (first CHIT in to last CHIT verified) | | | | | |
| 9 Persona testing and QA sign-off | | | | | |
| 10 Release | | | | | |
| 11 Documents | | | | | |
| 12 Ops and close-out | | | | | |
| **Total** | | | | | |

### 2.4 Human touches

| Stage | Architect decisions | Customer lines | Login-As sessions | Other | Total |
|---|---|---|---|---|---|
| 1 to 12 (one row each) | | | | | |
| **Total** | | | | | |

### 2.5 Manual workarounds

Every row needs a GCR ticket.

| # | Stage and step | What was done by hand | Why the platform could not | Gap | GCR ticket |
|---|---|---|---|---|---|
| 1 | | | | | |

Expected in Run 1, unless fixed first: the opportunity Slack modal (G1), the fresh-org creation and
load by hand (open SCRIM-03 task), the human Login-As path (G9), the UAT sign-off message (G7), and
any requirement accepted outside the platform (N2).

### 2.6 CHITs and first-time-right

| CHIT | Source (requirement or plant) | Design gate 1st | Dev deploy 1st | PR gate 1st | Verified 1st | QA 1st | Bundle deploys clean | First-time-right |
|---|---|---|---|---|---|---|---|---|
| | | | | | | | | |

First-time-right rate: ___ of ___ = ___%.

### 2.7 Defects per environment

| Environment | Deploy failures | Failing tests | Failed probes | Failed human tests | Release-audit critical | Total |
|---|---|---|---|---|---|---|
| dev | | | | | | |
| qa | | | | | | |
| uat | | | | | | |
| prod | | | | | | |

### 2.8 Spend

Copy the totals from the spend report (`spend-report.md`): per run, per bundle, per CHIT, and the
stage split.

### 2.9 Accepted gaps for this run

| Gap | Recorded as |
|---|---|
| **G13** EXT, accepted for Run 1 (Jim, 2026-10-31) | Customer lines are posted as Jim. Every customer-role path (customer permissions, customer-only cards, the customer side of the Slack Connect channel, customer clarification audience) is **not exercised**. Matrix rows M3 and M30 note this. A pass on M14, M15 or M17 shows the flow works with staff identity only. |

### 2.10 Reset

The clean-slate checklist from `reset.md` section 6, ticked.

## 3. Enterprise-grade bar

**Approved by Jim on 2026-10-31. Run 1 is scored against this list and its thresholds.**

The checks are copied from PHASE-SCRIM-03. Each one says how it is measured and what passes.
Scope is the delivered change: every component in the bundle
(`release_bundles_deploy_results(bundle_id=<bundle_id>, tenant_id=<tenant_id>)`) and the tenant
repository diff between the baseline retrieve commit and the release merge on `main`.

G17 applies: no platform signal measures code quality on its own. So the code, security and
low-code checks are read from the code by the independent reviewer (check I1), helped by the
greps below.

Run the greps from a clone of the tenant repository at the release merge commit. Run `sf`
commands with `powershell.exe -Command "..."` on Jim's machine.

### 3.1 Code

| # | Check | How it is measured | Pass threshold |
|---|---|---|---|
| C1 | Practice standards resolved by the platform | `library_resolve_standards(work_context={"agent": "cd", "activity": "development", "metadata_types": ["ApexClass", "ApexTrigger", "Flow", "LightningComponentBundle", "CustomObject", "PermissionSet", "PermissionSetGroup", "NamedCredential"], "tenant_id": "<tenant_id>"})` lists the required Standards. Reviewer I1 grades each changed component against each required Standard. | The list is not empty, and zero violations of a required Standard |
| C2 | Apex coverage at least 90% per class | `sf apex run test --target-org dh-r<run>-uat --test-level RunLocalTests --code-coverage --result-format json --wait 30`. Read per-class coverage for every Apex class and trigger the bundle added or changed. Cross-check `evidence_get(chit_id=<chit_id>, env="dev", tenant_id=<tenant_id>)` `code_coverage_percent`. | Every added or changed class and trigger at 90% or more |
| C3 | 200-record bulk tests | Reviewer I1 reads the test classes in the diff. For each trigger, handler and service touched, find a test that inserts or updates at least 200 records in one DML. | One such test per touched trigger, handler and service |
| C4 | `System.runAs` persona tests | `git grep -n "System.runAs" -- "*.cls"` on the diff's test classes. Reviewer I1 checks each runs as a persona user built from the persona profiles. | At least one `System.runAs` test per class that checks permissions or sharing (including every R7 change) |
| C5 | No `SeeAllData` | `git grep -n -i "SeeAllData\s*=\s*true" -- "*.cls"` on the whole repository at the release merge. | Zero hits (plant 6 repaired) |
| C6 | Typed errors | Reviewer I1 checks every new exception extends one project base exception, and no `catch (Exception e)` swallows an error without rethrowing or logging. `git grep -n "catch (Exception" -- "*.cls"` lists the places to check. | Zero untyped throws; zero swallowed catches |
| C7 | No hard-coded Ids | `git grep -n -E "['>](0|a)[0-9A-Za-z]{14}([0-9A-Za-z]{3})?['<]" -- "*.cls" "*.trigger" "*.flow-meta.xml"` (15- or 18-character Ids with a standard or custom key prefix, quoted in Apex or as an XML value); reviewer I1 rules out false positives. Also the post-release audit (12.3) has no hard-coded-Id finding. | Zero real hits (plant 3 repaired) |

### 3.2 Security

| # | Check | How it is measured | Pass threshold |
|---|---|---|---|
| S1 | FLS and CRUD through permission sets and groups, not profiles | `git diff <baseline>..<release> --stat -- "*.profile-meta.xml"` and reviewer I1 reads each profile change. `source_index(tenant_id=<tenant_id>, type_name="PermissionSetGroup")` after the post-release retrieve. | No `objectPermissions` or `fieldPermissions` added to any profile; at least one permission set group exists; the persona object and field access the kit gave through profiles (plants 2a, 2b) now comes from permission sets |
| S2 | Sharing declared | `git grep -L -E "(with|without|inherited) sharing" -- "*.cls"` on added or changed non-test classes. Every `without sharing` has a reason in its ApexDoc. | Zero classes without a sharing keyword |
| S3 | No new security findings in a release audit | `audits_get_run(run_id=<release_audit_run_id>, dimension="security", tenant_id=<tenant_id>)`, and `audits_compare(run_a=<audit_run_id>, run_b=<post_audit_run_id>, tenant_id=<tenant_id>)` for the security dimension. | Zero security findings whose fingerprint was not in the baseline audit |

### 3.3 Low code

| # | Check | How it is measured | Pass threshold |
|---|---|---|---|
| L1 | Flows are bulk-safe | Reviewer I1 reads every added or changed `*.flow-meta.xml`: no Get Records, Create, Update or Delete element inside a loop. The post-release audit's automation dimension has no bulk finding on them. | Zero DML or query elements inside loops |
| L2 | Flows have fault paths | For every DML and action element in an added or changed flow, a `faultConnector` exists. Check with `git grep -c "<faultConnector>"` against the count of DML and action elements, then reviewer I1. | Every DML and action element has a fault path |
| L3 | No automation collisions with existing triggers | `audits_get_run(run_id=<post_audit_run_id>, dimension="automation", tenant_id=<tenant_id>)`. Reviewer I1 checks every object the bundle touched for a flow and a trigger on the same event. | Zero mixed flow-and-trigger findings on touched objects (plant 8 repaired) |

### 3.4 Testing

| # | Check | How it is measured | Pass threshold |
|---|---|---|---|
| T1 | Functional evidence per persona in dev, qa and uat | `evidence_get(chit_id=<chit_id>, env=<dev|qa|uat>, tenant_id=<tenant_id>)` for every CHIT. Where N3 blocks qa or uat probes, Jim's recorded Login-As results stand in, and the check is marked PARTIAL. | For every persona a CHIT's acceptance tests name, at least one passing probe in each of dev, qa and uat |
| T2 | Humans test through Login-As | In each of `dh-r<run>-dev`, `-qa` and `-uat`: `sf data query --target-org dh-r<run>-dev --json -q "SELECT CreatedDate, CreatedBy.Name, Display FROM SetupAuditTrail WHERE Action = 'suOrgAdminLogin' ORDER BY CreatedDate"`. | At least one Login-As by Jim for each of the four personas in each of dev, qa and uat |
| T3 | Zero failing tests at any gate | `evidence_get` (dev test run) per CHIT; `release_bundles_deploy_results` for qa, uat and prod. | Zero failing tests in every environment |

### 3.5 Release

| # | Check | How it is measured | Pass threshold |
|---|---|---|---|
| R1 | One signed bundle | `release_bundles_list(tenant_id=<tenant_id>)` and `release_bundles_get(bundle_id=<bundle_id>, tenant_id=<tenant_id>)`. | Exactly one bundle reached prod; it carries Jim's signature; it holds every enhancement and audit-repair CHIT |
| R2 | Release audit clean of high or critical findings | `audits_get_run(run_id=<release_audit_run_id>, severity="critical", tenant_id=<tenant_id>)` and `severity="warning"`. The platform has no `high` (N4). | Zero `critical`; zero `warning` left `undecided` |
| R3 | `release_notes` and `qa_delivery_summary` pass their quality gates | `documents_review(document_id=<document_id>, tenant_id=<tenant_id>)` for each. | Every quality gate passes; none holds publication; both approved |
| R4 | Rollback path stated | `release_bundles_get(bundle_id=<bundle_id>, tenant_id=<tenant_id>)`: read the release notes narrative and known risks. The platform does not roll back a release, so the path is a stated plan. | The notes name how to restore each changed component (for example: redeploy the previous `main` commit of each component) and who decides |
| R5 | Prod deploy validated with tests | `release_bundles_deploy_results(bundle_id=<bundle_id>, tenant_id=<tenant_id>)` for prod. | Tests ran (RunLocalTests) with zero failures; every component succeeded |
| R6 | Zero manual steps | Scorecard section 2.5. | Zero manual workarounds. Run 1 is expected to fail this while G1, G7 and G9 are open |

### 3.6 Traceability

| # | Check | How it is measured | Pass threshold |
|---|---|---|---|
| TR1 | Every component traces to a requirement, CHIT, PR, test evidence and sign-off | `opportunities_get(opportunity_id=<opportunity_id>, with_trace=true)` (readout, proposal, workstreams, CHITs). Per CHIT: `chits_get` (PR and release), `evidence_get`, `delivery_state` (sign-offs), `audit_trail(resource_id=<chit_id>, resource_kind="chit", tenant_id=<tenant_id>)`. Map every component in `release_bundles_deploy_results` to a CHIT. Map audit-repair CHITs to their finding fingerprints. | 100% of components traced; each of R1 to R8 maps to at least one CHIT; each repaired plant maps to a fingerprint and a CHIT |

### 3.7 Platform signals

| # | Check | How it is measured | Pass threshold |
|---|---|---|---|
| P1 | `robustness_bar` met | `robustness_bar(tenant_id=<tenant_id>, rejections=20)` at the start (1.15) and end (12.1). | No check disabled during the run; every CHIT the bar blocked was later written only after it passed |
| P2 | `chits_run_accuracy` reviewed | `chits_run_accuracy(tenant_id=<tenant_id>, window_days=31)`. | Reviewed and recorded with comments; no threshold |
| P3 | `documents_quality_report` reviewed | `documents_quality_report(tenant_id=<tenant_id>, days=31)`. | Reviewed and recorded with comments; no threshold |

### 3.8 Independent check

| # | Check | How it is measured | Pass threshold |
|---|---|---|---|
| I1 | A reviewer that never saw the build grades the delivered changes against this bar | Claude starts a fresh agent with no run context. It gets: this section, the tenant repository diff from the baseline commit to the release merge, the kit answer key, and the R1 to R8 requirement set. It does not get the run's conversation, CHIT designs or this scorecard's results. It returns pass or fail per check with file and line evidence. | Every check passes; no Critical or High defect found |

Result: ___ of 27 checks pass. The run is enterprise grade only when all 27 pass.
