/**
* @File Name          : TR_User_TriggerHandler.trigger
* @Description        : 
* @Author             : hamza.bouzid.ext@louisvuitton.com
* @Group              : 
* @Last Modified By   : hamza.bouzid.ext@louisvuitton.com
* @Last Modified On   : 13-01-2023
* @Modification Log   : 
* Ver       Date            Author      		                     Modification
* 1.0       13-01-2023       hamza.bouzid.ext@louisvuitton.com     Initial Version
**/
public class TR_User_TriggerHandler {
    public static void handleTrigger(List<User> newList, Map<Id, User> newMap, List<User> oldList, Map<Id, User> oldMap, System.TriggerOperation triggerEvent) {
        switch on triggerEvent {
            when BEFORE_INSERT{
                handleBeforeInsert(newList);
            }
            when BEFORE_UPDATE{
                handleBeforeUpdate(oldMap ,newList);
            }
            when AFTER_INSERT{
                handleAfterInsert(newList);
            }
            when AFTER_UPDATE{
                handleAfterUpdate(oldList ,newList, newMap, oldMap);
            }
            
        }
    }
    public static void handleBeforeInsert(List<User> newList) { 
        User_MultiStore_TRG.multiStoreInsert(newList);
        User_Identity_TRG.setTechFields(newList);
    }
    public static void handleBeforeUpdate(Map<Id, User> oldMap ,List<User> newList) {
        User_MultiStore_TRG.multiStoreUpdate(oldMap, newList);
        User_Identity_TRG.setTechFields(newList);
    }
    public static void handleAfterInsert(List<User> newList) { 
        PASS_TR01_ContactCreateDateID.ContactCreateDateID(newList);
        Map<String,Profile> profileMap = new Map<String,Profile>([Select Id From Profile Where Name Like '%ICON\_%']);
        List<String> usersToCG = new List<String>();
        for(User u : newList){
            if(profileMap.keySet().contains(u.ProfileId)){
                usersToCG.add(u.Id);
            }
        }
        if(usersToCG.size()>0){
            IM_UserToChatterGroup.AddUsertoCG(usersToCG);
        }
    }
    public static void handleAfterUpdate(List<User> oldList ,List<User> newList, Map<Id, User> newMap, Map<Id, User> oldMap) {
        UserTriggerHandler.handleAfterUpdate(newList, oldList, newMap, oldMap);
        Club_MemberShipTriggerHandler.handleAfterUserDeactivated(newList, oldMap);
    }
}