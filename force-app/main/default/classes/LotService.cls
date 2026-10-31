/**
 * Lot inventory operations used by the community sales pages and the
 * nightly reservation clean-up job.
 */
public with sharing class LotService {
    // Spec Home record type
    private static final Id SPEC_HOME_RT_ID = '012Hs000001MkQzIAK';

    private static final Integer DEFAULT_RESERVATION_DAYS = 14;

    /**
     * Places a reservation on an available lot for a buyer.
     * @param lotId lot to reserve
     * @param buyerId Contact holding the reservation
     * @return the reserved lot
     */
    @AuraEnabled
    public static Lot__c reserveLot(Id lotId, Id buyerId) {
        if (lotId == null || buyerId == null) {
            throw new AuraHandledException('A lot and a buyer are required.');
        }
        Lot__c lot = [
            SELECT Id, Name, Status__c, Reserved_By__c, Reserved_Date__c
            FROM Lot__c
            WHERE Id = :lotId
        ];
        if (lot.Status__c != 'Available') {
            throw new AuraHandledException(
                'Lot ' + lot.Name + ' is not available (' + lot.Status__c + ').'
            );
        }
        lot.Status__c = 'Reserved';
        lot.Reserved_By__c = buyerId;
        lot.Reserved_Date__c = Date.today();
        update lot;
        return lot;
    }

    /**
     * Available lots in any community that can take the given plan.
     * @param homePlanId plan the buyer is interested in
     * @return available lots, cheapest premium first
     */
    @AuraEnabled(cacheable=true)
    public static List<Lot__c> getAvailableLotsByPlan(Id homePlanId) {
        return [
            SELECT
                Id,
                Name,
                Community__c,
                Community__r.Name,
                Home_Plan__c,
                Lot_Premium__c,
                Status__c
            FROM Lot__c
            WHERE Home_Plan__c = :homePlanId AND Status__c = 'Available'
            ORDER BY Lot_Premium__c ASC NULLS FIRST
        ];
    }

    /**
     * Spec homes in a community that a buyer can still purchase.
     * @param communityId community to search
     * @return spec home lots that are available or under construction
     */
    @AuraEnabled(cacheable=true)
    public static List<Lot__c> getSpecInventory(Id communityId) {
        return [
            SELECT
                Id,
                Name,
                Home_Plan__c,
                Home_Plan__r.Name,
                Lot_Premium__c,
                Status__c,
                Estimated_Completion_Date__c
            FROM Lot__c
            WHERE
                Community__c = :communityId
                AND RecordTypeId = :SPEC_HOME_RT_ID
                AND Status__c IN ('Available', 'Under Construction')
            ORDER BY Estimated_Completion_Date__c ASC NULLS LAST
        ];
    }

    /**
     * Releases reservations older than the reservation window so the lots go
     * back on sale. Called from the nightly scheduled job.
     * @param days reservation window in days; null uses the default
     * @return number of lots released
     */
    public static Integer releaseExpiredReservations(Integer days) {
        Integer window = days == null ? DEFAULT_RESERVATION_DAYS : days;
        Date cutoff = Date.today().addDays(-window);
        List<Lot__c> expired = [
            SELECT Id, Status__c, Reserved_By__c, Reserved_Date__c
            FROM Lot__c
            WHERE Status__c = 'Reserved' AND Reserved_Date__c < :cutoff
        ];
        for (Lot__c lot : expired) {
            lot.Status__c = 'Available';
            lot.Reserved_By__c = null;
            lot.Reserved_Date__c = null;
        }
        update expired;
        return expired.size();
    }
}
