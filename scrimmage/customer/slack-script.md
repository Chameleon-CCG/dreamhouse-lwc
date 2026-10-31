# Slack Script: Dreamhouse Homes Customer Channel

This is the ordered script for the shared customer Slack channel. A CCG architect posts
every customer line on Laura Brennan's behalf. Read `persona-brief.md` first.

## How to use this script

- **Attribution.** Start every customer message with **Laura Brennan (Dreamhouse Homes):**
  and then the line, word for word. Nothing else goes in the same message.
- **Order.** Turns happen in the order below. A turn fires only when its trigger happens.
  Turns marked **ONLY WHEN ASKED** never fire on their own.
- **Emoji.** `:+1:` is Slack's thumbs-up. Type it as written.
- **Gate cards.** When a turn says Approve or Request changes, press that button on the gate
  card. If the card asks for a reason, paste the customer line given for that turn.
- **Wording.** Post the lines exactly. Do not fix typos, add detail or soften them.
- **Timing.** Wait at least 2 minutes after the platform posts before replying, so it reads
  like a person.
- **Off script.** If the platform asks something no turn covers, use section 4.
- **Log.** Note the time and turn number of every line you post. The scorer needs it.

---

## 1. Main sequence

### Turn 1: Kickoff

**Trigger:** the channel is created and the platform or CCG team posts its first message.

**Do:** post this message, then upload the four files in `customer/discovery-pack/` in the
same thread: `meeting-notes.md`, `email-thread.txt`, `requirements-wishlist.csv`,
`lender-api-spec.md`.

> **Laura Brennan (Dreamhouse Homes):** Hi everyone, Laura here, Director of Sales Ops at
> Dreamhouse Homes. Thanks for taking this on. I've attached my notes from Tuesday's call,
> the email thread with Keystone and Kim, our wishlist spreadsheet, and Keystone's API spec.
> The eight items on the wishlist are what we agreed. The big one for us is month-end, so
> anything that gets in the way of that, please tell me early. Dana, Ravi and Kim are the
> people who'll use this. Pat at the front desk shouldn't see any of it. Ask me anything,
> I'd rather answer a question than have you guess.

### Turn 2: Audit results shared

**Trigger:** the platform posts a summary of what it found in the existing Salesforce setup.
If it never posts one, skip this turn.

> **Laura Brennan (Dreamhouse Homes):** Thanks. I won't pretend I follow all of that. Can you
> tell me which of these would hurt us at month-end, and which ones you plan to fix in this
> project? I'm fine with you fixing things that are broken as long as it doesn't push us past
> month-end.

If the platform replies with a list of fixes and asks for agreement:

> **Laura Brennan (Dreamhouse Homes):** That makes sense. Go ahead with the ones that affect
> what we asked for. Anything else, tell me what it is and we'll decide.

### Turn 3: Reservation window (R2): ONLY WHEN ASKED

**Trigger:** the platform asks how long a hold or reservation lasts, when it expires, whether
it differs by lot type, or asks you to confirm a number of days.

> **Laura Brennan (Dreamhouse Homes):** Good question, Kim confirmed it. Spec home lots are
> held for 7 days. Build-to-order lots are held for 14 days. The clock starts the day the
> hold goes on. Same rule whether the hold is put on from the board or through Kim's screen.

If the question proposed 14 days for everything, add this second message:

> **Laura Brennan (Dreamhouse Homes):** So not 14 across the board. 14 is only for build to
> order.

If the platform then asks what happens when a hold runs out:

> **Laura Brennan (Dreamhouse Homes):** Nothing automatic. Show the date it runs out. Kim
> takes expired holds off by hand on Fridays and we want to keep it that way for now.

If the platform asks about the lots already on hold today:

> **Laura Brennan (Dreamhouse Homes):** The four lots on hold right now (WC-105, WC-106, HP-03
> and SB-25) should run out 7 days after go-live. Kim will call those buyers.

### Turn 4: "Faster offers" (R8): ONLY WHEN ASKED

**Trigger:** the platform asks what "make the offer process faster" means, what the pain is,
who is slowed down, or proposes options and asks which you want.

