public with sharing class BL_EMAIL_Sender_Helper {
    public static Id requestCareRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Care_Service')?.getRecordTypeId();
    public static Id requestRemoteConsentsRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Remote_Consent')?.getRecordTypeId(); 
    public static Id requestClientelingRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Clienteling')?.getRecordTypeId(); 

    public static Object sendEmail(Map<String,Object> body, String application){
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();  
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();    
        try { 
            Map<String,Object> record = (Map<String,Object>) body.get('body');
            String emailType = (String) record.get('emailType'); 
            Id recordId = (Id) record.get('recordId'); 
            Map<String, Object> contact = (Map<String, Object>) record.get('defaultContact');
            Map<String, Object> sender = (Map<String, Object>) record.get('sender');
            List<String> toContacts = convertObjectToListString((List<Object>) record.get('toContacts'));
            List<String> ccContacts = convertObjectToListString((List<Object>) record.get('ccContacts'));
            List<String> bccContacts = convertObjectToListString((List<Object>) record.get('bccContacts'));
            String objectType = recordId.getSObjectType().getDescribe().getName();

            Boolean isClientenling = isClientenling(emailType, objectType, recordId);
            
            Id whatId = getWhatId(recordId , record);
            mail.setWhatId(whatId);

            if(record.containsKey('files') &&  !((List<Object>)record.get('files')).isEmpty()){
                    mail.setEntityAttachments(convertObjectToListString((List<Object>)record.get('files')));
            }

            if(String.isNotEmpty((String) contact.get('email'))){
                mail.setTargetObjectId((Id) contact.get('contactId'));
            }

            mail.setToAddresses(toContacts);  
            mail.setCcAddresses(ccContacts);  
            mail.setBccAddresses(bccContacts);   
            mail.setSubject((String) record.get('subject'));    
            mail.setHtmlBody((String) record.get('body'));

            if ((objectType == 'Case' || emailType == 'remoteConsent' || emailType == 'clienteling') && String.isNotBlank((String) record.get('body'))) {
                String refId = (emailType != 'remoteConsent' && emailType != 'clienteling') ? recordId:whatId;
                mail.setHtmlBody(formatEmailBody((String) record.get('body'), refId, referenceId(refId)));
                mail.setPlainTextBody(getTextMessage(record, recordId));
                setQueue(sender, refId);
            } else mail.setHtmlBody((String) record.get('body'));

    
            if((String) sender.get('type') == BL_EMAIL_Constants.USE_CASE_ADDRESSES && !isClientenling){
                mail.setOrgWideEmailAddressId((String) sender.get('id'));
            }else if(isClientenling){
                String emailAddress = IconicsSettings__c.getOrgDefaults().ClientelingEmailAddress__c;
                mail.setSenderDisplayName(UserInfo.getFirstName());
                mail.setReplyTo(emailAddress);
            }else {
                mail.setSenderDisplayName((String) sender.get('name'));
            }
            
            if(application == 'WARDROBING'){
                mail.setSaveAsActivity(false);
            }

            mails.add(mail);  
            
        } catch(Exception e) {
            System.debug('error => '+e);
            throw new BL_Exceptions.BL_Exception(e.getMessage(),'Error Sending Email');
        } 

        sendMail(mails);
     
        return true;
    }

    public static String formatEmailBody (String htmlBody, String recordId, String referenceId) {
        String divWithRef = '<div style="display:none ; color:#fff">'+referenceId+'</div>';

        if (htmlBody.contains('<head>')) {
            htmlBody = htmlBody.replace('<head>','<head>' + divWithRef);            
        }   
        if (htmlBody.contains('</body>')) {   
            htmlBody = htmlBody.replace('<body>','<body>' + divWithRef);            
            htmlBody = htmlBody.replace('</body>', divWithRef + '</body>');            
        } else {            
            htmlBody = htmlBody + '<body><br/><br/>'+divWithRef+'</body>';
        }
        return htmlBody;
    }

    public static String getTextMessage(Map<String,Object> record, String recordId) {
        String bodyString = (String) record.get('body');
        String textMessage = bodyString + ((bodyString.contains('signature')) ? '<br/>' + (String) record.get('signature') : '<br/>'+ referenceId(recordId));
        return textMessage.stripHtmlTags();
    }

    public static List<String> convertObjectToListString(List<Object> objects){
        List<String> strings = new List<String>();
        if(objects != null)
            for(Object o : objects){
                system.debug(o);
                if( o != null)
                    strings.add((String) o);
            }
        return strings;
    }

    public static void sendMail(List<Messaging.SingleEmailMessage> mails){
        try { 
            Messaging.SendEmailResult[] resultList = Messaging.sendEmail(mails);
            if (!resultList[0].isSuccess()) {    
                String errMsg = '';
                for (Messaging.SendEmailError errorMessaging : resultList[0].getErrors()) {
                    errMsg += errorMessaging.getMessage();
                }
                throw new BL_Exceptions.BL_Exception(errMsg ,'' );
            }
        } catch(Exception e) {

            throw new BL_Exceptions.BL_Exception(e.getMessage(),'Error Sending Email');
        } 
    }

    public static Id getWhatId(Id recordId , Map<String,Object> record){
        String objectType = recordId.getSObjectType().getDescribe().getName();
        String emailType = (String) record.get('emailType'); 


        switch on objectType {
            when 'Account'  {
                Boolean isRemoteConsent = emailType == 'remoteConsent';
                Boolean isClienteling = emailType == 'clienteling';

                if(isRemoteConsent){
                    Map<String, Object> contact = (Map<String, Object>) record.get('defaultContact');

                    Case request = new Case(
                        ContactId = (String) contact.get('contactId'),
                        Origin = 'Email',
                        Subject = (String) record.get('subject'),
                        AccountId = recordId,
                        Recordtypeid = requestRemoteConsentsRT
                    );
                    insert request;
                    return request.id;  
                }else if(isClienteling){
                    Map<String, Object> contact = (Map<String, Object>) record.get('defaultContact');
                    Case requestClienteling = new Case(
                        AccountId = recordId,
                        ContactId = (String) contact.get('contactId'),
                        Origin = 'Manual Creation',
                        Subject = (String) record.get('subject'),
                        RecordtypeId = requestClientelingRT,
                        Status = 'Pending',
                        Country__c = countryCodeMapping(recordId, false),
                        TECH_Country__c = countryCodeMapping(recordId, true)
                    );
                    
                    insert requestClienteling;
                    return requestClienteling.id;
                }
                return recordId;
            }
            when 'Case' {
                Map<String, Object> sender = (Map<String, Object>) record.get('sender');
                setQueue(sender, recordId);  
                return recordId;
            }
            when 'CareService__c' {
                List<Case> requests = getRelatedRequest(recordId);
                if(requests.isEmpty()){
                    Map<String, Object> contact = (Map<String, Object>) record.get('defaultContact');

                    Case request = new Case(
                        RecordTypeId = requestCareRT,
                        My_Repairs__c = recordId,
                        AccountId = (String) contact.get('clientId')
                    );
                    insert request;
                    return request.id;    
                }
                return requests.get(0).id;
            }             
            when 'Alias__c' ,'Family_Member__c' {
                return recordId;
            }
        }
        return null;
    }

    public static List<Case> getRelatedRequest(String repairId){
        return [SELECT Id 
                FROM Case
                WHERE My_Repairs__c=:repairId
                AND RecordtypeId =: requestCareRT
                LIMIT 1
        ];
    }

    @testvisible 
    private static void setQueue(Map<String, Object> sender, String requestId){
        if((String) sender.get('type') == BL_EMAIL_Constants.USE_CASE_ADDRESSES){
            String mail = (String) sender.get('email');
            List<Group> queues = [ SELECT Id, DeveloperName, Email 
                                   FROM Group 
                                   WHERE Type = 'Queue' AND Email =: mail
                                   LIMIT 1
                                  ];
            
            if(!queues.isEmpty()){
                Case request = [ SELECT id, TECH_Queue__c, TECH_Queue_ID__c 
                                 FROM Case 
                                 WHERE id =: requestId
                                ];
                if(String.isEmpty(request.TECH_Queue__c)){
                    Group queue = queues.get(0);
                    request.TECH_Queue_ID__c = queue.Id;
                    request.TECH_Queue__c = queue.DeveloperName;
                    
                    update request;
                }
            }
        }
    }

    private static String referenceId(String caseId) {
        List<Messaging.RenderEmailTemplateBodyResult> renderResults = Messaging.renderEmailTemplate(null, caseId, new List<String>{'{!Case.Thread_Token}'});
        String reference = renderResults[0].getMergedBody();
        return reference;
    }

    private static Boolean isClientenling(String emailType, String objectType, String recordId){
        String caseRecordType = '';
        if(objectType == 'Case'){
            caseRecordType = [SELECT Id, recordTypeId FROM Case WHERE Id =: recordId LIMIT 1].recordTypeId;
        }

        if(emailType == 'clienteling' || caseRecordType == (String) requestClientelingRT){
            return true;
        }
        return false;
    }

    private static String countryCodeMapping(String recordId, Boolean isIso3Code){
        Account accountRecord = [SELECT Id, SPO_Country_code__pc FROM Account WHERE Id =: recordId];
        
        if(accountRecord.SPO_Country_code__pc != null){
            if(isIso3Code){
                return accountRecord.SPO_Country_code__pc;
            }else{
                List<CountryMapping__mdt> countryMapping = [SELECT Id, Iso3Code__c, Case__c FROM CountryMapping__mdt
                WHERE  Iso3Code__c =: accountRecord.SPO_Country_code__pc LIMIT 1];
                if(countryMapping.size()>0)
                    return countryMapping[0]?.Case__c;
            }
        }

        return null;
    }
}