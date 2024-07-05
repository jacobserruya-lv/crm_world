trigger Account_BeforeUpdate on Account (before update) {
    /*If (IC_Utils.canTrigger('ACCOUNT_MANUAL_CHANGE')) {
        IC_PersonAccount_TRG.checkManuallyChange(Trigger.new, Trigger.oldMap);
    }
    If (IC_Utils.canTrigger('ACCOUNT')) {
        IC_PersonAccount_TRG.checkSAId(Trigger.new, Trigger.oldMap);
        IC_PersonAccount_TRG.updateAnniversaryFields(Trigger.new, Trigger.oldMap);
        If (IC_Utils.canTrigger('PROSPECT')){
          IC_PersonAccount_TRG.manageProspectBySettingField(Trigger.new);
        //   IC_PersonAccount_TRG.manageProspect(Trigger.new);
        }
    }
    If (IC_Utils.canTrigger('ACCOUNT_LASTMODIFIEDCOUNTRY')) {
        IC_PersonAccount_TRG.updateLastModifiedCountry(Trigger.new,Trigger.oldMap);
    }
    If (IC_Utils.canTrigger('BANNEDWORDS')) {
        List<String> bannedWords = IC_BannedWords.checkWords(Trigger.new, 'Account');
        if(!bannedWords.isEmpty())
            Trigger.new[0].addError(String.format(Label.IC_Banned_Words_Message, new String[] {String.join(bannedWords,',')}));
    }
    
    IC_PersonAccount_TRG.anonymizeUser(Trigger.new);*/
}