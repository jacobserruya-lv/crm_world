@isTest
private class SO_UTIL_TEST 
{

    /**
    * [Set database]
    * @scenario         [insert objects to the system]
    * @result           [database to work with]
    * @createdBy      
    * @lastModifiedBy    Ester Mendelson, 14-01-2015
    */

    @testSetup static void setUp() {
        SO_TestObjectCreator dataModel = new SO_TestObjectCreator();
        dataModel.initialization_one(true,true);
        Account acc = IC_TestFactory.createAccount();
        insert acc;
    }

    @isTest static void apexMessage() {
        Account acc = [SELECT id FROM Account WHERE FirstName ='Louis' LIMIT 1];
        RecordType rt = SO_UTIL.retRecordType('Business Account');
        Id rtId = SO_UTIL.retRecordTypeIdByName('Account','Business Account');
        System.assertEquals(rtId,rt.id);
        SO_UTIL.generateRandomString(5);

        //system.assertEquals(SO_UTIL.getSObjectFields('Account','',null).size(),304);

        List<String> str = new List<String>{'test'};
        SO_UTIL.ifContains(str,'test');
        SO_UTIL.sendApexErrorMessage('Error Message');
        SO_UTIL.sendApexInfoMessage('Error Message');   
        Id rtId2 = SO_UTIL.retRecordTypeIdByName('Account','error');
    }
    @isTest static void testGetObjectType() {

        Id id;
        Boolean yes =true;
        Datetime  now =Datetime.now();
        Time nowTime;
        String lala ='fff';
        Integer num =4;
        Long lon =2221;
        Decimal dec =22.22;
        Double doub=22;

        System.assertEquals('', SO_UTIL.getObjectType(id));
        System.assertEquals('Boolean', SO_UTIL.getObjectType(yes));
        System.assertEquals('Datetime', SO_UTIL.getObjectType(now));
        System.assertEquals('', SO_UTIL.getObjectType(nowTime));
        System.assertEquals('String', SO_UTIL.getObjectType(lala));
        System.assertEquals('Integer', SO_UTIL.getObjectType(num));
        System.assertEquals('Long', SO_UTIL.getObjectType(lon));
        System.assertEquals('Decimal', SO_UTIL.getObjectType(dec));
        System.assertEquals('Decimal', SO_UTIL.getObjectType(doub));
    }
    @isTest static void testOpp() {

        List<Opportunity> opp =[SELECT ID,IsDeleted, AccountId,RecordTypeId, IsPrivate,
                                        Name, StageName, Probability, CloseDate, IsClosed, IsWon, ForecastCategory,
                                        ForecastCategoryName, HasOpportunityLineItem, OwnerId, CreatedDate,
                                        CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, FiscalQuarter,
                                        FiscalYear, Fiscal, LastViewedDate, LastReferencedDate, SPO_DisplayOrder__c,
                                        SPO_BriefCode__c, SPO_CACode__c, SPO_MarketingApproval__c, SPO_BaseSku__c, SPO_SizeUnit__c, SPO_Lock__c,
                                        SPO_TotalAmountCurrency__c, SPO_BaseSKURefmodelSKU__c, SPO_Free__c, SPO_Store__c,
                                        SPO_DueAmount__c, SPO_ProcessWithQuotation__c, SPO_SkuQuantity__c, SPO_TotalAmount__c,
                                        SPO_NoPersonNeeded__c, SPO_StoreCode__c, SPO_EstimatedLeadTime__c, SPO_EstimatedDistributionTime__c,
                                        SPO_OpportunityCloning__c FROM Opportunity WHERE name='Test Class Opp' LIMIT 1];

        List<ProductReferential__c> proList = [SELECT ID,SKUCode__c FROM ProductReferential__c WHERE name ='PR-001' LIMIT 1];
        SO_UTIL.retProductReferential(proList[0].id);
        List<String> checkList ;
        SO_UTIL.isEmpty(checkList);
        checkList = new List<String>();
        SO_UTIL.isNotEmpty(checkList);
        SO_UTIL.getPicklistValues('Opportunity','SPO_SubDepartment__c');
        SO_UTIL.addApostrophe('Test');
        SO_UTIL.addApostrophe('');
        SO_UTIL.SearchProductData spd = new  SO_UTIL.SearchProductData();
        System.assertEquals(SO_UTIL.dateStringIsValid('21/4/2015'), true);
        SO_UTIL.transformDateStringToDateTimeFormat('21/4/2015');

        //System.assertEquals(SO_UTIL.convertDate('11/28/14 06:00 AM'), Date.newInstance(2014,11,28));
        SO_UTIL.convertDate('11/28/14 06:00 AM');
        //System.assertEquals(SO_UTIL.convertDate('11/28/14') ,Date.newInstance(2014,11,28));
        SO_UTIL.convertDate('11/28/14');
        System.assertEquals(SO_UTIL.convertDate(''),null);
        System.assertEquals(SO_UTIL.convertDateTime(''),null);
        System.assertEquals(SO_UTIL.convertDate('dv'),null);
        
        DateTime d= SO_UTIL.convertDateTime('02/02/01');
        DateTime d2= SO_UTIL.convertDateTime('02/02/01');
        SO_UTIL.selectAllQuery('Account','','id',null);
        SO_UTIL.retOpportunity(opp[0].id);
        SO_UTIL.addErrorMessage('Test Error');
        SO_UTIL.exceptionDump('Test Error');
        SO_UTIL.transformDateStringToDateFormat('11/28/14');
        
        Schema.DescribeFieldResult dfr = Account.Description.getDescribe();
        SO_UTIL.getOptionsFormPicklist(dfr);
        
        SO_UTIL.isAsnieresUser();


        List<Account> accList = [SELECT id FROM Account WHERE firstName ='Louis' LIMIT 1];
    }
    @isTest static void testExeptions() {
        try{
             insert new Lead();
        }
        catch(DMLException ex){
            String exDump = SO_UTIL.exceptionDump(ex);
            System.assertNotEquals(null, exDump);
            SO_UTIL.addErrorMessage(ex);
            SO_UTIL.addDMLMessage(ex);
            SO_UTIL.sendApexErrorMessage('test Error',ex);
            SO_UTIL.log('title', ex);
        }
    }
    @isTest static void testClasses() {
        SO_UTIL.PickListWrapper plw = new SO_UTIL.PickListWrapper('Account','Id');
        SO_UTIL.PickListWrapper plwTarget = new SO_UTIL.PickListWrapper('Account','Id','',new Account());
        String a ='test';
        plw.selectedValue = a;

        SO_UTIL.SearchClientData scd = new  SO_UTIL.SearchClientData();
        String searchString = scd.lastName ;
        searchString = scd.givenName;
        searchString = scd.firstName;
        searchString = scd.email;
        searchString = scd.phoneNumber;
        searchString = scd.passportNumber;
        searchString = scd.country;
        searchString = scd.zipCode;
        searchString = scd.dreamId;
        searchString = scd.storeCode;

        SO_UTIL.SearchProductData spd = new SO_UTIL.SearchProductData();
        searchString = spd.orderType;
        searchString = spd.nameOrSKU;
        searchString = spd.productCategory;
    }

    @isTest static void testGlobalSearchData() {
        SO_UTIL.GlobalSearchData gs = new SO_UTIL.GlobalSearchData();
        String globalSearchString = gs.accountName;
        globalSearchString = gs.statusDateTo;
        globalSearchString = gs.createdDateTo;
        globalSearchString = gs.opportunityExo;
        globalSearchString = gs.statusDateFrom;
        globalSearchString = gs.opportunityName;
        globalSearchString = gs.createdDateFrom;
        globalSearchString = gs.accountGivenName;
        globalSearchString = gs.opportunityCACode;
        globalSearchString = gs.opportunityOrderType;
        globalSearchString = gs.opportunityBriefCode;
        globalSearchString = gs.opportunityZoneApproval;
        globalSearchString = gs.opportunityProductCategory;
        globalSearchString = gs.opportunityCentralApproval;
        globalSearchString = gs.opportunityMarketingApproval;
        globalSearchString = gs.opportunitySpecialOrderSKUCode;
        globalSearchString = gs.asnieresSearchStoreCode;
        List<String> fs = gs.filterStatus;
    }
}