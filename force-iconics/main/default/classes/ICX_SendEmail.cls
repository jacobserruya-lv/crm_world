/** Class Name  : ICX_SendEmail
*  Description  : This class used to sending the email messages to Client used in the ICX_EmailComposer Lightning Component
*  
*  --------------------------------------------------------------------------------------------------------------------------------------
*   Developer                Date                   Modification ID      Description 
*  ---------------------------------------------------------------------------------------------------------------------------------------
**/
public class ICX_SendEmail {
    
    @AuraEnabled 
    public static Boolean sendMailMethod(String instance){
        System.debug('instance '+ instance);
        JSONParser parser = JSON.createParser(instance);
        ICX_SendEmail.EmailInstance emailMessageInstance = (ICX_SendEmail.EmailInstance) parser.readValueAs(ICX_SendEmail.EmailInstance.class);
        System.debug('js '+ emailMessageInstance);
        
        ID caseId = emailMessageInstance.requestRecordId;
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();  
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();        
        
        mail.setToAddresses(emailMessageInstance.emailToAddresses);  
        mail.setBccAddresses(emailMessageInstance.emailBccAddresses);   
        mail.setCcAddresses(emailMessageInstance.emailCcAddresses); 
        mail.setSubject(emailMessageInstance.emailSubject);
        String objectType = emailMessageInstance.requestRecordId.getSObjectType().getDescribe().getName();
        if ('Case'.equalsIgnoreCase(objectType)) {
            mail.setWhatId(emailMessageInstance.requestRecordId);
            // Avoid Single Email limitation : https://help.salesforce.com/articleView?language=en_US&type=1&mode=1&id=000323568
            // KO : SendEmail failed. First exception on row 0; first error: INVALID_SAVE_AS_ACTIVITY_FLAG, saveAsActivity must be false when sending mail to users.: [saveAsActivity, true]
            //mail.setTargetObjectId(UserInfo.getUserId());
            
            //set tech Queue on Case if emailFromAddress is a queue Email 
            //setQueue(emailMessageInstance.emailFromAddress,emailMessageInstance.requestRecordId);
            
            //set tech Queue on Case if emailFromAddress is a queue Email and Email Template default
            setQueueAndTemplate(emailMessageInstance.emailFromAddress, emailMessageInstance.emailTemplate?.Id, emailMessageInstance.requestRecordId);
            
        }else if('Alias__c'.equalsIgnoreCase(objectType)){
            mail.setWhatId(emailMessageInstance.requestRecordId);
            
        }else if('CareService__c'.equalsIgnoreCase(objectType)){
            /*  Description: if on CareService record page, create a case linked to CareService and link all sent emails from CareService page to this case
            *   Modification: 12/07/2021 by Keman WU 
            */          
            CareService__c cs = (CareService__c)getRecord(emailMessageInstance.requestRecordId);
            mail.setTargetObjectId(cs.client__r.PersonContactId);
            List<Case> exixstentCase = [select id, recordtype.DeveloperName,My_Repairs__c from case where My_Repairs__c =:emailMessageInstance.requestRecordId and recordtype.DeveloperName='Care_Service' Limit 1 ];
            if(exixstentCase.size()>0){
                mail.setWhatId(exixstentCase[0].id);
                system.debug('exixstent Case attach to CareService : '+exixstentCase[0].id);
                caseId = exixstentCase[0].id;
            }else{
                Case newCase = new Case();            
                newCase.recordtypeid = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Care_Service').getRecordTypeId();
                newCase.My_Repairs__c = emailMessageInstance.requestRecordId;         
                newCase.AccountId = cs.Client__c;
                newCase.DefaultEmailTemplateId__c = emailMessageInstance.emailTemplate?.Id;
                newCase.DefaultEmailFromAddressId__c =  emailMessageInstance.emailFromAddress.startsWith('0D2') ? emailMessageInstance.emailFromAddress : null;
                insert newCase;

                system.debug('new case attach to CareService : '+newCase.id);
                caseId = newCase.id; // NI-2694
                mail.setWhatId(newCase.id);
            }
            
        }else if('Family_Member__c'.equalsIgnoreCase(objectType)){
            Family_Member__c fm = (Family_Member__c)getRecord(emailMessageInstance.requestRecordId);
            mail.setTargetObjectId(fm.client__r.PersonContactId);
            mail.setWhatId(emailMessageInstance.requestRecordId);
            
        }else if('Account'.equalsIgnoreCase(objectType)){
            Account acc = (Account)getRecord(emailMessageInstance.requestRecordId);
            mail.setTargetObjectId(acc.PersonContactId);
            mail.setWhatId(emailMessageInstance.requestRecordId);
            /*  Description: Create Case if is remote consent email
             *  Modification: 17/10/2023 by Haim AMZALLAG
             */   
            if(emailMessageInstance.isRemoteConsent != null && emailMessageInstance.isRemoteConsent){
                Id contactId = [SELECT PersonContactId FROM Account WHERE Id = :emailMessageInstance.requestRecordId].PersonContactId;
                Case newCase = new Case();  
                newCase.Origin = 'Email';
                newCase.Subject = mail.getSubject();
														   
													  
																 
                newCase.recordtypeid = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Remote_Consent').getRecordTypeId();    
                newCase.AccountId = emailMessageInstance.requestRecordId; 
                newCase.ContactId = contactId; 

                newCase.DefaultEmailTemplateId__c = emailMessageInstance.emailTemplate?.Id;
                newCase.DefaultEmailFromAddressId__c =  emailMessageInstance.emailFromAddress.startsWith('0D2') ? emailMessageInstance.emailFromAddress : null;
                insert newCase;


                System.debug('new case attach to Remote Consent : '+newCase.id);
                caseId = newCase.Id;
                mail.setWhatId(caseId);
                mail.setSaveAsActivity(true);
            }
        }
        system.debug('caseId : '+caseId);
        
        String htmlBodyResult = previewEmail((emailMessageInstance.emailTemplate != null ? emailMessageInstance.emailTemplate.Id : null), 
                                             emailMessageInstance.emailBody, 
                                             caseId, 
                                             emailMessageInstance.emailSignature);
       htmlBodyResult = formatImageInEmailBody(htmlBodyResult);
        mail.setHtmlBody(htmlBodyResult);
        if (String.isNotBlank(emailMessageInstance.emailBody)) {
            String textMessage = emailMessageInstance.emailBody + (String.isNotBlank(emailMessageInstance.emailSignature) ? '<br/>' + emailMessageInstance.emailSignature : '<br/>'+ referenceId(caseId));
            mail.setPlainTextBody(textMessage.stripHtmlTags());
        }
        
        //mail.setHtmlBody(emailMessageInstance.emailBody);
        //mail.setTemplateId('00X3D000000eELPUA2');
        //
        //---***Start By Keman 26/09/2023 , if email is sent from Account Page, attache file to email message
        if('Account'.equalsIgnoreCase(objectType)){
            List<ContentVersion> ListOfFiles = [SELECT Id, VersionData, Title, FileExtension, ContentSize, ContentDocumentId FROM ContentVersion WHERE isLatest = true AND ContentDocumentId IN :emailMessageInstance.emailattachments];
            Set<Id> ContentVersionIdSet = (new Map<Id,SObject>(ListOfFiles)).keySet();
            List<Id> ContentVersionIdList = new List<Id>(ContentVersionIdSet);        
            mail.setEntityAttachments(ContentVersionIdList);
        }else{
            // if email is not sent from Account Page, attache file to email message
            mail.setFileAttachments(contentDocumentAsAttachement(emailMessageInstance.emailattachments));
        }
        //---***End By Keman 26/09/2023

        //emailMessageInstance.emailFromAddress.startsWith('0D2') if email send from generic email address
        if (emailMessageInstance.emailFromAddress.startsWith('0D2')) {
            mail.setOrgWideEmailAddressId(emailMessageInstance.emailFromAddress);
        } else {
            mail.setSenderDisplayName(emailMessageInstance.emailFromAddress);
        }
        mails.add(mail);
        
        try { 
            Messaging.SendEmailResult[] resultList = Messaging.sendEmail(mails);
            // only one email is sent
            //for (Messaging.SendEmailResult sendEmail : resultList) {
            if (resultList[0].isSuccess()) {
                return true;
            } else {
                String errMsg = '';
                for (Messaging.SendEmailError errorMessaging : resultList[0].getErrors()) {
                    errMsg += errorMessaging.getMessage();
                }
                throw new AuraHandledException(errMsg);
            }
            //}
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());   
        } 
    }
    
    @TestVisible private static List<Messaging.EmailFileAttachment> contentDocumentAsAttachement(List<Id> contentDocumentIds) {
        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>{};
            List<ContentVersion> documents  = new List<ContentVersion>{};
                Boolean isBigFile = FALSE;
        
        //CheckifBig file here if not query throw LOB Fields exception
        List <ContentVersion> ListCvTestBigFile = [SELECT Id, Title, ContentSize, ContentDocumentId FROM ContentVersion WHERE isLatest = true AND ContentDocumentId IN :contentDocumentIds];
        for (ContentVersion var : ListCvTestBigFile) {
            if(var.ContentSize >= 3000000)
                isBigFile = TRUE;
        }
        
        if(isBigFile)
        {
            List<ContentDistribution> cdLst = new List<ContentDistribution>();
            List<Id> cdLstId = new List<Id>();
            
            for (ContentVersion var : ListCvTestBigFile) {
                //Big file => create link
                ContentDistribution cd = new ContentDistribution();
                
                // ID of convertVersion => attachments
                cd.Name = 'Cd ' + var.id;
                cd.ContentVersionId = var.id;
                cd.PreferencesAllowViewInBrowser= true;
                cd.PreferencesLinkLatestVersion=true;
                cd.PreferencesNotifyOnVisit=false;
                cd.PreferencesPasswordRequired=false;
                cd.PreferencesAllowOriginalDownload= true;
                cdLst.add(cd);
            }
            insert cdLst;
            
            for (ContentDistribution varId : cdLst) {
                cdLstId.add(varId.id);
            }
            
            //GET LINKS
            List<ContentDistribution> cd1 = [select id, ContentDownloadUrl, DistributionPublicUrl, ContentVersion.Title from ContentDistribution where id =: cdLstId];
            
            //SET ATTACHEMENT
            for (ContentDistribution varCd : cd1) {   
                Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                attachment.setBody(Blob.valueOf('<html><head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8"><meta http-equiv="Refresh" content="0; URL=' + varCd.DistributionPublicUrl + '"></head><body><div>Attachment not opening? Click this link: <a href="' + varCd.DistributionPublicUrl + '">' + varCd.ContentVersion.Title + '</a></div></html>' + ''));
                attachment.setFileName( varCd.ContentVersion.Title+ '.htm');
                attachments.add(attachment);
            }
            return attachments;
        }
        else {
            documents.addAll([
                SELECT Id, Title, FileType, VersionData, isLatest, ContentDocumentId,FileExtension
                FROM ContentVersion
                WHERE isLatest = true AND ContentDocumentId IN :contentDocumentIds
            ]);
            
            for (ContentVersion document: documents) {
                Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                attachment.setBody(document.VersionData);
                attachment.setFileName(document.Title+'.' + document.FileExtension);
                attachments.add(attachment);
            }
            return attachments;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<FromEmailAddress> searchFromEmail(String searchKey){
		String likeValue = '%'+searchKey+'%';									 
        List<FromEmailAddress> listfromEmail = new List<FromEmailAddress>();
		
        listfromEmail.add(new FromEmailAddress(UserInfo.getName(), UserInfo.getUserEmail(), UserInfo.getUserId()));
      List<OrgWideEmailAddress> myowea = [Select Id ,DisplayName,Address FROM OrgWideEmailAddress WHERE Address LIKE :likeValue];
       
        for (OrgWideEmailAddress email : myowea) {
            String label = email.DisplayName;
            String value = '' + email.Address;
            listfromEmail.add( new FromEmailAddress(label ,value,email.Id));
        }

        return listfromEmail;    
    }
    
    @AuraEnabled(cacheable=true)
    public static List<FromEmailAddress> allFromEmailOptions(){
        List<FromEmailAddress> listfromEmail = new List<FromEmailAddress>();
        listfromEmail.add(new FromEmailAddress(UserInfo.getName(), UserInfo.getUserEmail(), UserInfo.getUserId()));
        List<OrgWideEmailAddress> owea = [Select Id, DisplayName, Address From OrgWideEmailAddress];
        
        for (OrgWideEmailAddress email : owea) {
            String label = email.DisplayName;
            String value = '' + email.Address;
            listfromEmail.add( new FromEmailAddress(label ,value,email.Id));
        }
        
        return listfromEmail;    
    }
    
    @AuraEnabled 
    public static Boolean remoteConsentAccess(){
        String UserRoleId = [SELECT UserRoleId From User WHERE Id = :UserInfo.getUserId()][0].UserRoleId;
        String roles = IconicsSettings__c.getOrgDefaults().ICX_RemoteConsentRoleAccess__c;
        if(String.isNotBlank(roles)){
            List<String> rolesList = roles.split(';');
            System.debug('Remote Consent Access: '+ rolesList.contains(UserRoleId));
            return rolesList.contains(UserRoleId);
        }
        return false;
    }
    
    public class FromEmailAddress {
        @AuraEnabled
        public String label {get; set;}
        @AuraEnabled
        public String email {get; set;}
        @AuraEnabled
        public Id id {get; set;}
        @AuraEnabled
        public String name {get; set;}
        
        public FromEmailAddress(String name ,String email ,Id id){
            this.label = name + ' <' + email + '>';
            this.name = name ;
            this.email = email ;
            this.id =  id ;
        }
        
    }
    
    @auraEnabled
    public static EmailMessageWrapper getDefaultReplyEmail(Id recordId) {
        sObject record = getRecord(recordId);
        String queueDeveloperName;
        String countryIso3code;
        String toAddress;    
        String defaultRecordId;    
        String emailTemplateId;
        String fromAddressId;
        String DPCARecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Digital_Private_CA').getRecordTypeId();
        Boolean isDPCA = false;
        
        ICX_Email_QuickActionDefaults emailDefault = new ICX_Email_QuickActionDefaults();
        if (record instanceof Case) {
            Case cas = (Case) record;
            queueDeveloperName = cas.TECH_Queue__c;
            countryIso3Code = cas.TECH_Country__c;
            toAddress = (String.isNotBlank(cas.SuppliedEmail) ? cas.SuppliedEmail : (String.isNotBlank(cas.Account.PersonEmail) ? cas.Account.PersonEmail : null));
       		defaultRecordId = cas.AccountId;
            emailTemplateId = cas.DefaultEmailTemplateId__c;
            fromAddressId = cas.DefaultEmailFromAddressId__c;
            isDPCA = cas.RecordTypeId == DPCARecordTypeId ? true : false;
        } else if (record instanceof Task) {
            Task tsk = (Task) record;
            toAddress = tsk.Account.PersonEmail;
            countryIso3code = tsk.ICX_Country__c;
            defaultRecordId = tsk.WhoId;
        }else if (record instanceof CareService__c) {
            CareService__c cs = (CareService__c) record;
            toAddress = cs.client__r.PersonEmail;
            defaultRecordId = cs.Client__c;
        }else if (record instanceof Family_Member__c) {
            Family_Member__c fm = (Family_Member__c) record;
            toAddress = fm.client__r.PersonEmail;
            defaultRecordId = fm.Client__c;
        }else if (record instanceof Account) {
            Account acc = (Account) record;
            toAddress = acc.PersonEmail;
            defaultRecordId = acc.Id;
        }
        System.debug('queueDeveloperName=' + queueDeveloperName);
        System.debug('countryIso3code=' + countryIso3code);
        
        ICX_Queue__mdt queueMetadata;
        if (String.isNotBlank(queueDeveloperName)) {
            queueMetadata = emailDefault.getQueueMetadata(queueDeveloperName);
        } else if (String.isNotBlank(countryIso3Code)) {
            queueMetadata = getQueueMetadataFromCountry(countryIso3code);
        }
        System.debug('queueMetadata=' + queueMetadata);
        
        EmailMessageWrapper wrapper = new EmailMessageWrapper();
        wrapper.toAddress = toAddress;
        wrapper.defaultRecordId = defaultRecordId;
        
        if (String.isNotBlank(fromAddressId))
        {
            wrapper.fromOrgWideAddressId = (Id) fromAddressId;
            OrgWideEmailAddress orgAddressList = [SELECT Id, Address, IsAllowAllProfiles from OrgWideEmailAddress WHERE Id = :fromAddressId];
                if (orgAddressList!=null) {
                    wrapper.fromOrgWideAddressId = orgAddressList.Id;
                    wrapper.fromAddress = orgAddressList.Address;
                }
        }
        else if (queueMetadata != null ) {
            if (String.isNotBlank(queueMetadata.TargetEmail__c)) {
                wrapper.fromAddress = queueMetadata.TargetEmail__c;
                List<OrgWideEmailAddress> orgAddressList = [SELECT id, Address, IsAllowAllProfiles from OrgWideEmailAddress WHERE Address = :queueMetadata.TargetEmail__c];
                if (!orgAddressList.isEmpty()) {
                    wrapper.fromOrgWideAddressId = orgAddressList[0].Id;
                    }
            }
        }
        


        if(queueMetadata != null  || String.isNotBlank(emailTemplateId))
        {

            
            // String emailTemplateDevName = emailDefault.getEmailTemplateDeveloperName(queueMetadata);
            String emailTemplateDevName = emailDefault.getEmailTemplateDeveloperName(queueMetadata,emailTemplateId,isDPCA);

            if (String.isNotBlank(emailTemplateDevName)) {
                EmailTemplate template = [SELECT id, Name, Subject, HtmlValue FROM EmailTemplate 
                                          WHERE developername = :emailTemplateDevName];
                wrapper.emailTemplate = template;
                
                if (template != null && String.isNotBlank(template.HtmlValue)) {
                    // Looking for the signature div so that the user can edit it if necesary
                    String signature = getSignature(template, recordId);//.substringBetween('<div id="icx_signature">', '</div>');
                    /*System.debug('signature=' + signature);
                    wrapper.body = formatEmail('<div id="icx_signature">' + signature + '</div>', recordId);
                    wrapper.body = formatEmail(signature, recordId);*/
                    wrapper.body = signature;
                }
            }
        }
        System.debug('wrapper=' + wrapper);
        return wrapper;
    }
    
    @auraEnabled
    public static String getSignature(EmailTemplate template, Id recordId) {
        String signature;
        if (template != null && String.isNotBlank(template.HtmlValue)) {
            //Looking for the signature div so that the user can edit it if necesary
            signature = template.HtmlValue.substringBetween('<div id="icx_signature">', '</div>');
            System.debug('signature=' + signature);
            //wrapper.body = formatEmail('<div id="icx_signature">' + signature + '</div>', recordId);
            //wrapper.body = formatEmail(signature, recordId);
            signature = formatEmail(signature, recordId);
        }
        return signature;
    }
    
    public class EmailMessageWrapper {
        @auraEnabled
        public String toAddress; 
        @auraEnabled
        public String defaultRecordId;      
        @auraEnabled
        public String fromAddress;
        @auraEnabled
        public Id fromOrgWideAddressId;     
		
        @auraEnabled
        public EmailTemplate emailTemplate;  
		
        @auraEnabled
        public String body;
    }
    
    private static sObject getRecord(Id recordId) {
        if (String.isNotBlank(recordId)) {
            try {
                //Id recId = Id.valueOf(recordId);
                String objectType = recordId.getSObjectType().getDescribe().getName();
                
                if ('Case'.equalsIgnoreCase(objectType)) {
                    Case cas = [SELECT AccountId, SuppliedEmail,DefaultEmailTemplateId__c,DefaultEmailFromAddressId__c, TECH_Queue__c, TECH_Queue_ID__c, Account.PersonEmail, TECH_Country__c, RecordTypeId FROM Case WHERE Id = :recordId];
                    System.debug('cas=' + cas);
                    return cas;
                } else if ('Task'.equalsIgnoreCase(objectType)) {
                    Task tsk = [SELECT Account.PersonEmail, ICX_Country__c, WhoId FROM Task WHERE Id = :recordId];
                    System.debug('tsk=' + tsk);
                    return tsk;
                }else if ('CareService__c'.equalsIgnoreCase(objectType)) {
                    CareService__c cs = [SELECT Client__c, client__r.PersonEmail, client__r.PersonContactId FROM CareService__c WHERE Id = :recordId];
                    System.debug('cs=' + cs);
                    return cs;
                }else if ('Family_Member__c'.equalsIgnoreCase(objectType)) {
                    Family_Member__c fm = [SELECT Client__c, client__r.PersonEmail, client__r.PersonContactId FROM Family_Member__c WHERE Id = :recordId];
                    System.debug('fm=' + fm);
                    return fm;
                }else if ('Account'.equalsIgnoreCase(objectType)) {
                    Account acc = [SELECT Id, PersonEmail, PersonContactId FROM Account WHERE Id = :recordId];
                    System.debug('acc=' + acc);
                    return acc;
                }
            } catch (Exception e) {
                System.debug('object type not found for: ' + recordId);
            }
        }
        return null;
    }
    
    private static ICX_Queue__mdt getQueueMetadataFromCountry(String countryIso3Code) {
        ICX_Queue__mdt queueResult;
        if (String.isNotBlank(countryIso3Code) && Schema.sObjectType.ICX_Queue__mdt.isAccessible()) {
            List<ICX_Queue__mdt> queueList = [SELECT Id, EmailTemplateDeveloperName__c,DPCA_Email_Template_DeveloperName__c, TargetEmail__c, CountryIso3Code__c, IsCSC__c FROM ICX_Queue__mdt WHERE CountryIso3Code__c = :countryIso3Code AND IsCSC__c = true AND  (NOT QueueDeveloperName__c like '%Priority')];
            if (!queueList.isEmpty()) {
                queueResult = queueList.get(0);
            }
        }
        return queueResult;
    }
    public class EmailInstance {
        public String emailSubject;
        public String emailBody;
        public String emailFromAddress;  
        public List<String> emailToAddresses;
        public List<String> emailCcAddresses;
        public List<String> emailBccAddresses;
        public List<Id> emailattachments;
        public Id requestRecordId;
        public EmailTemplate emailTemplate;
        public String emailSignature;
        public Boolean isRemoteConsent;      
    }
    
    @auraEnabled
    public static String previewEmail(Id emailTemplateId, String emailBody, Id recordId, String signature) {
        System.debug('emailTemplateId=' + emailTemplateId + ', emailBody=' + emailBody + ', recordId=' + recordId + ', signature=' + signature);
        
        emailBody = cleanPreviewEmailText(emailBody);
        signature = cleanPreviewEmailText(signature);
        
        String htmlBody;
        if (String.isNotBlank(emailTemplateId)) {
            // Load Email Template
            htmlBody = [select id, Body, DeveloperName, EnhancedLetterheadId, FolderName, HtmlValue from EmailTemplate where id = :emailTemplateId].HtmlValue;
            System.debug('htmlBody=' + htmlBody);
            
            // Replace user's writing in the Email Template
            if (String.isNotBlank(emailBody)) {
                htmlBody = htmlBody.replace('<div id="icx_content"></div>', emailBody);
                //htmlBody = htmlBody.replace('<div id="icx_content"></div>', '<div style=\"font-family: \'Louis Vuitton\';font-size:16px;line-height: 19px;">' + emailBody + '</div>');
            }
            
            // Add the Signature in the email body
            String currentSignature = htmlBody.substringBetween('<div id="icx_signature">', '</div>');
            if (String.isNotBlank(currentSignature)) {// && String.isNotBlank(signature)){ // Need to add an empty signature if the user removes all text from the signature field
                //System.debug('htmlBody=' + htmlBody);
                htmlBody = htmlBody.replace(currentSignature, signature);
                //htmlBody = htmlBody.replace(currentSignature, '<div style=\"font-family: \'Louis Vuitton\';font-size:16px;line-height: 19px;">' + signature + '</div>');
            }
            System.debug('htmlBody2=' + htmlBody);
        } else {
            htmlBody = emailBody + (String.isNotBlank(signature) ? '<br/><br/>' + signature : '');
        }
        
        // Add a reference and hide it in a Div tag
        String reference= referenceId(recordId);
        System.debug( '<div >'+reference+'</div>');
        if (htmlBody.contains('<head>')) {
            htmlBody = htmlBody.replace('<head>','<head><div style="display:none ; color:#fff">'+reference+'</div></body>');            

        }   
        if (htmlBody.contains('</body>')) {   
            htmlBody = htmlBody.replace('<body>','<body><div style="display:none ; color:#fff">'+reference+'</div></body>');            
            htmlBody = htmlBody.replace('</body>','<div style="display:none ; color:#fff">'+reference+'</div></body>');            
        } else {            
            String htmlHead ='<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"><html xmlns="http://www.w3.org/1999/xhtml">';
            htmlBody = htmlBody + '<body><br/><br/><div style="display:none ; color:#fff">' + reference + '</div></body>';
        }

        //lightning email template update naomi 10/2023
      
        if(htmlBody.contains('<style type="text/css">.contentpageDefaultEmailTemplatePageTemplate .contentRoot {width: 600px;}@media only screen and (max-width: 480px) {.contentpageDefaultEmailTemplatePageTemplate .contentRoot {width: 320px;}}</style>'))
        {
            htmlBody = htmlBody.replace('<style type="text/css">.contentpageDefaultEmailTemplatePageTemplate .contentRoot {width: 600px;}@media only screen and (max-width: 480px) {.contentpageDefaultEmailTemplatePageTemplate .contentRoot {width: 320px;}}</style>','');

        }
        if(htmlBody.contains('<table class="contentRoot" style="background-color: #FFFFFF;" role="presentation" width="600" cellpadding="0" cellspacing="0">'))
        {
            htmlBody = htmlBody.replace('<table class="contentRoot" style="background-color: #FFFFFF;" role="presentation" width="600" cellpadding="0" cellspacing="0">','<table class="contentRoot" style="background-color: #FFFFFF;width:70%;" role="presentation" cellpadding="0" cellspacing="0">');

        }
        
        // htmlBody = htmlBody + '<div style="display:none ; color:#fff">'+reference+'</div>';
        // htmlBody = htmlBody.replace('</body>','<div style="display:none ; color:#fff">'+reference+'</div></body>');
        System.debug('htmlBodywithReference=' + htmlBody);
        
        // Replace merge fields by their values
        Set<String> mergeSet = ICX_QuickTextControllerLC.mergeFields(htmlBody);
        String htmlBodyResult = ICX_QuickTextControllerLC.getMergeFields(htmlBody, recordId, new List<String>(mergeSet));
        //String htmlBodyResult = formatEmail(htmlBody, recordId);
        
        System.debug('htmlBodyResult=' + htmlBodyResult);
        return htmlBodyResult;
    }
    
    
    private static String formatEmail(String htmlBody, Id recordId) {
        Set<String> mergeSet = ICX_QuickTextControllerLC.mergeFields(htmlBody);
        return ICX_QuickTextControllerLC.getMergeFields(htmlBody, recordId, new List<String>(mergeSet));
    }
    
    private static String cleanPreviewEmailText(String message) {
        System.debug('message=' + message);
        if (String.isNotBlank(message)) {
            message = message.replaceAll('<p><br></p>', '<br/>'); // replace <p><br><\/p> created by the rich text by one <br/> as the email sent is different in the client's mailbox
            message = message.replaceAll('</p>', '<br/>');  // remove </p> created by the rich text by one <br/> as the email sent is different in the client's mailbox
            message = message.replaceAll('<p>', ''); // remove <p> created by the rich text as the email sent is different in the client's mailbox            
        }
        System.debug('message after=' + message);
        return message;
    }
    
    @auraEnabled(cacheable=true)
    public static List<EmailTemplate> getEmailTemplateList(String folderDeveloperName) {
        return [SELECT Id, Name, Subject, HtmlValue FROM EmailTemplate WHERE Folder.DeveloperName = :folderDeveloperName AND Folder.Type IN ('Email','EmailTemplate') AND IsActive = true WITH SECURITY_ENFORCED ORDER BY Name]; //updated for lightning email template haim 10/2023
    }
    
    // add a reference to the email (when the client replies to a CSC email, the client email will be linked to the Case)
    private static String referenceId(String caseId) {
        /* String caseThreadID = '_' + UserInfo.getOrganizationId().left(5) ;
			caseThreadID = caseThreadID + UserInfo.getOrganizationId().mid(11,4) + '._';
			caseThreadID = caseThreadID + caseId.left(5) + caseId.mid(10,5);
			String reference = 'ref:'+ caseThreadID +':ref';*/
        List<Messaging.RenderEmailTemplateBodyResult> renderResults = Messaging.renderEmailTemplate(null, caseId, new List<String>{'{!Case.Thread_Id}'});
        String reference = renderResults[0].getMergedBody();
        return reference;
    }
    
    @TestVisible
    // Display image in the body of the email in a client mailbox
    // https://help.salesforce.com/articleView?id=000320130&language=en_US&type=1&mode=1
    private static String formatImageInEmailBody(String bodyEmail) {
        //String val = '<html><img src="https://louisvuitton--iconics--c.cs70.content.force.com/sfc/servlet.shepherd/version/download/0683D000000hG1h?asPdf=false&amp;operationContext=CHATTER"><br/><div style="display:none ; color:#fff">ref:_00D3DCypS._5003D3q27d:ref</div><img src="https://louisvuitton--iconics--c.cs70.content.force.com/sfc/servlet.shepherd/version/download/0683D000000hG1cQAE?asPdf=false&amp;operationContext=CHATTER"></html>';
        //bodyEmail = '<html><img src="https://louisvuitton--iconics--c.cs70.content.force.com/sfc/servlet.shepherd/version/download/0683D000000hG4R?asPdf=false&amp;operationContext=CHATTER"><br/><div style="display:none ; color:#fff">ref:_00D3DCypS._5003D3q27d:ref</div></html>';
        
        // Map<contentDocumentId, Link>
        Map<Id, String> versionToUrlMap = new Map<Id,String>();
        // Pattern MyPattern = Pattern.compile('content.force.com(.*?)operationContext=CHATTER');
        
        Boolean enhancedDomaine =false;
        Pattern MyPattern = Pattern.compile('documentforce.com(.*?)operationContext=CHATTER');

        Pattern MyPatternEnhancedDomain = Pattern.compile('file.force.com/sfc/(.*?)operationContext=CHATTER'); //to be activated for enhanced domain

        Matcher m = MyPattern.matcher(bodyEmail);

        if(!m.find())
        {

            m = MyPatternEnhancedDomain.matcher(bodyEmail);
            enhancedDomaine = true;
        }

        m.reset();

        while (m.find()) {
            System.debug('nao file.force ' + m.group());
            // String contentVersionId = m.group().substringBetween('download/', '?');
            String contentVersionId = m.group().substringBetween('download/', '?')!=null?m.group().substringBetween('download/', '?'):m.group().substringBetween('versionId=', '&amp;'); //hybride version with enhance domain activated

																																 

            System.debug('contentVersionId=' + contentVersionId);
            try {
                if(contentVersionId!=null)
                {
                    Id versionId = Id.valueOf(contentVersionId);
                    versionToUrlMap.put(versionId, m.group().trim());
                }
            } catch (Exception e) {
                System.debug('Fail to convert Id for ' + contentVersionId);
            }
        }
        System.debug('versionToUrlMap=' + versionToUrlMap);
        
        if (!versionToUrlMap.isEmpty()) {
            List<ContentVersion> versionList = new List<ContentVersion>();
            Map<Id, Id> docToVersionMap = new Map<Id, Id>(); // Map < ContentDocumentId, ContentVersion>
            
            // Create ContentVersion to create ContentAsset automatically (ContentAsset can't be inserted with the not writeable ContentDocumentId field)
            Set<Id> contentVersionIdSet = versionToUrlMap.keySet();
            for (ContentVersion vers : [SELECT Id, Title, PathOnClient, VersionData, FirstPublishLocationId, ContentDocumentId FROM ContentVersion WHERE Id IN :contentVersionIdSet]) {
                ContentVersion newVers = new ContentVersion();
                newVers.Title = vers.Title;
                newVers.ContentDocumentId = vers.ContentDocumentId;
                newVers.PathOnClient = vers.PathOnClient;
                newVers.VersionData = vers.VersionData;
                //newcont.FirstPublishLocationId = cont.FirstPublishLocationId;
                newVers.IsAssetEnabled= true; // Create the ContentAsset
                versionList.add(newVers);
                
                docToVersionMap.put(vers.ContentDocumentId, vers.Id);
            }
            if (!versionList.isEmpty()) {
                insert versionList;
                
                // Set the ContentAsset visible in external mailbox
                Set<Id> contentDocumentIdSet = docToVersionMap.keySet();
                List<ContentAsset> assetList = new List<ContentAsset>();
                for (ContentAsset asset : [SELECT Id, IsVisibleByExternalUsers FROM ContentAsset WHERE ContentDocumentId IN :contentDocumentIdSet]) {
                    asset.IsVisibleByExternalUsers = true;
                    assetList.add(asset);
                }
                
                if (!assetList.isEmpty()) {
                    update assetList;
                    
                    // Replace the existing image url not visible in client mailbox to image url visible
                    Id orgId = UserInfo.getOrganizationId();
                    for (ContentDocument doc : [SELECT Id, ContentAssetId, ContentAsset.DeveloperName FROM ContentDocument WHERE Id IN :contentDocumentIdSet]) {
                        if (String.isNotBlank(doc.ContentAssetId)) {
                            Id contentVersionId = docToVersionMap.get(doc.Id);
                            if (String.isNotBlank(contentVersionId)) {
                                String url = versionToUrlMap.get(contentVersionId);
                                if (String.isNotBlank(url)) {
                                    // replace and resize the image to the template
                                    // Note: resize is working in mailbox in internet but resize is not working in Outlook client mailbox desktop app
                                    // bodyEmail = bodyEmail.replace(url, 'content.force.com/file-asset-public/' + doc.ContentAsset.DeveloperName + '?oid=' + orgId + '\" style=\"max-width: 640px;height: auto; display: block;');
																													
                                    // bodyEmail = bodyEmail.replace(url, 'documentforce.com/file-asset-public/' + doc.ContentAsset.DeveloperName + '?oid=' + orgId + '\" style=\"max-width: 640px;height: auto; display: block;');
																																																						 

                                    //hybride version with enhance domain activated
                                    String docPrefix = enhancedDomaine==false ?'documentforce.com':'file.force.com';
                                    bodyEmail = bodyEmail.replace(url, docPrefix+'/file-asset-public/' + doc.ContentAsset.DeveloperName + '?oid=' + orgId + '\" style=\"max-width: 640px;height: auto; display: block;'); 


                                    system.debug('bodyEmail with new content version id'+ bodyEmail);
                                }
                            }
                        }
                    }
                }
            }
            
        }
        System.debug('bodyEmail=' + bodyEmail);
        return bodyEmail;
    }
    

    //old version
    @TestVisible 
    private static void setQueue (String fromAddressId,String caseId){
        if(fromAddressId.startsWith('0D2')){
            OrgWideEmailAddress fromAddress = [SELECT Address FROM OrgWideEmailAddress WHERE Id=:fromAddressId];
            system.debug('fromAddress: ' +fromAddress.Address);
            If(fromAddress != null){
                List<Group> queque = [SELECT Id,DeveloperName,Email FROM Group WHERE Type ='Queue' AND Email=:fromAddress.Address LIMIT 1];
                If(queque.size() > 0){
                    Case c = [SELECT Id,TECH_Queue__c,TECH_Queue_ID__c FROM Case WHERE Id=:caseId];
                    if(c.TECH_Queue__c == null){
                        
                        c.TECH_Queue_ID__c = queque[0].Id;
                        c.TECH_Queue__c = queque[0].DeveloperName;
                        
                        Update c;
                    }
                }
            }
        }
    }

    //new version
    @TestVisible 
    private static void setQueueAndTemplate (String fromAddressId, String emailTemplateId,String caseId){

        if(fromAddressId.startsWith('0D2')){
            Boolean toUpdate = false;
            Case currentCase = [SELECT Id,TECH_Queue__c,TECH_Queue_ID__c,DefaultEmailFromAddressId__c,DefaultEmailTemplateId__c FROM Case WHERE Id=:caseId];
            if(currentCase.DefaultEmailFromAddressId__c == null)
            {
                currentCase.DefaultEmailFromAddressId__c =  fromAddressId; 
                toUpdate = true;
            }
            if(currentCase.DefaultEmailTemplateId__c==null)
            {
                currentCase.DefaultEmailTemplateId__c = emailTemplateId;
                toUpdate = true;
            }
            if(currentCase.TECH_Queue__c == null)
            {
                OrgWideEmailAddress fromAddress = [SELECT Address FROM OrgWideEmailAddress WHERE Id=:fromAddressId];
                if(fromAddress!=null)
                {

                    Group queue = [SELECT Id,DeveloperName,Email FROM Group WHERE Type ='Queue' AND Email=:fromAddress.Address LIMIT 1];
                    if(queue !=null){
                        currentCase.TECH_Queue_ID__c = queue.Id;
                        currentCase.TECH_Queue__c = queue.DeveloperName;
                        toUpdate = true;
                    }
                }

            }
            

            if(toUpdate)
            {
                Update currentCase;
            }
        }
    }
	
    @AuraEnabled(cacheable=true)
    public static List<EmailTemplate> findTemplates(String searchKey, String folderDeveloperName){
    List<EmailTemplate> foundTemplates = new List<EmailTemplate> ();
    system.debug('searchKey'+searchKey);  
    if ( !String.isBlank(searchKey)) {
        searchKey ='*'+searchKey+'*';
        List<List<EmailTemplate>> lst = [FIND :searchKey RETURNING EmailTemplate (Id, Name, Subject, HtmlValue WHERE Folder.DeveloperName = :folderDeveloperName AND Folder.Type IN ('Email','EmailTemplate') AND IsActive = true ORDER BY Name)];
        for(List<EmailTemplate> templates: lst){
            foundTemplates.addAll(templates);  
           }  
            system.debug('foundTemplates' +foundTemplates.size());
      
        system.debug(foundTemplates.size());     
            return foundTemplates;
     }else{
            return null;
        }
}
}