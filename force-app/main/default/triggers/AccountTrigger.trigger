trigger AccountTrigger on Account(
  before insert,
  before update,
  after update,
  after insert,
  after delete
) {
  IC_PersonAccount_TRG.handleTrigger(
    Trigger.new,
    Trigger.newMap,
    Trigger.old,
    Trigger.oldMap,
    Trigger.operationType
  );

  //ICONICS Trigger Handler
  if (Trigger.isInsert && Trigger.isBefore) {
    ICX_Account_TriggerHandler.beforeInsert(Trigger.new, Trigger.newMap);
  } else if (Trigger.isUpdate && Trigger.isBefore) {
    ICX_Account_TriggerHandler.beforeUpdate(
      Trigger.new,
      Trigger.newMap,
      Trigger.old,
      Trigger.oldMap
    );
  } else if (Trigger.isUpdate && Trigger.isAfter) {
    Club_MemberShipTriggerHandler.handleAfterAccountUpdate(Trigger.new, Trigger.oldMap);
  }
}