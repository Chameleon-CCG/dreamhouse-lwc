# Expected Outcomes: Dreamhouse Homes Scrimmage

**For the scorer only.** Do not give this file, or anything under `scrimmage/answer-key/`,
to the person voicing the customer or to the delivery platform.

This file says what a good delivery looks like at each stage. It covers the audit, the
readout, the solution proposal, the work items (CHITs), the Salesforce components, the
acceptance tests and the traps.

Inputs it is scored against:

- `data/ANSWER_KEY.md`: the planted org defects #1 to #8 (#2 is split into 2a and 2b).
- `scrimmage/customer/persona-brief.md`: what the customer wants and the hidden answers.
- `scrimmage/customer/discovery-pack/`: what the customer sent.
- `scrimmage/customer/slack-script.md`: what the customer says and when.

Component names in section 5 are the expected names. A different name is acceptable if the
component does the same job and the capability matrix in section 6.1 holds. Score the
behavior, then the name.

---

## 1. Expected audit findings

The audit must find the eight planted defects. They are listed with paths, symptoms,
dimensions and severities in `data/ANSWER_KEY.md`. That file is the source of truth. This
section adds only what each finding means for this release.

| Defect | Must be found | Release disposition | Why |
|--------|---------------|---------------------|-----|
| #1 OfferTrigger not bulk-safe | Yes | **Fix in this release** | R5 depends on it. It is the "Too many" error Dana reported. |
| #2a Profile-based access | Yes | **Fix in this release** | R7 depends on it. |
| #2b Listing Coordinator cannot read `Offer__c.Amount__c` | Yes | **Fix in this release** | Kim needs amounts for R6. The UAT script raises it if missed. |
| #3 Hard-coded Record Type Id in LotService | Yes | **Fix in this release** | R1 and R2 key the hold length on lot record type. |
| #4 Duplicate List Price field | Yes | Defer, or hide from the layout only | Customer said "don't delete anything this time". Deleting the field is a trap. |
| #5 Expiration validation rule unguarded | Yes | **Fix in this release (rework, not removal)** | R6 depends on it. Customer wants the check kept for new offers. |
| #6 OfferTriggerTest uses SeeAllData, 77% coverage | Yes | **Fix in this release** with #1 | The #1 refactor needs real tests. |
| #7 Showing follow-up Flow left in Draft | Yes | Activate if safe, or defer | Customer: "Turn it on if it's safe and doesn't hold up the release." Either is acceptable once asked. |
| #8 After-save Flow and trigger both on Offer__c | Yes | **Fix in this release** with #1 | R5's bulk path fires both. Move the stamp into the handler's before-update. |

Scoring notes:

- Severity and dimension should match `data/ANSWER_KEY.md` within one step.
- The "related findings" in `data/ANSWER_KEY.md` (Admin profile in source, API 52.0, weak
  `LotServiceTest` assertions, author comments in the trigger header) are worth credit but
  are not required.
- A finding that is not in `data/ANSWER_KEY.md` and is not a real issue counts as a false
  positive.

## 2. Expected readout findings

The readout is the platform's write-up of discovery: what the customer asked for, what the
org has today, the gaps, and the open questions. It should contain the points below.

### 2.1 Cross-cutting

- Two sales models share the org. New homes use `Community__c`, `Lot__c` and `Home_Plan__c`.
  Resale uses `Property__c`, `Offer__c`, `Showing__c` and `Broker__c`. R1 to R3 are new-home
  work. R4, R5, R6 and R8 are resale offer work. R7 spans both.
- Buyers are Contacts. `Lot__c.Reserved_By__c`, `Offer__c.Buyer__c` and
  `Showing__c.Contact__c` all point to Contact.
- Persona users and access today: Sales Manager has full access with View All and Modify All
  through the profile. Broker has Offer create and edit, Lot read and edit. Listing
  Coordinator has **read-only** Offer__c and Lot__c and cannot see `Offer__c.Amount__c`.
  Minimum Access has no object access.
- All 25 seeded lots are Spec_Home. Build_To_Order exists but has no records. UAT needs at
  least one Build_To_Order lot to test the 14-day hold.
- Audit findings that block requirements: #1 blocks R5, #5 blocks R6, #2a blocks R7, #3
  affects R1 and R2, #8 affects R5, #2b affects R6.

### 2.2 Per requirement

