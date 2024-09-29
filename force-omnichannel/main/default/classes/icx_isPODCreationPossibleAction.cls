public with sharing class icx_isPODCreationPossibleAction {
    @InvocableMethod(label='isPODCreationPossibleAction')
    public static List<Boolean> isPODCreationPossibleAction(List<Id> recordIdList){
        try {
            List<Boolean> results = new List<Boolean>();
            if(!recordIdList.isEmpty())
            {
                for(Id recordId:recordIdList)
                {

                    
                    if(recordId!=null)
                    {
                        
                        String objectType = recordId.getSObjectType().getDescribe().getName();
                        
                        if ('Case'.equalsIgnoreCase(objectType)) {
                            Case currentCase = [SELECT Type,Category__c FROM Case WHERE Id =:recordId];
                            results.add(currentCase!=null ? currentCase.Type!=null && currentCase.Category__c!=null ? true : false : false);
                        }
                        else if ('Task'.equalsIgnoreCase(objectType)) {
                            Task currentTask = [SELECT Nature__c,Category__c FROM Task WHERE Id =:recordId];
                            results.add(currentTask!=null ? currentTask.Nature__c!=null && currentTask.Category__c!=null ? true : false : false);
                        }
                        else if ('LiveChatTranscript'.equalsIgnoreCase(objectType)) {
                            LiveChatTranscript currentLiveChatTranscript = [SELECT Nature__c,Category__c FROM LiveChatTranscript WHERE Id =:recordId];
                            results.add(currentLiveChatTranscript!=null ? currentLiveChatTranscript.Nature__c!=null && currentLiveChatTranscript.Category__c!=null ? true : false : false);
                        }
                        else if ('MessagingSession'.equalsIgnoreCase(objectType)) {
                            MessagingSession currentMessagingSession = [SELECT Nature__c,Category__c FROM MessagingSession WHERE Id =:recordId];
                            results.add(currentMessagingSession!=null ? currentMessagingSession.Nature__c!=null && currentMessagingSession.Category__c!=null ? true : false : false);
                            
                        }
                        else if ('Account'.equalsIgnoreCase(objectType)) {
                            results.add(true);
                        }
                    }
                }
                return results;
            }
            else{
                throw new PODCreationPossibleException('No record detected.');

            }

  
        } catch (Exception e) {
        
            throw new PODCreationPossibleException(e.getMessage());
        }
    }

    public class PODCreationPossibleException extends Exception {}

}