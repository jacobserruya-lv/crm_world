@isTest
public class ICX_QuickTextControllerLC_TEST {

    private static QuickText createQuickText(String name, String message, String channel, String language) {
        QuickText quick = new QuickText();
        quick.Name = name;
        quick.Message = message;
        quick.Channel = channel;
        quick.Language__c = language;
        return quick;
        //return [SELECT Language__c, Name, Channel, Message, Category, FolderId, FolderName, Folder.AccessType, Folder.ParentId FROM QuickText WHERE Channel = :channel ORDER BY Language__c LIMIT 200];
    }

    @isTest
    public static void getQuickTextList_Test() {
        // Prepare data
        String channel = 'Email';
        String msg = 'Message';
        String language = 'English';

        QuickText quick = createQuickText('Name', msg, channel, language);
        insert quick;

		// Test
		Test.startTest();
		List<QuickText> resultList = ICX_QuickTextControllerLC.getQuickTextList(channel);
		Test.stopTest();

		// Check
        System.assertEquals(1, resultList.size());
        System.assertEquals(msg, resultList[0].Message);
    }

	@isTest
    public static void getFolderList_Test() {
        String name = 'myFolder';
        String folderType = 'QuickText';

        // Can(t insert a folder (Error: DML operation Insert not allowed on Folder). Workaround get existing folder
        List<Folder> lstFolder = [SELECT Id, Type FROM Folder LIMIT 10];

		// Test
		Test.startTest();
        List<Folder> resultList = ICX_QuickTextControllerLC.getFolderList(lstFolder[0].Type);
		Test.stopTest();

		// Check
        System.assert(resultList.size() > 0);
    }

	@isTest
    public static void addRecentlyViewed_Test() {
        // Prepare data
        String channel = 'Email';
        String msg = 'Message';
        String language = 'English';

        QuickText quick = createQuickText('Name', msg, channel, language);

        User currentUser = ICX_TestFactory.createUser(ICX_TestFactory.PROFILE_ICONICS_SA);
        currentUser.MANAGEMENT_ZONE_LEVEL__c = '15';
        insert currentUser;

        // Test
        Test.startTest();
        QuickText quickResult;
        System.runAs(currentUser) {
            insert quick;
            quickResult = ICX_QuickTextControllerLC.addRecentlyViewed(quick.Id);
        }
        Test.stopTest();

        // Check
        System.assertEquals(quick.Id, quickResult.Id);
    }

	@isTest
    public static void getRecentQuickTextList_Test() {
        // Prepare data
        String channel = 'Email';
        String msg = 'Message';
        String language = 'English';

        List<UserRole> roleList = [SELECT Id FROM UserRole WHERE DeveloperName = 'EUR_CSC_Fance_Benelux_SA'];
		System.assertEquals(1, roleList.size());

        User currentUser = ICX_TestFactory.createUser(ICX_TestFactory.PROFILE_ICONICS_SA);
        currentUser.MANAGEMENT_ZONE_LEVEL__c = '15';
        currentUser.UserRoleId = roleList[0].Id;
        //insert currentUser;

        //User quickTextCreatorUser = ICX_TestFactory.createUser(ICX_TestFactory.PROFILE_ICONICS_SA);
        //quickTextCreatorUser.MANAGEMENT_ZONE_LEVEL__c = '15';
        //quickTextCreatorUser.UserRoleId = roleList[0].Id;
        insert new List<User> {currentUser};//, quickTextCreatorUser};

        QuickText quick = createQuickText('Name', msg, channel, language);
        QuickText quick2 = createQuickText('Name2', msg, channel, language);

        // QuickText has a Private sharing model. Sharing settings should apply.
        //System.runAs(quickTextCreatorUser) {
		//}

        List<QuickText> resultList;
        System.runAs(currentUser) {
            insert new List<QuickText> {quick, quick2};

            // add the quick text as recently viewed
            ICX_QuickTextControllerLC.addRecentlyViewed(quick2.Id);

            // Test
            Test.startTest();
            resultList = ICX_QuickTextControllerLC.getRecentQuickTextList(channel);
            Test.stopTest();
        }

        // Check
		//System.assertEquals(2, resultList.size());
		//System.assertEquals(quick2.Id, resultList[0].Id);
    }

	@isTest
    public static void getMergeFields_Test() {
        // Init
        String storeName = 'storeName';
        Store__c store = ICX_TestFactory.createStore(storeName, 'XXX');
        insert store;

        String firstname = 'Firstname';
        Account acc = ICX_TestFactory.createAccount();
        acc.FirstName = firstname;

        String customSettingValue = '2020';
        String customSettingValue2 = '12345';
        IconicsSettings__c settings = new IconicsSettings__c();
        settings.CurrentYearLegalNotices__c = customSettingValue;
        settings.GooglePlaceKey__c = customSettingValue2;
        insert settings;

        String userFirstname = 'userFirstname';
        User currentUser = ICX_TestFactory.createUser(ICX_TestFactory.PROFILE_ICONICS_SA);
        currentUser.Firstname = userFirstname;
        currentUser.MANAGEMENT_ZONE_LEVEL__c = '15';
        insert currentUser;

        String channel = 'Email';
        String msg = 'Current record: {!Case.Id}. Related standard record : {!Account.FirstName}. Related custom record : {!Store__c.Name}. A custom setting: {!IconicsSettings__c.CurrentYearLegalNotices__c} OR from a HTML page: {!$Setup.IconicsSettings__c.GooglePlaceKey__c}. Current user is {!User.FirstName}';
        String language = 'English';

        //QuickText quick = createQuickText('Name', msg, channel, language);
        //insert quick;

        List<String> mergeFieldList = new List<String>();
        mergeFieldList.add('Case.Id');
        mergeFieldList.add('Account.FirstName');
        mergeFieldList.add('Store__c.Name');
        mergeFieldList.add('IconicsSettings__c.CurrentYearLegalNotices__c');
        mergeFieldList.add('$Setup.IconicsSettings__c.GooglePlaceKey__c');
        mergeFieldList.add('User.FirstName');

        // Test
        Case cas;
        String result;
        System.runAs(currentUser) {
            insert acc;

            cas = ICX_TestFactory.createCase(acc.Id);
            cas.Origin = 'Email';
            cas.Store__c = store.Id;
            insert cas;

            Test.startTest();

            result = ICX_QuickTextControllerLC.getMergeFields(msg, cas.Id, mergeFieldList);
            Test.stopTest();
        }

        // Check
        String expectedMsg = 'Current record: ' + cas.Id + '. Related standard record : ' + firstname + '. Related custom record : ' + storeName + '. A custom setting: ' + customSettingValue + ' OR from a HTML page: ' + customSettingValue2 + '. Current user is ' + userFirstname;
        System.assertEquals(expectedMsg, result);
    }
}