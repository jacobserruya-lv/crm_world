@isTest
private class LV_UTILS_TEST {
	
	@isTest static void testWrapperClass() {
		LV_UTILS.SearchCriteria searchCr = new LV_UTILS.SearchCriteria(); 
		searchCr.Label = 'TestLabel';
		searchCr.Value = 'TestValue';
		searchCr.Operator = 'EQUALS';

		system.assertEquals(searchCr.Label, 'TestLabel'); 
	}
	
	@isTest static void testEmptyMethodObjectEmpty() {
		Account accTest;

		system.assertEquals(LV_UTILS.empty(accTest), true);
	}

	@isTest static void testEmptyMethodObjectNotEmpty() {
		Account accTest = new Account();
		accTest.Name = 'Acc test';

		system.assertEquals(LV_UTILS.empty(accTest), false);
	}

	@isTest static void testEmptyMethodIntegerEmpty() {
		Integer intTest = null;

		system.assertEquals(LV_UTILS.empty(intTest), true);
	}

	@isTest static void testEmptyMethodIntegerNotEmpty() {
		Integer intTest = 1;

		system.assertEquals(LV_UTILS.empty(intTest), false);
	}
	
	@isTest static void testEmptyMethodDecimalEmpty() {
		Decimal decTest = null;

		system.assertEquals(LV_UTILS.empty(decTest), true);
	}

	@isTest static void testEmptyMethodDecimalNotEmpty() {
		Decimal decTest = 1.5;

		system.assertEquals(LV_UTILS.empty(decTest), false);
	}
}