| Req | Readout should say |
|-----|--------------------|
| R1 | No lot board exists. `LotService.reserveLot` already places a hold (Status, `Reserved_By__c`, `Reserved_Date__c`) and should be reused, not duplicated. Lots are Master-Detail to Community, so sharing follows Community. `getSpecInventory` returns nothing because of #3. |
| R2 | No guided process exists. The coordinator cannot edit lots today, so Kim needs Lot edit. **Open question: how long does a hold last, and does it differ by lot type?** `LotService` has a single 14-day default, which is not a customer answer. Follow-up task and notification are new. The `Showing_Follow_Up_Task` Draft Flow (#7) is a similar pattern, not a reusable component. |
| R3 | No deposit object exists. Deposits must link to both Lot and buyer Contact. Two record types are needed. `Lot__c` already has `Reserved_By__c` and `Reserved_Date__c`; only a hold expiry date (and optionally a deposit total) is new. `Offer__c.Earnest_Money__c` is resale earnest money and stays as is. |
| R4 | Keystone contract from `lender-api-spec.md`: `POST /v2/prequal/verify`, API key and partner ID headers, four results, 60 requests a minute, 10-second timeout. Callouts cannot run synchronously in a trigger, so the check must be asynchronous. The key must live in a Named Credential / External Credential, not code. Cash offers are skipped. |
| R5 | Root cause of Dana's "Too many" error is #1 (SOQL and DML inside the loop). Bulk accept depends on fixing #1, and should also fix #8 so the stamp does not re-fire the trigger. A list-view action is needed for Dana only. |
| R6 | Two blockers: the validation rule (#5) and the coordinator's read-only Offer access. Customer wants the rule kept for new offers. The fix is a guard on the rule, plus Offer edit for Kim. Kim also needs to see amounts (#2b). |
| R7 | Access is in profiles (#2a). Move object and field access to permission sets, bundle them in permission set groups per persona, and keep Pat on no new access. |
| R8 | **Open question: what does "faster" mean?** The readout must flag R8 as needing clarification and must not propose a solution until the customer answers. |

### 2.3 Expected open questions

Required: R2 hold length (by lot type) and R8 meaning. The run fails these items if the
platform proposes an answer without asking (see section 7).

Good to ask, not required: who receives the hold notification, whether holds auto-release,
what to do with the four existing holds, what "open" means for expiring offers, bulk-accept
duplicates on one property, pre-qual retry behavior, List Price (#4) and the Draft Flow (#7).

## 3. Expected solution proposal scope

| Req | In scope | Out of scope (should be stated) |
|-----|----------|---------------------------------|
| R1 | App page with an LWC board of all lots in all three communities, grouped by status, showing lot type, plan, premium, buyer on hold and hold expiry. Reserve button: pick buyer, confirm. Apex controller that delegates to `LotService`. | Deposits on the board. Automatic hold release. |
| R2 | Screen Flow for coordinators: lot, buyer, earnest-money deposit, confirm. Hold length 7 days Spec_Home, 14 days Build_To_Order, applied by shared Apex used by both R1 and R2. Record-triggered Flow on Lot__c: follow-up Task to the user who placed the hold, due on the hold expiry date; notification to the sales managers group. | Automatic release. Enforced deposit amounts. |
| R3 | `Deposit__c` with Earnest_Money and Design_Center_Upgrade record types, linked to Lot__c and Contact, status Received / Refunded / Applied at Closing, no delete for users. `Lot__c.Reservation_Expiration_Date__c`. Optional deposit roll-up on Lot__c. | Changes to `Offer__c.Earnest_Money__c`. Accounting integration. |
| R4 | Named Credential and External Credential for Keystone. Offer fields for result, approved price, reference and check time. Queueable callout on offer insert for non-cash offers. Error status on failure. HttpCalloutMock tests. | Re-check button. Retrying on a schedule. Showing results to sellers. |
| R5 | Repair #1 (handler, bulkified), #8 and #6. List-view action for Dana only (custom permission). Reject the whole pair when two selected offers share a property, and report them. | Bulk actions for other personas. |
| R6 | Rework #5 with an ISNEW/ISCHANGED guard and a custom-permission bypass for migration. Give the coordinator Offer edit. Fix #2b. | Removing the rule. New counter-offer object or fields. |
| R7 | Repair #2a: capability permission sets, permission set groups for Sales Manager, Broker and Listing Coordinator, profiles stripped of object and field access for the new objects. Pat gets nothing new. | Licence changes. New profiles. |
| R8 | After the customer answers: an "Offers Expiring This Week" list view (open offers expiring today to today + 7) and a New Offer action on Property that pre-fills the buyer from the latest Completed - Interested showing. | Any other offer-process redesign. |
| Audit | #1, #2a, #2b, #3, #5, #6, #8 fixed. #4 deferred or hidden only. #7 activated if safe, or deferred, as the customer allowed. | Deleting `Listing_Price__c`. |

## 4. Expected CHIT breakdown and dependencies

One or more CHITs per requirement, plus audit-repair CHITs. IDs below are scorer labels. The
platform's own IDs will differ. Merging two CHITs is acceptable when noted.

| CHIT | Title | Covers | Depends on |
|------|-------|--------|------------|
| AR-1 | Bulk-safe Offer trigger handler and tests | #1, #6 | none |
| AR-8 | Move Accepted Date stamp into the handler; retire the after-save Flow | #8 | AR-1 |
| AR-5 | Guard the offer expiration rule and add a migration bypass | #5 | none |
| AR-2a | Move object and field access from profiles to permission sets | #2a | none |
| AR-2b | Let Listing Coordinators read Offer Amount | #2b | AR-2a (may merge into AR-2a) |
| AR-3 | Resolve Spec Home record type by developer name | #3 | none |
| AR-7 | Activate Showing follow-up Flow (optional) | #7 | customer OK |
| AR-4 | Hide List Price from the Property layout (optional) | #4 | customer OK |
| R3-1 | Deposit object and lot hold expiry field | R3 | none |
| R2-1 | Hold length by lot type in LotService (7 / 14 days) | R2, R1 | AR-3, R3-1, **R2 clarification** |
| R1-1 | Lot availability board | R1 | R2-1, AR-3 |
| R2-2 | Reserve a Lot screen Flow | R2 | R2-1, R3-1 |
| R2-3 | Lot reserved follow-up task and sales manager notification | R2 | R3-1 |
| R4-1 | Keystone credentials and Offer pre-qual fields | R4 | none |
| R4-2 | Keystone pre-qual callout on offer insert | R4 | AR-1, R4-1 |
| R5-1 | Month-end bulk accept from list view | R5 | **AR-1**, AR-8, AR-5 |
| R6-1 | Late counter-offers for coordinators | R6 | **AR-5**, AR-2a, AR-2b |
| R7-1 | Persona permission set groups and assignments | R7 | **AR-2a**, and every feature CHIT that adds permissions |
| R8-1 | Offers Expiring This Week list view | R8 | **R8 clarification** |
| R8-2 | Pre-fill buyer on new offers from the latest interested showing | R8 | **R8 clarification**; AR-1 only if built in the trigger |

Required dependency statements (score each):

- **R5 needs the #1 repair.** R5-1 must not merge before AR-1.
- **R6 needs the #5 rework.** R6-1 must not ship with the original rule, and must not delete it.
- **R7 needs the #2a repair.** AR-2a and R7-1 must ship in the same release. Stripping profiles
  without assigning groups locks the personas out.
- R2-1 is blocked until the customer answers the hold-length question. R8-1 and R8-2 are
  blocked until the customer answers the "faster" question.

## 5. Expected Salesforce components per CHIT

Paths are under `force-app/main/default`.

### AR-1: Bulk-safe Offer trigger handler (#1, #6)

- `triggers/OfferTrigger.trigger`: one line delegating to the handler. API version 64.0.
- `classes/OfferTriggerHandler.cls`: before insert (status and 3-day expiry defaults), after
  insert and after update (accepted and withdrawn logic). One query for properties, one for
  sibling offers, one DML per object type, all outside loops.
- `classes/OfferTriggerHandlerTest.cls`: `@TestSetup` data, 200-record bulk accept, withdrawn
  branch, negative path, no `SeeAllData`, `Assert` class.
- `classes/OfferTriggerTest.cls`: rewritten without `SeeAllData` and `testMethod`, or deleted
  with its coverage moved to `OfferTriggerHandlerTest`.

### AR-8: Accepted Date stamp (#8)

- `classes/OfferTriggerHandler.cls`: sets `Accepted_Date__c` in before update when Status
  changes to Accepted.
- `flows/Offer_Stamp_Accepted_Date.flow-meta.xml`: deactivated (status Obsolete) or removed with
  destructive changes.

### AR-5: Expiration rule guard (#5)

- `objects/Offer__c/validationRules/Expiration_Date_Must_Be_Future.validationRule-meta.xml`:
  formula equivalent to
  `AND(NOT($Permission.Bypass_Offer_Validation), OR(ISNEW(), ISCHANGED(Expiration_Date__c)), Expiration_Date__c <= TODAY())`.
- `customPermissions/Bypass_Offer_Validation.customPermission-meta.xml`.
- `permissionsets/Dreamhouse_Data_Migration.permissionset-meta.xml`: grants the custom
  permission. In no persona group.

### AR-2a: Access to permission sets (#2a)

Permission sets (each with object access, field access and tab settings):

- `Dreamhouse_New_Homes_Read`: Read on `Community__c`, `Lot__c`, `Home_Plan__c`.
- `Dreamhouse_Resale_Read`: Read on `Property__c`, `Broker__c`, `Offer__c`, `Showing__c`,
  including read on `Offer__c.Amount__c`.
- `Dreamhouse_Showing_Management`: Create, Read, Edit, Delete on `Showing__c`.
- `Dreamhouse_Offer_Management`: Create, Read, Edit on `Offer__c`.
- `Dreamhouse_Property_Management`: Create, Read, Edit, Delete on `Property__c`.
- `Dreamhouse_Sales_Management`: full access with View All and Modify All on `Offer__c`,
  `Showing__c`, `Lot__c`, `Community__c`, `Home_Plan__c`, `Property__c`, `Broker__c`.

Profiles: `Dreamhouse Sales Manager`, `Dreamhouse Broker`, `Dreamhouse Listing Coordinator`
keep login, layout assignments and record type defaults, and grant **no** object or field
access on the five new objects. Because a profile deploy does not revoke access that is
simply left out, the profile files must set those permissions to `false` explicitly, or the
CHIT must show an org query proving they are gone.

### AR-2b: Coordinator reads Offer Amount (#2b)

- `Offer__c.Amount__c` readable in `Dreamhouse_Resale_Read` (and editable in
  `Dreamhouse_Offer_Management`). Not fixed by editing the profile FLS alone.

### AR-3: Record type by developer name (#3)

- `classes/LotService.cls`: `Schema.SObjectType.Lot__c.getRecordTypeInfosByDeveloperName()
  .get('Spec_Home').getRecordTypeId()` in place of the literal Id. API version 64.0.
- `classes/LotServiceTest.cls`: inserts Spec_Home and Build_To_Order lots and asserts
  `getSpecInventory` returns only the Spec_Home ones.

### AR-7 (optional): `flows/Showing_Follow_Up_Task.flow-meta.xml` status Active, with a test or a
documented manual check.

### AR-4 (optional): `layouts/Property__c-Property Layout.layout-meta.xml` without
`Listing_Price__c`. The field itself stays.

### R3-1: Deposit object

- `objects/Deposit__c/Deposit__c.object-meta.xml`: label Deposit, name field auto number
  `DEP-{00000}`, sharing Controlled by Parent, description set.
- Fields on `Deposit__c`:
  - `Lot__c`: Master-Detail to `Lot__c`, relationship name `Deposits`.
  - `Buyer__c`: Lookup to Contact, relationship name `Deposits`, delete constraint Restrict.
  - `Amount__c`: Currency.
  - `Received_Date__c`: Date.
  - `Status__c`: restricted Picklist, values Received (default), Refunded, Applied at Closing.
  - `Upgrade_Description__c`: Text(255), on the Design Center Upgrade layout only.
- Record types `Deposit__c.Earnest_Money` and `Deposit__c.Design_Center_Upgrade`.
- Layouts `Deposit__c-Earnest Money Layout` and `Deposit__c-Design Center Upgrade Layout`.
- Tab `Deposit__c`. List view `All`.
- Fields on `Lot__c`:
  - `Reservation_Expiration_Date__c`: Date.
  - `Total_Deposits__c` (optional): Roll-Up Summary, SUM of `Deposit__c.Amount__c` where
    `Status__c` = Received.
- Deposits related list on `Lot__c-Spec Home Lot Layout` and `Lot__c-Build To Order Lot Layout`.
- Existing `Reserved_By__c` and `Reserved_Date__c` reused, not duplicated.

### R2-1: Hold length by lot type

- `customMetadata` type `Lot_Reservation_Window__mdt` with field `Days__c`, records
  `Lot_Reservation_Window.Spec_Home` (7) and `Lot_Reservation_Window.Build_To_Order` (14).
  Named constants in `LotService` are acceptable; a single 14-day default is not.
- `classes/LotService.cls`: `reserveLot` reads the lot's record type and sets
  `Reservation_Expiration_Date__c` = today + window.
- `classes/LotReservationAction.cls`: `@InvocableMethod` wrapper over `LotService.reserveLot`
  for the screen Flow.
- `classes/LotReservationActionTest.cls`, and `LotServiceTest` covering 7 and 14 days.
- `releaseExpiredReservations` is not scheduled. Aligning it to the new field is fine.
  Scheduling it is scope creep.

### R1-1: Lot availability board

- `classes/LotAvailabilityController.cls` (`with sharing`): `@AuraEnabled(cacheable=true)
  getLotBoard()` with `WITH USER_MODE`, and `@AuraEnabled reserveLot(Id lotId, Id buyerId)`
  delegating to `LotService.reserveLot`.
- `classes/LotAvailabilityControllerTest.cls`, including a `System.runAs` test as the Minimum
  Access persona that asserts access is denied.
- `lwc/lotAvailabilityBoard/` with Jest tests.
- `flexipages/Lot_Availability_Board.flexipage-meta.xml` (App Page).
- `tabs/Lot_Availability_Board.tab-meta.xml`, added to `applications/Dreamhouse.app-meta.xml`.
- `permissionsets/Dreamhouse_Lot_Reservations.permissionset-meta.xml`: Edit on `Lot__c`, Read
  on `Deposit__c`, class access to `LotAvailabilityController`, tab visible.

### R2-2: Reserve a Lot screen Flow

- `flows/Screen_Reserve_A_Lot.flow-meta.xml`: screens for lot (or starts from a lot record),
  buyer (existing Contact or new), earnest-money amount and received date, confirm. Calls
  `LotReservationAction`, creates a `Deposit__c` (Earnest_Money, Received). Fault path shows
  the error and creates no deposit.
- `quickActions/Lot__c.Reserve_A_Lot.quickAction-meta.xml` on both lot layouts.
- `permissionsets/Dreamhouse_Deposit_Management.permissionset-meta.xml`: Create, Read, Edit
  on `Deposit__c` (no Delete), flow access to `Screen_Reserve_A_Lot`, class access to
  `LotReservationAction`.

### R2-3: Follow-up task and notification

- `flows/Notification_Lot_Reserved.flow-meta.xml`: record-triggered, after save, on `Lot__c`
  when `Status__c` changes to Reserved. Creates a Task (owner = the user who placed the hold,
  What = the lot, Who = `Reserved_By__c`, due = `Reservation_Expiration_Date__c`). Sends the
  notification.
- `notificationtypes/Lot_Reserved.notiftype-meta.xml` (custom notification), or an email alert.
- `groups/Sales_Managers.group-meta.xml` with Dana Whitfield as a member. Recipient is the group,
  never a hard-coded user Id.

### R4-1: Keystone credentials and fields

- `externalCredentials/Keystone_Lending.externalCredential-meta.xml`: custom protocol, named
  principal, API key parameter, custom headers `X-Api-Key` (from the credential) and
  `X-Partner-Id` = `DREAMHOUSE-0042`.
- `namedCredentials/Keystone_Lending.namedCredential-meta.xml`: URL
  `https://api.sandbox.keystonelending.example`. Production URL set at go-live.
- Fields on `Offer__c`:
  - `Prequal_Status__c`: Picklist, values Pending, Verified, Insufficient, Not Found, Expired,
    Error, Not Required.
  - `Prequal_Approved_Amount__c`: Currency.
  - `Prequal_Reference__c`: Text(60), Keystone `requestId`.
  - `Prequal_Checked_DateTime__c`: DateTime.
  - `Prequal_Message__c` (optional): Text(255).
  - `Prequal_Expiration_Date__c` (optional): Date.
- Fields added read-only to `Offer__c-Offer Layout`.
- `permissionsets/Dreamhouse_Lender_Prequal.permissionset-meta.xml`: read on the pre-qual
  fields, principal access to the `Keystone_Lending` external credential.
- No API key anywhere in source.

### R4-2: Pre-qual callout

- `classes/KeystonePrequalService.cls`: builds the request (`partnerReference` = offer Name,
  borrower from `Buyer__r`, `purchasePrice` = `Amount__c`, `loanProgram` mapped from
  `Financing_Type__c`, `propertyState` = `Property__r.State__c`), calls
  `callout:Keystone_Lending/v2/prequal/verify`, maps results and errors to `Prequal_Status__c`.
- `classes/KeystonePrequalQueueable.cls`: `Queueable, Database.AllowsCallouts`, takes a list of
  offer Ids, stays under 100 callouts per job, sets Error on 4xx/5xx and 429.
- `classes/KeystonePrequalHttpMock.cls` (`@IsTest`, `HttpCalloutMock`).
- `classes/KeystonePrequalServiceTest.cls`, `classes/KeystonePrequalQueueableTest.cls`.
- `classes/OfferTriggerHandler.cls`: before insert sets Pending (or Not Required for Cash);
  after insert enqueues **one** job for all eligible offers in the transaction.

Loan program mapping: Conventional → `CONVENTIONAL`, FHA → `FHA`, VA → `VA`, Jumbo → `JUMBO`,
Cash → no call.

### R5-1: Bulk accept

- `classes/OfferBulkAcceptService.cls`: checks `FeatureManagement.checkPermission('Bulk_Accept_Offers')`,
  rejects any pair of selected offers on the same property and reports them, sets Status
  Accepted on the rest in one DML. The repaired handler does the property and sibling work.
- `classes/OfferBulkAcceptServiceTest.cls`: 200 offers on 200 properties, the duplicate-property
  case, the permission-denied case under `System.runAs` as the Broker persona.
- `flows/Screen_Bulk_Accept_Offers.flow-meta.xml` launched from the list-view button, or a
  Visualforce page `OfferBulkAccept` with a standard set controller extension.
- `objects/Offer__c` list-view button `Accept_Selected_Offers`, added to the list-view
  search layout.
- `customPermissions/Bulk_Accept_Offers.customPermission-meta.xml`, granted only in
  `Dreamhouse_Sales_Management`.

### R6-1: Late counter-offers

- AR-5 rule guard (no new rule).
- `Offer__c` Edit for the coordinator through `Dreamhouse_Offer_Management` in the coordinator
  group.
- `Status__c` and `Notes__c` editable on the Offer layout.

### R7-1: Permission set groups

- `permissionsetgroups/Dreamhouse_Sales_Manager_Access.permissionsetgroup-meta.xml`: all
  `Dreamhouse_*` sets except `Dreamhouse_Data_Migration`.
- `permissionsetgroups/Dreamhouse_Broker_Access.permissionsetgroup-meta.xml`:
  `Dreamhouse_New_Homes_Read`, `Dreamhouse_Resale_Read`, `Dreamhouse_Showing_Management`,
  `Dreamhouse_Offer_Management`, `Dreamhouse_Lot_Reservations`, `Dreamhouse_Lender_Prequal`.
- `permissionsetgroups/Dreamhouse_Listing_Coordinator_Access.permissionsetgroup-meta.xml`:
  `Dreamhouse_New_Homes_Read`, `Dreamhouse_Resale_Read`, `Dreamhouse_Showing_Management`,
  `Dreamhouse_Offer_Management`, `Dreamhouse_Property_Management`,
  `Dreamhouse_Lot_Reservations`, `Dreamhouse_Deposit_Management`, `Dreamhouse_Lender_Prequal`.
- Assignments: Dana Whitfield, Ravi Menon, Kim Alvarez to their group. Pat Doyle to none.

### R8-1: Expiring offers list view

- `objects/Offer__c/listViews/Offers_Expiring_This_Week.listView-meta.xml`: label "Offers
  Expiring This Week", scope Everything, Status in Submitted, Countered, and expiration from
  today to today + 7. One valid filter: `(1 OR 2) AND 3` with
  `Expiration_Date__c = TODAY`, `Expiration_Date__c = NEXT_N_DAYS:7`, `Status__c = Submitted,Countered`.
  Columns as in `Open_Offers`.

### R8-2: Buyer pre-fill

- Preferred: `quickActions/Property__c.New_Offer.quickAction-meta.xml` launching
  `flows/Screen_New_Offer.flow-meta.xml`. The Flow finds the `Showing__c` on the property with
  `Outcome__c` = Completed - Interested and the latest `Scheduled_DateTime__c`, pre-fills
  `Buyer__c` (editable), and creates the offer. Action added to `Property__c-Property Layout`.
- Accepted with partial credit: defaulting `Buyer__c` in `OfferTriggerHandler` before insert
  when it is blank. The user cannot see or change the buyer before saving, which the customer
  asked for.

## 6. Acceptance tests

### 6.1 Capability matrix (after release)

| Capability | Dana (Sales Manager) | Ravi (Broker) | Kim (Listing Coordinator) | Pat (Minimum Access) |
|------------|:--:|:--:|:--:|:--:|
| See Lot Availability Board | Yes | Yes | Yes | **No** |
| Place a hold from the board | Yes | Yes | Yes | **No** |
| Run Reserve a Lot | Yes | No | Yes | **No** |
| Read deposits | Yes | Yes | Yes | **No** |
| Create and edit deposits | Yes | No | Yes | **No** |
| Delete deposits | No | No | No | **No** |
| Read pre-qual fields on offers | Yes | Yes | Yes | **No** |
| Bulk accept offers | **Yes** | No | No | **No** |
| Edit offers (late counter) | Yes | Yes | **Yes** | **No** |
| Read `Offer__c.Amount__c` | Yes | Yes | **Yes** | **No** |
| Offers Expiring This Week | Yes | Yes | Yes | **No** |
| New Offer with buyer pre-fill | Yes | Yes | Yes (if given create) | **No** |

Kim's offer create access is not scored either way.

### 6.2 Test data

- Seed data from `data/` as loaded.
- One Build_To_Order lot created in UAT: `HP-10`, Harbor Pointe, Available, record type
  Build_To_Order, no plan.
- Sandbox Keystone borrowers as Contacts: Vera Verified (`verified.buyer@example.com`), Ian
  Insufficient (`insufficient.buyer@example.com`), Ezra Expired (`expired.buyer@example.com`).
- Past-dated offers are created by a user with `Dreamhouse_Data_Migration` (the bypass). This
  also proves the bypass works.

"Today" means the run date. Dates below are relative.

### 6.3 R1: Lot board

Seed counts: 25 lots. Willow Creek 10, Harbor Pointe 9 (10 with HP-10), Stonebridge Farm 6.
Available 10 (WC-107, WC-108, WC-109, WC-110, HP-04, HP-05, HP-06, HP-07, HP-09, SB-26).
Reserved 4 (WC-105, WC-106, HP-03, SB-25). Under Construction 5 (WC-103, WC-104, HP-01, HP-02,
SB-24). Sold 6 (WC-101, WC-102, HP-08, SB-21, SB-22, SB-23).

1. **Given** Dana is logged in, **when** she opens the Lot Availability Board, **then** she sees
   all three communities and the 25 seeded lots grouped by the four statuses with the counts
   above, and each lot shows Spec Home or Build To Order.
2. **Given** Ravi is logged in and WC-107 is Available, **when** he clicks Reserve on WC-107,
   picks Priya Raman and confirms, **then** WC-107 is Reserved, `Reserved_By__c` = Priya Raman,
   `Reserved_Date__c` = today, `Reservation_Expiration_Date__c` = today + 7.
3. **Given** test 2 has run, **then** a Task exists for Ravi on WC-107, due today + 7, and the
   Sales_Managers group (Dana) received the Lot Reserved notification.
4. **Given** Ravi is logged in, **when** he tries to reserve WC-105 (already Reserved), **then**
   he sees "Lot WC-105 is not available (Reserved)." and nothing changes.
5. **Given** Kim is logged in, **when** she reserves HP-10 (Build_To_Order) for Tom Okafor from
   the board, **then** `Reservation_Expiration_Date__c` = today + 14.
6. **Given** Pat is logged in, **then** there is no Lot Availability Board tab, the app page
   URL shows no lot data, and a direct call to `LotAvailabilityController` fails with
   insufficient access.

### 6.4 R2: Reserve a Lot

1. **Given** Kim is logged in and HP-04 is Available, **when** she runs Reserve a Lot for
   HP-04, buyer Marcus Bell, earnest money $5,000 received today, **then** HP-04 is Reserved
   for Marcus Bell with expiry today + 7, and one `Deposit__c` exists: Earnest_Money, $5,000,
   Received, Lot HP-04, Buyer Marcus Bell.
2. **Given** test 1 has run, **then** a Task exists for Kim on HP-04 due today + 7, and Dana
   was notified through the Sales_Managers group.
3. **Given** Dana is logged in, **when** she runs Reserve a Lot for a Build_To_Order lot,
   **then** the expiry is today + 14.
4. **Given** Kim has started Reserve a Lot for HP-05 and Ravi reserves HP-05 from the board
   before she confirms, **when** Kim confirms, **then** she sees an error, HP-05 stays
   reserved for Ravi's buyer, and no deposit is created.
5. **Given** Ravi is logged in, **then** the Reserve a Lot action is not available to him.
6. **Given** Pat is logged in, **then** Pat cannot see or run Reserve a Lot.
7. **Given** the Sales_Managers group, **then** the notification recipient is the group, and a
   second user added to the group also receives it.

### 6.5 R3: Deposits

1. **Given** Kim is logged in, **when** she creates a Design_Center_Upgrade deposit on WC-106
   for Marcus Bell, $12,500, received today, "Quartz counters and wide-plank flooring",
   **then** it saves and shows on WC-106's Deposits list and on Marcus Bell's contact.
2. **Given** that deposit, **when** Kim sets Status to Refunded, **then** it saves.
3. **Given** that deposit, **when** Kim, Dana or Ravi tries to delete it, **then** it is denied.
4. **Given** Ravi is logged in, **then** he can read deposits and cannot edit them.
5. **Given** Pat is logged in, **then** Pat has no Deposits tab and no access to `Deposit__c`.
6. **Given** any resale offer, **then** `Offer__c.Earnest_Money__c` is unchanged and still
   editable by Ravi.

### 6.6 R4: Pre-qual (Apex tests with the mock; repeat 1 to 5 in UAT against the sandbox)

1. **Given** Ravi creates a Conventional offer of $900,000 on 32 Prince St for Vera Verified,
   **when** the job runs, **then** `Prequal_Status__c` = Verified and
   `Prequal_Approved_Amount__c` = 1,500,000, `Prequal_Reference__c` is set, and
   `Prequal_Checked_DateTime__c` is set.
2. **Given** an FHA offer of $650,000 for Ian Insufficient, **then** Insufficient, approved
   400,000.
3. **Given** an offer for Ezra Expired, **then** Expired.
4. **Given** a Jumbo offer for Priya Raman, **then** Not Found.
5. **Given** a Cash offer, **then** `Prequal_Status__c` = Not Required and no callout is made.
6. **Given** the mock returns 503 (or 429, 401, 400), **then** `Prequal_Status__c` = Error and
   the offer itself saved normally.
7. **Given** 200 non-cash offers inserted in one transaction, **then** exactly one queueable
   job is enqueued from the trigger and no limit exception occurs.
8. **Given** Dana, Ravi or Kim opens an offer, **then** they see the pre-qual fields read-only.
   **Given** Pat, **then** Pat cannot open offers.
9. **Given** the repository, **then** no API key appears in any file.

### 6.7 R5: Bulk accept

1. **Given** Dana is in the Open Offers list view, **when** she selects Elena Vasquez on 32
   Prince St, Nora Fitzgerald on 121 Harborwalk, Luis Ortega on 640 Harrison Ave, Samuel
   Adeyemi on 95 Gloucester St and Elena Vasquez on 145 Commonwealth Ave, and clicks Accept
   Selected Offers, **then** all five are Accepted with `Accepted_Date__c` = today, the five
   properties are Under Agreement with `Date_Agreement__c` = today, and Priya Raman's
   Countered offer on 95 Gloucester St and Marcus Bell's offer on 145 Commonwealth Ave are
   Rejected.
2. **Given** an Apex test with 200 Submitted offers on 200 properties, **when** they are accepted
   in one transaction, **then** all succeed within governor limits and `Accepted_Date__c` is
   stamped once (no second trigger pass from a Flow).
3. **Given** Dana selects Priya Raman's and Luis Ortega's offers on 18 Henry St together,
   **then** neither is accepted and the message names both offers.
4. **Given** a property with an open sibling offer whose expiration date has passed, **when**
   Dana accepts another offer on it, **then** the expired sibling is Rejected without a
   validation error.
5. **Given** Dana mass-edits 60 open offers to Accepted with inline list-view edit, **then** the
   save succeeds (proves #1 is fixed, not just worked around by the new button).
6. **Given** Ravi or Kim, **when** they try Accept Selected Offers, **then** the button is
   hidden or the action refuses with a permission message, and no offer changes.
7. **Given** Pat, **then** Pat cannot reach offers at all.

### 6.8 R6: Late counter-offers

1. **Given** Grace Murphy's Submitted offer on 127 Endicott St has `Expiration_Date__c` =
   yesterday (set by the migration user), **when** Kim sets Status to Countered, adds "Seller counters at $462,000" to
   Notes and saves, **then** it saves and the expiration date is unchanged.
2. **Given** the same offer, **when** Kim changes the expiration date to yesterday minus one
   day, **then** she sees "Expiration Date must be in the future."
3. **Given** the same offer, **when** Kim sets a new expiration date of today + 5, **then** it
   saves.
4. **Given** Ravi creates a new offer with expiration date yesterday, **then** he sees
   "Expiration Date must be in the future." and nothing is saved.
5. **Given** a user with `Dreamhouse_Data_Migration` inserts an offer with a past expiration
   date, **then** it saves.
6. **Given** Ravi edits an expired offer's status, **then** it saves (he could already edit
   offers).
7. **Given** Pat, **then** Pat cannot reach offers.

### 6.9 R7: Access

1. **Given** the org, **then** Dana has `Dreamhouse_Sales_Manager_Access`, Ravi has
   `Dreamhouse_Broker_Access`, Kim has `Dreamhouse_Listing_Coordinator_Access`, and Pat has no
   Dreamhouse group or permission set.
2. **Given** a query of `ObjectPermissions` where `Parent.IsOwnedByProfile = true` and the
   profile is one of the three Dreamhouse persona profiles, **then** no rows grant access to
   `Offer__c`, `Showing__c`, `Lot__c`, `Community__c`, `Home_Plan__c` or `Deposit__c`.
3. **Given** each persona, **then** every row of the matrix in 6.1 holds when tested by Login-As.
4. **Given** Ravi, **then** he can still create, edit and delete showings and create and edit
   offers, as before the release.

### 6.10 R8: Faster offers

1. **Given** open offers expiring today, today + 1, today + 7 and today + 8, and an Accepted
   offer expiring tomorrow, **when** Dana opens Offers Expiring This Week, **then** she sees
   the first three only.
2. **Given** Kim opens the same list view, **then** she sees the same offers with amounts.
3. **Given** Ravi is on 18 Henry St, **when** he clicks New Offer, **then** Buyer is pre-filled
   with Luis Ortega (latest Completed - Interested showing). **When** he changes it to Priya
   Raman and saves, **then** the offer's buyer is Priya Raman.
4. Pre-fill by property from seed data: 32 Prince St → Elena Vasquez; 127 Endicott St → Grace
   Murphy; 121 Harborwalk → Nora Fitzgerald; 640 Harrison Ave → Luis Ortega; 95 Gloucester St
   → Samuel Adeyemi; 145 Commonwealth Ave → Marcus Bell (Derek Chu's later showing was
   Cancelled). Scheduled future showings are ignored.
5. **Given** Ravi is on 24 Pearl St (no showings), **when** he clicks New Offer, **then** Buyer
   is blank.
6. **Given** Pat, **then** Pat has neither the list view nor the action.

### 6.11 Audit repairs (not covered above)

- **#3:** `LotService.getSpecInventory` for Willow Creek returns WC-103 and WC-104 (Spec_Home,
  Under Construction) and the Available Spec_Home lots, in this org and any sandbox.
- **#6:** No test class in the release uses `SeeAllData=true`. OfferTrigger and its handler are
  at 90% coverage or more.
- **#8:** `Offer_Stamp_Accepted_Date` is not active in the target org.

## 7. Traps: what a wrong delivery looks like

| Friction item | Wrong delivery | Right delivery |
|---------------|----------------|----------------|
| R2 hold length | Uses `LotService`'s 14-day default, or any number, without asking. Or asks but applies one window to both lot types. | Asks. Gets 7 days Spec_Home and 14 days Build_To_Order. Applies it in one shared place used by both the board and the Flow, keyed on record type developer name. |
| R2 notification | Sends to Dana's user Id or her email address. | Sends to a group or role that contains Dana. |
| R5 bulk accept | Builds the list-view action on top of the unrepaired OfferTrigger, so 60 offers still fail. Or works around it by processing offers one at a time in a loop of separate transactions, or with a Batch job that hides the limit. Leaves the after-save Flow (#8) in place so the trigger runs twice. | Repairs #1 first (handler, bulkified), fixes #8 and #6 with it, then adds a thin list-view action guarded by a custom permission. |
| R6 late counters | Deletes or deactivates `Expiration_Date_Must_Be_Future`. Or adds a profile check on the rule instead of the ISNEW/ISCHANGED guard. Or gives Kim a bypass permission so she can also enter past-dated new offers. | Guards the rule so it fires only on new offers or changed dates, adds a migration-only bypass, and gives Kim Offer edit. |
| R7 access | Adds more permissions to the profiles. Or creates permission sets but leaves the profile grants in place, so nothing is cleaned up. Or strips the profiles without assigning groups. | Capability permission sets, persona groups, profiles stripped, groups assigned, all in one release. |
| R8 vague | Builds something without asking: a new offer wizard, offer templates, auto-expiry jobs, a dashboard, e-signature. Or asks and then builds more than the two answered items. | Flags R8 as unclear in the readout, asks, builds the expiring list view and the buyer pre-fill. |
| #2b | Fixes Kim's blank amounts by editing the Listing Coordinator profile FLS, against the R7 direction. Or never notices until the UAT feedback. | Finds it in the audit and fixes it in a permission set. |
| #3 | Copies the hard-coded Record Type Id pattern into the new reservation code. | Resolves record types by developer name everywhere. |
| #4 | Deletes `Listing_Price__c` or migrates prices. | Defers, or removes it from the layout only. |
| R4 | Makes the callout synchronously from the trigger, or one queueable per offer. Hard-codes the URL or key. | One queueable per transaction through the Named Credential. Mock tests for every result and error. |
| R1 | Writes a second reserve method in the new controller instead of using `LotService.reserveLot`. Creates new "reserved by" fields beside the existing ones. | Delegates to `LotService` and reuses the existing fields. |
| Pat | Gives Pat read access "so the page loads", or leaves the new tab visible by default. | Pat gets nothing new. Tested with `System.runAs` and Login-As. |
| Scope | Schedules `releaseExpiredReservations`, builds auto-release, adds a pre-qual re-check button, or changes resale earnest money. | Asks first. The customer says no to each of these. |
