# Dreamhouse Scrimmage Runbook

This runbook is the ordered run of one scrimmage. Claude drives the Chameleon Cloud platform
through its MCP tools. The platform takes the fictional customer Dreamhouse Homes from org
standup to a production release. Every run follows these steps in this order, so runs can be
compared on the scorecard (`scorecard.md`).

Read this whole file before starting a run. Then do the steps in order. Do not skip a gate.

## 0. Conventions

### 0.1 Which connector

- Use the **Chameleon Cloud Staging** connector only. In a Claude session its tools are named
  `mcp__claude_ai_Chameleon_Cloud_Staging__<tool>`. This runbook writes the bare `<tool>` name.
- Never call a `mcp__claude_ai_Chameleon_Cloud__<tool>` tool. That is production.
- Never act on the Xyla tenant (`tenant-7df2ceb8`) or any customer tenant. Every call that takes a
  `tenant_id` passes this run's `<tenant_id>` explicitly, even when the tool says it is optional.

### 0.2 Where tool names come from

`api/mcp-contract.json` in chameleon-cloud lists the gateway routes the MCP calls. It does not
list MCP tool names. Every tool name and argument here was checked against the MCP server source,
`services/mcp/chameleon_mcp/` (269 tools), at chameleon-cloud main `b3004b2ff`. Before each run,
pull main and re-check any tool whose step fails with an unknown-argument error.

### 0.3 The preview-then-confirm pattern

Almost every write tool works in two calls:

1. Call it without `confirm_token`. Nothing changes. It returns a preview and a `confirm_token`.
2. Read the preview. If it matches the step's expected result, call again with the same
   arguments plus `confirm_token`.

A step written as "`tool(args)` (confirm)" means both calls. Save both answers as evidence.
If the preview shows something the step does not expect, stop and log a finding
(`finding-log.md`).

### 0.4 Actors

| Actor | Meaning |
|---|---|
| **Claude** | Claude calls the MCP tool or runs the command. |
| **Jim (architect)** | Jim makes the decision. He acts on the Slack card or GitHub, or tells Claude the decision and the reason, and Claude makes the call with Jim's words as the `reason`. Record which surface was used. |
| **Customer (posted as Jim)** | A line from the customer Slack script in `scrimmage/customer/`. It is posted in the joint channel under Jim's Slack identity: by Jim, or by Claude through the Slack connector (`slack_send_message`) when Jim has allowed that for the run. G13 (accepted): customer-role paths are not exercised. |

Every Jim action and every customer line counts as one **human touch** on the scorecard.

### 0.5 Run-specific tokens

Only these tokens appear in commands. Replace each with the value from this run.

| Token | Value |
|---|---|
| `<run>` | Two-digit run number: `01`, `02` and so on |
| `<tenant_id>` | From `projects_create` in step 1.6 |
| `<admin_username>` | The scratch org admin username for a slot, from step 1.3 |
| `<consumer_key>` | From `attach-cert` in step 1.10 |
| `<user_id>` | A Salesforce user id from `tunnel_org_users` |
| `<retrieve_run_id>`, `<audit_run_id>`, `<release_audit_run_id>`, `<post_audit_run_id>` | Run ids returned by the tools |
| `<fingerprint>` | An audit finding fingerprint |
| `<opportunity_id>`, `<document_id>`, `<generation>`, `<version>` | Returned by the tools |
| `<chit_id>`, `<bundle_id>`, `<request_id>`, `<clarification_ref>`, `<question_id>`, `<probe_id>` | Returned by the tools |
| `<conversation_id>`, `<proposal_id>` | From the Slack conversation that drafted a knowledge proposal |
| `<workspace_id>`, `<internal_channel_id>`, `<joint_channel_id>` | From `channels_list` |

### 0.6 Evidence

- Save evidence in the kit worktree under `scrimmage/operator/runs/run-<run>/`.
- `run.json` holds every id this run creates: tenant, org aliases and usernames, channel ids,
  opportunity, CHITs, bundle, audit runs, documents, and each stage's start and end time in UTC.
  `reset.md` reads it to know what to delete.
- Save each tool answer as `evidence/S<stage>.<step>-<tool>.json`. Save screenshots as `.png`
  beside them.
- Never save secrets. `org_login_link` returns a one-time login link: hand it to Jim once and do
  not write it down. Do not save private keys. Consumer keys and public certificates stay in the
  scratchpad, not in the repo.
- Commit the evidence at the end of each stage:
  `docs(scrimmage): add run <run> stage <n> evidence`.

### 0.7 Waiting

Long jobs (retrieve, audit, authoring, deploys, bundle moves) run in the background. To wait,
re-call the read tool named in the step. `audits_status` takes `wait_seconds` up to 55. For the
others, use the Monitor tool with a loop that re-reads, or re-call every two to five minutes. Do
not use a foreground `sleep`.

### 0.8 Gap labels

Gaps come from PHASE-SCRIM-01 and use the agreed labels: **FIX** (fix in the loop), **CFG**
(runbook or config), **MAN** (accepted manual step, logged), **EXT** (needs something outside the
platform). Gaps this runbook found that SCRIM-01 does not list are numbered **N1** onwards and
carry a proposed label that Jim has not agreed yet.

### 0.9 When a step fails

1. Save the evidence.
2. Try again once, changing one thing, if the failure looks transient.
3. After two failed attempts, stop. Do the structured analysis in `finding-log.md` and file a GCR
   finding before a third attempt.
4. Never hand-fix the tenant or the org without a scorecard entry and a GCR ticket.

---

### 0.10 Customer inputs and scoring

The customer's words come only from `scrimmage/customer/`. Jim posts each line in the shared channel, starting it with "**Laura Brennan (Dreamhouse Homes):**". Scoring uses `scrimmage/answer-key/expected-outcomes.md` together with `data/ANSWER_KEY.md`, and neither file is shown to the platform.

| Stage | Customer input | Slack script turn |
|---|---|---|
| 1.9 Slack channels ready | Kickoff | Turn 1 |
| 3.2 Audit findings shared | Reaction to the audit | Turn 2 |
| 5.1 Discovery intake | Upload every file in `customer/discovery-pack/` unchanged | None |
| 8.2 R2 clarification, only when the platform asks | Reservation window | Turn 3 |
| 8.2 R8 clarification, only when the platform asks | What "faster" means | Turn 4 |
| 6.3 Readout decision | Request changes, then approve the revision | Turns 5 and 6 |
| 7.2 Proposal decision | Approve | Turn 7 |
| 8.x CHIT gate cards | Gate card rules | Turn 8 and section 3 |
| 9.2 / UAT | UAT invitation, feedback and fix confirmation | Turns 9 to 11 |
| 10 Production sign-off | Sign-off, then the release confirmed | Turns 12 and 13 |

Anything the platform asks that the script doesn't cover is answered from section 4 of the Slack script. If that can't answer it, the reply is the "Questions Laura can't answer" line. Every unscripted exchange is logged on the scorecard.

## Stage 1. Standup

Goal: a fresh staging tenant, four fresh scratch orgs (dev, qa, uat, prod) loaded with
`dreamhouse-brownfield`, four connected tunnels with prod as primary, persona bindings, and a
green `tunnel_login_readiness` on dev, qa and uat.

Every run uses **four fresh orgs**. Never reuse pool orgs (Jim, 2026-10-31).

