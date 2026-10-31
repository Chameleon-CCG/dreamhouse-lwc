@isTest
private class LotServiceTest {
    @testSetup
    static void setup() {
        Community__c community = new Community__c(
            Name = 'Test Ridge',
            City__c = 'Concord',
            State__c = 'MA',
            Phase__c = 'Phase 1',
            Total_Lots__c = 3
        );
        insert community;
        Home_Plan__c plan = new Home_Plan__c(
            Name = 'The Test',
            Beds__c = 3,
            Baths__c = 2,
            Square_Feet__c = 1800,
            Base_Price__c = 400000
        );
        insert plan;
        Contact buyer = new Contact(
            FirstName = 'Test',
            LastName = 'Buyer',
            Email = 'test.buyer@example.com'
        );
        insert buyer;
        insert new List<Lot__c>{
            new Lot__c(
                Name = 'TR-1',
                Community__c = community.Id,
                Home_Plan__c = plan.Id,
                Status__c = 'Available',
                Lot_Premium__c = 10000
            ),
            new Lot__c(
                Name = 'TR-2',
                Community__c = community.Id,
                Home_Plan__c = plan.Id,
                Status__c = 'Sold'
            ),
            new Lot__c(
                Name = 'TR-3',
                Community__c = community.Id,
                Status__c = 'Reserved',
                Reserved_By__c = buyer.Id,
                Reserved_Date__c = Date.today().addDays(-30)
            )
        };
    }

    @isTest
    static void testReserveLot() {
        Lot__c lot = [SELECT Id FROM Lot__c WHERE Name = 'TR-1'];
        Contact buyer = [SELECT Id FROM Contact WHERE LastName = 'Buyer'];

        Test.startTest();
        LotService.reserveLot(lot.Id, buyer.Id);
        Test.stopTest();

        lot = [SELECT Status__c, Reserved_By__c FROM Lot__c WHERE Id = :lot.Id];
        System.assertEquals('Reserved', lot.Status__c);
        System.assertEquals(buyer.Id, lot.Reserved_By__c);
    }

    @isTest
    static void testReserveLotNotAvailable() {
        Lot__c lot = [SELECT Id FROM Lot__c WHERE Name = 'TR-2'];
        Contact buyer = [SELECT Id FROM Contact WHERE LastName = 'Buyer'];
        Boolean failed = false;
        try {
            LotService.reserveLot(lot.Id, buyer.Id);
        } catch (AuraHandledException e) {
            failed = true;
        }
        System.assert(failed);
    }

    @isTest
    static void testGetAvailableLotsByPlan() {
        Home_Plan__c plan = [SELECT Id FROM Home_Plan__c LIMIT 1];
        List<Lot__c> lots = LotService.getAvailableLotsByPlan(plan.Id);
        System.assertEquals(1, lots.size());
    }

    @isTest
    static void testGetSpecInventory() {
        Community__c community = [SELECT Id FROM Community__c LIMIT 1];
        List<Lot__c> lots = LotService.getSpecInventory(community.Id);
        System.assertNotEquals(null, lots);
    }

    @isTest
    static void testReleaseExpiredReservations() {
        Integer released = LotService.releaseExpiredReservations(null);
        System.assertEquals(1, released);
    }
}
