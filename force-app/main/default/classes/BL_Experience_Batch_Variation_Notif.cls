global with sharing class BL_Experience_Batch_Variation_Notif implements Database.Batchable<sObject> {

    public String query;

    
    public static List<String> variationStatusFilter = new List<String> {'Ready', 'Preview', 'Registration Opened', 'Registration Closed','Selection Opened', 'Selection Closed', 'Participation Opened'};

	
	global BL_Experience_Batch_Variation_Notif() {
		query = 'SELECT Id, Name, Store__c, Nb_Pending_Clients__c, Store__r.RetailStoreId__c , Store__r.ISO3_Code__c ' +
        'FROM Brand_Experience_Variation__c '+
        'WHERE Status__c IN: variationStatusFilter ' +
        'AND Brand_Experience__r.RecordTypeId = \'' + BL_Experience_Variation_Utils.getRecordTypeExperience('Experience') + '\'';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
	
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<Push_Notification_Item__c> pushNotificationItems = new List<Push_Notification_Item__c>();
        Map<String, String> countryByStoreCode = new Map<String, String>();
        Set<String> storeIds = new Set<String>();
        List<Brand_Experience_Variation__c> experiences = (List<Brand_Experience_Variation__c>) scope;

        for(Brand_Experience_Variation__c experience : experiences){

            storeIds.add(experience.Store__r.RetailStoreId__c);
            countryByStoreCode.put(experience.Store__r.RetailStoreId__c, experience.Store__r.ISO3_Code__c);
        }  
		Map<String, String> languagePerCountry = BL_Experience_Variation_Utils.getLanguagePerStore(countryByStoreCode.values());
        Map<String, List<Id>> managersPerStore = BL_Experience_Variation_Utils.getUsersByStore(storeIds,IC_UTILS.getSAManagerProfile());
        try {

            for(Brand_Experience_Variation__c experience : experiences) {

                Decimal clientNumber = (Decimal) experience.Nb_Pending_Clients__c;

                if(clientNumber > 0){

                    String storeCode = (String) experience.Store__r.RetailStoreId__c;
                    List<Id> managerIds = managersPerStore.get(storeCode);
                    String caLanguage = languagePerCountry.get(countryByStoreCode.get(storeCode)) ;
                    String placeholder = IM_SendPushNotifications.getNotificationTemplate( caLanguage , 'VariationMemberPending__c');
                    List<String> fillers = new String[]{String.valueOf(clientNumber) , experience.Name };

                    Push_Notification_Item__c push = new Push_Notification_Item__c(
                        Body__c = String.format(placeholder, fillers),
                        Type__c = 'Experience_Variation',
                        ObjectId__c = experience.Id,
                        UsersIds__c  = String.join(managerIds, ';')
                    );

                    pushNotificationItems.add(push);
                }
            }
            if(!pushNotificationItems.isEmpty()){
                Database.insert(pushNotificationItems, false);
            }
        } catch (Exception e) {
            System.debug(e);

        }
    }

    global void finish(Database.BatchableContext CD){}


}