> **Open SCRIM-03 task, no G-number (proposed MAN until built):** `staging_env.py` acquires pool
> orgs and has no fresh-org path. Until that path exists, steps 1.3 and 1.4 create and load the
> orgs by hand with `scratch_org.py`, and steps 1.5 to 1.12 do through the MCP what
> `staging_env.py` does through the gateway. The org side (create, load, attach the certificate)
> has no MCP tool: it is **EXT** (Salesforce CLI on Jim's machine).

### 1.1 Preflight

- **Actor:** Claude.
- **Tools:** `me_tenants()`; `tenants_overview(query="dreamhouse", status="active")`.
- **Expect:** Claude is signed in to staging. No active tenant from an earlier run.
- **Gate:** if an earlier Dreamhouse tenant is still active, stop and run `reset.md` first.
- **Evidence:** both answers. Write `run.json` with `run`, `started_at` and the chameleon-cloud
  main SHA (`git -C C:\Users\jh\Applications\chameleon-cloud rev-parse HEAD`).

### 1.2 Dev Hub headroom

- **Actor:** Claude (PowerShell).
- **Commands:**
  - `powershell.exe -Command "sf org list --json"`
  - `powershell.exe -Command "sf limits api display --target-org C360 --json"`
- **Expect:** Dev Hub `C360` (ccg-camp) is connected. `ActiveScratchOrgs` remaining is at least 9
  (four orgs plus the five that `scratch_org.py` keeps free). `DailyScratchOrgs` remaining is at
  least 4.
- **Gate:** if headroom is short, stop and tell Jim. Never use a customer Dev Hub (IPD, Xyla, ECP).
  G16 is settled: the Dev Hub is `C360`.
- **Evidence:** the `ActiveScratchOrgs` and `DailyScratchOrgs` rows.

### 1.3 Create four fresh scratch orgs (EXT)

- **Actor:** Claude (PowerShell), from `C:\Users\jh\Applications\chameleon-cloud` on main.
- **Commands,** one per slot (`dev`, `qa`, `uat`, `prod`):
  `powershell.exe -Command "python scripts/e2e/scratch_org.py create --alias dh-r<run>-dev --duration-days 14 --dev-hub C360"`
- **Expect:** each prints `alias`, `username`, `org_id`, `instance_url`, `consumer_key` and
  `expires`. The org also holds the standup seed project (`Project_Task__c`,
  `ProjectTaskEscalation`, `ProjectTaskTrigger`, `Project_Task_Access`) and the
  `Chameleon_Tunnel` External Client App.
- **Gate:** four orgs exist with distinct org ids.
- **Evidence:** the four outputs. Record each alias and `username` in `run.json` as the slot's
  `<admin_username>`.

### 1.4 Load `dreamhouse-brownfield` into each org (EXT)

- **Actor:** Claude (PowerShell), same folder.
- **Command,** one per alias:
  `powershell.exe -Command "python -c \"import sys; sys.path.insert(0, 'scripts/e2e'); import samples, scratch_org; print(scratch_org.load_sample('dh-r<run>-dev', samples.SAMPLES['dreamhouse-brownfield']))\""`
- **Expect:** each returns `sample: dreamhouse-brownfield`, revision `43a53d14eff9…`, and four
  personas: Sales Manager, Broker, Listing Coordinator, Minimum Access.
- **Check the load,** per alias:
  `powershell.exe -Command "sf data query -o dh-r<run>-dev --json -q 'SELECT COUNT() FROM Lot__c'"`
  and the same for `Home_Plan__c`, `Community__c`, `Offer__c`, `Showing__c`, `Property__c`,
  `Broker__c` and `Contact`.
- **Gate:** counts are 5 plans, 3 communities, 25 lots, 20 offers, 20 showings, 12 properties,
  8 brokers and 15 contacts in all four orgs. If any org differs, that is a kit finding.
- **Evidence:** the load outputs and a count table per org.

### 1.5 Customer

- **Actor:** Claude.
- **Tool:** `customers_list(limit=100)`.
- **If `dreamhouse-homes` is missing** (first run only):
  `customers_create(customer_id="dreamhouse-homes", name="Dreamhouse Homes", classification="internal_lab", reason="Fictional customer for the repeatable Dreamhouse scrimmage")` (confirm).
- **Expect:** `dreamhouse-homes` is listed and `active`. Later runs reuse it. There is no
  customer delete tool, so the customer stays.
- **Gate:** active customer.
- **Evidence:** the list answer.

### 1.6 Project and tenant

- **Actor:** Claude.
- **Tool:** `projects_create(customer_id="dreamhouse-homes", company_name="Dreamhouse Homes", reason="Scrimmage run <run>: Dreamhouse Homes from standup to production", jira_project_key_override="DHR<run>", github_repo_name_override="client-dreamhouse-homes-r<run>", enable_autonomous_authoring=true)` (confirm).
- Do not pass `website`. The customer is fictional, so no research dossier is wanted.
- **Expect:** a `tenant_id`, a Jira project `DHR<run>`, a GitHub repository and a Drive folder.
- **Then:** `tenants_standup(tenant_id=<tenant_id>)`, `projects_inspect(tenant_id=<tenant_id>)`,
  and `projects_verify_github(ref=<the repository URL from projects_create>)`.
- **Gate:** every standup ledger step succeeded. The repository exists and is private.
- **G11 CFG:** autonomous authoring is off by default. It is turned on here. Step 1.7 checks the
  switch. Stage 8 checks that the worker actually authors.
- **Evidence:** all four answers. Record `<tenant_id>`, the Jira key and the repository URL in
  `run.json`.

### 1.7 Tenant switches

- **Actor:** Claude.
- **Tool:** `tenant_settings(tenant_id=<tenant_id>)`.
- **Expect:** `autonomous_authoring_enabled`, `chits_enabled` and `release_deploys_enabled` are
  true.
- **If any is false:** `tenant_settings_change(tenant_id=<tenant_id>, reason="Scrimmage run <run> needs authoring, CHITs and release deploys", autonomous_authoring_enabled=true, chits_enabled=true, release_deploys_enabled=true)` (confirm). Log a CFG finding, because `projects_create` should have set authoring.
- **Also set:** `tenant_settings_change(tenant_id=<tenant_id>, reason="Require verification in every pre-production environment", verification_required_envs=["dev","qa","uat"])` (confirm).
  This is config only. **G8 FIX** still stands: bundle promotion checks `deployed`, not
  verification, so stage 10 checks verification by hand before each resume.
- **G14 CFG and N1 (proposed FIX):** SCRIM-01 says set the tenant coverage bar to 90. No MCP tool
  sets it: the bar is `sf.apex_coverage_min_percent` on the tenant, and `tenant_settings_change`
  has no argument for it. Leave it at the default 75. The scorecard measures 90% per class
  directly (check C2).
- **Evidence:** before and after settings.

### 1.8 Branches

- **Actor:** Claude.
- **Tool:** `projects_ensure_dev_branch(tenant_id=<tenant_id>, reason="Scrimmage run <run>: dev, qa and uat branches before the first retrieve")` (confirm).
- **Expect:** `dev` is the default branch. `qa` and `uat` exist. All three are protected.
- **Gate:** all three branches exist.
- **Evidence:** the answer.

### 1.9 Slack channels

- **Actor:** Claude.
- **Tool:** `channels_provision(tenant_id=<tenant_id>, change="provision", kinds=["internal","joint"], extra_emails=["jim@weareccg.io"], test_environment=true, reason="Scrimmage run <run>: internal and customer channels for Dreamhouse Homes")` (confirm).
- `test_environment=true` is required. Without it, `reset.md` cannot archive the channels.
- **Then:** `channels_list(tenant_id=<tenant_id>)`.
- **Expect:** one internal and one joint channel, with Jim in both.
- **G13 EXT (accepted):** no Slack Connect invite is sent, because the customer has fake emails.
  Do not call `tenants_onboard` with a `customer_email`. The Connect-invite part of the matrix row
  is recorded as not exercised.
- **Evidence:** both answers. Record `<workspace_id>`, `<internal_channel_id>` and
  `<joint_channel_id>` in `run.json`.

### 1.10 Tunnels: certificate, org trust, connect (per slot)

Do this for `dev`, `qa`, `uat` and then `prod`.

1. **Claude:** `tunnels_create_cert(slot="dev", tenant_id=<tenant_id>)`. Save `cert_pem` to
   `<scratchpad>\dh-r<run>-dev.pem`. This is the public certificate only.
2. **Claude (EXT, PowerShell):**
   `powershell.exe -Command "python scripts/e2e/scratch_org.py attach-cert --alias dh-r<run>-dev --cert-file <scratchpad>\dh-r<run>-dev.pem"`.
   It prints `consumer_key`.
3. **Claude:** `tunnels_connect(slot="dev", consumer_key=<consumer_key>, integration_username=<admin_username>, environment="sandbox", is_primary=false, tenant_id=<tenant_id>)` (confirm).
   For `prod`, pass `is_primary=true`.
   Scratch orgs sign in through test.salesforce.com, so `environment` is always `sandbox`.

- **Expect:** each connect signs in and succeeds. Salesforce can refuse the first JWT for about
  ten seconds after the app deploys. If the confirm call fails on sign-in, wait 30 seconds and
  confirm again once.
- **Gate:** all four slots connected.
- **Evidence:** each create, attach and connect answer, without the PEM body.

### 1.11 Primary and user-testing environment

- **Actor:** Claude.
- **Tools:** `tunnels_status(tenant_id=<tenant_id>)`.
  - If prod is not primary: `tunnels_set_primary(slot="prod", role="primary", tenant_id=<tenant_id>, reason="Production org is the primary, so retrieve and release stops cover dev to prod")` (confirm).
  - Always: `tunnels_set_primary(slot="uat", role="user_testing", tenant_id=<tenant_id>, reason="Customer user testing happens in UAT, not production")` (confirm).
- **Why the second call:** with no user-testing slot named, user testing uses the primary, which
  is prod. The admin and user guides are written when a bundle reaches user testing, so it must
  be uat.
- **G5 CFG:** release stops come from connected slots up to the primary. With all four connected
  and prod primary, the stops are qa, uat and prod. Stage 10 asserts this.
- **Gate:** `tunnels_status` shows four connected slots, prod primary, uat as user testing.
- **Evidence:** the status answer.

### 1.12 Tunnel sign-in test

- **Actor:** Claude.
- **Tool:** `tunnels_test(slot=<each slot>, tenant_id=<tenant_id>, reason="Scrimmage run <run> standup check")` (confirm), for all four.
- **Gate:** every slot signs in.
- **Evidence:** four answers.

### 1.13 Persona bindings (dev, qa, uat)

Do this for `dev`, `qa` and `uat`. Prod has no persona bindings.

1. **Claude:** `tunnel_org_users(slot="dev", tenant_id=<tenant_id>, is_active=true, search=<last name>)`
   for Whitfield, Menon, Alvarez and Doyle. Note each `<user_id>`.
2. **Claude:** `tunnel_persona_set(slot="dev", persona=<label>, user_id=<user_id>, tenant_id=<tenant_id>, reason="Scrimmage run <run> persona binding")` (confirm), for:

   | Persona label | User | Profile |
   |---|---|---|
   | `default` | Dana Whitfield | Dreamhouse Sales Manager |
   | `Sales Manager` | Dana Whitfield | Dreamhouse Sales Manager |
   | `Broker` | Ravi Menon | Dreamhouse Broker |
   | `Listing Coordinator` | Kim Alvarez | Dreamhouse Listing Coordinator |
   | `Minimum Access` | Pat Doyle | Dreamhouse Minimum Access |

3. **Claude:** `tunnel_personas(slot="dev", tenant_id=<tenant_id>)`.

- **Expect:** five bindings per slot. Each profile fits its label.
- **Gate:** 15 bindings in total.
- **Evidence:** the three `tunnel_personas` answers.

### 1.14 Login-As readiness gate (SCRIM-06 Run 1 gate)

- **Actor:** Claude.
- **Tool:** `tunnel_login_readiness(slot=<dev|qa|uat>, tenant_id=<tenant_id>)`.
- **Expect:** all four checks pass on each slot: Login-As policy (from the kit's
  Security.settings), Manage Users on the integration user, the Web scope on the app, and the
  `default` persona.
- **If only the Web scope fails:** `tunnels_add_web_scope(slot=<slot>, tenant_id=<tenant_id>, reason="Login-As needs the Web scope")` (confirm), then check again. Log a CFG finding, because new connections should already ask for Web.
- **Any other failure:** a kit finding. Stop at the gate.
- **Gate:** green on dev, qa and uat. This is the Run 1 gate moved from SCRIM-02.
- **Evidence:** three answers.

### 1.15 Baselines

- **Actor:** Claude.
- **Tools:** `budget_status(tenant_id=<tenant_id>)`, `tenant_health(tenant_id=<tenant_id>)`,
  `tenant_roles(tenant_id=<tenant_id>)`, `robustness_bar(tenant_id=<tenant_id>, rejections=0)`.
- **Expect:** calls are not blocked. Jim holds Owner on the tenant (Tester or above is needed for
  persona binding and QA sign-off). Note which robustness checks are on.
- **Gate:** `calls_blocked` is false.
- **Evidence:** four answers. Record the stage end time.

---

## Stage 2. Source retrieve and index

### 2.1 Full retrieve

- **Actor:** Claude.
- **Tool:** `source_retrieve(tenant_id=<tenant_id>)` (confirm). No `slot`: this is the full
  retrieve of the primary (prod) org, and it commits the snapshot onto the production branch.
- **Wait:** `source_retrieves(tenant_id=<tenant_id>, limit=5)` until the newest retrieve is done.
- **Expect:** `done`, `complete` (not partial), slot prod, a commit.
- **Gate:** complete. A partial retrieve is a finding: record what came back short.
- **SCRIM-05 check:** the retrieve must not become the dev baseline by mistake. Record the slot
  and branch it committed to.
- **Evidence:** both answers.

### 2.2 Index

- **Actor:** Claude.
- **Tools:**
  - `source_runs(tenant_id=<tenant_id>)`. Record the newest `<retrieve_run_id>` as the baseline.
  - `source_index(tenant_id=<tenant_id>)` for counts by type and tag.
  - `source_index(tenant_id=<tenant_id>, type_name="ApexTrigger")` and `type_name="Flow"`.
  - `source_data_dictionary(tenant_id=<tenant_id>, object="Offer__c")`.
- **Expect:** at least these kit components, plus the standup seed project:
  - ApexClass: the 14 kit classes plus `ProjectTaskEscalation`.
  - ApexTrigger: `OfferTrigger` plus `ProjectTaskTrigger`.
  - Flow: `Create_property`, `Offer_Stamp_Accepted_Date`, `Showing_Follow_Up_Task`.
  - Custom objects: `Broker__c`, `Community__c`, `Home_Plan__c`, `Lot__c`, `Offer__c`,
    `Property__c`, `Showing__c`, plus `Project_Task__c`.
  - Profiles: Admin and the four Dreamhouse profiles. Permission set `dreamhouse`.
  - `Offer__c` has `Amount__c`, `Status__c`, `Expiration_Date__c` and `Accepted_Date__c`, and the
    validation rule `Expiration_Date_Must_Be_Future`.
- **Gate:** every kit component is in the index. A missing one is a finding (platform or kit).
- **Evidence:** all answers.

### 2.3 Drift baseline

- **Actor:** Claude.
- **Tool:** `drift_report(tenant_id=<tenant_id>)`.
- **Expect:** no drift, or none yet scanned. Do not promote anything here.
- **Evidence:** the answer.

### 2.4 Describe the existing application

- **Actor:** Claude.
- **Tool:** `documents_generate(document_type="application_design_document", tenant_id=<tenant_id>, reason="Scrimmage run <run>: describe the Dreamhouse org as retrieved")` (confirm).
- **Then:** `documents_list(tenant_id=<tenant_id>, document_type="application_design_document")`
  and `documents_review(document_id=<document_id>, tenant_id=<tenant_id>)` once it is written.
- **Expect:** a draft that names the resale (Property, Broker, Offer, Showing) and new-construction
  (Community, Lot, Home Plan) sides.
- **Gate:** draft exists. Approval is not needed to move on.
- **Evidence:** the review answer. Record the stage end time.

---

## Stage 3. Full audit, dispositions and audit-repair CHITs

### 3.1 Start the full audit

- **Actor:** Claude.
- **Tool:** `audits_start(trigger="manual", tenant_id=<tenant_id>)` (confirm). Leave out
  `dimensions` to get all eight: code, automation, security, data_model, performance, integration,
  ux_maintainability and compliance.
- **Expect:** the preview gives the scope and an estimated cost. Record the estimate.
- **Wait:** `audits_status(run_id=<audit_run_id>, wait_seconds=55, tenant_id=<tenant_id>)`, repeated
  until it ends.
- **Gate:** the run succeeded and covered all eight dimensions. A stalled run is a finding.
- **Evidence:** start preview, final status. Record `<audit_run_id>`.

### 3.2 Read and score the findings

- **Actor:** Claude.
- **Tools:** `audits_get_run(run_id=<audit_run_id>, tenant_id=<tenant_id>, limit=100)` and further
  pages with `offset`. Use `audits_get_finding(fingerprint=<fingerprint>, tenant_id=<tenant_id>)`
  for detail.
- **Score against the kit answer key** (`data/ANSWER_KEY.md`, planted defects 1, 2a, 2b, 3, 4, 5,
  6, 7, 8). For each plant, record the matching finding fingerprint, its dimension and severity,
  or "missed".
- **Expect:** each plant is found in or near its expected dimension. The answer key's expected
  severities (High, Medium, Low) do not match the platform's scale (`critical`, `warning`,
  `info`; N4). Record the platform severity beside the expected one; do not score a mismatch.
