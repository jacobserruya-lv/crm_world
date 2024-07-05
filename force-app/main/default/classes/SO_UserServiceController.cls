global with sharing class SO_UserServiceController {

    @AuraEnabled
	public static User getUser() {
		return [SELECT MANAGEMENT_ZONE_LEVEL__c, MGMT_ZONE_SUB_LEVEL1__c, MGMT_ZONE_SUB_LEVEL2__c, MGMT_ZONE_SUB_LEVEL3__c, DefaultStore__c
				FROM User
				WHERE Id =:UserInfo.getUserId()];
	}
}