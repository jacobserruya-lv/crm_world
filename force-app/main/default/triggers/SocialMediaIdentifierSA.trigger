trigger SocialMediaIdentifierSA on Social_Media_Identifier_CA__c (before insert, before update) {
    SM_TRG_SocialMediaIdentifier.setUniqueKeysSMI_SA(Trigger.new);
}