- **Gate:** none. A missed plant is a platform finding, but the run goes on.
- **Evidence:** all pages and the plant-to-finding table.

### 3.3 Dispositions

- **Actor:** Jim (architect) decides. Claude records each decision.
- **Rules for Run 1:**
  - `fix` for every finding that matches a planted defect.
  - `ignore` for findings on the standup seed project (`Project_Task__c`, `ProjectTaskEscalation`,
    `ProjectTaskTrigger`, `Project_Task_Access`) and the `Chameleon_Tunnel` app, with the reason
    "standup seed, not part of the customer org".
  - Anything else: Jim decides `fix`, `ignore` or `refute` and gives the reason.
- **Tool:** `audits_set_dispositions(run_id=<audit_run_id>, fingerprints=[...], disposition="fix", reason=<Jim's reason>, tenant_id=<tenant_id>)` (confirm). One call per disposition, up to 100 fingerprints each.
- **Gate:** no finding left `undecided`. Check with `audits_get_run`.
- **Evidence:** each call and the final counts by disposition.

### 3.4 Raise the audit-repair CHITs

- **Actor:** Claude.
- **Tool:** `audits_execute(run_id=<audit_run_id>, tenant_id=<tenant_id>)` (confirm).
- **Then:** `chits_list(tenant_id=<tenant_id>, limit=50)`.
- **Expect:** one CHIT per `fix` finding. Each enters triage.
- **Gate:** the CHIT count equals the `fix` count. Record each `<chit_id>` against its fingerprint
  and plant number in `run.json`.
