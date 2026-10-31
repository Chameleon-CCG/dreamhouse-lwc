/*
 * Offer automation.
 * - Defaults status and expiration on new offers
 * - When an offer is accepted, puts the property Under Agreement and rejects the other open offers
 * - When an accepted offer is withdrawn, puts the property back on the market
 * DK 2021-03, updated MR 2022-08 (withdrawn handling)
 */
trigger OfferTrigger on Offer__c(
    before insert,
    before update,
    after insert,
    after update
) {
    if (Trigger.isBefore) {
        for (Offer__c o : Trigger.new) {
            if (o.Status__c == null) {
                o.Status__c = 'Submitted';
            }
            if (Trigger.isInsert && o.Expiration_Date__c == null) {
                // standard 3 day offer window
                o.Expiration_Date__c = Date.today().addDays(3);
            }
        }
    }

    if (Trigger.isAfter) {
        for (Offer__c o : Trigger.new) {
            Offer__c oldOffer = Trigger.isUpdate
                ? Trigger.oldMap.get(o.Id)
                : null;

            // Offer accepted -> property under agreement, reject everything else
            if (
                o.Status__c == 'Accepted' &&
                (oldOffer == null || oldOffer.Status__c != 'Accepted')
            ) {
                Property__c prop = [
                    SELECT Id, Status__c, Date_Agreement__c
                    FROM Property__c
                    WHERE Id = :o.Property__c
                ];
                prop.Status__c = 'Under Agreement';
                prop.Date_Agreement__c = Date.today();
                update prop;

                List<Offer__c> otherOffers = [
                    SELECT Id, Status__c
                    FROM Offer__c
                    WHERE
                        Property__c = :o.Property__c
                        AND Id != :o.Id
                        AND Status__c IN ('Submitted', 'Countered')
                ];
                for (Offer__c other : otherOffers) {
                    other.Status__c = 'Rejected';
                }
                if (!otherOffers.isEmpty()) {
                    update otherOffers;
                }
            }

            // Accepted offer withdrawn -> back on the market
            if (
                o.Status__c == 'Withdrawn' &&
                oldOffer != null &&
                oldOffer.Status__c == 'Accepted'
            ) {
                Property__c prop = [
                    SELECT Id, Status__c, Date_Agreement__c
                    FROM Property__c
                    WHERE Id = :o.Property__c
                ];
                prop.Status__c = 'Available';
                prop.Date_Agreement__c = null;
                update prop;
            }
        }
    }
}
