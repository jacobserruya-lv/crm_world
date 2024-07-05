trigger ActionPlan_BeforeUpdate on ActionPlan__c (before update) {
	/*
    If (IC_Utils.canTrigger('BANNEDWORDS')) {
        List<String> bannedWords = IC_BannedWords.checkWords(Trigger.new, 'ActionPlan__c');
        if(!bannedWords.isEmpty())
            Trigger.new[0].addError(String.format(Label.IC_Banned_Words_Message, new String[] {String.join(bannedWords,', ')}));
    }
*/
}