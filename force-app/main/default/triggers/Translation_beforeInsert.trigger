trigger Translation_beforeInsert on Translation__c (before insert) {
    for(Translation__c trans : Trigger.New){
        trans.ExternalId__c = trans.Application__c+trans.Target__c+trans.Language__c+trans.Key__c;
    }
}