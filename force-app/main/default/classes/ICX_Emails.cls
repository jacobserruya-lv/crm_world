public with sharing class ICX_Emails  {
	
	// Function used also in ICX_IPDTransfer_CTL and ICX_Files

	@AuraEnabled
	public static List<EmailMessage> getEmails(Id recordId){
		string soql = 'Select Id, Subject, MessageDate, toLabel(Status), Has_Files__c,HasAttachment, Incoming From EmailMessage Where ';
        
        /*  Description: if on CareService record page, show emails related to the case which is linked to CareService
         * Modification: 08/07/2021 by Keman WU 
        */
         if (recordId.getSobjectType() == CareService__c.SobjectType)  
             soql+= 'parentId in (select id from case where My_Repairs__c=:recordId) ';
        else{
		soql += (recordId.getSobjectType() == Case.SobjectType)?'parentId':'relatedToId';
		soql+= '=:recordId ';
    }
        soql+= 'order by MessageDate Desc';
        system.debug(soql);
        List<EmailMessage> allEmails = Database.query(soql);
        List<String> lstStatus = new List<String>();
        if(allEmails.size()>0){            
        for(EmailMessage mail : [select Status from EmailMessage where id in:allEmails]){
            lstStatus.add(mail.Status);
        }
        if(!lstStatus.contains('0')){
        if(recordId.getSobjectType() == Case.SobjectType){
            //update case TECH_NewEmailReceived__c
             case currentCase = [select id,TECH_NewEmailReceived__c from case where id =:recordId ];
             currentCase.TECH_NewEmailReceived__c = false; 
             update currentCase;        
        }
        if(recordId.getSobjectType() == CareService__c.SobjectType){
            //update careService Has_Unread_Email__c
            CareService__c currentCareService = [select id,Has_Unread_Email__c from CareService__c where id =:recordId ];
            currentCareService.Has_Unread_Email__c = false;   
            update currentCareService;
        }     
            }
    }
		return Database.query(soql);
	}

}