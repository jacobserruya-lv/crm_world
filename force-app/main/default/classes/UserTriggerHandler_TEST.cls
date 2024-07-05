@isTest
public class UserTriggerHandler_TEST {

    @isTest
    public static void testRemoveLicenseForInactiveUsers()
    {
		// create a user
		User u = ICX_TestFactory.createUser(ICX_TestFactory.PROFILE_ICONICS_SA);
        u.IsActive = true;
        insert u;
        
        // get the installed package
         PackageLicense pl = [SELECT id from PackageLicense where namespacePrefix = 'cnx'][0];
        
        // grant a license to the user
        // TODO : uncomment this line when no more error in production : "LICENSE_LIMIT_EXCEEDED, There are no licenses available to assign to this user: [PackageLicenseId]"
        // insert new UserPackageLicense(UserId = u.id, PackageLicenseId = pl.id);

        // Run test: deactivate user
        Test.startTest();
        u.IsActive = false;
        update u;
        Test.stopTest();
        
        // check test result: there should be no license for user u
        List<UserPackageLicense> upl = [SELECT id from UserPackageLicense where userId =: u.id AND PackageLicenseId =: pl.id];
        // TODO : uncomment this line when no more error in production : "LICENSE_LIMIT_EXCEEDED, There are no licenses available to assign to this user: [PackageLicenseId]"
        // System.assertEquals(0, upl.size());
    }

	@isTest
    public static void addPermSetAssignmentToIconicsUser_OK() {
        // Init
        User u = ICX_TestFactory.createUser(ICX_TestFactory.PROFILE_ICONICS_SA);
        insert u;

        // User
        User userWithoutSearchPermissionSet = ICX_TestFactory.createUser(ICX_TestFactory.PROFILE_SYSTEM_ADMINNISTRATOR);
        insert userWithoutSearchPermissionSet;

        List<PermissionSet> psList = [SELECT id FROM PermissionSet WHERE Name = 'mySearch'];
        PermissionSet ps;
        if (psList.isEmpty()) {
            ps = new PermissionSet();
            ps.Name = 'mySearch';
            ps.Label = 'mySearch';
            insert ps;
        } else {
            ps = psList[0];
        }

        // Test
        Test.startTest();
        u.IsActive = true;
        update u;
        
        userWithoutSearchPermissionSet.IsActive = true;
        update userWithoutSearchPermissionSet;
        Test.stopTest();

        // Check
        List<PermissionSetAssignment> upl = [SELECT id FROM PermissionSetAssignment WHERE AssigneeId = :u.id AND PermissionSetId = :ps.id];
        System.assertEquals(1, upl.size());

        List<PermissionSetAssignment> upl2 = [SELECT id FROM PermissionSetAssignment WHERE AssigneeId = :userWithoutSearchPermissionSet.id AND PermissionSetId = :ps.id];
        System.assertEquals(0, upl2.size());
        
        // Test 2: update user again to see if no error message is displayed
        Boolean noError = false;
        try {
            u.City = 'Paris';
            update u;
        } catch (Exception e) {
            noError = true;
        }
        System.assertEquals(false, noError);
    }
}