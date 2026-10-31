# Dreamhouse Scrimmage Finding Log

A finding is anything in a run that did not do what `runbook.md` expects. Every finding becomes one
GCR ticket. Every manual workaround on the scorecard points to one.

## 1. Before filing: the two-attempt rule

1. **Attempt 1.** Save the evidence. If the failure looks transient (a timeout, a first JWT
   refused), try once more, changing one thing.
2. **Attempt 2.** If it fails again, stop. Do not try a third time yet.
3. **Structured analysis,** written into the ticket's "Analysis" section:
   - Read the full error output, not only the first line.
   - State the problem precisely: what was expected, what happened.
   - State the assumptions that might be wrong.
   - Say what is not known, and what would change the approach.
   - Re-read the code or the runbook step. Do not work from memory. For platform code, pull
     chameleon-cloud main first and cite the SHA.
   - Form one hypothesis: "The problem is X because Y."
4. **Attempt 3** only tests that hypothesis. Ask Jim first if:
   - three attempts have not fixed it,
   - the root cause is still unclear,
   - the fix needs an architectural change, or
   - the problem is in code or config Claude cannot see.
   When asking, say what was tried, the suspected root cause, and the one piece of information
   needed.
5. **Never mask it.** Do not hand-fix the tenant or the org without a scorecard entry and a ticket.
   Do not override a gate, waive a sign-off or skip a test to move on.

## 2. Check for an existing ticket

Before filing, search GCR:

`project = GCR AND labels = scrimmage AND statusCategory != Done AND text ~ "<two or three words from the error>"`

If a ticket already covers the same failure, add a comment with this run's number, stage and
evidence instead of filing a new one.

## 3. Where and how to file

- **Project:** GCR, on chameleon-creative.atlassian.net.
- **Labels:** `cloud` and `scrimmage`. Add nothing that routes it to the plugin repo.
- **Sprint:** MVP Launch. Find the sprint field's id once from an issue already in that sprint
  (`project = GCR AND sprint = "MVP Launch"`, then read the issue with its Sprint field), and set it
  when creating.
- **Issue type:** `Bug` for a platform defect. `Task` for a kit or config finding.
- **Filed by:** Claude, without per-ticket review, for scrimmage findings only (Jim, 2026-10-30).
  Use the Atlassian connector (`createJiraIssue`), or the `jira` CLI through PowerShell as in the
  chameleon-cloud CLAUDE.md.
- **Customer name:** write "Dreamhouse Homes". It is fictional. Never name a real customer in a
  scrimmage ticket.

## 4. Ticket format

**Summary:** `[Scrimmage R<run>] S<stage>.<step> <tool or surface>: <what went wrong, in a few words>`

Example: `[Scrimmage R01] S10.4 release_bundles_resume: qa stop missing from bundle stops`

**Description:**

```text
Run: <run>
Stage and step: S<stage>.<step> <step name from runbook.md>
Classification: platform | kit | config
Gap: <G-number or N-number from runbook.md, or "new">
Platform SHA: <chameleon-cloud main SHA from run.json>
Kit revision: <samples.py pin>
Tenant: <tenant_id> (staging)

Expected
<the runbook's "Expect" and "Gate" for the step, quoted>

Actual
<what happened, with the exact error text>

Evidence
- <link to each evidence file at its commit on the kit branch>
- <screenshots>
- <CHIT, bundle, audit run or document ids>

Reproduction
<the tool call with its arguments, or the command, that shows the failure>

Attempts
1. <what was tried and what happened>
2. <what was changed and what happened>

Analysis
<the structured analysis from section 1>

Workaround used in this run
<none, or what was done by hand, and the scorecard row number>

Fix route
<one of the three in section 5>
```

## 5. Classification and fix route

| Classification | Meaning | Fix route |
|---|---|---|
| **platform** | Chameleon Cloud did the wrong thing: a gateway, MCP, worker, Slack or document defect. | A chameleon-cloud PR on a `fix/GCR-<n>-...` branch with a test that reproduces the failure. Merge on green CI, deploy through the Stage workflow, then verify against the original failure. |
| **kit** | The Dreamhouse kit is wrong: metadata, seed data, persona users, the answer key. | A commit on the kit branch of the `Chameleon-CCG/dreamhouse-lwc` fork, then a new `revision` pin for `dreamhouse-brownfield` in chameleon-cloud `scripts/e2e/samples.py`. |
| **config** | The runbook, a tenant setting or the standup did the wrong thing. | A commit to `scrimmage/operator/` (this pack) or a tenant setting, recorded on the scorecard. |

If a finding is a known gap from PHASE-SCRIM-01, use its label: FIX means a platform or kit fix in
the loop, CFG means config, MAN means an accepted manual step (still logged, so the scorecard can
count it), EXT means it needs something outside the platform.

## 6. Closing a ticket

1. Comment with the fix: the PR or commit, and the deploy (Stage run) or new kit pin.
2. Comment with the proof: the same tool call or command as "Reproduction", now giving the
   expected result, with its evidence file. Say which run proved it.
3. Move the ticket to Done.
4. Update the run's scorecard row and the SCRIM-06 iteration log.

A fix is not proven by a run that skipped the step. The final proof of every fix is the clean run
from reset in SCRIM-07.
