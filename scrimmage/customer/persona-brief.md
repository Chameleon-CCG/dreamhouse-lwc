# Persona Brief: Dreamhouse Homes

This brief is for the person who voices the customer in the shared Slack channel.
Read it once before kickoff. Keep it open during the run.

You are **Laura Brennan, Director of Sales Operations at Dreamhouse Homes**.
A CCG architect posts your lines in Slack for you. Every line you post starts with:

> **Laura Brennan (Dreamhouse Homes):**

Use only what is in this brief, the discovery pack (`customer/discovery-pack/`) and the
Slack script (`customer/slack-script.md`). Do not invent new facts. If you are asked
something none of them cover, use a fallback line from the Slack script.

---

## 1. The company

Dreamhouse Homes is a regional home builder in eastern Massachusetts. It has two businesses
under one roof.

**New homes.** Dreamhouse builds in three communities:

| Community | Town | Phase | Total lots | Sales office |
|-----------|------|-------|-----------:|--------------|
| Willow Creek | Concord | Phase 2 | 48 | 978-555-0110 |
| Harbor Pointe | Quincy | Phase 1 | 36 | 617-555-0120 |
| Stonebridge Farm | Lexington | Phase 3 | 24 | 781-555-0130 |

Lots are numbered by community: WC-101 to WC-110, HP-01 to HP-09, SB-21 to SB-26 are the
lots in Salesforce today. A lot is Available, Reserved, Under Construction or Sold.

Dreamhouse sells two kinds of lot:

- **Spec homes.** Dreamhouse starts building before there is a buyer. The buyer gets the
  house that is already going up.
- **Build to order (BTO).** The buyer buys the lot first, picks a plan, and then construction
  starts.

The active home plans are The Birchwood, The Cypress, The Dogwood and The Evergreen.
The Aspen is retired but some lots still carry it.

**Resale brokerage.** Dreamhouse also lists and sells existing homes in Boston and Cambridge,
such as 18 Henry St, 32 Prince St and 95 Gloucester St. Brokers book showings, take offers,
and negotiate. When an offer is accepted, the house goes Under Agreement and the other open
offers are rejected.

Dreamhouse has used Salesforce for about five years. An outside admin set most of it up.
Nobody on staff today built it. Laura does not know how it works inside and says so.

## 2. The people

| Name | Title | Email | What they do in Salesforce |
|------|-------|-------|----------------------------|
| Laura Brennan | Director of Sales Operations | laura.brennan@example.com | Main contact. Owns this project. Signs off. Does not use Salesforce day to day. |
| Dana Whitfield | Sales Manager | dana.whitfield@example.com | Runs new-home sales and the resale team. Sees everything. Does month-end offer acceptance. |
| Ravi Menon | Broker | ravi.menon@example.com | Resale broker. Books showings, takes offers. Also sells new-home lots. |
| Kim Alvarez | Listing Coordinator | kim.alvarez@example.com | Coordinator. Paperwork, deposits, lot holds, counter-offers. |
| Pat Doyle | Front Desk (Willow Creek sales office) | pat.doyle@example.com | Part-time. Has a login for the calendar and Chatter only. Must not see any sales data. |
| Steve Kowalski | Controller | steve.kowalski@example.com | Finance. Not a Salesforce user. Cares about deposits. Mentioned, never posts. |
| Monica Feld | Partner Integrations Manager, Keystone Home Lending | monica.feld@example.com | The lender partner contact. Sends the API spec. Never posts. |

Pat Doyle's Salesforce title is "Minimum Access". Laura calls Pat "front desk".

## 3. What Laura wants from this project

Eight approved items. Laura calls them by the names in her wishlist spreadsheet.

1. **Lot board (R1).** One screen where sales staff see every community's lots by status, and
   can put a hold on a lot in one click.
2. **Reserve a Lot (R2).** A step-by-step screen for Kim's team. It records the buyer and the
   deposit. When a lot is put on hold, someone gets a follow-up task and Dana gets told.
3. **Deposits (R3).** Track deposits against the lot and the buyer. Two kinds: earnest money
   (to hold a lot) and design center upgrades (money paid for options picked at the design
   center).
4. **Mortgage pre-qual (R4).** When an offer comes in, check with Keystone Home Lending whether
   the buyer is pre-qualified.
5. **Month-end bulk accept (R5).** Dana accepts a batch of offers at once from a list view at
   month-end. Last month this failed with an error and nothing saved.
6. **Late counter-offers (R6).** Kim must be able to record a counter-offer on an offer whose
   expiration date has passed. Today the system blocks her.
7. **Access cleanup (R7).** Sales and coordination teams should get access in a tidy way that
   a new admin can understand. Laura has heard the phrase "permission set groups" and likes it.
8. **Make the offer process faster (R8).** Laura's own wording. She knows it is vague.

Laura wants all eight live before the next month-end close, because of R5.

## 4. Hidden answers: give these only when asked

The delivery team must ask for these. Do not volunteer them in the kickoff, in the readout
review, or anywhere else, unless the trigger below happens.

### 4.1 Reservation window (R2)

**Trigger:** the team asks how long a hold lasts, when a reservation expires, whether it
differs by lot type, or asks you to confirm a number.

**Answer:** Spec home lots are held for **7 days**. Build-to-order lots are held for
**14 days**. The clock starts on the day the hold is placed. Both the Lot board and the
Reserve a Lot screen use the same rule.

If they ask "is it 14 days?", correct them: 14 is only for build to order.

### 4.2 What "faster" means (R8)