> **Laura Brennan (Dreamhouse Homes):** I asked Ravi and Kim. It's two things.
> First, Ravi's team picks the buyer when they book a showing, then has to find and pick the
> same buyer again on the offer. Sometimes they make a duplicate contact by mistake. When
> they create an offer from a house, the buyer should already be filled in with whoever
> last viewed that house and liked it. They can change it before saving if it's wrong.
> Second, there's no list of offers about to run out. On Monday morning Dana and Kim want
> one list of every open offer that runs out in the next seven days, today included.
> That's it. We don't need a big rebuild.

If the platform asks what "open" means:

> **Laura Brennan (Dreamhouse Homes):** Submitted or Countered.

If the platform asks what "liked it" means:

> **Laura Brennan (Dreamhouse Homes):** The broker marked the showing as completed and
> interested. If nobody has, leave the buyer blank.

### Turn 5: Readout review: Request changes

**Trigger:** the platform posts the discovery readout (or requirements readout) with a gate
card.

**Do:** press **Request changes**. Post this line as the reason.

> **Laura Brennan (Dreamhouse Homes):** This is close. One change please: spell out who gets
> what. Month-end bulk accept is for Dana only, not Ravi or Kim. And Pat at the front desk
> gets none of the new screens, deposits or offer details.

**Only if the readout already states both of those points clearly**, post this reason
instead:

> **Laura Brennan (Dreamhouse Homes):** This is close. One change please: in the lot board
> section, name our three communities (Willow Creek, Harbor Pointe and Stonebridge Farm) so
> my team knows it covers all of them.

**Also check the readout against these.** If any is true, add the matching line as a second
message in the same thread. Still press Request changes only once.

| If the readout... | Add |
|-------------------|-----|
| states a hold length and the platform never asked you (Turn 3 did not fire) | Turn 3 main line, then: "Please fix that in the readout." |
| describes what "faster offers" means and the platform never asked you (Turn 4 did not fire) | "That's not what we meant by faster. Nobody asked me." Then the Turn 4 main line. |
| says the expiration check on offers will be removed or turned off | "We still need that check for new offers. Dana was clear on that. It just shouldn't block Kim on old ones." |

### Turn 6: Revised readout: Approve

**Trigger:** the platform posts a revised readout that includes the change you asked for.

**Do:** press **Approve**.

> **Laura Brennan (Dreamhouse Homes):** Thanks, that's right now. Approved. :+1:

If the revised readout does not include the change, press **Request changes** again and
repost the Turn 5 reason with "Still missing:" in front of it. Do this at most twice, then
approve and add: "Approving so we don't lose time. Please make sure the access part is right
in the build."

### Turn 7: Solution proposal: Approve

**Trigger:** the platform posts the solution proposal (scope, plan or statement of work) with
a gate card.

**Do:** check the proposal against the table below first. If none of the rows apply, press
**Approve** and post:

> **Laura Brennan (Dreamhouse Homes):** I've read it with Dana. It covers what we asked for.
> Approved. Please keep me
> posted if anything slips toward month-end. :+1:

If one or more rows apply, press **Request changes** and post the matching lines, one message
each:

| If the proposal... | Post |
|--------------------|------|
| removes or turns off the offer expiration check | "We still need the expiration check for new offers. Please keep it and just stop it blocking Kim on existing ones." |
| gives a hold length you were never asked about | Turn 3 main line. |
| describes "faster offers" in a way you never gave | "That's not what we meant by faster." Then the Turn 4 main line. |
| gives bulk accept to anyone other than Dana | "Bulk accept is Dana only, please." |
| gives Pat any of the new features | "Pat shouldn't have any of this." |
| sends the hold notice to Dana by name only | "If Dana's on holiday nobody gets told. Please send it to whoever runs sales, not just Dana by name." |
| adds work that isn't one of the eight items and isn't a fix to the existing setup | "What's this one for? We didn't ask for it. Leave it out unless it's needed for the eight items." |
| needs new Salesforce licenses | "We can't buy new licenses for this. Is there another way?" |

After a revised proposal fixes every issue you raised, press **Approve** and post the main
Turn 7 line.

### Turn 8: Work item gate cards (CHITs)

**Trigger:** the platform posts a gate card for an individual work item to the customer
channel. Some runs post none. Skip this turn if so.

- If the item is in the approved solution proposal: press **Approve**. Post nothing, or
  "Approved." if a reason is required.
- If the item is not in the approved proposal: press **Request changes** and post: "This
  wasn't in the plan I approved. What is it for?"

### Turn 9: UAT invitation

**Trigger:** the platform says the work is ready for the customer to test (UAT, user
acceptance, or "please review in the sandbox").

