@isTest
public class BL_SITE_Translation_Test  {
    @isTest
    static void testMethodGet(){
        try{
            BL_AppSettings.setAppSettings('Icon');
            User u = IC_Test_Common.prepareTestUser('System Administrator');
            insert u;
            BL_SITE_Translation blTrans = new BL_SITE_Translation();
            system.runAs(u){
                Translation__c trans = new Translation__c(Language__c = 'en_US');
                trans.Key__c = 'Ok';
                trans.Value__c='Ok';
                trans.Is_Public__c = true;
                insert trans;
                Test.startTest();
                blTrans.queryParams  = new Map<String, String>();
                blTrans.queryParams.put('language', null);
                blTrans.executeGET();
                Test.stopTest();
            }
        }
        catch(Exception ex){}
    }

    @isTest
    static void testMethodGet2(){
        BL_AppSettings.setAppSettings('Icon');

        User u = IC_Test_Common.prepareTestUser('System Administrator');
        insert u;
        BL_SITE_Translation blTrans = new BL_SITE_Translation();
        system.runAs(u){
            Translation__c trans = new Translation__c(Language__c = 'en_US');
            trans.Key__c = 'Ok';
            trans.Value__c='Ok';
            trans.Is_Public__c = true;
            trans.Application__c = 'NowYours';
            insert trans;
            Test.startTest();
            blTrans.queryParams  = new Map<String, String>();
            blTrans.queryParams.put('language','fr');
            blTrans.queryParams.put('application','NowYours');
            blTrans.executeGET();
            Test.stopTest();
        }
    }
}