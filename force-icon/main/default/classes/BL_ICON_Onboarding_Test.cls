@isTest
public class BL_ICON_Onboarding_Test {
	    @IsTest static void testExecuteGet() {
        try{
            Test.startTest();
            User u = IC_Test_Common.prepareTestUser('ICON_LV Administrator');
       	    u.DefaultStore__c = '1234';
             insert u;               
            BL_AppSettings.setAppSettings('Wechat');
            BL_ICON_Onboarding Onboarding = new BL_ICON_Onboarding();
            Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
            insert store;
            Onboarding.me = (BL_UserInfo)Type.forName('BL_ICON_UserInfo').newInstance();
            BL_WS_QueryMergeFields.init(Onboarding.me.userMergeFields);
            OnboardingItem__c o = new OnboardingItem__c(IsActive__c = true, Language__c = UserInfo.getLanguage(),Application__c = 'ICON');
            insert o;
            Onboarding.executeGET();
            Test.stopTest();   
        }
        catch (Exception ex){
            
        }     
    }
}