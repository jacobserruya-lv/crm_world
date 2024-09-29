global with sharing class icx_podCreationAction {
    @InvocableMethod(label='Create POD')
    global static List<Id> podCreation(List<PODCreation> podToCreate) {
        try{
            List<Id> newRecordID = new List<Id>();
            if(!podToCreate.isEmpty())
            {

                for(PODCreation currentPodToCreate : podToCreate)
                {
                    System.debug('nao currentPodToCreate ' + currentPodToCreate );

                    Id recordId = (Id)currentPodToCreate.recordId;
                    String objectType = recordId.getSObjectType().getDescribe().getName();
                    System.debug(objectType+'UUUUUUUUUU');
                    if ('Case'.equalsIgnoreCase(objectType)) {
                        newRecordID.add(createPODFromCase(currentPodToCreate));
                    }
                    else if ('Task'.equalsIgnoreCase(objectType)) {
                        newRecordID.add(createPODFromTask(currentPodToCreate));
                    }
                    else if ('LiveChatTranscript'.equalsIgnoreCase(objectType)) {
                        newRecordID.add(createPODFromLiveChatTranscript(currentPodToCreate));
                    }
                    else if ('MessagingSession'.equalsIgnoreCase(objectType)) {
                        newRecordID.add(createPODFromMessagingSession(currentPodToCreate));
                        
                    }
                }
            }
            else{
                throw new PODCreationException('No POD to create.');

            }
            return newRecordID;
        }
     catch (Exception e) {
        throw new PODCreationException(e.getMessage());
    }
    }



    global class PODCreation {
        @InvocableVariable(required=true)
        global String recordId;
       
        @InvocableVariable(required=true)
        global String VarAccountId ;

        @InvocableVariable
        global String digitalStoreId;

        @InvocableVariable
        global String price;

        @InvocableVariable
        global String currencyValue;

        @InvocableVariable
        global String desiredDate;

        @InvocableVariable
        global String comment;

        @InvocableVariable
        global String contactPreference;



        @InvocableVariable
        global String selectedProductId;
    
        @InvocableVariable
        global Boolean hotSku;
    
        @InvocableVariable
        global String collection;
    
        @InvocableVariable
        global String gender;
    
        @InvocableVariable
        global String category;
    
        @InvocableVariable
        global String productDescription;
      }

    
      public class PODCreationException extends Exception {}


      //need to create record of ICX_ProductEnquired__c ? check with business if this object is used
      private static Id createPODFromCase(PODCreation currentPodToCreate)
      {
        Case currentCase = [SELECT Id,AccountId,ContactId,Origin,TECH_Country__c FROM Case WHERE Id=:currentPodToCreate.recordId];
        Id accountId = String.isNotBlank(currentCase.AccountId) ? currentCase.AccountId : currentPodToCreate.VarAccountId;
        Id newPODId = createPodRecord(currentPodToCreate.selectedProductId, accountId, currentPodToCreate.collection, currentPodToCreate.comment, currentCase.ContactId, currentPodToCreate.contactPreference, currentPodToCreate.CurrencyValue, currentPodToCreate.desiredDate, currentPodToCreate.HotSKU,  currentCase.Origin, currentCase.Id, currentPodToCreate.Category, currentPodToCreate.Gender, currentPodToCreate.Price,currentPodToCreate.productDescription, currentPodToCreate.digitalStoreId, currentCase.TECH_Country__c);
      
        return newPODId;
    }

      private static Id createPODFromTask(PODCreation currentPodToCreate)
      {
        Task currentTask = [SELECT Id,AccountId,WhoId,ICX_Country__c FROM Task WHERE Id=:currentPodToCreate.recordId];
        Id accountId = String.isNotBlank(currentTask.AccountId) ? currentTask.AccountId : currentPodToCreate.VarAccountId;
        Id newPODId = createPodRecord(currentPodToCreate.selectedProductId, accountId, currentPodToCreate.collection, currentPodToCreate.comment, currentTask.WhoId, currentPodToCreate.contactPreference, currentPodToCreate.CurrencyValue, currentPodToCreate.desiredDate, currentPodToCreate.HotSKU,  'Phone', null, currentPodToCreate.Category, currentPodToCreate.Gender, currentPodToCreate.Price,currentPodToCreate.productDescription, currentPodToCreate.digitalStoreId, currentTask.ICX_Country__c);

        currentTask.WhatId =newPODId;
        update currentTask;
        return newPODId;
      }
      private static Id createPODFromLiveChatTranscript(PODCreation currentPodToCreate)
      {
        LiveChatTranscript currentLiveChatTranscript = [SELECT Id,AccountId,ContactId,Country__c FROM LiveChatTranscript WHERE Id=:currentPodToCreate.recordId];
        Id newPODId = createPodRecord(currentPodToCreate.selectedProductId, currentLiveChatTranscript.AccountId, currentPodToCreate.collection, currentPodToCreate.comment, currentLiveChatTranscript.ContactId, currentPodToCreate.contactPreference, currentPodToCreate.CurrencyValue, currentPodToCreate.desiredDate, currentPodToCreate.HotSKU,  'Social', null, currentPodToCreate.Category, currentPodToCreate.Gender, currentPodToCreate.Price,currentPodToCreate.productDescription, currentPodToCreate.digitalStoreId, currentLiveChatTranscript.Country__c);
        currentLiveChatTranscript.CaseId = newPODId;
        update currentLiveChatTranscript;
        return newPODId;
      }
      private static Id createPODFromMessagingSession(PODCreation currentPodToCreate)
      {
        MessagingSession currentMessagingSession = [SELECT Id,EndUserAccountId,EndUserContactId,Country__c FROM MessagingSession WHERE Id=:currentPodToCreate.recordId];
        Id accountId = String.isNotBlank(currentMessagingSession.EndUserAccountId) ? currentMessagingSession.EndUserAccountId : currentPodToCreate.VarAccountId;
        Id newPODId = createPodRecord(currentPodToCreate.selectedProductId, accountId, currentPodToCreate.collection, currentPodToCreate.comment, currentMessagingSession.EndUserContactId, currentPodToCreate.contactPreference, currentPodToCreate.CurrencyValue, currentPodToCreate.desiredDate, currentPodToCreate.HotSKU,  null, null, currentPodToCreate.Category, currentPodToCreate.Gender, currentPodToCreate.Price,currentPodToCreate.productDescription, currentPodToCreate.digitalStoreId, currentMessagingSession.Country__c);
        currentMessagingSession.CaseId = newPODId;
        system.debug('chegei akiiiiiiiiiiiiiiii');
        List<MessagingSession> messList = [SELECT MessagingEndUserId FROM MessagingSession WHERE Id = :currentPodToCreate.recordId ];
        if (!messList.isEmpty()) {
            MessagingEndUser mess = new MessagingEndUser();
            mess.Id = messList[0].MessagingEndUserId;
           // mess.ContactId = ;
            mess.AccountId = currentPodToCreate.VarAccountId;
            update mess;
        }    
        update currentMessagingSession;
        return newPODId;
      }

      private static Id createPodRecord(String selectedProductId, String AccountId, String Collection, String Comment, String ContactId, String contactPreference, String CurrencyValue, String desiredDate, Boolean HotSKU,  String Origin,String ParentId,  String Category, String Gender, String Price,String productDescription, String digitalStoreId, String Country)
      {
        Case PODcase = new Case(AccountId = AccountId, Collection__c=Collection,Comment__c=Comment,ContactId = ContactId, Contact_preference_from_client__c = contactPreference, Currency__c = CurrencyValue, Hot_Sku__c = HotSKU!=null ? HotSKU : false, Origin = Origin,ParentId = ParentId, PoD_Category__c = Category, PoD_Gender__c = Gender, Price__c =String.isNotBlank(Price)? decimal.valueOf(Price) : null, Product_Sku__c= String.isNotBlank(selectedProductId) ? (Id)selectedProductId : null, Product_Sku_unknown__c = productDescription, Store__c = String.isNotBlank(digitalStoreId)? (Id)digitalStoreId : null, TECH_Country__c = Country);

        if(String.isNotBlank(selectedProductId))
        {
            PODcase.RecordTypeId = SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Product_On_Demand_with_sku').getRecordTypeId();
            PODcase.Status = 'Follow-up';

            ProductCatalogue__c currentProductCatalog = [Select Id, Name FROM ProductCatalogue__c WHERE Id=: selectedProductId];
            PODcase.Subject ='Product on Demand - ' + currentProductCatalog?.Name ;
        }
        else
        {
            PODcase.RecordTypeId  = SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Product_on_Demand_without_sku').getRecordTypeId();
            PODcase.Status = 'New';
            PODcase.Subject ='Product on Demand without sku - ' + productDescription;


        }
        if (String.isNotBlank(desiredDate))
        {

            PODcase.Desired_date_for_the_product__c = Date.newInstance(Integer.valueOf(desiredDate.split('-')[0]), Integer.valueOf(desiredDate.split('-')[1]), Integer.valueOf(desiredDate.split('-')[2]));
        }


        insert PODcase;
        return PODCase.Id;

      }


}