/**
 * Unit tests for HomePlanService.
 */
@IsTest
private class HomePlanServiceTest {
    private static final Integer BULK_LOT_COUNT = 200;

    /**
     * Builds a community, three plans (one retired) and a priced lot.
     */
    @TestSetup
    static void setup() {
        Community__c community = new Community__c(Name = 'Plan Test Meadows', City__c = 'Acton', State__c = 'MA');
        insert community;
        List<Home_Plan__c> plans = new List<Home_Plan__c>{
            new Home_Plan__c(Name = 'The Alder', Beds__c = 3, Baths__c = 2, Square_Feet__c = 2000, Base_Price__c = 500000),
            new Home_Plan__c(Name = 'The Birch', Beds__c = 4, Baths__c = 3, Square_Feet__c = 2600, Base_Price__c = 640000),
            new Home_Plan__c(
                Name = 'The Cedar',
                Beds__c = 5,
                Baths__c = 4,
                Square_Feet__c = 3400,
                Base_Price__c = 820000,
                Is_Active__c = false
            )
        };
        insert plans;
        insert new Lot__c(Name = 'PTM-1', Community__c = community.Id, Home_Plan__c = plans[0].Id, Lot_Premium__c = 25000);
    }

    /**
     * Loads a plan created in setup by name.
     * @param name plan name
     * @return the plan with pricing fields
     */
    private static Home_Plan__c planNamed(String name) {
        return [SELECT Id, Base_Price__c, Square_Feet__c FROM Home_Plan__c WHERE Name = :name];
    }

