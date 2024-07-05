@isTest
public class TR_User_TriggerHandler_TEST {
 @isTest
    public static void testMethodUser()
    {
        User u;
        List<Profile> p = [Select id, name from profile where name = 'ICON_LV_Country_Support'];
        if (p.size() > 0){
            u = ICX_TestFactory.createUser(p[0].Id);
            u.IsActive = true;
            insert u;
        }
        u.Email = 'testNEWemail@testEmail.com';
        update u;
    }
}