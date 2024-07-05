/**
* This is a test class for VO_Specific_Statistics_CTRL class
* @createdBy           Menash
* @lastModifiedBy      Nadav Lichtenshtein, 10-2-2016
*/

@isTest (seeAllData=false)
private class VO_Specific_Statistics_TEST {
    
    /**
* [Set database]
* @scenario         [insert objects to the system]
* @result           [database to work with]
* @createdBy        Menash
* @lastModifiedBy   Menash
*/
    @testSetup
    static void initDate()
    {
        Test.loadData(VO_Config__c.sobjectType, 'VO_Config_TestCLS');
        
        List<VO_Survey__c> surveyList = VO_data_Object_Creator_TEST.createSurvayList();
        List<Store__c> storeList = VO_data_Object_Creator_TEST.createStoreByNum(3);
        Store__c storee1 = new Store__c(Status__c = 'Open', MGMT_ZONE_SUB_LEVEL3__c = '70');
        storeList.add(storee1);
        insert storeList;
        
        
        
        List<VO_Survey__c> surveyListInsert = new List<VO_Survey__c> ();
        for(Integer i = 0; i < surveyList.size(); i++)
        {
            surveyList[i].Store__c = storeList[math.mod(i,3)].id;
            surveyListInsert.add(surveyList[i]);
            
            if (i== 5)  i= surveyList.size();
            
            
        }        
        //insert surveyList;
        insert surveyListInsert;
        
        
        Profile p = [SELECT Id FROM Profile WHERE Name='ICON_SA'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com.menashTestTt123', TECH_User_Stores__c='NA2', MGMT_ZONE_SUB_LEVEL3__c = '70');
        insert u;
        
        User u45 = new User(Alias = 'stanzdt', Email='standazrduser@testorg.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com.menashTesttttTt456', TECH_User_Stores__c='NA2');
        insert u45;
        
        
        system.runAs(u){
            VO_Specific_Statistics_CTRL ctrl1 = new VO_Specific_Statistics_CTRL();
            
            String VOICE_AFTER_SALES1 = ctrl1.VOICE_AFTER_SALES;
            
            String TECH_User_Stores1 = ctrl1.TECH_User_Stores;
            
            String CCCSCSales1 = ctrl1.CCCSCSales;
            
            String CCWEBSales1 = ctrl1.CCWEBSales;
            
            String EOSales1 = ctrl1.EOSales;
            
            
            String storesSelectedForExcel1 = ctrl1.storesSelectedForExcel;
            
            
            List<String> storesSelected1 = ctrl1.storesSelected;
            storesSelected1.add(u.TECH_User_Stores__c);
            
            List<String> surveyIdList = new List<String>{surveyList[0].Id};
                
                ctrl1.clearForm();    
            
            
            
            
        }
        
        system.runAs(u45){
            VO_Specific_Statistics_CTRL ctrl2 = new VO_Specific_Statistics_CTRL();
            
            String VOICE_AFTER_SALES1 = ctrl2.VOICE_AFTER_SALES;
            
            String TECH_User_Stores1 = ctrl2.TECH_User_Stores;
            
            String CCCSCSales1 = ctrl2.CCCSCSales;
            
            String CCWEBSales1 = ctrl2.CCWEBSales;
            
            String EOSales1 = ctrl2.EOSales;
            
            String storesSelectedForExcel1 = ctrl2.storesSelectedForExcel;
            
            
            List<String> storesSelected1 = ctrl2.storesSelected;
            storesSelected1.add(u45.TECH_User_Stores__c);
            
            List<String> surveyIdList = new List<String>{surveyList[0].Id}; 
                
                }
        
        
    }
    
    /**
* [myUnitTest test the flow]
* @scenario         [test the flow]
* @result           []
* @createdBy        Menash
* @lastModifiedBy   Menash
*/
    
    
    
    @isTest
    static void myUnitTest()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='ICON_SA'];
        User searchCurrUser = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                                       EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                       LocaleSidKey='en_US', ProfileId = p.Id, 
                                       TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@test1111111org.com.menashTestTt789', TECH_User_Stores__c='NA2');
        insert searchCurrUser;
        
        
        
        PageReference ref = Page.VO_Specific_Statistics;
        List<String> surveyTypeValueList = VO_data_Object_Creator_TEST.getPickListValByAPIName('VO_Survey__c','SurveyType__c');
        ref.getParameters().put('surveyType',surveyTypeValueList[0]);
        
        List<VO_Survey__c> surveyList = [SELECT id FROM VO_Survey__c ];
        ref.getParameters().put('id',surveyList[0].id);
        Test.setCurrentPage(ref);
        
        VO_Specific_Statistics_CTRL webPage = new VO_Specific_Statistics_CTRL();
        //PageReference methods
        webPage.clearForm();
        webPage.mainSearch();
        
        
        webPage.initModal();//need to get param
        webPage.clickOnEye();
        
        String commentFromForm = ApexPages.currentPage().getParameters().put('Comment','false');
        String chanelFromForm  = ApexPages.currentPage().getParameters().put('Chanel','');
        String rootFromForm    = ApexPages.currentPage().getParameters().put('Root','');
        String caFromForm      = ApexPages.currentPage().getParameters().put('CA','');
        
