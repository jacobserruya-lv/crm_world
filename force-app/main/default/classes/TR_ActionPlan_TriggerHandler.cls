/**
* @File Name          : TR_C360Integration_TriggerHandler.trigger
* @Description        : 
* @Author             : hamza.bouzid.ext@louisvuitton.com
* @Group              : 
* @Last Modified By   : hamza.bouzid.ext@louisvuitton.com
* @Last Modified On   : 16-09-2022
* @Modification Log   : 
* Ver       Date            Author      		                     Modification
* 1.0       16-09-2022       hamza.bouzid.ext@louisvuitton.com     Initial Version
**/
public class TR_ActionPlan_TriggerHandler {
    public static void handleTrigger(List<ActionPlan__c> newList, Map<Id, ActionPlan__c> newMap, List<ActionPlan__c> oldList, Map<Id, ActionPlan__c> oldMap, System.TriggerOperation triggerEvent) {
        switch on triggerEvent {
            when BEFORE_INSERT{
                handleBeforeInsert(newList);
            }
            when BEFORE_UPDATE{
                handleBeforeUpdate(oldMap ,newList);
            }
            
        }
    }
    public static void handleBeforeInsert(List<ActionPlan__c> newList) { 
       System.debug(IC_Utils.canTrigger('BANNEDWORDS'));
       If (IC_Utils.canTrigger('BANNEDWORDS')) {
            List<String> bannedWords = IC_BannedWords.checkWords(newList, 'ActionPlan__c');
            if(!bannedWords.isEmpty())
                newList[0].addError(String.format(Label.IC_Banned_Words_Message, new String[] {String.join(bannedWords,', ')}));
        }
    }
    public static void handleBeforeUpdate(Map<Id, ActionPlan__c> oldMap ,List<ActionPlan__c> newList) {
        If (IC_Utils.canTrigger('BANNEDWORDS')) {
            List<String> bannedWords = IC_BannedWords.checkWords(newList, 'ActionPlan__c');
            if(!bannedWords.isEmpty())
                newList[0].addError(String.format(Label.IC_Banned_Words_Message, new String[] {String.join(bannedWords,', ')}));
        }
    }
}