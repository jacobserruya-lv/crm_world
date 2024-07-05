/*
BW - 29/12/2015
*/

@isTest
private class SO_WS_Test {

    static testMethod void myUnitTest() {
        User usr = IC_TestFactory.createUser('dreamuserLV@lvtest.com');
	  	usr.profileId = IC_UTILS.getSAProfile();
	  	usr.isactive = true;
	  	insert usr;

		Boolean b = SO_WS_Utils.runForTest();
		String ep = SO_WS_Utils.getEndPoint('ClientAdvisorEnquiry');
		Integer to = SO_WS_Utils.getWSTimeOut();
	  	
	  	SO_Settings__c setting = new SO_Settings__c(Name='WSCallNoCall', Value__c='nocall');
	  	insert setting;
	  	
	  	SO_WS_RMS_DoClientAdvisorEnquiry.callToTest();
	  	SO_WS_RMS_ClientAdvisorEnquiry.mainService ms = new SO_WS_RMS_ClientAdvisorEnquiry.mainService();
	  	SO_WS_RMS_ClientAdvisorEnquiry.mainServiceResponse msr = new SO_WS_RMS_ClientAdvisorEnquiry.mainServiceResponse();
	  	SO_WS_RMS_ClientAdvisorEnquiry.clientAdvisorEnquiryResponse caer = new SO_WS_RMS_ClientAdvisorEnquiry.clientAdvisorEnquiryResponse();
	  	SO_WS_RMS_ClientAdvisorEnquiry.clientAdvisorEnquiryResponse2 caer2 = new SO_WS_RMS_ClientAdvisorEnquiry.clientAdvisorEnquiryResponse2();
	  	SO_WS_RMS_ClientAdvisorEnquiry.docTypeRef_LvmHeaderResponse lvm = new SO_WS_RMS_ClientAdvisorEnquiry.docTypeRef_LvmHeaderResponse();
	  	SO_WS_RMS_ClientAdvisorEnquiry.DataResponse caer2dr = new SO_WS_RMS_ClientAdvisorEnquiry.DataResponse();
	  	SO_WS_RMS_ClientAdvisorEnquiry.clientAdvisorDetails cad = new SO_WS_RMS_ClientAdvisorEnquiry.clientAdvisorDetails();
		System.assertNotEquals(null, cad);

	  	SO_WS_RMS_DoClientCreationUpdate.callToTest(false);
	  	SO_WS_RMS_ClientCreationUpdate_v2.mainService ms2 = new SO_WS_RMS_ClientCreationUpdate_v2.mainService();
	  	SO_WS_RMS_ClientCreationUpdate_v2.mainServiceResponse msr2 = new SO_WS_RMS_ClientCreationUpdate_v2.mainServiceResponse();
		SO_WS_RMS_ClientCreationUpdate_v2.docTypeRef_updateToBlank utb = new SO_WS_RMS_ClientCreationUpdate_v2.docTypeRef_updateToBlank();
		SO_WS_RMS_ClientCreationUpdate_v2.docTypeRef_communicationPreference cp = new SO_WS_RMS_ClientCreationUpdate_v2.docTypeRef_communicationPreference();
		SO_WS_RMS_ClientCreationUpdate_v2.docTypeRef_anniversary da = new SO_WS_RMS_ClientCreationUpdate_v2.docTypeRef_anniversary();
		SO_WS_RMS_ClientCreationUpdate_v2.docTypeRef_comments dc = new SO_WS_RMS_ClientCreationUpdate_v2.docTypeRef_comments();
		SO_WS_RMS_ClientCreationUpdate_v2.clientCreationUpdateResponse ccur = new SO_WS_RMS_ClientCreationUpdate_v2.clientCreationUpdateResponse();
		SO_WS_RMS_ClientCreationUpdate_v2.ClientCreationUpdateResponse2 ccur2 = new SO_WS_RMS_ClientCreationUpdate_v2.ClientCreationUpdateResponse2();
		SO_WS_RMS_ClientCreationUpdate_v2.docTypeRef_LvmHeaderResponse lvm2 = new SO_WS_RMS_ClientCreationUpdate_v2.docTypeRef_LvmHeaderResponse();
		SO_WS_RMS_ClientCreationUpdate_v2.docTypeRef_ClientCreationUpdateDataResponse ccudr = new SO_WS_RMS_ClientCreationUpdate_v2.docTypeRef_ClientCreationUpdateDataResponse();
		System.assertNotEquals(null, ccudr);

	

		
		// SO_WS_RMS_DoClientSearch.callToTest(); // MIY-2154


		// SO_UTIL.SearchClientData dataIn = new SO_UTIL.SearchClientData();
		// dataIn.StoreCode = 'A06';
        // dataIn.givenName = 'virginie';
        // dataIn.lastName = 'legrand';
        // SO_WS_RMS_DoClientSearch ws = new SO_WS_RMS_DoClientSearch();
		// SO_WS_RMS_DoClientSearch.Result result = ws.doClientSearch(dataIn);
		// System.assertNotEquals(null, result);


		

		SO_WS_RMS_DoSalesServices.callToTest();	
		SO_WS_RMS_DoSalesServices.DataInput d = new SO_WS_RMS_DoSalesServices.DataInput();
		SO_WS_RMS_SaleServices.error errr = new SO_WS_RMS_SaleServices.error();	
		SO_WS_RMS_SaleServices.errors errrs = new SO_WS_RMS_SaleServices.errors();
		SO_WS_RMS_SaleServices.mainService ms6222 = new SO_WS_RMS_SaleServices.mainService();
		SO_WS_RMS_SaleServices.DataResponse dtr = new SO_WS_RMS_SaleServices.DataResponse();
		SO_WS_RMS_SaleServices.salesCreationFromNYResponse msr622 = new SO_WS_RMS_SaleServices.salesCreationFromNYResponse();
		SO_WS_RMS_SaleServices.docTypeRef_addressOccurences	scao222 = new SO_WS_RMS_SaleServices.docTypeRef_addressOccurences();
		SO_WS_RMS_SaleServices.mainServiceResponse ms62223 = new SO_WS_RMS_SaleServices.mainServiceResponse();
		SO_WS_RMS_SaleServices.addressId2 scad2 = new SO_WS_RMS_SaleServices.addressId2();
		SO_WS_RMS_SaleServices.docTypeRef_salesCommentOccurences scco2 = new SO_WS_RMS_SaleServices.docTypeRef_salesCommentOccurences();
		SO_WS_RMS_SaleServices.salesCreationResponse sccr22 = new SO_WS_RMS_SaleServices.salesCreationResponse();
		SO_WS_RMS_SaleServices.SalesCreationResponse2 sccr21 = new SO_WS_RMS_SaleServices.SalesCreationResponse2();
		SO_WS_RMS_SaleServices.docTypeRef_LvmHeaderResponse sclhr2 = new SO_WS_RMS_SaleServices.docTypeRef_LvmHeaderResponse();
		SO_WS_RMS_SaleServices.docTypeRef_SalesCreationDataResponse scscdr2 = new SO_WS_RMS_SaleServices.docTypeRef_SalesCreationDataResponse();
	  System.assertNotEquals(null, scscdr2);

	  	
	  	SO_WS_RMS_DoProductSearch.callToTest();
	  	SO_WS_RMS_ProductSearch.mainService ms6 = new SO_WS_RMS_ProductSearch.mainService();	  	
	  	SO_WS_RMS_ProductSearch.mainServiceResponse msr6 = new SO_WS_RMS_ProductSearch.mainServiceResponse();	  	
	  	SO_WS_RMS_ProductSearch.itemSearchResponse psisr = new SO_WS_RMS_ProductSearch.itemSearchResponse();	  	
	  	SO_WS_RMS_ProductSearch.itemSearchResponse2 psisr2 = new SO_WS_RMS_ProductSearch.itemSearchResponse2();	  	
	  	SO_WS_RMS_ProductSearch.DataResponse psdr = new SO_WS_RMS_ProductSearch.DataResponse();	  	
	  	SO_WS_RMS_ProductSearch.itemInformation psii = new SO_WS_RMS_ProductSearch.itemInformation();	  	
	  	SO_WS_RMS_ProductSearch.docTypeRef_LvmHeaderResponse pclhr = new SO_WS_RMS_ProductSearch.docTypeRef_LvmHeaderResponse();	  	
		System.assertNotEquals(null, pclhr);

	  	SO_WS_RMS_DoStoreGetId.callToTest();
	  	SO_WS_RMS_StoreGetId.mainService ms7 = new SO_WS_RMS_StoreGetId.mainService();	  	
	  	SO_WS_RMS_StoreGetId.mainServiceResponse msr7 = new SO_WS_RMS_StoreGetId.mainServiceResponse();
	  	SO_WS_RMS_StoreGetId.storeGetIDResponse sgtsgir = new SO_WS_RMS_StoreGetId.storeGetIDResponse();	  	
	  	SO_WS_RMS_StoreGetId.storeGetIDResponse2 sgtsgir2 = new SO_WS_RMS_StoreGetId.storeGetIDResponse2();	  	
	  	SO_WS_RMS_StoreGetId.DataResponse sgtsgidr = new SO_WS_RMS_StoreGetId.DataResponse();	  	
	  	SO_WS_RMS_StoreGetId.storeInformation sgtsgisi = new SO_WS_RMS_StoreGetId.storeInformation();	  	
	  	SO_WS_RMS_StoreGetId.docTypeRef_LvmHeaderResponse sgtsgihr = new SO_WS_RMS_StoreGetId.docTypeRef_LvmHeaderResponse();
		System.assertNotEquals(null, sgtsgihr);
        
        SO_WS_RMS_DoSalesServices.callToTest();
    }
}