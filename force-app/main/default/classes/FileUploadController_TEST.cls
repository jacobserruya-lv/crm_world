//Transverse
@isTest
public class FileUploadController_TEST {
	@testSetup
	public static void setup (){		
		User u = IC_TestFactory.createUser('FileUploadController_TEST@test.com');
		u.ProfileId = IC_UTILS.getSAProfile();
		u.DefaultStore__c = 'L36';
		u.TECH_User_Stores__c = 'URZ';
		insert u;
	}
	
	@isTest
	public static void initTest (){

		User testUser = [SELECT id, DefaultStore__c, TECH_User_Stores__c, User_Stores__c FROM User WHERE Username LIKE :('%' + 'FileUploadController_TEST@test.com')];
		Test.setCurrentPage(Page.EditUserStores);
		ApexPages.currentPage().getParameters().put('id', testUser.id);
		FileUploadController controller = new FileUploadController();

		System.assertEquals('User', controller.getObjectType());
        System.assertEquals(testUser.id, controller.getId());
	}
}