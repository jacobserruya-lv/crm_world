@isTest
private class User_MultiStore_TRG_TEST {

	public static final String username = 'User_MultiStore_TRG_TEST@test.com';

	@testSetup
	public static void setup (){

		User u = IC_TestFactory.createUser(username);
		u.ProfileId = IC_UTILS.getSAProfile();
		u.DefaultStore__c = 'NA7';
		insert u;
	}
	
	@isTest
	public static void insertTest() {

		User u = [SELECT DefaultStore__c, TECH_User_Stores__c, User_Stores__c FROM User WHERE username LIKE :('%' + username)];

		System.assertEquals(u.DefaultStore__c, u.TECH_User_Stores__c);
		System.assertEquals('LV KAOHSIUNG STAR PLACE', u.User_Stores__c);
	}

	@isTest
	public static void updateTest(){

		User u = [SELECT DefaultStore__c, TECH_User_Stores__c, User_Stores__c FROM User WHERE username LIKE :('%' + username)];

		u.TECH_User_Stores__c = u.TECH_User_Stores__c + ',NA1';
		update u;

		u = [SELECT DefaultStore__c, TECH_User_Stores__c, User_Stores__c FROM User WHERE Id = :u.id];

		System.assertEquals('NA1,' + u.DefaultStore__c, u.TECH_User_Stores__c);
		System.assertEquals('LV BEIJING SEASONS PLACE FINAN, LV KAOHSIUNG STAR PLACE', u.User_Stores__c);
	}
	
}