@isTest
public class BL_ICON_Badges_TEST {
    @isTest
    static void testMethodGet(){
     
        BL_AppSettings.setAppSettings('Icon');
        BL_ICON_Badges blBadges = new BL_ICON_Badges();
        User u = IC_Test_Common.prepareTestUser('System Administrator');
        u.defaultStore__c = 'N03';
        insert u;
        User ca = IC_Test_Common.prepareTestUser('System Administrator');
        ca.defaultStore__c = 'N03';
        insert ca;
        TeamMember__c teammember = new TeamMember__c( manager__c = u.id, user__c = ca.Id);
        insert teammember;
        insert new IconBadge__c(Type__c = 'Regular', ownerId = ca.Id);

        system.runAs(u){
            
            blBadges.me = (BL_UserInfo)Type.forName('BL_ICON_UserInfo').newInstance();
            
            Test.startTest();   
            blBadges.queryParams = new Map<String, String>();
            blBadges.queryParams.put('managerId',null);
            blBadges.executeGET();
            Test.stopTest();
        }
    }

}