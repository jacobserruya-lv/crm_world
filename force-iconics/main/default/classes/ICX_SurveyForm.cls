public with sharing class ICX_SurveyForm {
  
    @AuraEnabled(cacheable=true)
    public static  Object getSurveyFormResult(String recordId){ 
        
        try{
            System.debug('getSurveyFormResult recordId : '+recordId);
            String feedbackId = [SELECT Id, FeedbackID__c
                                 FROM VO_Survey__c 
                                 WHERE Id =:recordId][0].FeedbackID__c;

            System.debug('getSurveyFormResult feedbackId : '+feedbackId);

            String result = ICX_WS_SurveyForm.getSurveyForm(feedbackId);
            system.debug('getSurveyFormResult result : ' + result);
            
            Map<String,Object> surveyForm = (Map<String,Object>) JSON.deserializeUntyped(result);
            system.debug('getSurveyFormResult surveyForm : ' + surveyForm);
            
            Map<String,Object> dataFromSurvey =  (Map<String,Object>) surveyForm.get(ICX_SurveyFormWrapper.VOICE_API_RESULT_DATA);
            system.debug('getSurveyFormResult dataFromSurvey : ' + dataFromSurvey);
            
            Map<String,Object> attributeFromData =  (Map<String,Object>) dataFromSurvey.get(ICX_SurveyFormWrapper.VOICE_API_RESULT_ATTRIBUTES);
            system.debug('getSurveyFormResult attribuFromData : ' + attributeFromData);

            return attributeFromData;
            
        }  catch(Exception error) {
            system.debug('getSurveyFormResult error :   ' +error);
            return error;                    
        }

    }

    @AuraEnabled
    public static Object getTransactionProduct(String transactionId, String dreamIdClient){
        try {
            PPR_PurchProduct__c myTransactionInSF = [SELECT TransactionRMSId__c,
                                                            Name, 
                                                            SKU__c, 
                                                            CreatedDate, 
                                                            CAName__c,
                                                            Image_Url__c
                                                    FROM PPR_PurchProduct__c
                                                    WHERE TransactionRMSId__c = :transactionId
                                                    AND DREAMIdClient__c = :dreamIdClient
                                                    LIMIT 1][0];
            system.debug('getTransationInSF myTransactionInSF :   ' +myTransactionInSF);
                                                    
            Map<String,String> transactionMapped = new Map<String,String> {
                'productName' => myTransactionInSF.Name,
                'productSku' => myTransactionInSF.SKU__c,
                'purchaseDate' => myTransactionInSF.CreatedDate.format(),
                'CAName' => myTransactionInSF.CAName__c,
                'imageUrl' => myTransactionInSF.Image_Url__c
            };

            system.debug('getTransationInSF transactionMapped :   ' +transactionMapped);

            return transactionMapped;
            
        } catch (Exception error) {
            system.debug('getTransationInSF error :   ' +error);
            return error;                    
        }
    }

    @AuraEnabled
    public static string getVoiceLanguageUser(){
        String userLanguage = UserInfo.getLanguage();
        system.debug(userLanguage);

        String voiceLanguage = [SELECT id, Salesforce_Language__c, VoiceAPILanguages__c 
                                 FROM    CountryLanguage__c 
                                 WHERE   Salesforce_Language__c =:userLanguage][0]?.VoiceAPILanguages__c;
                                    
        system.debug(voiceLanguage);
        return voiceLanguage;
    }

}