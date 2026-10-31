# Salesforce discovery call: notes

**Date:** Tuesday, October 27, 2026, 10:00 to 11:15
**Written up by:** Laura Brennan (Dir. Sales Ops)
**Our side:** Laura Brennan, Dana Whitfield, Kim Alvarez, Ravi Menon (joined 10:30)
**CCG side:** the CCG delivery team

These are my notes, not minutes. Shout if I got something wrong.

---

## Background (what I told them)

- We build in 3 communities: Willow Creek (Concord), Harbor Pointe (Quincy), Stonebridge Farm (Lexington).
  Stonebridge is the last phase. Harbor Pointe is just getting going.
- We also run the resale side, mostly Boston and Cambridge listings.
- Salesforce has been in about 5 yrs. The admin who set it up left in 2022. Nobody here really
  knows how it hangs together. We'd like CCG to look under the hood as part of this.
- We have the lots, communities and home plans in Salesforce already, and the resale houses,
  offers and showings. The data is mostly OK.

## New homes: lots and holds

- Right now the sales team finds out what's free by opening each community and scrolling the
  lots. Or they call Kim. Kim keeps a whiteboard. **We want one board** that shows every
  community and every lot by status (available / on hold / under construction / sold).
- From that board a salesperson should be able to **put a hold on a lot in one click**. Pick the
  buyer, done.
- Dana: "I want to know every time a lot goes on hold. Every time."
- Kim's team does the proper paperwork side of a hold. Buyer, deposit, the lot. She wants a
  **step-by-step screen** so new coordinators can't skip anything. After a hold goes on,
  someone should get a reminder task to follow up with the buyer.
- How long a hold lasts: Kim to confirm. (Kim said "it depends" and then we got sidetracked.)
- Holds don't come off by themselves today. Kim clears the old ones on Fridays.

## Deposits

- Deposits live in Steve's spreadsheet. Steve hates it. Every month he asks Kim "who paid what on
  which lot" and she has to dig.
- Two kinds of deposit:
  - **Earnest money** when a buyer puts a hold on a lot.
  - **Design center upgrades.** Buyer goes to the design center, picks cabinets, flooring,
    whatever, and pays for the upgrades up front.
- We need to see deposits on the lot AND against the buyer.
- If a buyer walks we refund. We never throw the record away. Steve needs the history.
- (Resale offers already have an earnest money box. Leave that alone, that's a different thing.)

## Mortgage pre-qual

- Our lender partner is **Keystone Home Lending**. A lot of our buyers are pre-qualified with them.
- Right now Ravi emails Keystone to ask "is this buyer good for this price?" and waits a day.
- Keystone has an API. Monica Feld at Keystone is sending the spec. See the email thread.
- Want: when an offer comes in, Salesforce asks Keystone automatically and shows the answer on
  the offer.
- Cash offers don't need it obviously.

## Month-end

- Month-end is our crunch. Brokers get verbal acceptances through the last week. Dana goes in on
  the last day and accepts a batch of offers so they land in the right month.
- **Last month Dana selected about 60 offers in the list view and changed them all to Accepted. Got
  a big red error that said something about "Too many" and NOTHING saved.** She had to do them
  one at a time. Took her till 9pm.
- Want: Dana can accept offers in bulk from the list view and it just works.
- Only Dana does this. Brokers accept one at a time if they need to.

## Counter-offers on expired offers

- Kim: when the seller counters late (after the offer's expiration date), the system won't let
  her save the offer at all. Error says the expiration date must be in the future.
- She just wants to mark it Countered and type the counter in the notes. Often there's no new
  deadline agreed yet.
- See her email in the thread.
- Dana: we DO still want to stop people entering new offers that are already expired. That
  check was put in for a reason.

## Access

- Ravi asked why he can do some things and not others. Nobody knew.
- CCG mentioned "permission set groups". Sounds right to me. I want it set up so the next admin
  can understand who gets what by looking at it.
- Pat at the Willow Creek front desk has a login for the calendar. Pat should NOT see deposits,
  offers, the new board, any of it.

## "Faster offers"

- Ravi and Kim both said the offer process is slow. I've put it on the list as "make the offer
  process faster". We ran out of time to dig in.

## Timing

- Need it live before month-end close. The bulk accept is the one that really matters for that.

## Actions

- Laura: send CCG the wishlist spreadsheet and the email thread with Keystone. **Done.**
- Monica (Keystone): send API spec. **Done, attached.**
- Kim: confirm hold length. (Still open.)
- CCG: look under the hood of the current setup and come back with what they find.
