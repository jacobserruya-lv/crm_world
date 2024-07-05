@isTest
public with sharing class BL_ICON_Retention_TEST {
    @isTest
    static void testMethodGetPyramid(){
     
        BL_AppSettings.setAppSettings('Icon');
        BL_ICON_Retention blRetention = new BL_ICON_Retention();

        
        List<Retention__c> ret = new List<Retention__c>{new Retention__c(type__c='Pyramid',segregation_type__c='store', Store_code__c='N12',level__c='1 Time', Pyramid_type__c='byVisit', clientNbr__c=110000),
                                                        new Retention__c(type__c='Pyramid',segregation_type__c='store', Store_code__c='N12',level__c='2 Times', Pyramid_type__c='byVisit',clientNbr__c=110000),
                                                        new Retention__c(type__c='Pyramid',segregation_type__c='store', Store_code__c='N12',level__c='3 Times', Pyramid_type__c='byVisit', clientNbr__c=110000),
                                                        new Retention__c(type__c='Pyramid', segregation_type__c='store', Store_code__c='N12',level__c='1 Time', Pyramid_type__c='byVisit', clientNbr__c=110000),
                                                        new Retention__c(type__c='Pyramid',segregation_type__c='store', Store_code__c='N12',level__c='<5W', Pyramid_type__c='byR12MSpending', clientNbr__c=110000),
                                                        new Retention__c(type__c='Pyramid',segregation_type__c='store', Store_code__c='N12',level__c='10K', Pyramid_type__c='byR12MSpending',clientNbr__c=110000),
                                                        new Retention__c(type__c='Pyramid',segregation_type__c='store', Store_code__c='N12',level__c='50K', Pyramid_type__c='byR12MSpending', clientNbr__c=110000)};
         
        insert ret;

        Test.startTest();   
        blRetention.queryParams = new Map<String, String>{'filter'=>'store', 'storeCode'=>'N12','type'=>'Pyramid'};
        blRetention.executeGET();
        Test.stopTest();
    
    }
    @isTest
    static void testMethodGetDashboard(){
     
        BL_AppSettings.setAppSettings('Icon');
        BL_ICON_Retention blRetention = new BL_ICON_Retention();

        
        List<Retention__c> ret = new List<Retention__c>{new Retention__c(type__c='Dashboard',segregation_type__c='store', Store_code__c='N12',Refresh_type__c='Monthly',Date__c= Date.newInstance(2021,12,01), R12MTotClient__c= 1119735,RetainedClient__c=263479 ),
        new Retention__c(type__c='Dashboard',segregation_type__c='store', Store_code__c='N12',Refresh_type__c='Monthly',Date__c=Date.newInstance(2022,01,01), R12MTotClient__c= 1119735,RetainedClient__c=263479 ),
        new Retention__c(type__c='Dashboard', segregation_type__c='store',Store_code__c='N12',Refresh_type__c='Monthly',Date__c=Date.newInstance(2022,02,02), R12MTotClient__c= 1119735,RetainedClient__c=263479 ),
        new Retention__c(type__c='Dashboard', segregation_type__c='store',Store_code__c='N12',Refresh_type__c='Monthly',Date__c=Date.newInstance(2022,03,03), R12MTotClient__c= 1119735,RetainedClient__c=263479 ),
        new Retention__c(type__c='Dashboard',segregation_type__c='store', Store_code__c='N12',Refresh_type__c='Monthly',Date__c=Date.newInstance(2022,04,04), R12MTotClient__c= 1119735,RetainedClient__c=263479 ),
        new Retention__c(type__c='Dashboard',segregation_type__c='store', Store_code__c='N12',Refresh_type__c='Weekly',Date__c=Date.newInstance(2022,05,28), R12MTotClient__c= 1119735,RetainedClient__c=263479 ),
        new Retention__c(type__c='Dashboard',segregation_type__c='store', Store_code__c='N12',Refresh_type__c='Weekly',Date__c=Date.newInstance(2022,06,04), R12MTotClient__c= 1119735,RetainedClient__c=263479 ),
        new Retention__c(type__c='Dashboard',segregation_type__c='store', Store_code__c='N12',Refresh_type__c='Weekly',Date__c=Date.newInstance(2022,06,11), R12MTotClient__c= 1119735,RetainedClient__c=263479 )};
        insert ret;
        
        Test.startTest();   
        blRetention.queryParams = new Map<String, String>{'filter'=>'store', 'storeCode'=>'N12','type'=>'Dashboard'};
        blRetention.executeGET();
        Test.stopTest();
    
    }

    @isTest
    static void testMethodGetStoreRanking(){

        List<Retention__c> ret = new List<Retention__c>{new Retention__c(LVM_Id__c='123', type__c='Dashboard',segregation_type__c='store', Store_code__c='N12',Refresh_type__c='Monthly',Date__c= Date.today(), CANewRetentionRate__c=0.237709378 ),
                                                        new Retention__c(LVM_Id__c='456', type__c='Dashboard',segregation_type__c='store', Store_code__c='N12',Refresh_type__c='Monthly',Date__c=Date.today(), CANewRetentionRate__c= 0.238964343),
                                                        new Retention__c(LVM_Id__c='789', type__c='Dashboard', segregation_type__c='store',Store_code__c='N12',Refresh_type__c='Monthly',Date__c=Date.today(), CANewRetentionRate__c= 0.239728537)};
                                                        
        insert ret;

        List<User> userList = new List<User>();
        User ca = IC_Test_Common.prepareTestUser('System Administrator');
        ca.defaultStore__c = 'N12';
        ca.WWEmployeeNumber__c = '123';
        userList.add(ca);
        User ca2 = IC_Test_Common.prepareTestUser('System Administrator');
        ca2.defaultStore__c = 'N12';
        ca2.WWEmployeeNumber__c = '456';
        userList.add(ca2);
        User ca3 = IC_Test_Common.prepareTestUser('System Administrator');
        ca3.defaultStore__c = 'N12';
        ca3.WWEmployeeNumber__c = '789';
        userList.add(ca3);

        insert userList;
        
        BL_AppSettings.setAppSettings('Icon');
        BL_ICON_Retention blRetention = new BL_ICON_Retention();
        blRetention.me = (BL_UserInfo) Type.forName('BL_ICON_UserInfo').newInstance();
        blRetention.path='/retention/store-ranking';
        blRetention.queryParams=new Map<String, String>{ 'storeCode'=>'N12'};
        blRetention.executeGET();

    }
}