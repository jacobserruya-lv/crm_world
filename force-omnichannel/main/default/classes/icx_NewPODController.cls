global with sharing class icx_NewPODController {
   

   

    @AuraEnabled(cacheable=false)
    public static ProductCatalogue__c getProductDetails(Id recordId){
        try {

            return [SELECT Id,Name,SKU__c,Image1Url__c,SPO_Category__c FROM ProductCatalogue__c WHERE Id=:recordId LIMIT 1];
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getOptionValues(String selectedObject, String selectedField){
        
        List<String> picklistListResult = new  List<String>();

        DescribeSObjectResult objResult = Schema.getGlobalDescribe().get(selectedObject).getDescribe();
        DescribeFieldResult fieldResult = objResult.fields.getMap().get(selectedField).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple) {


            picklistListResult.add('{"label":"'+ f.getLabel()+'", "value" :"' + f.getValue()+'"}');



        }  
        System.debug('getPicklistValue picklistListResult : '+picklistListResult);
        return  picklistListResult;
    }


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
            }
            return results;

  
        } catch (Exception e) {
            System.debug('ERROR : ' + e.getMessage());
            return new List<Boolean> {false};
            // throw new AuraHandledException(e.getMessage());
        }
    }

  





}