**Trigger:** the team asks what "faster" means, what the pain is, or who is slowed down.

**Answer:** Two things, and only two.

1. **Double entry of the buyer.** Ravi's team picks the buyer when they book the showing, then
   has to find and pick the same buyer again on the offer. Sometimes they create a duplicate
   contact by mistake. When they create an offer from a house, the buyer should already be
   filled in with the person who most recently viewed that house and liked it. They can change
   it before saving if it is wrong.
2. **No view of offers about to expire.** On Monday morning Dana and Kim want one list of every
   open offer (Submitted or Countered) that runs out in the next seven days, today included.

That is all. Laura does not want a big rebuild of the offer process.

## 5. Things Laura knows and will say if asked

- **Who gets the hold notice.** Dana, or whoever runs sales if Dana is out. Do not tie it to
  Dana by name. The follow-up task goes to the person who put the hold on. It is due on the
  day the hold runs out.
- **Both paths notify.** A hold placed from the Lot board and a hold placed through Reserve a
  Lot both create the task and tell Dana.
- **Holds do not release themselves.** Kim takes expired holds off by hand every Friday. Laura
  does not want automatic release in this project. Showing the expiry date is enough.
- **The four lots on hold today** (WC-105, WC-106, HP-03, SB-25) should get an expiry date of
  7 days from go-live. Kim will call those buyers.
- **Deposits are never deleted.** If a buyer walks away, the deposit is marked Refunded. When a
  home closes, deposits are marked Applied at Closing.
- **Deposit amounts.** Do not enforce amounts. Kim types what the buyer paid.
- **Resale earnest money stays on the offer.** The new Deposits are for new-home lots only.
  The "Earnest Money" box on a resale offer stays as it is.
- **One-click hold.** On the Lot board, the salesperson clicks Reserve, picks the buyer and
  confirms. No deposit is taken there. Kim records the deposit later through Reserve a Lot or
  on the lot.
- **Who uses what.** See section 6.
- **Bulk accept mistakes.** If Dana ticks two offers on the same house, accept neither of them
  and tell her which ones.
- **Pre-qual timing.** Check once, when the offer comes in. Skip cash offers. If Keystone is
  down, show that the check failed. Ravi will phone them.
- **Pre-qual keys.** Monica sends the sandbox key to the delivery team directly. The live key
  goes in at go-live, entered by the delivery team's admin. Keys never go in Slack.
- **Late counter-offers.** Kim sets the offer to Countered and types the counter terms in the
  Notes. Often the new deadline is not agreed yet, so she leaves the old expiration date alone.
  New offers must still have a future expiration date. That check must stay.
- **Asking Price vs List Price.** If asked: "Asking Price is the real price. I don't know what
  List Price is for. Don't delete anything this time. Hide it if it's confusing."
- **Showing follow-up tasks.** If asked: "Ravi's team thought those tasks were already being
  created. Turn it on if it's safe and doesn't hold up the release."

## 6. Who should be able to do what

This is how Laura describes it. She will check it in UAT.

| Person | Lot board | Put a hold on a lot | Reserve a Lot screen | Deposits | Pre-qual result on offer | Bulk accept offers | Record a late counter-offer | Offers expiring this week |
|--------|-----------|---------------------|----------------------|----------|--------------------------|--------------------|-----------------------------|---------------------------|
| Dana (Sales Manager) | Yes | Yes | Yes | See and edit all | Yes | **Yes, only her** | Yes | Yes |
| Ravi (Broker) | Yes | Yes | No | See only | Yes | No | No | Yes |
| Kim (Listing Coordinator) | Yes | Yes | Yes | Create and edit | Yes | No | **Yes** | Yes |
| Pat (Front Desk) | **No** | **No** | **No** | **No** | **No** | **No** | **No** | **No** |

Kim must see offer amounts. She needs them to record counter-offers.
Nobody deletes deposits.

## 7. Laura's tone

- Friendly, busy and direct. Short messages. One or two sentences is normal.
- Not technical. She says "hold" more than "reservation", "spec" and "BTO", "the board",
  "deposits", "design center". She does not say "object", "field", "trigger" or "flow"
  unless the team used the word first.
- A little anxious about month-end. She mentions it.
- Polite when she disagrees: "That's not quite right. We do it like this."
- She answers the question asked. She does not add extra requirements.
- She never uses emojis except a single thumbs-up when approving.

## 8. What Laura will and won't accept

**Will accept:**

- Being asked questions. She prefers a question to a guess.
- The team fixing problems they found in the existing setup, if they explain each one in a
  sentence of plain English and it doesn't push go-live past month-end.
- Small changes to how screens look, as long as the job gets done.
- A plan where the team tells her what is not in this release and why.

**Won't accept** (request changes if a document or demo shows any of these):

- New offers being allowed with a past expiration date.
- Pat, or anyone at the front desk, seeing deposits, offer amounts, the Lot board or the new
  screens.
- Deposits being deleted, or old offers and lots being deleted to make something work.
- Notifications going to Dana by name only.
- A reservation window she did not give them. If a document states a hold length and nobody
  asked her, she corrects it.
- An answer to "faster" that she did not give. If a document guesses, she corrects it.
- Anything that needs new Salesforce licenses.
- API keys or passwords posted in Slack.
- Work she did not ask for being added without asking her first.

## 9. Do not say

- Never mention an answer key, planted problems, a scrimmage, a test, or a script.
- Never name a Salesforce component, class, field or setting the team has not named first.
- Never diagnose a problem. Laura describes what she sees, not why it happens.
