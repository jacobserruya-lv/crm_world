/**
 * @ Dscription: Controller of ICX_IPDTransfer_VF page AND LWC icx_ipd_confirmation
 * Sends the email to the right IPD, creates a task and close the case
 * @ Modification History:
 *      New fuction called on the lwc 
 *      Addition of the name and the email address of the client
*/

public without sharing class ICX_IPDTransfer_CTL {
    public Case cas;
    public string message {get; set;}

    public ICX_IPDTransfer_CTL(ApexPages.StandardController stdController){
        if (!Test.isRunningTest()) {  
            stdController.addFields(new LIST<String> {'TECH_Is_Queue_owner__c', 'Resolution__c', 'Type', 'Category__c'});
        }
        this.cas = (case) stdController.getRecord(); 
    }
    public PageReference sendEmailToIPDAndCreateTask(){
        try {
            if(cas.TECH_Is_Queue_owner__c){
                throw new CustomException(System.label.ICX_IPD_ErrorMessage1);
            }
            if(cas.Resolution__c != System.Label.ICX_IPD_CaseResolution || cas.Type != System.Label.ICX_IPD_CaseType || cas.Category__c != System.Label.ICX_IPD_CaseCategory){
                sendEmailToIPD(this.cas.id);
                return new PageReference('/' + cas.id ); 
            }else{
                throw new CustomException(System.label.ICX_IPD_ErrorMessage3);
            }
           
        } catch (Exception e) {

            message = e.getMessage();
            return null;
            
        }         
    }
    class CustomException extends Exception {}  
    
    /** * Send email to IPD with LWC inside a quick action  **/
    @AuraEnabled 
    public static void  sendEmailToIPD(id recordId){
        try {
            String errorMessage = '';
            if( String.isNotBlank(recordId)){            
                // Get the related record with the nessary information 
                List<Case> caseRecords = [ SELECT Id,subject, Status, description, origin, Country__c, account.name,account.PersonEmail,SuppliedEmail, SuppliedName, 
                                            TECH_Is_Queue_owner__c, account.PersonContactId, sent_to_IPD__c ,ParentId
                                            FROM    Case 
                                            WHERE   Id=:recordId 
                                            LIMIT   1];

                Case caseRecord = (caseRecords.isEmpty() ? null : caseRecords.get(0));

                String country = String.isNotBlank(caseRecord.Country__c) ? caseRecord.Country__c : System.Label.ICX_IPD_DefaultCountry;

                List<CountryMapping__mdt> idpEmail = [SELECT id, IPD_To__c, IPD_CC__c FROM CountryMapping__mdt WHERE Case__c =: country]; 

                if(!idpEmail.isEmpty() && String.isNotBlank(idpEmail[0].IPD_To__c)) {
                    
                    List<String> ccAddresses = (idpEmail[0].IPD_CC__c != null ? idpEmail[0].IPD_CC__c.split('\\|') : new List<String>{});  
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  
                    
                   
                    mail.setToAddresses( idpEmail[0].IPD_To__c.split('\\|')); 
                    mail.setccAddresses(ccAddresses);
                    mail.setSubject(caseRecord.subject);
                    String clientInfo = '<b>CLIENT INFORMATION:</b> <br/><br/>' + 
                                    (caseRecord.account != null ? caseRecord.account.name+'<br/>' : caseRecord.SuppliedName+'<br/>') + 
                                    (caseRecord.account != null  && caseRecord.account.PersonEmail!= null  ? caseRecord.account.PersonEmail+'<br/><br/>' : caseRecord.SuppliedEmail+'<br/><br/>')+
                                    '<b>REQUEST DETAILS:</b> <br/><br/>';

                    String emailToSend = caseRecord.Description;
                    //Id caseid = (String.isNotBlank(caseRecord.ParentId) ? caseRecord.ParentId : caseRecord.id );  
                    Id caseid = caseRecord.id; 
                    if(caseRecord.origin == 'Email' || caseRecord.origin == 'Web'){     // Get the most recent email , This email should already include all the exchanged email history
                      
                        List<Emailmessage> emList = [SELECT id, HtmlBody 
                                                    FROM Emailmessage  
                                                    WHERE relatedToId =: caseid and Incoming = true 
                                                    ORDER BY createddate DESC] ;

                        Emailmessage em = ( emList.isEmpty() ? null : emList.get(0));
                        String body = ( em != null && String.isNotBlank(em.HtmlBody) ? em.HtmlBody : '' );
                        emailToSend = ( String.isNotBlank(body) ? body : caseRecord.Description);
                        
                    } 
                    mail.setFileAttachments(ContentDocumentAsAttachement(recordId));
                    mail.setHtmlBody(clientInfo + emailToSend); 

                    Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{mail};
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                    if(results[0].success){  // create task and close the case when the email has been sent to IPD
                       
                        createTaskClosecase(caseRecord);
                    }  
                } else // if no IPD email is set up for that case's queue or country then display an explicit error message
                    errorMessage = System.label.ICX_IPD_ErrorMessage2 ;
            } else // record id is empty 
                errorMessage = 'Please refresh the page and try again' ;

            if(String.isNotBlank(errorMessage)){ // throw error if there is an error message
                AuraHandledException e = new AuraHandledException(errorMessage);
                e.setMessage(errorMessage);
                throw e;
            }

        } catch (Exception e) {
            AuraHandledException ex = new AuraHandledException(e.getMessage());
            ex.setMessage(e.getMessage());
            throw ex;
        }
    }

    public static List<Messaging.EmailFileAttachment> ContentDocumentAsAttachement(Id recordId) {

        List<Id> ContentDocIDList = new List<Id>();
        List<EmailMessage> relatedMails = ICX_Emails.getEmails(recordId);

        Map<Id, EmailMessage> relatedMailsMap = new Map<Id, EmailMessage>(relatedMails);
        for(ContentDocumentLink cdl: [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:recordId or LinkedEntityId in :relatedMailsMap.keySet()]){
            ContentDocIDList.add(cdl.ContentDocumentId);
        }

        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>{};
       
        for (ContentVersion document: [SELECT Id, Title, FileType, FileExtension ,VersionData, isLatest, ContentDocumentId FROM ContentVersion WHERE isLatest = true AND ContentDocumentId IN :ContentDocIDList]){
          Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
          String name = document.Title.contains(document.FileExtension)? document.Title: document.Title + '.' + document.FileExtension; 
          attachment.setBody(document.VersionData);
          attachment.setFileName(name);
    
          attachments.add(attachment);
        }
        return attachments;
    }

    private static void createTaskClosecase(case caseRecord){

        Task t = new Task(Subject = System.Label.ICX_IPD_TaskSubject, 
        Whatid = caseRecord.id,
        whoid = caseRecord.account.PersonContactId,
        Status = System.Label.ICX_IPD_TaskStatus, 
        Priority= System.Label.ICX_IPD_TaskPriority, 
        ActivityDate = System.today());
        insert t;

        caseRecord.Resolution__c = System.Label.ICX_IPD_CaseResolution; 
        caseRecord.Type = System.Label.ICX_IPD_CaseType; 
        caseRecord.Category__c = System.Label.ICX_IPD_CaseCategory; 
        caseRecord.sent_to_IPD__c = true;

        update caseRecord;

    } 
   


/*  
    public ICX_IPDTransfer_CTL(ApexPages.StandardController stdController) {
        if(!Test.isRunningTest()){
            stdController.addFields(new LIST<String> {'subject', 'Status', 'description', 'origin', 'Country__c', 
                 'TECH_Is_Queue_owner__c', 'account.PersonContactId', 'Resolution__c', 'Type', 'Category__c'});
        }
        this.cas = (case) stdController.getRecord();  
        message = '';
        
    }*/
    
    /**
     * @ Description: send the client original email to IPD, generates a task and close the case
     * @ Result: if all the operations run successfully then return to the case page so the newly created task is displayed. 
     *   Otherwise, an error message is displayed to the user
    *
    public PageReference sendEmailToIPDAndCreateTask(){           
      
        String country = String.isNotBlank(cas.Country__c)?cas.Country__c : System.Label.ICX_IPD_DefaultCountry;
        
        List<CountryMapping__mdt> idpEmail = [SELECT id, IPD_To__c, IPD_CC__c from CountryMapping__mdt where Case__c =: country];   // get the right record from custom metadata type
    
        if(idpEmail != null && idpEmail.size()> 0 && String.isNotBlank(idpEmail[0].IPD_To__c)) {    // build the email to be sent to IPD
            if(cas.Resolution__c != System.Label.ICX_IPD_CaseResolution || cas.Type != System.Label.ICX_IPD_CaseType || cas.Category__c != System.Label.ICX_IPD_CaseCategory) {   // Do not sent to IPD twice

                Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
                msg.toAddresses = idpEmail[0].IPD_To__c.split('\\|');
                msg.ccAddresses = (idpEmail[0].IPD_CC__c != null ? idpEmail[0].IPD_CC__c.split('\\|') : new List<String>{});  
                msg.subject = cas.subject;
                Savepoint sp = Database.setSavepoint();
                try {
                  
                    String description = cas.description;

                    if(cas.origin == 'Email' || cas.origin == 'Web') {     // for email and web cases, get the latest incoming email. This email should already include all the exchanged email history 
                        List<Emailmessage> emList = [SELECT id, HtmlBody 
                                                     FROM Emailmessage  
                                                     WHERE relatedToId =: cas.id and Incoming = true 
                                                     ORDER BY createddate DESC] ;
                        if(emList.size() > 0) {
                             Emailmessage  em = emList[0];
                            Folder f = [SELECT id FROM Folder WHERE DeveloperName = 'ICONICS_IPD'];
                            String body = handleImageInEmailBody(em, f);
                            description = String.isNotBlank(body)? body: cas.description; 
                        } 
                    } 
                    msg.htmlbody = description;
                    msg.setFileAttachments(ContentDocumentAsAttachement(cas));

                    if(String.isNotBlank(msg.htmlBody)) {   // There must be either an incoming email or a description on the case

                        if(!cas.TECH_Is_Queue_owner__c)  {  // user must be the case owner before sending the email to IPD     

                            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{msg};
                            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                            
                            if(results[0].success){    // if email is sent successfully then create a task on case and close the case
                             
                                createTaskClosecase(cas);
                            }     
                        }else {  //if the case is in a queue, then prevent the email from being transfered to IPD by displaying an error message case must be owned by an agent

                            message = System.Label.ICX_IPD_ErrorMessage1; 
                        }
                    } else  {  // there is no incoming email and case description is empty then there is nothing to send to IPD
                        message = System.Label.ICX_IPD_ErrorMessage4; 
                    }
                }catch(Exception e){
                    message = e.getMessage();
                    Database.rollback(sp);
                }      
            }  else {
                message = System.label.ICX_IPD_ErrorMessage3;
            }   
        } else{  // if no IPD email is set up for that case's queue or country then display an explicit error message
       
            message = System.label.ICX_IPD_ErrorMessage2; 
        }
        if (!String.isBlank(message)) {   // if any error message is returned then display it 
            return null;
        } else { // if everything runs fine, then return to the case page layout. The newly created task will display
      
            return new PageReference('/' + cas.id ); 
        }
    }*/
    /**
     * @ Description: images in email body (screenshots for example) are created as attachment but
     * when openeing the IPD email, they are broken because they are only visible by internal users.
     * This method makes images publically availabl by creating an externally available document 
     * for each attachment and replacing the attachment URL by 
     * documents
     * @ result: renders the emailmessage body where attachment URL are replaced by document URL
    *
    private static String handleImageInEmailBody(EmailMessage em, Folder f) {
        String emailBody = em.HTMLBody;
        list<Attachment> attList = [SELECT id, Name, ContentType, Body from Attachment where parentid =: em.id and Name like 'image%'];

        // create an externally available doduments
        if(!attList.isEmpty() && f!= null){
            List<Document> docsList = new List<Document>();
            Map<Id, Document> mapAttDoc =  new Map<Id, Document>();
            for(Attachment att: attList){
                Document doc = new Document(Name = em.id + '-' + att.name,   ContentType = att.ContentType,Body = att.Body, FolderID = f.id, IsPublic = true);
                docsList.add(doc);
                mapAttDoc.put(att.id, doc);
            }
            insert docsList;
            
            Map<String, String> mapURL = new Map<String, String>();
            
            String orgID = UserInfo.getOrganizationId();
            String attachmentDownloadURL = 'FileDownload?file=';
            String documentURL = 'ImageServer?id=';
            
            for(Attachment att: attList) {
                mapURL.put(attachmentDownloadURL + String.valueof(att.id).left(15), documentURL+mapAttDoc.get(att.id).id+'&oid='+orgID);
            }

            for(String attURL: mapURL.keySet()){ // replace attachement URL by document URL in EmailMessage body
                emailBody = emailBody.replace(attURL, mapURL.get(attURL));
            }
        }
        
        return emailBody;
    }
    */
    /* public static List<Messaging.EmailFileAttachment> ContentDocumentAsAttachement(case cas) {  
        
        List<Messaging.EmailFileAttachment> efaList = new List<Messaging.EmailFileAttachment>();

        // get all emails related to this case (those emails may have attachments)
        List<Id> emIdList = new list<Id>();
        for(EmailMessage emsg:  [SELECT id FROM EmailMessage WHERE relatedToId=: cas.id]) {
            emIdList.add(emsg.Id);
        }
        // get all files attached to the exchanged emails and case
        List<ContentDocumentLink> cdlList =  new List<ContentDocumentLink>();
        if(emIdList.size() > 0) {
            cdlList = [SELECT id, ContentDocumentId 
                        FROM ContentDocumentLink WHERE LinkedEntityId in: emIdList];
        }
        cdlList.addAll([SELECT id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: cas.id]);
        
        if(cdlList.size() > 0) {
            List<Id> ContentDocIDList = new List<Id>();
            for(ContentDocumentLink cdl: cdlList){
                ContentDocIDList.add(cdl.ContentDocumentId);
            }
            List<ContentVersion> cvList = [SELECT Id, Title, FileExtension, VersionData 
                                            FROM ContentVersion WHERE ContentDocumentId in:ContentDocIDList];
            if(cvList.size() > 0) {
                String name = '';
                for(ContentVersion cv: cvList){
                    Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                    name = cv.Title.contains(cv.FileExtension)? cv.Title: cv.Title + '.' + cv.FileExtension; // Title may already contains the extension
                    efa.setFileName(name);
                    efa.setBody(cv.versionData);
                    efaList.add(efa); 
                }
            }
        }
        return efaList;
    }*/
                    
    
}