- **Evidence:** both answers.

### 3.5 Org health assessment

- **Actor:** Claude.
- **Tool:** `documents_generate(document_type="org_health_assessment", tenant_id=<tenant_id>, reason="Scrimmage run <run>: health assessment from the baseline audit")` (confirm).
- **Then:** `documents_review(document_id=<document_id>, tenant_id=<tenant_id>)`.
- **Expect:** the draft cites the planted defects found in 3.2.
- **Evidence:** the review answer. Record the stage end time.

The audit-repair CHITs now run through Stage 8 alongside the enhancement CHITs.

---

## Stage 4. Opportunity creation

**G1 FIX (fix before run, SCRIM-05):** the MCP has no `opportunities_create` at main `b3004b2ff`.

### 4.1 Create the opportunity

- **Before the run:** check `services/mcp/chameleon_mcp/opportunity_tools.py` on main for
  `opportunities_create`.
  - **If it exists (preferred):** Claude calls it with customer `dreamhouse-homes`, name
    `Dreamhouse Homes Phase 1 (run <run>)`, type project, and home tenant `<tenant_id>`. Commit
    the exact arguments into this step first: `docs(scrimmage): record opportunities_create args`.
  - **Until then:** Jim runs the Slack modal `/chameleon opp new` (limited to jd, jim and
    abhilash). Customer: Dreamhouse Homes. Name: `Dreamhouse Homes Phase 1 (run <run>)`. Type:
    project. Log this as a human touch and a manual workaround against the G1 GCR ticket.
- **Do not** use the CRM-sync route. It would put a fictional customer into ccg-camp production.

### 4.2 Link it to the tenant

- **Actor:** Claude.
- **Tools:** `opportunities_list(customer_id="dreamhouse-homes", with_documents=true)`. Find
  `<opportunity_id>`.
- If its home tenant is not `<tenant_id>`:
  `opportunities_change(opportunity_id=<opportunity_id>, home_tenant_id=<tenant_id>, tenant_ids=[<tenant_id>], reason="Scrimmage run <run> works in this tenant")` (confirm).
- **Then:** `opportunities_get(opportunity_id=<opportunity_id>)`.
- **Gate:** status `open`, home tenant `<tenant_id>`.
- **Evidence:** the answers. Record `<opportunity_id>` and the stage end time.