        webPage.clickSaveModal();//need params
        webPage.initModal();//need to get param
        webPage.clickCloseCaseModal();
        webPage.clickOnEye();
        
        
        
    }
    
    @isTest
    static void myUnitTest1()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='ICON_SA'];
        User searchCurrUser = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                                       EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                       LocaleSidKey='en_US', ProfileId = p.Id, 
                                       TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@test1111111org.com.menashTestTt987', TECH_User_Stores__c='NA2');
        insert searchCurrUser;
        
        
        
        PageReference ref = Page.VO_Specific_Statistics;
        List<String> surveyTypeValueList = VO_data_Object_Creator_TEST.getPickListValByAPIName('VO_Survey__c','SurveyType__c');
        ref.getParameters().put('surveyType',surveyTypeValueList[0]);
        
        List<VO_Survey__c> surveyList = [SELECT id FROM VO_Survey__c ];
        ref.getParameters().put('id',surveyList[0].id);
        Test.setCurrentPage(ref);
        
        VO_Specific_Statistics_CTRL webPage = new VO_Specific_Statistics_CTRL();
        //PageReference methods
        webPage.clearForm();
        webPage.mainSearch();
        
        
        webPage.initModal();//need to get param
        webPage.clickOnEye();
        
        String commentFromForm = ApexPages.currentPage().getParameters().put('Comment','true');
        String chanelFromForm  = ApexPages.currentPage().getParameters().put('Chanel','Chanel');
        String rootFromForm    = ApexPages.currentPage().getParameters().put('Root','');
        String caFromForm      = ApexPages.currentPage().getParameters().put('CA','false');
        String rootMultyFromForm = ApexPages.currentPage().getParameters().put('RootMulty','');
        
        webPage.clickSaveModal();//need params
        webPage.initModal();//need to get param
        webPage.clickCloseCaseModal();
        webPage.clickOnEye();
        
    }
    
    @isTest
    static void myUnitTest3()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='ICON_SA'];
        User searchCurrUser = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                                       EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                       LocaleSidKey='en_US', ProfileId = p.Id, 
                                       TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@test1111111org.com.menashTestTt876', TECH_User_Stores__c='NA2');
        insert searchCurrUser;
        
        
        
        PageReference ref = Page.VO_Specific_Statistics;
        List<String> surveyTypeValueList = VO_data_Object_Creator_TEST.getPickListValByAPIName('VO_Survey__c','SurveyType__c');
        ref.getParameters().put('surveyType',surveyTypeValueList[0]);
        List<Integer> answersList = new List<Integer>{1,2,3,11};
            
            List<VO_Survey__c> surveyList = [SELECT id, Type__c, Status__c FROM VO_Survey__c];
        
        VO_Survey__c surv1 = new VO_Survey__c(Type__c = 'Recovery Act', STOREORDER__c = 'B00', Status__c = 'Open', AnswerDate__c = system.today());
        VO_Survey__c surv2 = new VO_Survey__c(Type__c = 'Delighted Client', STOREORDER__c = 'B00', Status__c = 'Open', AnswerDate__c = system.today());
        VO_Survey__c surv3 = new VO_Survey__c(Type__c = 'Promoter', STOREORDER__c = 'B00', Status__c = 'Open', AnswerDate__c = system.today());
        VO_Survey__c surv4 = new VO_Survey__c(Type__c = 'Recovery Act', STOREORDER__c = 'B00', Status__c = 'No action', AnswerDate__c = system.today());
        VO_Survey__c surv5 = new VO_Survey__c(Type__c = 'Delighted Client', STOREORDER__c = 'B00', Status__c = 'Closed', AnswerDate__c = system.today());
        VO_Survey__c surv6 = new VO_Survey__c(Type__c = 'Promoter', STOREORDER__c = 'B00', Status__c = 'New', AnswerDate__c = system.today());
        VO_Survey__c surv7 = new VO_Survey__c(Type__c = 'Recovery Act', STOREORDER__c = 'B00', Status__c = 'New', AnswerDate__c = system.today());
        VO_Survey__c surv8 = new VO_Survey__c(Type__c = 'Delighted Client', STOREORDER__c = 'B00', Status__c = 'New', AnswerDate__c = system.today());
        VO_Survey__c surv9 = new VO_Survey__c(Type__c = 'Recovery Act', STOREORDER__c = 'B00', Status__c = 'Pending', AnswerDate__c = Date.today().addDays(-8));
        VO_Survey__c surv10 = new VO_Survey__c(Type__c = 'Delighted Client', STOREORDER__c = 'B00', Status__c = 'Pending', AnswerDate__c = Date.today().addDays(-8));
        VO_Survey__c surv11 = new VO_Survey__c(Type__c = 'Promoter', STOREORDER__c = 'B00', Status__c = 'Pending', AnswerDate__c = Date.today().addDays(-8));
        
        surveyList.add(surv1);
        surveyList.add(surv2);
        surveyList.add(surv3);
        surveyList.add(surv4);
        surveyList.add(surv5);
        surveyList.add(surv6);
        surveyList.add(surv7);
        surveyList.add(surv8);
        surveyList.add(surv9);
        surveyList.add(surv10);
        surveyList.add(surv11);
        
        
        
        
        ref.getParameters().put('id',surveyList[0].id);
        Test.setCurrentPage(ref);
        
        VO_Specific_Statistics_CTRL webPage = new VO_Specific_Statistics_CTRL();
        //PageReference methods
        webPage.clearForm();
        webPage.mainSearch();
        VO_Specific_Statistics_CTRL.addQuestionToQuery(answersList);
        
        VO_Specific_Statistics_CTRL.updateHeaderWrapperListQ(answersList, surveyList[0].id);
        
        VO_Specific_Statistics_CTRL.computeKPIResults(surveyList);
        
        
        webPage.initModal();//need to get param
        webPage.clickOnEye();
        
        String commentFromForm = ApexPages.currentPage().getParameters().put('Comment','true');
        String chanelFromForm  = ApexPages.currentPage().getParameters().put('Chanel','Chanel');
        String rootFromForm    = ApexPages.currentPage().getParameters().put('Root','');
        String caFromForm      = ApexPages.currentPage().getParameters().put('CA','');
        
        webPage.clickSaveModal();//need params
        webPage.initModal();//need to get param
        webPage.clickCloseCaseModal();
        webPage.clickOnEye();
        
    }
    
    /**
* [initCurrSurvayTypeWithNoSurveyType test initCurrSurvayType function]
* @scenario         [call initCurrSurvayType with standard user]
* @result           []
* @createdBy        Nadav Lichtenshtein, 10-2-2016
* @lastModifiedBy   Nadav Lichtenshtein, 10-2-2016
*/
    @isTest
    static void initCurrSurvayTypeWithNoSurveyType()
    {
        PageReference ref = Page.VO_Specific_Statistics;
        
        List<VO_Survey__c> surveyList = [SELECT id FROM VO_Survey__c ];
        ref.getParameters().put('id',surveyList[0].id);
        Test.setCurrentPage(ref);
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='testingSO_Template', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='testingSO_Template@testorg.com');
        
        System.runAs(u) {
            // The following code runs as user 'u' 
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId()); 
            
            VO_Specific_Statistics_CTRL webPage = new VO_Specific_Statistics_CTRL();
            
            
            
        }
    }
    
    @isTest
    static void initCurrSurvayTypeWithNoSurveyType1()
    {
        PageReference ref = Page.VO_Specific_Statistics;
        
        List<VO_Survey__c> surveyList = [SELECT id FROM VO_Survey__c ];
        ref.getParameters().put('id',surveyList[0].id);
        Test.setCurrentPage(ref);
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='testingSO_Template', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='testingSO_Template@testorg.com', TECH_User_Stores__c='NA2');
        
        System.runAs(u) {
            // The following code runs as user 'u' 
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId()); 
            
            VO_Specific_Statistics_CTRL webPage = new VO_Specific_Statistics_CTRL();
            
            
            
        }
    }
    
    /**
* [getSurveysByIdList test getSurveysByIdList function]
* @scenario         [call getSurveysByIdList with Ids survey list]
* @param            [List<String>] [List<VO_Survey__c Id>]  
* @result           []
* @createdBy        Nadav Lichtenshtein, 10-2-2016
* @lastModifiedBy   Nadav Lichtenshtein, 10-2-2016
*/
    @isTest
    static void getSurveysByIdList()
    {
        PageReference ref = Page.VO_Specific_Statistics;
        List<String> surveyTypeValueList = VO_data_Object_Creator_TEST.getPickListValByAPIName('VO_Survey__c','SurveyType__c');
        ref.getParameters().put('surveyType',surveyTypeValueList[0]);
        
        List<VO_Survey__c> surveyList = [SELECT id FROM VO_Survey__c ];
        ref.getParameters().put('id',surveyList[0].id);
        Test.setCurrentPage(ref);
        
        List<String> surveyIdList = new List<String>{surveyList[0].Id};
            
            VO_Specific_Statistics_CTRL.getSurveysByIdList(surveyIdList); 
    }
    
    /**
* [clickOnEye test clickOnEye function]
* @scenario         [call clickOnEye with eyeId parameter in Url]
* @result           []
* @createdBy        Nadav Lichtenshtein, 10-2-2016
* @lastModifiedBy   Nadav Lichtenshtein, 10-2-2016
*/
    @isTest
    static void clickOnEye()
    {
        PageReference ref = Page.VO_Specific_Statistics;
        List<String> surveyTypeValueList = VO_data_Object_Creator_TEST.getPickListValByAPIName('VO_Survey__c','SurveyType__c');
        ref.getParameters().put('surveyType',surveyTypeValueList[0]);
        
        List<VO_Survey__c> surveyList = [SELECT id FROM VO_Survey__c ];
        ref.getParameters().put('id',surveyList[0].id);
        ref.getParameters().put('eyeId',surveyList[0].id);
        Test.setCurrentPage(ref);
        
        List<String> surveyIdList = new List<String>{surveyList[0].Id};
            
            VO_Specific_Statistics_CTRL webPage = new VO_Specific_Statistics_CTRL(); 
        
        webPage.clickOnEye();
        
        
    }
    
    /**
* [updateHeaderListQ test updateHeaderListQ function]
* @scenario         [call updateHeaderListQ with surveyList and answersList
*                       survey list must contain all questions fields
*                       answerList contains muber smaller and bigger then 10 for cases]
* @param            [surveyList] [List<VO_Survey__c>]
* @param            [answersList] [List<Integer>]
* @result           []
* @createdBy        Nadav Lichtenshtein, 10-2-2016
* @lastModifiedBy   Nadav Lichtenshtein, 10-2-2016
*/
    @isTest
    static void updateHeaderListQ()
    {
        PageReference ref = Page.VO_Specific_Statistics;
        List<String> surveyTypeValueList = VO_data_Object_Creator_TEST.getPickListValByAPIName('VO_Survey__c','SurveyType__c');
        ref.getParameters().put('surveyType',surveyTypeValueList[0]);
        
        List<VO_Survey__c> surveyList = [SELECT Id, Q01Shortname__c, Q02Shortname__c, Q03Shortname__c, Q04Shortname__c, Q05Shortname__c,
                                         Q06Shortname__c, Q07Shortname__c, Q08Shortname__c, Q09Shortname__c, Q10Shortname__c, Q11Shortname__c,
                                         Q12Shortname__c, Q13Shortname__c, Q14Shortname__c, Q15Shortname__c, Q16Shortname__c, Q17Shortname__c,
                                         Q18Shortname__c, Q19Shortname__c, Q20Shortname__c, Q21Shortname__c, Q22Shortname__c, Q23Shortname__c,
                                         Q24Shortname__c, Q25Shortname__c, Q26Shortname__c, Q27Shortname__c, Q28Shortname__c, Q29Shortname__c,
                                         Q30Shortname__c, Q31Shortname__c, Q32Shortname__c, Q33Shortname__c, Q34Shortname__c, Q35Shortname__c,
                                         Q36Shortname__c, Q37Shortname__c, Q38Shortname__c, Q39Shortname__c, Q40Shortname__c, Q41Shortname__c,
                                         Q42Shortname__c, Q43Shortname__c, Q44Shortname__c, Q45Shortname__c, Q46Shortname__c, Q47Shortname__c,
                                         Q48Shortname__c, Q49Shortname__c, Q50Shortname__c
                                         FROM VO_Survey__c ];
        ref.getParameters().put('id',surveyList[0].id);
        ref.getParameters().put('eyeId',surveyList[0].id);
        Test.setCurrentPage(ref);
        
        
        
        List<Integer> answersList = new List<Integer>{1,2,3,11};
            
            VO_Specific_Statistics_CTRL.updateHeaderListQ(surveyList, answersList);
        
        VO_Specific_Statistics_CTRL webpage = new VO_Specific_Statistics_CTRL();
        webPage.VOICE_AFTER_SALES = 'VOICE Store After Sales';
        
    }
    
    /**
* [mainSearchRemote test mainSearchRemote function]
* @scenario         [call mainSearchRemote
*                    fieldFilter and valueOf need to have 2 fields seperated by ; for if case]
* @param            [fromDate]          [String]
* @param            [toDate]            [String]
* @param            [currSurvayType]    [String]
* @param            [fieldFilter]       [String]
* @param            [valueOf]           [String]
* @result           []
* @createdBy        Nadav Lichtenshtein, 10-2-2016
* @lastModifiedBy   Nadav Lichtenshtein, 10-2-2016
*/
    @isTest
    static void mainSearchRemote()
    {
        PageReference ref = Page.VO_Specific_Statistics;
        List<String> surveyTypeValueList = VO_data_Object_Creator_TEST.getPickListValByAPIName('VO_Survey__c','SurveyType__c');
        ref.getParameters().put('surveyType',surveyTypeValueList[0]);
        
        
        List<VO_Survey__c> surveyList = [SELECT id FROM VO_Survey__c ];
        ref.getParameters().put('id',surveyList[0].id);
        Test.setCurrentPage(ref);
        
        String fromDate = '12-12-2016';
        String toDate = '15-12-2016';
        String currSurvayType = VO_Utils.VOICE_SALES ;
        String fieldFilter = 'Channel__c;Status__c';
        String valueOf = 'Channel__c;Status__c';
        
        VO_Specific_Statistics_CTRL.mainSearchRemote(fromDate, toDate, currSurvayType, fieldFilter, valueOf);
    }
    
    @isTest
    static void KPISearchRemote()
    {
        PageReference ref = Page.VO_Specific_Statistics;
        List<String> surveyTypeValueList = VO_data_Object_Creator_TEST.getPickListValByAPIName('VO_Survey__c','SurveyType__c');
        ref.getParameters().put('surveyType',surveyTypeValueList[0]);
        
        
        List<VO_Survey__c> surveyList = [SELECT id FROM VO_Survey__c ];
        ref.getParameters().put('id',surveyList[0].id);
        Test.setCurrentPage(ref);
        
        String fromDate = '12-12-2016';
        String toDate = '15-12-2016';
        String currSurvayType = VO_Utils.VOICE_SALES ;
        String fieldFilter = 'Channel__c;Status__c';
        String valueOf = 'Channel__c;Status__c';
        Id searchFromId = surveyList[0].id;
        
        VO_Specific_Statistics_CTRL.KPISearchRemote(fromDate, toDate, currSurvayType, fieldFilter, valueOf, searchFromId);
    }
    
    
    
    @isTest
    static void mainSearchRemoteVO_UtilsVOICE_CC_CSC_SALES()
    {
        PageReference ref = Page.VO_Specific_Statistics;
        List<String> surveyTypeValueList = VO_data_Object_Creator_TEST.getPickListValByAPIName('VO_Survey__c','SurveyType__c');
        ref.getParameters().put('surveyType',surveyTypeValueList[1]);
        
        List<VO_Survey__c> surveyList = [SELECT id FROM VO_Survey__c ];
        ref.getParameters().put('id',surveyList[0].id);
        Test.setCurrentPage(ref);
        
        String fromDate = '12-12-2016';
        String toDate = '15-12-2016';
        
        String fieldFilter = 'Channel__c;Status__c';
        String valueOf = 'Channel__c;Status__c';
        
        VO_Specific_Statistics_CTRL babi1 = new VO_Specific_Statistics_CTRL();
        
    }
    
    @isTest
    static void mainSearchRemoteVOICE_CC_WEB_SALES()
    {
        PageReference ref = Page.VO_Specific_Statistics;
        List<String> surveyTypeValueList = VO_data_Object_Creator_TEST.getPickListValByAPIName('VO_Survey__c','SurveyType__c');
        ref.getParameters().put('surveyType',surveyTypeValueList[2]);
        
        List<VO_Survey__c> surveyList = [SELECT id FROM VO_Survey__c ];
        ref.getParameters().put('id',surveyList[0].id);
        
        Test.setCurrentPage(ref);
        
        String fromDate = '12-12-2016';
        String toDate = '15-12-2016';
        
        String fieldFilter = 'Channel__c;Status__c';
        String valueOf = 'Channel__c;Status__c';
        
        VO_Specific_Statistics_CTRL babi2 = new VO_Specific_Statistics_CTRL();
        
    }
    
    @isTest
    static void mainSearchRemoteVOICE_WEB_SALES()
    {
        PageReference ref = Page.VO_Specific_Statistics;
        List<String> surveyTypeValueList = VO_data_Object_Creator_TEST.getPickListValByAPIName('VO_Survey__c','SurveyType__c');
        system.debug('BNG : SURVEY TYPE LIST : '+surveyTypeValueList[2]);
        ref.getParameters().put('surveyType',surveyTypeValueList[2]);
        
        List<VO_Survey__c> surveyList = [SELECT id FROM VO_Survey__c ];
        ref.getParameters().put('id',surveyList[0].id);
        Test.setCurrentPage(ref);
        
        String fromDate = '12-12-2016';
        String toDate = '16-12-2016';
        String currSurvayType = VO_Utils.VOICE_WEB_SALES;
        String fieldFilter = 'Channel__c;Status__c';
        String valueOf = 'Channel__c;Status__c';
        
        VO_Specific_Statistics_CTRL babi3 = new VO_Specific_Statistics_CTRL();
    }
    
    @isTest
    static void mainSearchRemoteVOICE_CSC_SALES()
    {
        PageReference ref = Page.VO_Specific_Statistics;
        List<String> surveyTypeValueList = VO_data_Object_Creator_TEST.getPickListValByAPIName('VO_Survey__c','SurveyType__c');
        ref.getParameters().put('surveyType',surveyTypeValueList[4]);
        
        List<VO_Survey__c> surveyList = [SELECT id FROM VO_Survey__c ];
        ref.getParameters().put('id',surveyList[0].id);
        Test.setCurrentPage(ref);
        
        String fromDate = '12-12-2016';
        String toDate = '15-12-2016';
        String currSurvayType = VO_Utils.VOICE_CSC_SALES;
        String fieldFilter = 'Channel__c;Status__c';
        String valueOf = 'Channel__c;Status__c';
        
        VO_Specific_Statistics_CTRL babi4 = new VO_Specific_Statistics_CTRL();
    }
    
    @isTest
    static void mainSearchRemoteVOICE_SALES()
    {
        PageReference ref = Page.VO_Specific_Statistics;
        List<String> surveyTypeValueList = VO_data_Object_Creator_TEST.getPickListValByAPIName('VO_Survey__c','SurveyType__c');
        ref.getParameters().put('surveyType',surveyTypeValueList[5]);
        
        List<VO_Survey__c> surveyList = [SELECT id FROM VO_Survey__c ];
        ref.getParameters().put('id',surveyList[0].id);
        Test.setCurrentPage(ref);
        
        String fromDate = '12-12-2016';
        String toDate = '15-12-2016';
        String currSurvayType = VO_Utils.VOICE_SALES ;
        String fieldFilter = 'Channel__c;Status__c';
        String valueOf = 'Channel__c;Status__c';
        
        VO_Specific_Statistics_CTRL babi5 = new VO_Specific_Statistics_CTRL();
    }
    
    /**
* [changeSurveyType test changeSurveyType function]
* @scenario         [call changeSurveyType with id in url parameters]
* @result           []
* @createdBy        Nadav Lichtenshtein, 10-2-2016
* @lastModifiedBy   Nadav Lichtenshtein, 10-2-2016
*/
    @isTest
    static void changeSurveyType()
    {
        PageReference ref = Page.VO_Specific_Statistics;
        List<String> surveyTypeValueList = VO_data_Object_Creator_TEST.getPickListValByAPIName('VO_Survey__c','SurveyType__c');
        ref.getParameters().put('surveyType',surveyTypeValueList[0]);
        
        List<VO_Survey__c> surveyList = [SELECT id FROM VO_Survey__c ];
        ref.getParameters().put('id',surveyList[0].id);
        Test.setCurrentPage(ref);
        
        VO_Specific_Statistics_CTRL webPage = new VO_Specific_Statistics_CTRL(); 
        
        webPage.changeSurveyType();
    }
    
    /**
* [changeSurveyStatusAfterexportToPDF test changeSurveyStatusAfterexportToPDF function]
* @scenario         [call changeSurveyStatusAfterexportToPDF with survey Id list]
* @param            [surveyIdList]          [List<String>]
* @result           []
* @createdBy        Nadav Lichtenshtein, 10-2-2016
* @lastModifiedBy   Nadav Lichtenshtein, 10-2-2016
*/
    @isTest
    static void changeSurveyStatusAfterexportToPDF()
    {
        PageReference ref = Page.VO_Specific_Statistics;
        List<String> surveyTypeValueList = VO_data_Object_Creator_TEST.getPickListValByAPIName('VO_Survey__c','SurveyType__c');
        ref.getParameters().put('surveyType',surveyTypeValueList[0]);
        
        
        
        List<VO_Survey__c> surveyList = [SELECT id FROM VO_Survey__c];
        ref.getParameters().put('id',surveyList[0].id);
        
        
        Test.setCurrentPage(ref);
        
        List<String> surveyIdList = new List<String>{surveyList[0].Id};
            
            VO_Specific_Statistics_CTRL.changeSurveyStatusAfterexportToPDF(surveyIdList); 
    }
    
    /**
* [AnswerHeader_Wrapper test AnswerHeader_Wrapper constructor inner class]
* @scenario         [call AnswerHeader_Wrapper inner class with title and shortname]
* @param            [title]     [String]
* @param            [shortname] [String]
* @result           []
* @createdBy        Nadav Lichtenshtein, 10-2-2016
* @lastModifiedBy   Nadav Lichtenshtein, 10-2-2016
*/
    @isTest
    static void AnswerHeader_Wrapper()
    {
        VO_Specific_Statistics_CTRL.AnswerHeader_Wrapper webPage = new VO_Specific_Statistics_CTRL.AnswerHeader_Wrapper('title','shortname'); 
        VO_Specific_Statistics_CTRL.AnswerHeader_Wrapper webPage2 = new VO_Specific_Statistics_CTRL.AnswerHeader_Wrapper('title','shortname', 'origanSFansNum'); 
    }
    
    static testmethod void getUserStoreType()
    {
        // creating a user
        Profile p = [SELECT Id FROM Profile WHERE Name='ICON_SA Manager'];
        User currUser = new User(Alias = 'storeu', Email='userStore@testgetuserstore.com', 
                                 EmailEncodingKey='UTF-8', LastName='Store', LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', ProfileId = p.Id, 
                                 TimeZoneSidKey='America/Los_Angeles', UserName='userStore@testgetuserstore.com',  
                                 MANAGEMENT_ZONE_LEVEL__c = '13', MGMT_ZONE_SUB_LEVEL1__c= '31', MGMT_ZONE_SUB_LEVEL2__c= '98', MGMT_ZONE_SUB_LEVEL3__c= '70', DefaultStore__c='A06', TECH_User_Stores__c='NA2');
        insert currUser;
        
        // creating a store
        Store__c st = new Store__c (Name = 'LV PARIS CHAMPS ELYSEES', RetailStoreId__c = 'A06', StoreType__c = 'Store');
        insert st;
        
        System.runAs(currUser)
        {
            Test.starttest();
            PageReference ref = Page.VO_Specific_Statistics;
            String userStoreType = VO_Specific_Statistics_CTRL.getUserStoreType();
            String TECH_User_Stores = currUser.TECH_User_Stores__c;
            Test.stoptest();
            System.assertEquals( 'Store', userStoreType);
        }
        
    }
    
    static testmethod void getUserStoreType1()
    {
        // creating a user
        Profile p = [SELECT Id FROM Profile WHERE Name='ICON_SA Manager'];
        User currUser = new User(Alias = 'storeu', Email='userStore@testgetuserstore.com', 
                                 EmailEncodingKey='UTF-8', LastName='Store', LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', ProfileId = p.Id, 
                                 TimeZoneSidKey='America/Los_Angeles', UserName='userStore@testgetuserstore.com',  
                                 MANAGEMENT_ZONE_LEVEL__c = '13', MGMT_ZONE_SUB_LEVEL1__c= '31', MGMT_ZONE_SUB_LEVEL2__c= '98', MGMT_ZONE_SUB_LEVEL3__c= '70', DefaultStore__c='A06', TECH_User_Stores__c='NA2');
        insert currUser;
        
        // creating a store
        Store__c st = new Store__c (Name = 'LV PARIS CHAMPS ELYSEES', RetailStoreId__c = 'A06', StoreType__c = 'Store');
        insert st;
        
        System.runAs(currUser)
        {
            Test.starttest();
            PageReference ref = Page.VO_Specific_Statistics;
            
            String TECH_User_Stores = currUser.TECH_User_Stores__c;
            Test.stoptest();
            
        }
        
    }
    
    
    static testmethod void testQueryForClickAndCollect()
    {
        // create 2 stores of type CSC and Store
        Store__c st1 = new Store__c (Name = 'LV PARIS CHAMPS ELYSEES TEST', RetailStoreId__c = 'A00', StoreType__c = 'Store');
        Store__c st2 = new Store__c (Name = 'CLIENT SERVICE France Test', RetailStoreId__c = 'B00', StoreType__c = 'CSC');
        insert new List<Store__c>{st1,st2};
            
            // Creating a store user
            Profile pManager = [SELECT Id FROM Profile WHERE Name='ICON_SA Manager'];
        User sUser = new User(Alias = 'storeu', Email='userStore@testgetuserstore.com', 
                              EmailEncodingKey='UTF-8', LastName='StoreUser', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = pManager.Id, 
                              TimeZoneSidKey='America/Los_Angeles', UserName='userStore@testgetuserstore.com',  
                              MANAGEMENT_ZONE_LEVEL__c = '13', MGMT_ZONE_SUB_LEVEL1__c= '31', MGMT_ZONE_SUB_LEVEL2__c= '98', MGMT_ZONE_SUB_LEVEL3__c= '70', DefaultStore__c='A00', TECH_User_Stores__c='NA2');
        //Creating a CSC user
        User cUser = new User(Alias = 'cscu', Email='usercsc@testgetuserstore.com', 
                              EmailEncodingKey='UTF-8', LastName='CscUser', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = pManager.Id, 
                              TimeZoneSidKey='America/Los_Angeles', UserName='usercsc@testgetuserstore.com',  
                              MANAGEMENT_ZONE_LEVEL__c = '13', MGMT_ZONE_SUB_LEVEL1__c= '31', MGMT_ZONE_SUB_LEVEL2__c= '98', MGMT_ZONE_SUB_LEVEL3__c= '70', DefaultStore__c='B00', TECH_User_Stores__c='NA2');
        // Creating a corporate user
        Profile pCorporate = [SELECT Id FROM Profile WHERE Name='ICON_Corporate'];
        User coUser = new User(Alias = 'corpu', Email='userCorp@testgetuserstore.com', 
                               EmailEncodingKey='UTF-8', LastName='CorpUser', LanguageLocaleKey='en_US', 
                               LocaleSidKey='en_US', ProfileId = pCorporate.Id, 
                               TimeZoneSidKey='America/Los_Angeles', UserName='userCorp@testgetuserstore.com', TECH_User_Stores__c='NA2');
        insert new List<User> {sUser, cUser, coUser};
            
            // creating a C&C CSC survey
            VO_Survey__c surv = new VO_Survey__c(SurveyType__c = 'VOICE CSC Click And Collect', Store__c = st2.id, STOREDELIVERY__c = 'A00', AnswerDate__c = system.today());
        VO_Survey__c surv2 = new VO_Survey__c(SurveyType__c = 'VOICE Endless Offer', Store__c = st2.id, STOREORDER__c = 'B00', AnswerDate__c = system.today());
        insert surv;
        
        String fromDate = String.valueof(system.now().adddays(-2).format('DD-MM-YYYY'));
        String toDate = String.valueof(system.now().format('DD-MM-YYYY'));
        String currSurvayType = VO_Utils.VOICE_CC_CSC_SALES ;
        String fieldFilter = 'StoreID__c;';
        String valueOf = 'A00';
        String fieldFilter2 = 'StoreID__c;CAName__c';
        String valueOf2 = 'A00;AAA';
        String valueOf3 = 'B00';
        
        
        System.runAs(sUser)
        {
            String res = VO_Specific_Statistics_CTRL.mainSearchRemote(fromDate, toDate, currSurvayType, fieldFilter, valueOf);
            String res2 = VO_Specific_Statistics_CTRL.mainSearchRemote(fromDate, toDate, currSurvayType, fieldFilter2, valueOf2);
            System.assert(res != null);
            System.assert(res2 != null);
        }
    }
    
    static testmethod void testQueryForClickAndCollect1()
    {
        // create 2 stores of type CSC and Store
        Store__c st1 = new Store__c (Name = 'LV PARIS CHAMPS ELYSEES TEST', RetailStoreId__c = 'A00', StoreType__c = 'Store');
        Store__c st2 = new Store__c (Name = 'CLIENT SERVICE France Test', RetailStoreId__c = 'B00', StoreType__c = 'CSC');
        insert new List<Store__c>{st1,st2};
            
            // Creating a store user
            Profile pManager = [SELECT Id FROM Profile WHERE Name='ICON_SA Manager'];
        User sUser = new User(Alias = 'storeu', Email='userStore@testgetuserstore.com', 
                              EmailEncodingKey='UTF-8', LastName='StoreUser', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = pManager.Id, 
                              TimeZoneSidKey='America/Los_Angeles', UserName='userStore@testgetuserstore.com124',  
                              MANAGEMENT_ZONE_LEVEL__c = '13', MGMT_ZONE_SUB_LEVEL1__c= '31', MGMT_ZONE_SUB_LEVEL2__c= '98', MGMT_ZONE_SUB_LEVEL3__c= '70', DefaultStore__c='A00', TECH_User_Stores__c='NA2');
        //Creating a CSC user
        User cUser = new User(Alias = 'cscu', Email='usercsc@testgetuserstore.com', 
                              EmailEncodingKey='UTF-8', LastName='CscUser', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = pManager.Id, 
                              TimeZoneSidKey='America/Los_Angeles', UserName='usercsc@testgetuserstore.com456',  
                              MANAGEMENT_ZONE_LEVEL__c = '13', MGMT_ZONE_SUB_LEVEL1__c= '31', MGMT_ZONE_SUB_LEVEL2__c= '98', MGMT_ZONE_SUB_LEVEL3__c= '70', DefaultStore__c='B00', TECH_User_Stores__c='NA2');
        // Creating a corporate user
        Profile pCorporate = [SELECT Id FROM Profile WHERE Name='ICON_Corporate'];
        User coUser = new User(Alias = 'corpu', Email='userCorp@testgetuserstore.com', 
                               EmailEncodingKey='UTF-8', LastName='CorpUser', LanguageLocaleKey='en_US', 
                               LocaleSidKey='en_US', ProfileId = pCorporate.Id, 
                               TimeZoneSidKey='America/Los_Angeles', UserName='userCorp@testgetuserstore.com', TECH_User_Stores__c='NA2');
        insert new List<User> {sUser, cUser, coUser};
            
            // creating a C&C CSC survey
            VO_Survey__c surv = new VO_Survey__c(SurveyType__c = 'VOICE CSC Click And Collect', Store__c = st2.id, STOREDELIVERY__c = 'A00', AnswerDate__c = system.today());
        VO_Survey__c surv2 = new VO_Survey__c(SurveyType__c = 'VOICE Endless Offer', Store__c = st2.id, STOREORDER__c = 'B00', AnswerDate__c = system.today());
        insert surv;
        
        String fromDate = String.valueof(system.now().adddays(-2).format('DD-MM-YYYY'));
        String toDate = String.valueof(system.now().format('DD-MM-YYYY'));
        String currSurvayType = VO_Utils.VOICE_CC_CSC_SALES ;
        String fieldFilter = 'StoreID;';
        String valueOf = 'A00';
        String fieldFilter2 = 'StoreID';
        String valueOf2 = 'A00;AAA';
        String valueOf3 = 'B00';
        String userStoretype = 'Store';
        
        
        System.runAs(sUser)
        {
            String res = VO_Specific_Statistics_CTRL.mainSearchRemote(fromDate, toDate, currSurvayType, fieldFilter, valueOf);
            String res2 = VO_Specific_Statistics_CTRL.mainSearchRemote(fromDate, toDate, currSurvayType, fieldFilter2, valueOf2);
            System.assert(res != null);
            System.assert(res2 != null);
        }
    } 
    
    @isTest
    static void myUnitTest2222()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='ICON_SA'];
        User u1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id, 
                           TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@test1111111org.com.menashTestTt654', TECH_User_Stores__c='NA2');
        
        User u2 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id, 
                           TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@test1111111org.com.menashTestTt2', MGMT_ZONE_SUB_LEVEL3__c ='70');
        
        User u3 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id, 
                           TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@test1111111org.com.menashTestTt3', MGMT_ZONE_SUB_LEVEL2__c ='70');
        
        User u4 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id, 
                           TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@test1111111org.com.menashTestTt4', MGMT_ZONE_SUB_LEVEL1__c ='70');
        
        User u5 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id, 
                           TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@test1111111org.com.menashTestTt5');
        
        User u6 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id, 
                           TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@test1111111org.com.menashTestTt6', MANAGEMENT_ZONE_LEVEL__c='70');
        
        insert new List<User> {u1,u2,u3,u4,u5,u6};
            
            
            
            PageReference ref = Page.VO_Specific_Statistics;
        List<String> surveyTypeValueList = VO_data_Object_Creator_TEST.getPickListValByAPIName('VO_Survey__c','SurveyType__c');
        ref.getParameters().put('surveyType',surveyTypeValueList[0]);
        
        List<VO_Survey__c> surveyList = [SELECT id FROM VO_Survey__c ];
        ref.getParameters().put('id',surveyList[0].id);
        Test.setCurrentPage(ref);
        
        
        Test.startTest();
        system.runAs(u1) {
            VO_Specific_Statistics_CTRL webPage1 = new VO_Specific_Statistics_CTRL();
            webPage1.mainSearch();
        }
        
        system.runAs(u2) {
            VO_Specific_Statistics_CTRL webPage2 = new VO_Specific_Statistics_CTRL();
            webPage2.mainSearch();
        }
        
        system.runAs(u3) {
            VO_Specific_Statistics_CTRL webPage3 = new VO_Specific_Statistics_CTRL();
            webPage3.mainSearch();
        }
        
        system.runAs(u4) {
            VO_Specific_Statistics_CTRL webPage4 = new VO_Specific_Statistics_CTRL();
            webPage4.mainSearch();
        }
        
        system.runAs(u5) {
            VO_Specific_Statistics_CTRL webPage5 = new VO_Specific_Statistics_CTRL();
            
            webPage5.mainSearch();
        }
        
        system.runAs(u6) {
            VO_Specific_Statistics_CTRL webPage6 = new VO_Specific_Statistics_CTRL();
            webPage6.mainSearch();
        }
        Test.stopTest();
        
    }
    
}