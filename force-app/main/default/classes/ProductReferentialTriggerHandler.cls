public class ProductReferentialTriggerHandler {

	public static void handleBeforeInsert (List<ProductReferential__c> newList) {
		calculateSortOrder(newList);
	}

	public static void handleAfterInsert(List<ProductReferential__c> newList) {
		assignRefsToOrders(newList);
	}

	public static void handleBeforeUpdate (
		List<ProductReferential__c> oldList,
		Map<Id, ProductReferential__c> oldMap,
		List<ProductReferential__c> newList,
		Map<Id, ProductReferential__c> newMap
		) {

		// As opposed to on insert, this covers cases where the sort order is
		// somehow null; if the value is null, it appears at the top (incorrectly)
		List<ProductReferential__c> unordered = new List<ProductReferential__c>();
		for (ProductReferential__c pr : newList) {
			if (pr.Creation_Sort_Order__c == null) {
				unordered.add(pr);
			}
		}
		if (!unordered.isEmpty()) {
			calculateSortOrder(unordered);
		}
	}

	public static void handleAfterUpdate (
		List<ProductReferential__c> oldList,
		Map<Id, ProductReferential__c> oldMap,
		List<ProductReferential__c> newList,
		Map<Id, ProductReferential__c> newMap
		) {
		assignRefsToOrders(newList);
	}

	/**
	 * Calculates the sort order for the Creation process screens. Queries
	 * the category name on the corresponding Product Catalogue object,
	 * then assigns a weight as defined by the business rules.
	 *
	 * @param    prodRefList the list of Product Referential objects that need
	 *                       calculating
	 * @see      <a href="https://vuitton.atlassian.net/browse/MIY-613">MIY-613</a>
	 * @see      SO_ProductController#findAll(String, String, Boolean, Decimal, Decimal) SO_ProductController.findAll
	 * @since    4.13
	 */
	private static void calculateSortOrder(List<ProductReferential__c> prodRefList) {
		// Create a temp object so the default value can be accessed below
		ProductReferential__c prTemp = (ProductReferential__c)ProductReferential__c.sObjectType.newSObject(null, true);

		// Create a mapping for the SKU order values
		Map<String, Decimal> skuOrderMap = new Map<String, Decimal>();
		for (ProductReferential__c pr : prodRefList) {
			if (pr.SKUCode__c != null) {
				// Use the default value for Creation_Sort_Order__c so that it can be changed in the future
				skuOrderMap.put(pr.SKUCode__c, prTemp.Creation_Sort_Order__c);
			}
		}

		// Find the corresponding Product Catalogue objects by SKU and correct their ordering values.
		// May want to rely on a field on the Category__c object in the future.
		for (ProductCatalogue__c pc : [SELECT Id, Category__r.Name, SKU__c FROM ProductCatalogue__c WHERE SKU__c IN :skuOrderMap.keySet()]) {
			if (pc.Category__r.Name == 'Trunks') {
				skuOrderMap.put(pc.SKU__c, 10);
			} else if ((new Set<String> {'Suitcases', 'Watches & Jewelry Cases', 'Game Cases', 'Gastronomy Cases', 'Writing Cases'}).contains(pc.Category__r.Name)) {
				skuOrderMap.put(pc.SKU__c, 20);
			}
		}

		// Apply the new, corrected sort order values to the Product Referential objects
		for (ProductReferential__c pr : prodRefList) {
			if (skuOrderMap.containsKey(pr.SKUCode__c)) {
				pr.Creation_Sort_Order__c = skuOrderMap.get(pr.SKUCode__c);
			}
		}
	}

	private static void assignRefsToOrders(List<ProductReferential__c> prodRefList) {
		Map<String, Id> orderNumberMap = new Map<String, Id>();

		// collect order numbers and map to product ref. id
		for (ProductReferential__c prodRef : prodRefList) {
			if (prodRef.OrderNumber__c != null) {
				orderNumberMap.put(prodRef.OrderNumber__c, prodRef.Id);
			}
		}

		// collect orders according to order numbers from above
		List<Opportunity> ordersToUpdate = [
			SELECT Id, SPO_SpecialOrderSKUCodeRef__c, OrderNumber__c
			FROM Opportunity
			WHERE OrderNumber__c IN :orderNumberMap.keySet() AND StageName = 'Creation in progress'
		];

		// set product referential on orders
		for (Opportunity order : ordersToUpdate) {
			order.SPO_SpecialOrderSKUCodeRef__c = orderNumberMap.get(order.OrderNumber__c);
		}

		if (!ordersToUpdate.isEmpty()) {
			update ordersToUpdate;
		}
	}
}