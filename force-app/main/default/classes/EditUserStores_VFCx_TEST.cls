@isTest
public class EditUserStores_VFCx_TEST {

	public static String username = 'EditUserStores_VFCx_TEST@test.com';
	public static String username2 = 'username2@test.com';
    
	@testSetup
	public static void setup (){		
		User u = IC_TestFactory.createUser(username);
		u.ProfileId = IC_UTILS.getSAProfile();
		u.DefaultStore__c = 'L36';
		u.TECH_User_Stores__c = 'URZ';
		insert u;
	}
    
    @isTest
    public static void allTests (){
        User testUser = [SELECT id, DefaultStore__c, TECH_User_Stores__c, User_Stores__c FROM User WHERE Username LIKE :('%' + username)];
        initTest(testUser);
        cancelTest(testUser);
        addTest(testUser);
        removeTest(testUser);
        validateTest(testUser);
    }

	public static void initTest (User testUser){
		Test.setCurrentPage(Page.EditUserStores);
		ApexPages.currentPage().getParameters().put('id', testUser.id);
		EditUserStores_VFCx controller = new EditUserStores_VFCx();

		System.assertEquals(2, controller.selectedStoresOptions.size());
		System.assertEquals('URZ', controller.selectedStoresOptions.get(0).getValue());
		System.assertEquals('L36', controller.selectedStoresOptions.get(1).getValue());
		System.assert(controller.isAddDisabled);
		System.assert(controller.isRemoveDisabled);
                
        System.assertEquals(false, controller.isMaxNbStores, 'isMaxNbStores should be false when selectedStoresOptions size does not reach the maximum limit');
        System.assertEquals('Max number of Stores reached (5).', controller.warningMessage, 'warningMessage should match the expected label');
	}
	
	public static void cancelTest (User testUser){

		//User testUser = [SELECT id, DefaultStore__c, TECH_User_Stores__c, User_Stores__c FROM User WHERE Username LIKE :('%' + username)];
		Test.setCurrentPage(Page.EditUserStores);
		ApexPages.currentPage().getParameters().put('id', testUser.id);
		EditUserStores_VFCx controller = new EditUserStores_VFCx();

		Test.setCurrentPage(controller.cancel());

		System.assert(ApexPages.currentPage().getURL().endsWith('/' + testUser.id));
		System.assertEquals(2, testUser.TECH_User_Stores__c.split(',').size());
		System.assertEquals('URZ', testUser.TECH_User_Stores__c.split(',')[0]);
		System.assertEquals('L36', testUser.TECH_User_Stores__c.split(',')[1]);
	}

	public static void addTest (User testUser){

		//User testUser = [SELECT id, DefaultStore__c, TECH_User_Stores__c, User_Stores__c FROM User WHERE Username LIKE :('%' + username)];
		Test.setCurrentPage(Page.EditUserStores);
		ApexPages.currentPage().getParameters().put('id', testUser.id);
		EditUserStores_VFCx controller = new EditUserStores_VFCx();

		controller.currentUser.DefaultStore__c = ('UIC');
		System.assert(!controller.isAddDisabled);

		controller.add();

		System.assertEquals(3, controller.selectedStoresOptions.size());
		System.assertEquals('URZ', controller.selectedStoresOptions.get(0).getValue());
		System.assertEquals('L36', controller.selectedStoresOptions.get(1).getValue());
		System.assertEquals('UIC', controller.selectedStoresOptions.get(2).getValue());
		System.assert(controller.isAddDisabled);
	}

	public static void removeTest (User testUser){

		//User testUser = [SELECT id, DefaultStore__c, TECH_User_Stores__c, User_Stores__c FROM User WHERE Username LIKE :('%' + username)];
		Test.setCurrentPage(Page.EditUserStores);
		ApexPages.currentPage().getParameters().put('id', testUser.id);
		EditUserStores_VFCx controller = new EditUserStores_VFCx();

		controller.selectedStoresClicked.add('URZ');
		System.assert(!controller.isRemoveDisabled);

		controller.remove();

		System.assertEquals(1, controller.selectedStoresOptions.size());
		System.assertEquals('L36', controller.selectedStoresOptions.get(0).getValue());
		System.assert(controller.isRemoveDisabled);
	}

	public static void validateTest (User testUser){

		//User testUser = [SELECT id, DefaultStore__c, TECH_User_Stores__c, User_Stores__c FROM User WHERE Username LIKE :('%' + username)];
		Test.setCurrentPage(Page.EditUserStores);
		ApexPages.currentPage().getParameters().put('id', testUser.id);
		EditUserStores_VFCx controller = new EditUserStores_VFCx();

		controller.currentUser.DefaultStore__c = ('UIC');
		controller.add();
		controller.selectedStoresClicked.add('URZ');
		controller.remove();

		Test.setCurrentPage(controller.validate());
		//System.assert(ApexPages.currentPage().getURL().endsWith('/' + testUser.id));
		
		testUser = [SELECT id, DefaultStore__c, TECH_User_Stores__c, User_Stores__c FROM User WHERE Username LIKE :('%' + username)];

		System.assertEquals(2, testUser.TECH_User_Stores__c.split(',').size());
		System.assertEquals('UIC', testUser.TECH_User_Stores__c.split(',')[0]);
		System.assertEquals('L36', testUser.TECH_User_Stores__c.split(',')[1]);

	}
}