/*	 * @author Keman WU
* @date creation 15/06/2022
* @description Trigger Handler of AliasMemberTrigger 
*/
public class AliasMember_TriggerHandler {
    public static void beforeInsert(List<Alias_Member__c> newAliasMemberList, Map<id, Alias_Member__c> newAliasMemberMap) {
        for(Alias_Member__c myRecord : newAliasMemberList){           
            myRecord.Unique_ID__c = myRecord.Client__c +'-'+ myRecord.Alias__c;
        }
    }
}