---

## Stage 5. Discovery pack intake

The discovery pack (notes, email thread, spreadsheet) is in `scrimmage/customer/` on the kit
branch. The customer Slack script there says when each piece is sent.

### 5.1 Customer sends the pack

- **Actor:** Customer (posted as Jim).
- **Drive route (the matrix route):**
  1. Claude: `documents_real_folder(section="01-Inbound", tenant_id=<tenant_id>)`. Note the
     folder.
  2. Jim, or Claude with the Google Drive connector, uploads each pack file into that folder.
     This upload has no Chameleon tool. It is the customer's own action.
- **Slack route:** the customer's opening message and any attachment the script names are posted
  in the joint channel.

### 5.2 Ingest

- **Actor:** Claude.
- **Tools:** `ingest_status(tenant_id=<tenant_id>)`, `inbound_files(tenant_id=<tenant_id>)` (for
  Slack attachments), `evidence_browse(tenant_id=<tenant_id>)`.
- **Expect:** the Drive source has run and put content in the corpus. Every pack file is listed
  as read, not unread or pending.
- **Gate:** every pack file is read. "Never run" is a finding.
- **Evidence:** all three answers.

### 5.3 Requirements become knowledge

- **Actor:** Claude reads. Jim (architect) accepts.
- **Tools:** `knowledge_list(tenant_id=<tenant_id>, item_type="requirement")`, then
  `knowledge_search(tenant_id=<tenant_id>, query="Dreamhouse Homes requirements for lots, reservations, deposits, pre-qualification, offers and permissions")` once.
- **Expect:** candidate requirements that cover R1 to R8 from the approved requirement set.
- **Accepting candidates:** a candidate is accepted through a knowledge proposal, with
  `knowledge_proposal_apply(conversation_id=<conversation_id>, proposal_id=<proposal_id>, reason=<Jim's reason>, tenant_id=<tenant_id>)` (confirm).
- **N2 (proposed MAN for Run 1, FIX candidate):** no MCP tool lists pending knowledge proposals.
  `<conversation_id>` and `<proposal_id>` come only from the Slack conversation that drafted the
  proposal. Jim reads them from Slack. If no proposal is drafted, log a finding and record which
  requirements stayed `candidate`.
- **Also read:** `knowledge_conflicts(tenant_id=<tenant_id>)`. R6 (late counter-offers on expired
  offers) conflicts with planted defect 5. Record whether the platform sees the conflict.
- **Gate:** R1 to R8 are each held as an `accepted` requirement
  (`knowledge_list(tenant_id=<tenant_id>, status="accepted", item_type="requirement")`).
- **Evidence:** the lists before and after, and the conflicts answer. Record the stage end time.

---

## Stage 6. Opportunity readout

**G2 CFG:** the readout needs an audit report. Stage 3 made one.
**G3 CFG:** the order is intake, then readout, then architect approval, then customer decision,
then proposal.

### 6.1 The readout draft

- **Actor:** Claude.
- **Tools:** `documents_list(tenant_id=<tenant_id>, document_type="opportunity_readout")`. The
  readout regenerates as content lands, so it may already exist.
  - If none: `documents_generate(document_type="opportunity_readout", tenant_id=<tenant_id>, reason="Scrimmage run <run>: readout after audit and discovery intake")` (confirm).
- **Then:** `documents_review(document_id=<document_id>, tenant_id=<tenant_id>)` and
  `documents_draft(document_id=<document_id>, generation=<generation>, tenant_id=<tenant_id>)`.
- **Expect:** the draft states audit findings and the accepted requirements. No quality gate holds
  publication.
- **Gate:** draft ready for architect review.

### 6.2 Architect approval

- **Actor:** Jim (architect). Preferred surface: the document card in Slack, whose Approve asks for
  a reason. Otherwise Claude calls
  `documents_decide(document_id=<document_id>, decision="approve", generation=<generation>, reason=<Jim's reason>, tenant_id=<tenant_id>)`.
- **Gate:** published. If Jim sends it back (`request_changes`), the readout is not first-time-right.
  Wait for the next generation and repeat 6.1.

### 6.3 Customer decision

- **Actor:** Claude shares, then the customer decides.
- After approval the readout goes to the customer channel for a decision. If it has not landed
  there within ten minutes:
  `documents_share(document_id=<document_id>, version=<version>, change="share", tenant_id=<tenant_id>, reason="Readout for the customer's decision")` (confirm). Log a finding: it should post itself.
- **Customer (posted as Jim):** the decision line from the Slack script.
- **Gate:** `opportunities_list(customer_id="dreamhouse-homes", with_documents=true)` shows the
  readout decided.
- **Evidence:** review, decision, share and list answers, and a screenshot of the customer
  channel. Record the stage end time.

---

## Stage 7. Solution proposal and decomposition

### 7.1 The proposal draft

- **Actor:** Claude.
- **Tool:** `documents_generate(document_type="solution_proposal", tenant_id=<tenant_id>, reason="Scrimmage run <run>: proposal from the approved readout")` (confirm). It is written from the approved readout.
- **Then:** `documents_review(document_id=<document_id>, tenant_id=<tenant_id>)` and `documents_draft`.
- **Expect:** pointed workstreams that cover R1 to R8 and the audit repairs they depend on (R5 on
  plant 1, R7 on plant 2a).
- **Gate:** draft ready, no gate holding publication.

### 7.2 Architect approval and customer decision

- **Jim (architect):** approve on the Slack card, or Claude calls
  `documents_decide(document_id=<document_id>, decision="approve", generation=<generation>, reason=<Jim's reason>, tenant_id=<tenant_id>)`.
- **Claude:** if it does not reach the customer channel,
  `documents_share(document_id=<document_id>, version=<version>, change="share", tenant_id=<tenant_id>, reason="Proposal for the customer's decision")` (confirm), and log a finding.
- **Customer (posted as Jim):** the approval line from the Slack script.
- **Gate:** proposal approved and published.

### 7.3 Decompose into CHITs

- **G4 (resolved after Sprint 44):** an approved proposal decomposes into one CHIT per workstream.
- **Actor:** Claude.
- **Tools:**
  - `opportunities_get(opportunity_id=<opportunity_id>, with_trace=true)`. Note the workstreams.
  - `opportunities_change(opportunity_id=<opportunity_id>, decompose_proposal_id=<document_id>, tenant_id=<tenant_id>, reason="Scrimmage run <run>: one CHIT per approved workstream")` (confirm).
  - `opportunities_get(opportunity_id=<opportunity_id>, with_trace=true)` again.
- **Expect:** one CHIT per workstream, each tied to the opportunity. Each CHIT goes to the design
  gate before any plan.
- **Gate:** CHIT count equals workstream count. Every requirement R1 to R8 traces to at least one
  CHIT. Record each `<chit_id>` against its requirement in `run.json`.
- **Evidence:** all answers. Record the stage end time.

---

## Stage 8. CHIT lifecycle (per CHIT)

Run this for every CHIT: the audit repairs from 3.4 and the enhancements from 7.3. CHITs run in
parallel. Keep a per-CHIT row in `run.json` with the time it entered each state and whether it
passed each gate first time.

