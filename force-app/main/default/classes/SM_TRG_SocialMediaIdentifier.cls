public without sharing class SM_TRG_SocialMediaIdentifier {

  /*
    *** DESCRIPTION Set TECH Key Fields 
            In insert case: to preserve the unicity of the key, allow the insertion but remove duplicate key
            In update case: dont allow the update if duplicate records => dont remov, keep the existing record
    */
  public static void setUniqueKeys(List<Social_Media_Identifier__c> newRecords, Boolean remove) {

    // Get Client data
    Set<String> clientIds = new Set<String>();
    for(Social_Media_Identifier__c identifier : newRecords) {
      clientIds.add(identifier.Client__c);
    }
    Map<Id,Account> clients = new Map<Id,Account> ([SELECT Id, DREAMID__c FROM Account WHERE Id IN: clientIds]);

    // Retrieve KEYS
    Set<String> keys = new Set<String>();
    for(Social_Media_Identifier__c identifier : newRecords) {

      identifier.Social_SF_External_Id__c = identifier.Social_Media_Type__c + '_' + identifier.Social_Id__c;
      keys.add(identifier.Social_SF_External_Id__c);

      identifier.TECH_Type_Client__c = identifier.Social_Media_Type__c + '_' + identifier.Client__c;
      keys.add(identifier.TECH_Type_Client__c);

      if(clients.get(identifier.Client__c) != null && clients.get(identifier.Client__c).DREAMID__c != null) {
        identifier.TECH_Type_DreamId__c = identifier.Social_Media_Type__c + '_' + clients.get(identifier.Client__c).DREAMID__c;
        keys.add(identifier.TECH_Type_DreamId__c);
      }
    }

    // For insert case 
    if(remove) {
      String query = 'SELECT Name ' +
      'FROM Social_Media_Identifier__c ' + 
      'WHERE Social_SF_External_Id__c IN: keys OR TECH_Type_DreamId__c IN: keys OR TECH_Type_Client__c IN: keys' ;

      Database.delete(Database.query(query), true);    
    }
  }

  public static void setUniqueKeysSMI_SA(List<Social_Media_Identifier_CA__c> newRecords) {

    // Get Client data
    Set<String> smiIds = new Set<String>();
    for(Social_Media_Identifier_CA__c smisa : newRecords){
      smiIds.add(smisa.Client_Social_Media_Identifier__c);
    }
    Map<Id, Social_Media_Identifier__c> smis = new Map<Id, Social_Media_Identifier__c>([select Id, Social_SF_External_Id__c FROM Social_Media_Identifier__c Where ID IN :smiIds]);
    for(Social_Media_Identifier_CA__c smisa : newRecords){
      smisa.TECH_ExternalId__c = smisa.CA__c + '_' + smis.get(smisa.Client_Social_Media_Identifier__c).Social_SF_External_Id__c;
    }
    system.debug(newRecords);
  }
}