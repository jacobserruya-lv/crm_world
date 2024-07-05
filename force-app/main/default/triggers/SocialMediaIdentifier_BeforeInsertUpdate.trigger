trigger SocialMediaIdentifier_BeforeInsertUpdate on Social_Media_Identifier__c (before insert, before update) {
  
  if(Trigger.isInsert) {
   // SM_TRG_SocialMediaIdentifier.setUniqueKeys(Trigger.new, true);
  }
  else {
    //SM_TRG_SocialMediaIdentifier.setUniqueKeys(Trigger.new, false);
  }
}