States: `triaging` → `awaiting-answers` (if questions) → `blocked-on-approval` (design gate) →
`in-flight` (authoring and dev deploy) → `awaiting-review` → `ca_reviewing` →
`awaiting_architect_review` (PR gate) → `in-testing` → `ready-for-release` → `done`.

### 8.1 Triage

- **Actor:** Claude watches.
- **Tools:** `chits_runs(chit_id=<chit_id>, tenant_id=<tenant_id>)`, `chits_get(chit_id=<chit_id>, tenant_id=<tenant_id>)`.
- **Expect:** enrichment finishes inside its estimate. The CHIT has acceptance criteria and moves
  to `awaiting-answers` or `blocked-on-approval`.
- **If stalled:** the stall alert should land in Slack (SCRIM-05 fix). Then
  `chits_stall_action(chit_id=<chit_id>, action="re-drive", reason="Stalled in triage", tenant_id=<tenant_id>)` (confirm), and log a finding.
- **If a CHIT is too big:** Jim may split it with `chits_split(chit_id=<chit_id>, summaries=[...], reason=<Jim's reason>, tenant_id=<tenant_id>)` (confirm). A split counts as not first-time-right.

### 8.2 Clarifications over Slack

- **Actor:** the customer answers customer questions. Jim answers architect questions.
- **Tools:** `clarifications_pending(tenant_id=<tenant_id>)` to see what is open.
- **Expect:** at least R2 asks a question. The Slack script's answer is that the reservation window
  is 7 days for a spec home and 14 days for build-to-order. Customer-audience questions appear in
  the joint channel. Architect questions appear in the internal channel.
- **Customer (posted as Jim):** answer in the Slack thread, word for word from the script.
- **Jim (architect):** answer in Slack, or Claude calls
  `clarifications_answer(chit_id=<chit_id>, clarification_ref=<clarification_ref>, answers=[{"question_id": <question_id>, "answer_text": <Jim's answer>}], tenant_id=<tenant_id>)` (confirm on the answer that completes the set).
- **G13 (accepted):** a customer answer posted as Jim is recorded as staff, not customer.
- **Gate:** the CHIT leaves `awaiting-answers`.

### 8.3 Design gate (plan gate)

- **Actor:** Jim (architect).
- The plan-gate card posts in the internal channel with the solution design PDF in its thread.
  If it is missing:
  `chits_repost_gate_card(chit_id=<chit_id>, reason="Plan card missing", tenant_id=<tenant_id>)` (confirm), and log a finding.
- **Preferred surface:** the card's Approve button, which asks for a reason. Otherwise Claude
  reads `design_version` from `chits_get` and calls
  `chits_gate_decision(chit_id=<chit_id>, decision="approve", design_version=<design_version>, reason=<Jim's reason>, tenant_id=<tenant_id>)` (confirm).
- **Expect:** `in-flight`.
- **First-time-right:** `request_changes` here means the CHIT failed this gate first time.
- **Evidence:** `chits_history(chit_id=<chit_id>, tenant_id=<tenant_id>)` after the decision.

### 8.4 Autonomous authoring, dev deploy and self-heal

- **Actor:** Claude watches. No human action.
- **What happens:** the CD worker authors the change, writes it to the checkout, deploys it to dev,
  self-heals up to three times per distinct deploy error, then opens the PR and moves the CHIT to
  `awaiting-review`.
- **Tools:** `chits_get`, `delivery_state(chit_id=<chit_id>, tenant_id=<tenant_id>)`,
  `chits_failed_builds(tenant_id=<tenant_id>)`, `chits_failed_deploys(tenant_id=<tenant_id>)`,
  `deploy_failure_examples(tenant_id=<tenant_id>, chit_id=<chit_id>)`.
- **Expect:** a PR opens. The dev slot shows deployed.
- **G11 CFG check:** if the CHIT stays `in-flight` with no authoring, check
  `projects_inspect(tenant_id=<tenant_id>)` for the GitHub App wiring and log a finding.
- **Self-heal paused:** if the loop exhausts its budget, the CHIT stops before the PR. That is a
  platform finding. Do not deploy by hand.
- **G15 (verify in Run 1):** after authoring, run
  `cost_rollup(dimension="chit", chit_id=<chit_id>, days=31, tenant_id=<tenant_id>)` and
  `cost_rollup(dimension="skill", days=31, tenant_id=<tenant_id>)`. Record whether CD authoring
  spend appears under the CHIT, and `records_without_dimension_value`.
- **First-time-right:** any self-heal attempt means the CHIT did not pass dev deploy first time.

### 8.5 CA review and PR gate

- **Actor:** Claude watches CA review. Jim (architect) decides the PR.
- **Tools:** `chits_pr_get(chit_id=<chit_id>, tenant_id=<tenant_id>)`, `chits_get`.
- **Expect:** `ca_reviewing` then `awaiting_architect_review`. The review card posts in the
  internal channel with the PR summary and CA verdict.
- **Jim:** reviews the PR on GitHub and approves or requests changes there. GitHub is the one place
  code is approved; Slack has no PR approve button. An approval past an adverse CA verdict needs a
  comment. Jim may instead tell Claude to call
  `chits_gate_decision(chit_id=<chit_id>, decision="approve", reason=<Jim's reason>, tenant_id=<tenant_id>)` (confirm).
- **Claude may comment** with `pr_comment(chit_id=<chit_id>, comment=<text>, tenant_id=<tenant_id>)`.
  It posts as the GitHub App.
- **Expect:** `in-testing`.
- **First-time-right:** `request_changes` here means the CHIT failed this gate first time.

### 8.6 Dev verification

- **Actor:** Claude watches.
- **Tools:** `delivery_state(chit_id=<chit_id>, tenant_id=<tenant_id>)`,
  `evidence_get(chit_id=<chit_id>, env="dev", tenant_id=<tenant_id>)`.
- **Expect:** dev verification passed. The Apex test run shows zero failures. Record
  `code_coverage_percent` and `meets_coverage_bar`.
- **If verification never started:** `delivery_verification_retry(chit_id=<chit_id>, reason="Dev verification never started", tenant_id=<tenant_id>)` (confirm), and log a finding.
- **SCRIM-05 check:** a verification that failed before approval must route to rework after
  approval. Record what happened.
- **Gate:** dev verified. Then go to Stage 9 for this CHIT.

---

## Stage 9. Persona testing and QA sign-off (per CHIT, in dev)

### 9.1 Automated persona tests

- **Actor:** Claude.
- The browser tests run automatically in testing. To run them again:
  `delivery_test_run(chit_id=<chit_id>, target_env="dev", tenant_id=<tenant_id>, reason="Re-run persona probes")` (confirm).
- **Tool:** `evidence_get(chit_id=<chit_id>, env="dev", tenant_id=<tenant_id>)`.
- **Expect:** probes for each persona the acceptance tests name, with screenshots, passing.
  `verdicts_judge_this_run` is true.
- **Gate:** every probe passes, or a failure is understood and the CHIT is back in rework.

### 9.2 Human Login-As test

- **G9 FIX (interim MAN):** there is no persona login for humans. The interim path is
  `org_login_link`, which logs in as Jim's own user, and then Salesforce Login-As.
- **Claude:** `org_login_link(slot="dev", tenant_id=<tenant_id>, reason="Scrimmage run <run>: human persona test")` (confirm). Hand the link to Jim once. Do not save it.
- **Jim:** opens the link, then Setup, Users, and "Login" next to each persona the CHIT touches.
  He runs the authored tests that `evidence_get` lists as "no probe ran".
