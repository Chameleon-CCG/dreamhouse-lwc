/**
 * Pricing and catalogue queries for new-construction home plans.
 * @description All queries run in user mode so callers only see plans and
 * lots their profile can read.
 */
public with sharing class HomePlanService {
    /**
     * Thrown when a pricing request is missing the data it needs.
     */
    public class HomePlanException extends Exception {
    }

    /**
     * Returns the active plans with at least the requested number of bedrooms.
     * @param minBeds minimum bedrooms; null or negative means no minimum
     * @return active plans ordered by base price, lowest first
     */
    public static List<Home_Plan__c> getActivePlans(Integer minBeds) {
        return queryActivePlans(normalizeMinBeds(minBeds));
    }

    /**
     * Calculates the contract price for building a plan on a lot.
     * @param plan the plan being built; must have Base_Price__c
     * @param lot the lot it is built on; a blank premium counts as zero
     * @return base price plus lot premium
     * @throws HomePlanException when the plan or its base price is missing
     */
    public static Decimal calculateLotPrice(Home_Plan__c plan, Lot__c lot) {
        validatePlan(plan);
        return plan.Base_Price__c + premiumOf(lot);
    }

    /**
     * Calculates contract prices for many lots at once, using each lot's plan.
     * @param lots lots with Home_Plan__c and Lot_Premium__c populated
     * @return contract price keyed by lot Id; lots without a plan are omitted
     */
    public static Map<Id, Decimal> calculateLotPrices(List<Lot__c> lots) {
        Map<Id, Home_Plan__c> plansById = queryPlansById(collectPlanIds(lots));
        Map<Id, Decimal> pricesByLotId = new Map<Id, Decimal>();
        for (Lot__c lot : lots) {
            Home_Plan__c plan = plansById.get(lot.Home_Plan__c);
            if (plan != null && plan.Base_Price__c != null) {
                pricesByLotId.put(lot.Id, plan.Base_Price__c + premiumOf(lot));
            }
        }
        return pricesByLotId;
    }

    /**
     * Calculates the base price per finished square foot of a plan.
     * @param plan plan with Base_Price__c and Square_Feet__c
     * @return price per square foot rounded to cents
     * @throws HomePlanException when the plan, price or square footage is missing
     */
    public static Decimal pricePerSquareFoot(Home_Plan__c plan) {
        validatePlan(plan);
        if (plan.Square_Feet__c == null || plan.Square_Feet__c <= 0) {
            throw new HomePlanException('Plan square footage must be greater than zero.');
        }
        return (plan.Base_Price__c / plan.Square_Feet__c).setScale(2, RoundingMode.HALF_UP);
    }

    /**
     * Clamps the requested bedroom minimum to a non-negative value.
     * @param minBeds requested minimum
     * @return zero for null or negative input, otherwise the input
     */
    private static Integer normalizeMinBeds(Integer minBeds) {
        return (minBeds == null || minBeds < 0) ? 0 : minBeds;
    }

    /**
     * Ensures a plan is present and priced.
     * @param plan plan to check
     * @throws HomePlanException when the plan or its base price is missing
     */
    private static void validatePlan(Home_Plan__c plan) {
        if (plan == null || plan.Base_Price__c == null) {
            throw new HomePlanException('A home plan with a base price is required.');
        }
    }

    /**
     * Returns a lot's premium, treating a missing lot or blank premium as zero.
     * @param lot lot to read
     * @return the premium or zero
     */
    private static Decimal premiumOf(Lot__c lot) {
        return (lot == null || lot.Lot_Premium__c == null) ? 0 : lot.Lot_Premium__c;
    }

    /**
     * Collects the distinct plan Ids referenced by a list of lots.
     * @param lots lots to scan
     * @return non-null plan Ids
     */
    private static Set<Id> collectPlanIds(List<Lot__c> lots) {
        Set<Id> planIds = new Set<Id>();
        for (Lot__c lot : lots) {
            if (lot.Home_Plan__c != null) {
                planIds.add(lot.Home_Plan__c);
            }
        }
        return planIds;
    }

    /**
     * Queries active plans with at least the given bedrooms in user mode.
     * @param minBeds minimum bedrooms
     * @return matching plans by ascending base price
     */
    private static List<Home_Plan__c> queryActivePlans(Integer minBeds) {
        return [
            SELECT Id, Name, Beds__c, Baths__c, Square_Feet__c, Base_Price__c
            FROM Home_Plan__c
            WHERE Is_Active__c = TRUE AND Beds__c >= :minBeds
            WITH USER_MODE
            ORDER BY Base_Price__c ASC
        ];
    }

    /**
     * Queries plans by Id in user mode.
     * @param planIds plan Ids to load
     * @return plans keyed by Id
     */
    private static Map<Id, Home_Plan__c> queryPlansById(Set<Id> planIds) {
        return new Map<Id, Home_Plan__c>(
            [
                SELECT Id, Base_Price__c
                FROM Home_Plan__c
                WHERE Id IN :planIds
                WITH USER_MODE
            ]
        );
    }
}
