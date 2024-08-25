/**
* @Description:
* Apex controller of ICX_caseCreationFromTask lightning component
* Handles the creation of a case when user clicks on "Create Request" button 
*
* @Modification history:
**/
public with sharing class ICX_CaseCreationFromTask_CTRL {
    

    
    @AuraEnabled
    /**
    * @Description: if task is not related to a case then create a case based on task information 
    * and related the task to the newly created case
    * @Param:
    * taskID = id of the task
    * @Return:
    * return the case id if it has been created or an error message if 
    * - there is already a case link to this task
    * - some mandatory fields are empty
    **/
    public static String createCase(String taskID)    
    {    
        // get task information
        Task ta = [SELECT id, Accountid, Category__c, Whatid, Whoid, Country__c, Description,
                    Domaine__c, CreatedById, Product_SKU__c, Product_SKU_Unknown__c,
                    Subject, Nature__c, Transaction_Id__c, Phone_Number__c, Resolution__c
                    from Task where id=:taskID LIMIT 1];
		// if task is already related to a case then there is nothing to do. 
        if(ta.WhatId != null && String.valueof(ta.whatId).startsWith('500'))
        {
			return 'ERROR_CASE_EXIST';          
        }
        else if(String.isBlank(ta.AccountId) || String.isBlank(ta.Resolution__c) )
        {
            return 'ERROR_MISSING_REQUIRED_FIELDS';
        }
        // if there is no related case then create one
        else
        {
            // get Call task record type
            Id callRecordTypeID;
            RecordTypeInfo recordTypeCall = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Call_Case');
            if (recordTypeCall != null) {
                callRecordTypeID = recordTypeCall.getRecordTypeId();
            }

            // create a case based on task information
            Case newCase = New Case(
                AccountId = ta.Accountid,
                Category__c =  ta.Category__c,
                ContactId = ta.Whoid,
                Country__c = ta.Country__c,
                Description = ta.Description,
                Domaine__c = ta.Domaine__c,
                Origin = 'Phone',
                OwnerId = ta.CreatedById,
                Product_SKU__c = ta.Product_SKU__c,
                Product_Sku_unknown__c = ta.Product_SKU_Unknown__c,
                RecordTypeId = callRecordTypeID,
                Subject = ta.Subject,
                Type = ta.Nature__c,
                Transaction_Id__c = ta.Transaction_Id__c,
                SuppliedPhone = ta.Phone_Number__c
            );
            insert newCase;
            
            //relate task to the newly created case
            ta.whatid = newCase.id;
            update ta; 
             
            return newCase.id;  
        }
    }
  

}