- **If `org_login_link` finds no user for jim@weareccg.io in the scratch org:** log a kit/config
  finding. Interim: Jim opens the org with
  `powershell.exe -Command "sf org open -o dh-r<run>-dev"` and records this as a manual workaround.
- **Evidence:** Jim's pass/fail per persona and test, with screenshots. The org's Setup Audit Trail
  records each Login-As (scorecard check T2 reads it).

### 9.3 QA sign-off

- **Actor:** Jim (architect, with a Tester grant on the tenant).
- **Tool:** Claude calls `delivery_qa_signoff(chit_id=<chit_id>, target_env="dev", verdicts=[{"probe_id": <probe_id>, "passed": true, "comment": <Jim's note>}], tenant_id=<tenant_id>)` (confirm), with one verdict per probe, after Jim says so.
- Never pass `override=true` without a GCR finding and a scorecard entry. Never use
  `delivery_signoff_waiver` without the same.
- **Expect:** when the sign-offs are complete, the gateway squash-merges the PR. This cannot be
  undone. The CHIT moves to `ready-for-release`.
- **Gate:** `delivery_state` shows the PR merged and the CHIT `ready-for-release`.
- **Evidence:** the sign-off answer and `delivery_state`. Record the stage end time once every CHIT
  is `ready-for-release`.

---

## Stage 10. Release bundle

One bundle carries every enhancement and audit-repair CHIT.

> **Order changed from the brief.** The brief says assemble, audit, sign, schedule. But
> `release_bundles_schedule` clears the signature of a signed bundle. So this runbook schedules
> before it signs, and signs only after UAT. That also matches the platform, which pauses an
> unsigned bundle before prod.

### 10.1 Assemble

- **Actor:** Claude.
- **Tool:** `release_bundles_assemble(chit_ids=[<every ready-for-release chit_id>], release_narrative=<what Dreamhouse Homes gets, by requirement, plus the audit repairs>, tenant_id=<tenant_id>)`.
  Read each CHIT's eligibility in the preview, then confirm.
- **G10 FIX (trivial):** the docstring says qa must be deployed; eligibility actually checks
  dev-verified and merged. If the preview refuses a CHIT for being undeployed in qa, log it under
  G10.
- **Then:** `release_bundles_get(bundle_id=<bundle_id>, tenant_id=<tenant_id>)`.
- **G5 CFG assert:** `stops` is exactly `["qa", "uat", "prod"]`. If qa or uat is missing, stop.
  That is a finding, because those slots were dropped silently.
- **Gate:** state `ready`, all CHITs in, stops correct.
- **Evidence:** preview, assemble and get answers. Record `<bundle_id>`.

### 10.2 Release audit

- **Actor:** Claude.
- **Tool:** `release_bundles_audit(bundle_id=<bundle_id>, tenant_id=<tenant_id>)` (confirm). Note
  `<release_audit_run_id>`.
- **Wait:** `audits_status(run_id=<release_audit_run_id>, wait_seconds=55, tenant_id=<tenant_id>)`.
- **Read:** `audits_get_run(run_id=<release_audit_run_id>, severity="critical", tenant_id=<tenant_id>)`
  and `severity="warning"`.
- **N4 (proposed CFG):** audit severities are `critical`, `warning` and `info`. There is no `high`.
  So "clean of high or critical" is measured as: zero `critical`, and every `warning` either fixed
  or given a disposition by Jim with a reason (`audits_set_disposition`).
- **Gate:** zero `critical`, and no `warning` left `undecided`. Otherwise stop: the bundle does not
  move. Never call `release_bundles_override_gate` without Jim and a GCR finding.
- **Evidence:** both reads.

### 10.3 Schedule

- **Actor:** Claude.
- **Tool:** `release_bundles_schedule(bundle_id=<bundle_id>, bundle_priority="standard", reason="Scrimmage run <run>: standard release", tenant_id=<tenant_id>)` (confirm). Do not set a `release_window`, so the run is not held to a calendar.
- **Also read:** `release_cadence(tenant_id=<tenant_id>)`.
- **Evidence:** both answers.

### 10.4 Promote to qa

- **G8 FIX check, before every resume:** for each CHIT, `delivery_state(chit_id=<chit_id>, tenant_id=<tenant_id>)`
  must show the previous environment verified, not only deployed. If not, stop and log G8. Do not
  promote unverified.
- **G6 MAN:** the resume is the human promotion gate.
- **Jim (architect):** says go. Claude calls `release_bundles_resume(bundle_id=<bundle_id>, tenant_id=<tenant_id>)` (confirm).
- **Wait:** `operations_status(kind="release_bundle", operation_id=<bundle_id>, tenant_id=<tenant_id>)`
  and `release_bundles_get` until the bundle is `ready` again with qa cleared.
- **Check:** `release_bundles_deploy_results(bundle_id=<bundle_id>, tenant_id=<tenant_id>)`. Every CHIT
  and component in qa succeeded, with zero test failures.
- **Persona tests in qa:** `delivery_test_run(chit_id=<chit_id>, target_env="qa", tenant_id=<tenant_id>, reason="Persona probes in qa")`.
  **N3 (proposed FIX):** this tool needs the CHIT in testing, but a merged CHIT is
  `ready-for-release`. Expect a refusal. Record it. If it is refused, the qa persona evidence comes
  only from 10.4's human test.
- **Human Login-As in qa:** as 9.2, with `slot="qa"`.
- **Gate:** qa deploy results clean, human test passed.

### 10.5 Promote to uat and user testing

- **G8 check** as in 10.4, now for qa.
- **Jim:** says go. Claude calls `release_bundles_resume(bundle_id=<bundle_id>, tenant_id=<tenant_id>)` (confirm).
- **Wait and check** as in 10.4, for uat.
- **Expect:** uat is the user-testing environment (step 1.11), so the admin and user guides are
  written now. Check with `documents_list(tenant_id=<tenant_id>, document_type="admin_guide")` and
  `document_type="user_guide"`.
- **Persona tests in uat:** as in 10.4, with `target_env="uat"` (N3 applies).
- **Human Login-As in uat:** as 9.2, with `slot="uat"`. Jim tests as each persona against the
  customer's acceptance tests.
- **G7 FIX:** there is no recorded UAT sign-off on a bundle. Interim MAN: Jim posts
  "UAT signed off for bundle `<bundle_id>`" in the internal channel. Record it on the scorecard as
  a manual workaround against the G7 ticket.
- **Customer (posted as Jim):** the UAT acceptance line from the Slack script.
- **Gate:** uat deploy results clean, UAT signed off.

### 10.6 Sign

- **Actor:** Jim (architect). This is the production attestation.
- **Tool:** Claude calls `release_bundles_sign(bundle_id=<bundle_id>, tenant_id=<tenant_id>)`. The
  preview shows the attestation and the exact CHITs. Jim reads it. Claude confirms only when Jim
  says so.
- **Gate:** `release_bundles_get` shows the signature. Do not schedule again after this: it would
  clear the signature.

### 10.7 Promote to prod

