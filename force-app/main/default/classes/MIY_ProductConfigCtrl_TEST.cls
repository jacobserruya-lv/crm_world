@isTest
public with sharing class MIY_ProductConfigCtrl_TEST {

	@isTest
	static void test_getFluidDetails() {
		Test.setMock(HttpCalloutMock.class, new MockHttpResponse('successJsonFluidData', 'json'));
		List<ProductConfigurationDetail__c> configDetails = MIY_ProductConfigCtrl.getFluidDetails('45497832');
		System.assertEquals(5, configDetails.size());
	}
	@isTest
	static void test_getFluidRecipeUrl() {
		System.assertEquals(ProductSettings__c.getInstance().Fluid_Recipe_URL_China__c, MIY_ProductConfigCtrl.getFluidRecipeUrl(true));
		System.assertEquals(ProductSettings__c.getInstance().FluidPictureUrl__c, MIY_ProductConfigCtrl.getFluidRecipeUrl(false));
	}
	@isTest
	static void test_getFluidProductsUrl() {
		System.assertEquals(ProductSettings__c.getInstance().Fluid_Products_URL_China__c, MIY_ProductConfigCtrl.getFluidProductsUrl(true));
		System.assertEquals(ProductSettings__c.getInstance().Fluid_Products_URL__c, MIY_ProductConfigCtrl.getFluidProductsUrl(false));
	}
}