    /**
     * Creates a user on the given profile without inserting it.
     * @param profileName profile to assign
     * @return unsaved user
     */
    private static User buildUser(String profileName) {
        Profile p = [SELECT Id FROM Profile WHERE Name = :profileName];
        String unique = String.valueOf(Crypto.getRandomInteger()).replace('-', '');
        return new User(
            ProfileId = p.Id,
            LastName = 'PlanTest',
            Email = 'plantest' + unique + '@example.com',
            Username = 'plantest' + unique + '@example.com.dreamhouse',
            Alias = 'pt' + unique.left(6),
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
    }

    /**
     * @description Retired plans are excluded from the active catalogue.
     */
    @IsTest
    static void testGetActivePlans_NoMinimum_ExcludesRetiredPlans() {
        Test.startTest();
        List<Home_Plan__c> plans = HomePlanService.getActivePlans(null);
        Test.stopTest();

        Assert.areEqual(2, plans.size(), 'Only the two active plans should be returned');
    }

    /**
     * @description The bedroom minimum filters the catalogue.
     */
    @IsTest
    static void testGetActivePlans_MinBedsFour_ReturnsLargerPlansOnly() {
        Test.startTest();
        List<Home_Plan__c> plans = HomePlanService.getActivePlans(4);
        Test.stopTest();

        Assert.areEqual(1, plans.size(), 'Only The Birch is active with 4+ beds');
        Assert.areEqual('The Birch', plans[0].Name, 'The Birch should be returned');
    }

    /**
     * @description A negative bedroom minimum is treated as no minimum.
     */
    @IsTest
    static void testGetActivePlans_NegativeMinBeds_TreatedAsZero() {
        Test.startTest();
        List<Home_Plan__c> plans = HomePlanService.getActivePlans(-2);
        Test.stopTest();

        Assert.areEqual(2, plans.size(), 'Negative minimum should not filter anything out');
    }

    /**
     * @description A user whose profile cannot read Home Plans gets a query error.
     */
    @IsTest
    static void testGetActivePlans_MinimumAccessUser_ThrowsQueryException() {
        User restricted = buildUser('Dreamhouse Minimum Access');
        insert restricted;
        Boolean threw = false;

        Test.startTest();
        System.runAs(restricted) {
            try {
                HomePlanService.getActivePlans(null);
            } catch (QueryException e) {
                threw = true;
            }
        }
        Test.stopTest();

        Assert.isTrue(threw, 'User mode query should fail without Home Plan read access');
    }

    /**
     * @description A broker can read the active catalogue in user mode.
     */
    @IsTest
    static void testGetActivePlans_BrokerUser_ReturnsActivePlans() {
        User broker = buildUser('Dreamhouse Broker');
        insert broker;
        List<Home_Plan__c> plans;

        Test.startTest();
        System.runAs(broker) {
            plans = HomePlanService.getActivePlans(null);
        }
        Test.stopTest();

        Assert.areEqual(2, plans.size(), 'Broker should see both active plans');
    }

    /**
     * @description Contract price is base price plus lot premium.
     */
    @IsTest
    static void testCalculateLotPrice_WithPremium_AddsPremium() {
        Home_Plan__c plan = planNamed('The Alder');
        Lot__c lot = new Lot__c(Lot_Premium__c = 25000);

        Test.startTest();
        Decimal price = HomePlanService.calculateLotPrice(plan, lot);
        Test.stopTest();

        Assert.areEqual(525000, price, 'Price should be base plus premium');
    }

    /**
     * @description A lot without a premium is priced at the plan base price.
     */
    @IsTest
    static void testCalculateLotPrice_BlankPremium_ReturnsBasePrice() {
        Home_Plan__c plan = planNamed('The Alder');

        Test.startTest();
        Decimal price = HomePlanService.calculateLotPrice(plan, new Lot__c());
        Test.stopTest();

        Assert.areEqual(500000, price, 'Blank premium should count as zero');
    }

    /**
     * @description Pricing without a plan throws.
     */
    @IsTest
    static void testCalculateLotPrice_NullPlan_ThrowsHomePlanException() {
        Test.startTest();
        try {
            HomePlanService.calculateLotPrice(null, new Lot__c());
            Assert.fail('Expected HomePlanException');
        } catch (HomePlanService.HomePlanException e) {
            Assert.isTrue(e.getMessage().contains('base price'), 'Message should mention the base price');
        }
        Test.stopTest();
    }

    /**
     * @description Bulk pricing returns a price for every lot with a plan.
     */
    @IsTest
    static void testCalculateLotPrices_BulkLots_PricesEveryPlannedLot() {
        Home_Plan__c plan = planNamed('The Birch');
        Community__c community = [SELECT Id FROM Community__c LIMIT 1];
        List<Lot__c> lots = new List<Lot__c>();
        for (Integer i = 0; i < BULK_LOT_COUNT; i++) {
            lots.add(new Lot__c(Name = 'BULK-' + i, Community__c = community.Id, Home_Plan__c = plan.Id, Lot_Premium__c = i));
        }
        lots.add(new Lot__c(Name = 'BULK-NOPLAN', Community__c = community.Id));
        insert lots;

        Test.startTest();
        Map<Id, Decimal> prices = HomePlanService.calculateLotPrices(lots);
        Test.stopTest();

        Assert.areEqual(BULK_LOT_COUNT, prices.size(), 'Every lot with a plan should be priced; the unplanned lot is skipped');
    }

    /**
     * @description Bulk pricing applies each lot's own premium.
     */
    @IsTest
    static void testCalculateLotPrices_SingleLot_UsesLotPremium() {
        Lot__c lot = [SELECT Id, Home_Plan__c, Lot_Premium__c FROM Lot__c WHERE Name = 'PTM-1'];

        Test.startTest();
        Map<Id, Decimal> prices = HomePlanService.calculateLotPrices(new List<Lot__c>{ lot });
        Test.stopTest();

        Assert.areEqual(525000, prices.get(lot.Id), 'Price should be The Alder base plus the 25k premium');
    }

    /**
     * @description Price per square foot is rounded to cents.
     */
    @IsTest
    static void testPricePerSquareFoot_ValidPlan_ReturnsRoundedRate() {
        Home_Plan__c plan = planNamed('The Birch');

        Test.startTest();
        Decimal rate = HomePlanService.pricePerSquareFoot(plan);
        Test.stopTest();

        Assert.areEqual(246.15, rate, '640000 / 2600 rounds to 246.15');
    }

    /**
     * @description A plan without square footage cannot be rated.
     */
    @IsTest
    static void testPricePerSquareFoot_ZeroSquareFeet_ThrowsHomePlanException() {
        Home_Plan__c plan = new Home_Plan__c(Base_Price__c = 400000, Square_Feet__c = 0);

        Test.startTest();
        try {
            HomePlanService.pricePerSquareFoot(plan);
            Assert.fail('Expected HomePlanException');
        } catch (HomePlanService.HomePlanException e) {
            Assert.isTrue(e.getMessage().contains('square footage'), 'Message should mention square footage');
        }
        Test.stopTest();
    }
}