- **G8 check** as in 10.4, now for uat.
- **Jim:** says go. Claude calls `release_bundles_resume(bundle_id=<bundle_id>, tenant_id=<tenant_id>)` (confirm).
  This is the last stop: it promotes to prod and merges to main.
- **Wait** as in 10.4.
- **Check:** `release_bundles_deploy_results(bundle_id=<bundle_id>, tenant_id=<tenant_id>)`.
  Every CHIT and component in prod succeeded. Tests ran (prod uses RunLocalTests) with zero
  failures.
- **G14:** the coverage bar is not checked at bundle deploy. If any touched class is under 90% in
  prod (scorecard check C2), log it under G14 FIX.
- **Expect:** release notes are written at the prod promote.
- **Gate:** bundle done, prod deploy clean.
- **Evidence:** every resume, get, operations and deploy-results answer. Record the stage end time.

---

## Stage 11. Documents

For every document in this stage, the gate is the same:

1. `documents_review(document_id=<document_id>, tenant_id=<tenant_id>)`: no quality gate holds
   publication.
2. **Jim (architect):** approves on the Slack card, or Claude calls
   `documents_decide(document_id=<document_id>, decision="approve", generation=<generation>, reason=<Jim's reason>, tenant_id=<tenant_id>)`.
3. For customer documents: `documents_share(document_id=<document_id>, version=<version>, change="share", tenant_id=<tenant_id>, reason=<why>)` (confirm), if it did not post itself.
4. `documents_staleness(document_id=<document_id>, tenant_id=<tenant_id>)`: current.

### 11.1 Release notes

- **Claude:** `documents_list(tenant_id=<tenant_id>, document_type="release_notes")` and
  `release_bundles_get(bundle_id=<bundle_id>, tenant_id=<tenant_id>)` for the bundle's notes status.
- If the bundle's notes are `pending_approval`, Jim approves:
  `release_bundles_notes_edit(bundle_id=<bundle_id>, approval_action="approve", edit_reason=<Jim's reason>, tenant_id=<tenant_id>)` (confirm).
- **Check:** the notes state a rollback path (scorecard check R4). If they do not, Jim adds it with
  `release_bundles_notes_edit(bundle_id=<bundle_id>, known_risks=<rollback path>, edit_reason="Add rollback path", tenant_id=<tenant_id>)`. That is a manual workaround: log it.

### 11.2 QA delivery summary

- **Claude:** `documents_generate(document_type="qa_delivery_summary", chit_ids=[<every chit_id in the bundle>], tenant_id=<tenant_id>, reason="Scrimmage run <run>: QA summary for the release")` (confirm). Then the stage gate.

### 11.3 Admin and user guides

- They should exist from 10.5. If not:
  `documents_generate(document_type="admin_guide", chit_ids=[...], tenant_id=<tenant_id>, reason="Admin guide for the release")` (confirm), and the same with `document_type="user_guide"`. Log a finding. Then the stage gate.

### 11.4 Weekly status

- **Claude:** `documents_generate(document_type="customer_weekly_status", tenant_id=<tenant_id>, reason="Scrimmage run <run>: weekly status for Dreamhouse Homes")` (confirm). Then the stage gate.

- **Evidence:** every review, decide, share and staleness answer. Record the stage end time.

---

## Stage 12. Ops visibility and close-out

### 12.1 Queues and feeds

- **Actor:** Claude.
- **Tools:**
  - `attention_queue(tenant_id=<tenant_id>)`: expect nothing waiting.
  - `work_notices(limit=50)`: every gate, completion and failure for Jim's CHITs is there.
  - `activity_feed(tenant_id=<tenant_id>, since=<run started_at>)`, every page: the lifecycle of
    every CHIT is visible.
  - `reports_throughput(days=31)` (Owners only): the run's CHITs show their decision spans.
  - `reports_review_loops(tenant_id=<tenant_id>, days=31)`: plan first-time-right rate.
  - `chits_run_accuracy(tenant_id=<tenant_id>, window_days=31)`.
  - `robustness_bar(tenant_id=<tenant_id>, rejections=20)`.
  - `documents_quality_report(tenant_id=<tenant_id>, days=31)`.
  - `tenant_health(tenant_id=<tenant_id>, days=14)`.
  - `reports_release_history(days=31)`.
  - `tunnels_status(tenant_id=<tenant_id>)`.
- **Slack check:** gate cards, notifications and any stall alert landed in channels that exist.
  Screenshot each kind once.
- **Evidence:** all answers.

### 12.2 Spend

- Produce the spend report as `spend-report.md` describes: `cost_rollup`, `reports_spend`,
  `budget_status`, `reports_budget_burn` and `budget_history`.

### 12.3 Post-release audit

- **Actor:** Claude.
- **Tools:**
  - `source_retrieve(tenant_id=<tenant_id>)` (confirm), then `source_retrieves` until complete.
  - `source_compare(tenant_id=<tenant_id>)`: the change between the baseline and the release.
  - `audits_start(trigger="manual", tenant_id=<tenant_id>)` (confirm). Note `<post_audit_run_id>`.
    Wait with `audits_status`.
  - `audits_compare(run_a=<audit_run_id>, run_b=<post_audit_run_id>, tenant_id=<tenant_id>)`.
- **Expect:** every planted defect marked `fix` is gone. No new security finding.
- **Evidence:** all answers.

### 12.4 Independent review and scorecard

- Run the independent check (scorecard check I1).
- Fill in `runs/run-<run>/scorecard.md` from the template in `scorecard.md`.
- File every finding as a GCR ticket (`finding-log.md`).
- Commit: `docs(scrimmage): add run <run> scorecard and evidence`.
- Then reset (`reset.md`) when Jim says so.

---

## Appendix A. Steps with no MCP tool path

| Step | What has no tool | Label |
|---|---|---|
| 1.2 to 1.4 | Dev Hub check, scratch org create, sample load | EXT (Salesforce CLI); fresh-org path in `staging_env.py` is an open SCRIM-03 task, MAN until built |
| 1.7 | Setting the tenant coverage bar to 90 | G14 CFG has no tool: **N1**, proposed FIX |
| 1.10 step 2 | Trusting the tunnel certificate in the org and reading the consumer key | EXT (Salesforce CLI) |
| 1.9 | Slack Connect invite to the customer | G13 EXT, accepted |
| 4.1 | Opportunity create | G1 FIX (SCRIM-05); Slack modal until then |
| 5.1 | Uploading the discovery pack to Drive | Customer action, outside the platform |
| 5.3 | Listing pending knowledge proposals to accept requirements | **N2**, proposed MAN for Run 1, FIX candidate |
| 9.2, 10.4, 10.5 | Human sign-in as a persona | G9 FIX, interim MAN (`org_login_link` then Login-As) |
| 10.4, 10.5 | Persona browser tests in qa and uat for a merged CHIT | **N3**, proposed FIX (expected refusal of `delivery_test_run`) |
| 10.5 | Recorded UAT sign-off on the bundle | G7 FIX, interim MAN |
| 10.2 | A "high" severity to gate on | **N4**, proposed CFG: gate on zero `critical` and no undecided `warning` |
| 10.4 to 10.7 | Promotion only after verification | G8 FIX; checked by hand with `delivery_state` |
| 10.4 to 10.7 | Each resume | G6 MAN (the human promotion gate) |
| Customer lines | A customer identity in Slack | G13 EXT, accepted: posted as Jim |