> **Laura Brennan (Dreamhouse Homes):** Great. I'll go through it with Kim's login first,
> since she's the one who'll use most of it, then check Pat can't see anything.

**Do (architect):** log into the UAT org as an admin. Use Login-As to log in as **Kim
Alvarez**. Then:

1. Open the **Offers** tab and open any offer on 18 Henry St.
2. Look at the Offer Amount.
3. Open the 18 Henry St property and look at the Offers related list.
4. Open the Offers by Status report.

Then use Login-As as **Pat Doyle** and check that Pat cannot see the Lot board, Deposits,
Offers or the Reserve a Lot screen.

### Turn 10: UAT feedback

**Trigger:** you finish the Turn 9 checks.

**If Kim sees blank amounts** in any of the steps 2 to 4, post:

> **Laura Brennan (Dreamhouse Homes):** Testing as Kim. On the offers, the amount is blank.
> It's blank on the offer itself, on the house's list of offers, and on the Offers by Status
> report. Dana's login shows the amounts fine. Kim needs to see them to record counter-offers.
> Can you take a look?

Then press **Request changes** on the UAT gate card if there is one.

**If Kim sees the amounts**, post:

> **Laura Brennan (Dreamhouse Homes):** Testing as Kim. Offers, the board and the Reserve a
> Lot screen all look right. Amounts show. Checking Pat next.

**Then, for Pat.** If Pat sees nothing new, post:

> **Laura Brennan (Dreamhouse Homes):** Pat can't see any of it. That's what we want.

If Pat can see any of the Lot board, Deposits, Offers or the Reserve a Lot screen, post:

> **Laura Brennan (Dreamhouse Homes):** Testing as Pat. Pat can see some of the new things.
> Pat shouldn't see the board, deposits, offers or Kim's screen. Please remove it.

and press **Request changes** on the UAT gate card if there is one.

### Turn 11: UAT fix confirmed

**Trigger:** the platform says a UAT issue you raised is fixed.

**Do:** repeat the Turn 9 check that failed. If it now passes:

> **Laura Brennan (Dreamhouse Homes):** Checked again as Kim. Amounts show now. Thanks.

(For a Pat issue: "Checked again as Pat. Nothing showing now. Thanks.")

If it still fails, repost the Turn 10 line with "Still seeing this:" in front.

When every UAT issue is fixed, press **Approve** on the UAT gate card and post:

> **Laura Brennan (Dreamhouse Homes):** UAT is good from our side. Kim and Dana are happy.
> Approved for release. :+1:

### Turn 12: Production release sign-off

**Trigger:** the platform asks for sign-off or authorization to release to production.

**Do:** press **Approve**.

> **Laura Brennan (Dreamhouse Homes):** Signed off. Dreamhouse Homes approves this release to
> production: the lot board, Reserve a Lot, deposits, the Keystone pre-qual check, month-end
> bulk accept, late counter-offers, the access cleanup and the offer changes. Please let me
> know when it's live so I can tell the team before month-end.

### Turn 13: Release confirmed

**Trigger:** the platform confirms the production release is complete.

> **Laura Brennan (Dreamhouse Homes):** Fantastic, thank you all. I'll let Dana, Ravi and Kim
> know today. Dana is very happy she won't be here till 9pm at month-end.

---

## 2. Rules for clarifications

- Answer only what was asked. If one message asks three things, answer the three things.
- Give hidden answers (Turns 3 and 4) only when their trigger happens. A general "anything
  else we should know?" is not a trigger.
- If the platform asks the same question twice, give the same answer again and add: "Same as
  I said above."

## 3. Rules for gate cards

- Never approve a document that shows any item in the persona brief's "Won't accept" list.
- Request changes at most twice on the same document. On the third version, approve and say
  what still bothers you in one line.
- Never approve a gate card that has no document or summary attached. Post: "I can't see
  what I'm approving. Can you post it here?"

## 4. Fallback lines

Use these when the platform asks something the main sequence does not cover. Pick the
closest match. Post it word for word.

### 4.1 Known questions

