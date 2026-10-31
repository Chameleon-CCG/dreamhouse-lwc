/*
 * Tests for OfferTrigger.
 * Uses a real property from the org so the property record page / Under Agreement
 * status can be checked against live config.
 */
@isTest(SeeAllData=true)
private class OfferTriggerTest {
    static Property__c getProperty() {
        List<Property__c> props = [
            SELECT Id, Name, Status__c
            FROM Property__c
            WHERE Status__c = 'Available'
            LIMIT 1
        ];
        if (props.isEmpty()) {
            Property__c p = new Property__c(
                Name = 'Offer Trigger Test',
                Status__c = 'Available',
                Price__c = 500000
            );
            insert p;
            return p;
        }
        return props[0];
    }

    static testMethod void testSubmitOffer() {
        Property__c prop = getProperty();

        Offer__c o = new Offer__c(
            Property__c = prop.Id,
            Amount__c = 450000,
            Status__c = 'Submitted',
            Expiration_Date__c = Date.today().addDays(10)
        );
        insert o;

        o = [SELECT Id, Status__c FROM Offer__c WHERE Id = :o.Id];
        System.assertEquals('Submitted', o.Status__c);
    }

    static testMethod void testAcceptOffer() {
        Property__c prop = getProperty();

        Offer__c o1 = new Offer__c(
            Property__c = prop.Id,
            Amount__c = 450000,
            Status__c = 'Submitted',
            Expiration_Date__c = Date.today().addDays(10)
        );
        Offer__c o2 = new Offer__c(
            Property__c = prop.Id,
            Amount__c = 440000,
            Status__c = 'Submitted',
            Expiration_Date__c = Date.today().addDays(10)
        );
        insert new List<Offer__c>{ o1, o2 };

        Test.startTest();
        o1.Status__c = 'Accepted';
        update o1;
        Test.stopTest();

        prop = [SELECT Id, Status__c FROM Property__c WHERE Id = :prop.Id];
        System.assertEquals('Under Agreement', prop.Status__c);
        o2 = [SELECT Id, Status__c FROM Offer__c WHERE Id = :o2.Id];
        System.assertEquals('Rejected', o2.Status__c);
    }
}
