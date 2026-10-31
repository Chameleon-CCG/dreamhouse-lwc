# Dreamhouse Brownfield Kit: Answer Key

The planted defects an automated org audit is expected to find. Paths are relative to
`force-app/main/default` unless they start with `data/` or `config/`.

**Do not load this file into the org or give it to the auditor.**

## Planted defects

| # | File | What's wrong | Expected audit dimension | Expected severity |
|---|------|--------------|--------------------------|-------------------|
| 1 | `triggers/OfferTrigger.trigger` | All logic is inline in the trigger; there is no handler class. In the after-insert/after-update loop, each Accepted offer runs a SOQL query for its Property, a property `update`, a SOQL query for sibling offers and an offer `update`. The Withdrawn branch does the same. A bulk status change (a Data Loader file, or a list-view mass edit of 50+ offers) hits the 100-SOQL / 150-DML governor limits. | Apex architecture (trigger framework, bulkification) | High |
| 2a | `profiles/Dreamhouse Sales Manager.profile-meta.xml`, `profiles/Dreamhouse Broker.profile-meta.xml`, `profiles/Dreamhouse Listing Coordinator.profile-meta.xml` | Object CRUD for Offer__c, Showing__c, Lot__c, Community__c and Home_Plan__c, and the FLS for their fields, is granted only through custom profiles. The `dreamhouse` permission set was never extended to the new objects. Sales Manager also has View All and Modify All on all five objects through its profile. | Security / access model (profiles instead of permission sets) | Medium |
| 2b | `profiles/Dreamhouse Listing Coordinator.profile-meta.xml` | The Listing Coordinator has Read on Offer__c but `Offer__c.Amount__c` has readable=false. The Property page's Offers related list, the Offer page, list views and the "Offers by Status" / "Offers by Property" reports all show blank amounts for this persona, and nothing records why. | Security / FLS | Medium |
| 3 | `classes/LotService.cls` (`SPEC_HOME_RT_ID = '012Hs000001MkQzIAK'`) | An 18-character Record Type Id is hard-coded and used to filter `getSpecInventory`. Record type Ids differ per org, so in this org and every sandbox the query silently returns no rows. `LotServiceTest.testGetSpecInventory` only asserts the result is non-null, which hides the bug. | Maintainability / Apex best practice (hard-coded Ids) | High |
| 4 | `objects/Property__c/fields/Listing_Price__c.field-meta.xml`, `layouts/Property__c-Property Layout.layout-meta.xml` | "List Price" (Listing_Price__c) duplicates the stock "Asking Price" (Price__c) and sits directly beneath it on the layout. The seed data already shows drift: 3 properties have a stale List Price after a price change (24 Pearl St, 127 Endicott St, 640 Harrison Ave) and 2 have none (110 Baxter St, 145 Commonwealth Ave). The LWCs, PropertyController and reports read only Price__c. | Data quality / data model (duplicate field) | Medium |
| 5 | `objects/Offer__c/validationRules/Expiration_Date_Must_Be_Future.validationRule-meta.xml` | `Expiration_Date__c <= TODAY()` has no `ISNEW()` / `ISCHANGED()` guard and no bypass for integration or migration users. Historical offers can't be loaded. Once an offer's expiration date has passed it can't be edited at all, including by OfferTrigger's sibling rejection, so accepting one offer fails if a sibling has expired. | Data quality / automation (validation rule blocks bulk and historical loads) | Medium |
| 6 | `classes/OfferTriggerTest.cls` | `@isTest(SeeAllData=true)`: the test depends on an Available Property__c existing in org data. It uses legacy `testMethod` and `System.assertEquals`, has no bulk test and no negative test, and never exercises the Withdrawn branch. It covers OfferTrigger at **77% (27 of 35 lines)**, just over the 75% deploy threshold. | Test quality | High |
| 7 | `flows/Showing_Follow_Up_Task.flow-meta.xml` | "Showing - Follow Up Task" is a record-triggered Flow saved as **Draft** and never activated. The follow-up tasks for interested prospects it is meant to create never get created. | Automation / maintainability (inactive automation) | Low |
| 8 | `flows/Offer_Stamp_Accepted_Date.flow-meta.xml` plus `triggers/OfferTrigger.trigger` | A record-triggered **after-save** Flow on Offer__c stamps Accepted_Date__c. OfferTrigger acts on the same object and the same Accepted transition, so two automation tools run with no defined order. The Flow updates the triggering record after save (a before-save field update would do), which fires OfferTrigger and the validation rule a second time. | Automation (mixed Flow and trigger on one object, recursion) | Medium |

## Related findings an auditor may also raise (consequences of the above, not separate plants)

- `profiles/Admin.profile-meta.xml` is kept in source to grant the admin FLS, layouts and Lot__c record types. This reinforces #2a.
- OfferTrigger and LotService use API version 52.0, while the rest of the codebase is on 64.0.
- `LotServiceTest` uses `System.assert*` and weak assertions (see #3).
- The trigger header carries author and date comments ("DK 2021-03, updated MR 2022-08").

## Known kit limitation

`sf data import tree` can't resolve `RecordType` by DeveloperName ("Cannot reference a foreign key field RecordType"). So all 25 seeded Lot__c records get the admin's default record type, **Spec_Home**. Build_To_Order is deployed with its own layout and profile assignment but has no seed records.

## Personas (`config/users/`)

| File | Profile | Licence | Title |
|------|---------|---------|-------|
| `sales-manager.json` | Dreamhouse Sales Manager | Salesforce | Sales Manager |
| `broker.json` | Dreamhouse Broker | Salesforce Platform | Broker |
| `listing-coordinator.json` | Dreamhouse Listing Coordinator | Salesforce Platform | Listing Coordinator |
| `minimum-access.json` | Dreamhouse Minimum Access | Salesforce Platform | Minimum Access |
