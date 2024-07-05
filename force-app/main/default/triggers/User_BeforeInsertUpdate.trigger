/**
* ALL triggers centralized in TR_User_Trigger.trigger
* @Author             : hamza.bouzid.ext@louisvuitton.com
* @Last Modified By   : hamza.bouzid.ext@louisvuitton.com
* @Last Modified On   : 19-09-2023  
**/
trigger User_BeforeInsertUpdate on User(before insert, before update) {
  /*if (Trigger.isInsert) {
    User_MultiStore_TRG.multiStoreInsert(Trigger.new);
    User_Identity_TRG.setTechFields(Trigger.new);
  } else if (Trigger.isUpdate) {
    User_MultiStore_TRG.multiStoreUpdate(Trigger.oldMap, Trigger.new);
    User_Identity_TRG.setTechFields(Trigger.new);
    Club_MemberShipTriggerHandler.handleBeforeUserDeactivated(
      Trigger.new,
      Trigger.oldMap
    );
  }*/
}