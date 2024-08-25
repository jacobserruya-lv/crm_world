@isTest
public class BL_ICON_TeamMembers_Test {
    @isTest static void test_method_one() {
        BL_AppSettings.setAppSettings('Clienteling');
        BL_ICON_TeamMembers blTeam = new BL_ICON_TeamMembers();
        User user = new User(
            username = 'testtest2@acme.com',
            alias = 'testtest',
            emailEncodingKey = 'UTF-8',
            firstName = 'Jotesttes',
            lastName = 'test',
            localeSIDKey = 'en_US',
            languageLocaleKey = 'en_US',
            timezoneSIDKey = 'America/Los_Angeles');
        user.email =   'testtest123@acme.com';
        user.profileId = IC_UTILS.getSAProfile();
        insert user;
  		List<String> teamIds = new List<String>(); 
        teamIds.add(user.Id);
        blTeam.requestBody = new Map<String, Object>{'teamIds'=> teamIds};
        Test.startTest();       
            blTeam.executePOST();
        Test.stopTest();
        
    }
}