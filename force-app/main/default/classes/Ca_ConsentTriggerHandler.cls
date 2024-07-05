public with sharing class Ca_ConsentTriggerHandler {
    
    public static void handleTrigger(List<Ca_Consent__c> newList,Map<Id, Ca_Consent__c> oldMap, System.TriggerOperation triggerEvent) {
        switch on triggerEvent {
            when BEFORE_INSERT {
                handleBeforeInsert(newList);
            }
            when BEFORE_UPDATE {
                handleBeforeUpdate(newList,oldMap);
            }
            when else {
                //do nothing for AFTER_UNDELETE, BEFORE_DELETE, or BEFORE_UPDATE
            }
        }
    }
    public static void handleBeforeInsert(List<Ca_Consent__c> newList){
        for (Ca_Consent__c consent : newList) {

            if(String.isEmpty(consent.user__c)|| consent.user__c != UserInfo.getUserId()){
                consent.addError( new myException('ERROR PLEASE CHECK THE USER'));
                return;
            }

            if(String.isNotEmpty(consent.Consent__c)){
                consent.Last_Consent__c = System.Now();
                consent.ExKey__c = consent.User__c;
            }
        }       
    }


    public static void handleBeforeUpdate(List<Ca_Consent__c> newList , Map<Id, Ca_Consent__c> oldMap ){

        for (Ca_Consent__c consent : newList) {

            if(String.isEmpty(consent.user__c) || consent.user__c != UserInfo.getUserId()){
                consent.addError( new myException('ERROR PLEASE CHECK THE USER'));
                return;
            }

            if(consent.Consent__c != oldMap.get(consent.id).Consent__c ){
                consent.Last_Consent__c = System.Now();
            }
         
        }       
    }
    public class MyException extends Exception {}

}