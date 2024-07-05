// Class to specify your default email field values and logic in the class. 
// Then in Setup, go to the Support Settings page. Select Enable Default Email Templates or the Default Handler for Email Action, and point to your new class.
global class ICX_Email_QuickActionDefaults implements QuickAction.QuickActionDefaultsHandler {

    // Empty constructor
    global ICX_Email_QuickActionDefaults() {
    }

    // The main interface method
    global void onInitDefaults(QuickAction.QuickActionDefaults[] defaults) {
        
        QuickAction.SendEmailQuickActionDefaults sendEmailDefaults = null;

        // Check if the quick action is the standard Case Feed send email action
        /*for (Integer j = 0; j < defaults.size(); j++) {
            if (defaults.get(j) instanceof QuickAction.SendEmailQuickActionDefaults && 
               defaults.get(j).getTargetSObject().getSObjectType() == 
                   EmailMessage.sObjectType && 
               defaults.get(j).getActionName().equals('Case.Email') && 
               defaults.get(j).getActionType().equals('Email')) {
                   sendEmailDefaults = 
                       (QuickAction.SendEmailQuickActionDefaults)defaults.get(j);
                   break;
            }
        }*/
        sendEmailDefaults = (QuickAction.SendEmailQuickActionDefaults)defaults.get(0);
        
        if (sendEmailDefaults != null && Schema.sObjectType.Case.isAccessible()) {
            String DPCARecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Digital_Private_CA').getRecordTypeId();
            Case currentCase = [SELECT Status, Reason, TECH_Queue__c, DefaultEmailTemplateId__c,DefaultEmailFromAddressId__c, contact.Email, SuppliedEmail,RecordTypeId FROM Case 
                      WHERE Id=:sendEmailDefaults.getContextId()];
            System.debug('ICX_Email_QuickActionDefaults>c=' + currentCase);
        
            if (currentCase != null) {
                ICX_Queue__mdt queueMetadata = getQueueMetadata(currentCase.TECH_Queue__c);

                EmailMessage emailMessage = (EmailMessage)sendEmailDefaults.getTargetSObject();
                // toAddress already predefined by Case.SendEmail action
                //emailMessage.toAddress = (String.isNotBlank(c.SuppliedEmail) ? c.SuppliedEmail : (c.contact != null && String.isNotBlank(c.contact.Email) ? c.contact.Email : ''));

                if (String.isNotBlank(currentCase.DefaultEmailFromAddressId__c))
                {
                    OrgWideEmailAddress fromAddress = [SELECT Address FROM OrgWideEmailAddress WHERE Id=:currentCase.DefaultEmailFromAddressId__c];
                    if(fromAddress!=null)
                    {

                        emailMessage.FromAddress =fromAddress.Address  ;
                        emailMessage.ValidatedFromAddress = fromAddress.Address ;
                    }
    
                }
                else if (queueMetadata != null && String.isNotBlank(queueMetadata.TargetEmail__c)) {
                    // From fields only works if the email is verified (email-to-case or org-wide address). So, works only in production or change the Metadata to match queue's email
                    emailMessage.FromAddress = queueMetadata.TargetEmail__c;
                    emailMessage.ValidatedFromAddress = queueMetadata.TargetEmail__c;
                }
               
                sendEmailDefaults.setTemplateId(//'00X3D000000eNEm');//'00X3D000000eELPUA2');//'00X3D000000eNEm');
                    getTemplateIdHelper(queueMetadata,currentCase.DefaultEmailTemplateId__c, currentCase.RecordTypeId == DPCARecordTypeId ? true : false)); // Louis_Vuitton_Client_Service_UK
                sendEmailDefaults.setInsertTemplateBody(true);
                sendEmailDefaults.setIgnoreTemplateSubject(false);
            }
            System.debug('sendEmailDefaults=' + sendEmailDefaults);
        }
            
            // Set bcc address to make sure each email goes for audit
            //emailMessage.BccAddress = 'test@est.com';//getBccAddress(c.Reason);

            /* 
            Set Template related fields 
            When the In Reply To Id field is null we know the interface 
            is called on page load. Here we check if 
            there are any previous emails attached to the case and load 
            the 'New_Case_Created' or 'Automatic_Response' template.
            When the In Reply To Id field is not null we know that 
            the interface is called on click of reply/reply all 
            of an email and we load the 'Default_reply_template' template
            */
 /*           if (sendEmailDefaults.getInReplyToId() == null) {
                Integer emailCount = [SELECT count() FROM EmailMessage 
                                      WHERE ParentId=:sendEmailDefaults.getContextId()];
                if (emailCount!= null && emailCount > 0) {
                    //sendEmailDefaults.setTemplateId(
                        //getTemplateIdHelper('Automatic_Response'));
                } else {
                    //    getTemplateIdHelper('New_Case_Created'));
//                    sendEmailDefaults.setTemplateId(
//                      getTemplateIdHelper('TEST'));
                }
                //sendEmailDefaults.setInsertTemplateBody(true);
                //sendEmailDefaults.setIgnoreTemplateSubject(false);
            } else {
                sendEmailDefaults.setTemplateId(
                    getTemplateIdHelper('Default_reply_template'));
                sendEmailDefaults.setInsertTemplateBody(false);
                sendEmailDefaults.setIgnoreTemplateSubject(true);

            }*/
    }
    
    public ICX_Queue__mdt getQueueMetadata(String queueDeveloperName) {
        ICX_Queue__mdt queueResult;
        System.debug('queueDeveloperName=' + queueDeveloperName);
        if (String.isNotBlank(queueDeveloperName)) {// && Schema.sObjectType.ICX_Queue__mdt.isAccessible()) {
            List<ICX_Queue__mdt> queueList = [SELECT Id, EmailTemplateDeveloperName__c,DPCA_Email_Template_DeveloperName__c, TargetEmail__c FROM ICX_Queue__mdt WHERE QueueDeveloperName__c = :queueDeveloperName];
            if (!queueList.isEmpty()) {
                queueResult = queueList.get(0);
            }
        }
        return queueResult;
    }

    @TestVisible
    private Id getTemplateIdHelper(ICX_Queue__mdt queue, String DefaultEmailTemplateId, Boolean isDPCA) {
        Id templateId = null;

        String emailTemplateDevName;
        try {
            emailTemplateDevName = getEmailTemplateDeveloperName(queue,DefaultEmailTemplateId,isDPCA);
            if (String.isNotBlank(emailTemplateDevName)) {
                templateId = [SELECT id, name FROM EmailTemplate 
                              WHERE developername = :emailTemplateDevName].id;
            }
        } catch (Exception e) {
            system.debug('Unble to locate EmailTemplate using name: ' + 
                emailTemplateDevName + ' refer to Setup | Communications Templates ');
        }
        System.debug('templateId=' + templateId);
        return templateId;
    }

    // nao new 
    public String getEmailTemplateDeveloperName(ICX_Queue__mdt queue,String emailTemplateId, Boolean isDPCA) {
        String emailTemplateDevName;
        
        //if (queue != null && String.isNotBlank(queue.EmailTemplateDeveloperName__c)) {
        if (String.isNotBlank(emailTemplateId)) {
                emailTemplateDevName = [SELECT DeveloperName FROM EmailTemplate WHERE Id=:emailTemplateId].DeveloperName;
            }
        else if (queue != null) {
            // Set a default Email Template when the Queue is empty
           emailTemplateDevName = isDPCA == false ? queue.EmailTemplateDeveloperName__c: queue.DPCA_Email_Template_DeveloperName__c;
            
        } 
        if(String.isBlank(emailTemplateDevName)) 
        {
             // Set a default Email Template when the Queue is empty
             emailTemplateDevName = IconicsSettings__c.getInstance().DefaultEmailTemplateDevName__c;

        }
        return emailTemplateDevName;
    }

    // nao old 
    // public String getEmailTemplateDeveloperName(ICX_Queue__mdt queue) {
    //     String emailTemplateDevName;
        
    //     //if (queue != null && String.isNotBlank(queue.EmailTemplateDeveloperName__c)) {
    //     if (queue == null) {
    //          // Set a default Email Template when the Queue is empty
    //         emailTemplateDevName = IconicsSettings__c.getInstance().DefaultEmailTemplateDevName__c;
    //     } else {
    //         // Set a default Email Template when the Queue is empty
    //        //emailTemplateDevName = IconicsSettings__c.getInstance().DefaultEmailTemplateDevName__c;
    //         emailTemplateDevName = queue.EmailTemplateDeveloperName__c;
    //     }
    //     return emailTemplateDevName;
    // }


/*
    private String getBccAddress(String reason) {
        if (reason != null && reason.equals('Technical')) 
            { return 'support_technical@mycompany.com'; } 
        else if (reason != null && reason.equals('Billing')) 
            { return 'support_billing@mycompany.com'; } 
        else { return 'support@mycompany.com'; }
    }
*/
}