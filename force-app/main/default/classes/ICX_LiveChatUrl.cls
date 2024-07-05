public with sharing class ICX_LiveChatUrl {
    @AuraEnabled
    public static String getData(Id recordId) {
        List<LiveChatTranscript> llst = [SELECT Entry_URL__c FROM LiveChatTranscript WHERE Id = :recordId];
        String s = '';
        if (!llst.isEmpty())
            s = llst[0].Entry_URL__c;
        if (String.isBlank(s)) 
            s = 'Unknown entry web site';
        return s;
    }
}