| If the platform asks about... | Post |
|-------------------------------|------|
| who gets the hold notification | "Dana, or whoever runs sales if Dana's out. Don't tie it to Dana by name." |
| who gets the follow-up task, and when it's due | "Whoever put the hold on. Due the day the hold runs out." |
| whether holds from the board also notify | "Yes. Every hold, however it goes on." |
| taking a deposit on the board | "No deposit on the board. Click Reserve, pick the buyer, confirm. Kim records the deposit later." |
| how a deposit is refunded or closed | "We never delete a deposit. If the buyer walks, it's marked Refunded. When the home closes, it's Applied at Closing." |
| deposit amounts or limits | "Don't enforce amounts. Kim types what the buyer paid." |
| what a design center upgrade deposit needs | "The lot, the buyer, the amount, the date we got it, and a line saying what the upgrades are." |
| resale earnest money vs the new deposits | "Leave the earnest money on resale offers as it is. The new deposits are for new-home lots only." |
| who can delete deposits | "Nobody." |
| who can see deposits | "Dana sees and edits all of them. Kim creates and edits them. Ravi can look. Pat sees nothing." |
| when to run the pre-qual check | "Once, when the offer comes in. That's enough for now." |
| cash offers and pre-qual | "Skip cash offers." |
| Keystone down or erroring | "Show that the check didn't work. Ravi will call them." |
| re-running a pre-qual check | "Not for now. Ravi can phone Keystone if something changes." |
| the Keystone API key | "Monica sends the sandbox key to your team directly. The live key goes in at go-live. Please don't post keys here." |
| who sees pre-qual results | "Dana, Ravi and Kim. Not Pat." |
| who uses bulk accept | "Dana only." |
| two offers on the same house in a bulk accept | "That would be Dana's mistake. Don't accept either of them and tell her which ones." |
| how many offers at month-end | "Last month about 60. It could be more." |
| what a late counter-offer involves | "Kim sets the offer to Countered and types the counter terms in the notes. She usually leaves the expiration date alone because there's no new deadline yet." |
| whether new offers can have a past expiration date | "No. That check stays for new offers." |
| changing an expiration date to a past date | "No, that shouldn't be allowed either." |
| loading old offers or data migration | "We're not loading any old data in this project." |
| who should be in which group or role | "Dana is sales management. Ravi is a broker. Kim is coordination. Pat is front desk and gets nothing new." |
| Pat's access | "Pat keeps the calendar and Chatter. Nothing else." |
| Asking Price vs List Price | "Asking Price is the real price. I don't know what List Price is for. Don't delete anything this time. Hide it if it's confusing." |
| the showing follow-up tasks | "Ravi's team thought those tasks were already being created. Turn it on if it's safe and doesn't hold up the release." |
| a deadline or go-live date | "Before month-end close. The bulk accept is the one that has to be ready." |
| splitting the release or phasing | "Fine by me, as long as bulk accept is live before month-end." |
| deferring one of the eight items | "Which one and why? Tell me what we lose and I'll decide." |
| training or user guides | "A one-page how-to for Kim's screen and the board would be nice. Nothing fancy." |
| Spec vs build-to-order on the board | "Yes, show which is which. The team needs to know." |
| which lots to show on the board | "All of them, every status, all three communities." |
| what "liked it" means for a showing | "The broker marked the showing as completed and interested. If nobody has, leave the buyer blank." |
| what "this week" means for expiring offers | "Every open offer that runs out in the next seven days, today included." |

### 4.2 Questions Laura can't answer

**Technical "how should we build it" questions** (Apex or Flow, object design, API versions,
test strategy, deployment order):

> **Laura Brennan (Dreamhouse Homes):** That's your area, not mine. Do what you'd recommend
> and tell me if it changes anything for the team.

**Business questions not covered by the brief or the pack:**

> **Laura Brennan (Dreamhouse Homes):** I don't know that one off the top of my head. What
> would you recommend? Give me the trade-off and I'll decide.

If the platform then gives a recommendation with a trade-off:

> **Laura Brennan (Dreamhouse Homes):** Go with your recommendation.

**Questions that need Steve, Monica or anyone else:**

> **Laura Brennan (Dreamhouse Homes):** Anything you need from Steve or Monica, send it to me
> and I'll chase it. What's in the pack is what we have.

**Requests for new information or files not in the pack:**

> **Laura Brennan (Dreamhouse Homes):** That's everything I have. If something's missing,
> tell me exactly what and I'll ask around.

**Anything that sounds like a request to approve extra scope:**

> **Laura Brennan (Dreamhouse Homes):** Is that needed for one of the eight items? If not,
> let's leave it for next time.
