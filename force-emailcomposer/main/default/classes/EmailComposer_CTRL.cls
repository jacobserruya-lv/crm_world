public with sharing class EmailComposer_CTRL {

    public string recordId {get; set;}
    public string application {get; set;}
    public string emailDefaultValues {get; set;}
    public static Map<String,Object> vars = new Map<String,Object>();
    public static Set<String> listFoldersTemplateName = new Set<String>();

    enum UseCase {EMAIL_TYPE}

    public EmailComposer_CTRL() {
        recordId = ApexPages.currentPage().getParameters().get('recordId');
        application = ApexPages.currentPage().getParameters().get('application');
        if(String.isNotEmpty(recordId)){
            setDatas(recordId,application);
        }
        emailDefaultValues = JSON.serialize(vars);
    }

    public static Boolean checkRoleAccess(String typeEmail){
        String roles;
        String UserRoleId = [SELECT UserRoleId From User WHERE Id = :UserInfo.getUserId()][0].UserRoleId;

        if(typeEmail == 'remoteConsent'){
            roles = IconicsSettings__c.getOrgDefaults().ICX_RemoteConsentRoleAccess__c;
        }else if(typeEmail == 'clienteling'){
            roles = IconicsSettings__c.getOrgDefaults().ICX_ClientelingRoleAccess__c;
        }
        
        if(String.isNotBlank(roles)){
            List<String> rolesList = roles.split(';');
            return rolesList.contains(UserRoleId);
        }

        return false;
    }



    @AuraEnabled
    public static Boolean refreshAllowed(Id recordId)
    {
       Id webAndEmailRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Web_Email_Case')?.getRecordTypeId(); 
        Boolean isRefreshPermited ;
        case currentCase = [SELECT Id,RecordTypeId FROM Case WHERE Id =:recordId limit 1];
         isRefreshPermited = currentCase.recordTypeId == webAndEmailRT;
         return isRefreshPermited;
    
    }



   
    public static void setDatas(Id recordId, string application){
        Map<String,Object> defaultValues = new  Map<String,Object>();
        Map<String, Object> contact ;
        List<Map<String,Object>> emailTypeOptions;
        String objectType = recordId.getSObjectType().getDescribe().getName();
        vars.put('objectType', objectType);
        String usecase = getUseCaseByObject(objectType);
        Map<String, Object> record = new Map<String, Object>();
        String requestDigitalPrivateCA = String.valueOf(Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Digital_Private_CA')?.getRecordTypeId());


        switch on objectType {
            when 'Account'  {
                contact = BL_EMAIL_Contacts_Helper.getContactById((Id) recordId);
                vars.put('defaultTo', contact);
                List<Map<String, Object>> allEmailTypeOptions = getEmailTypeOption();
                Map<String, Object>  mapTypeOption = new Map<String, Object> ();
                
                for (Map<String, Object> emailType : allEmailTypeOptions) { 
                    mapTypeOption.put((String)emailType.get('id'), emailType);
                }
                
                if(!checkRoleAccess('remoteConsent')) {
                    mapTypeOption.remove('remoteConsent');
                }
                
                if(!checkRoleAccess('clienteling')){
                    mapTypeOption.remove('clienteling');
                }
                
                vars.put('emailTypeOptions', mapTypeOption.values());
            }
            when 'Case' {
                record = BL_EMAIL_Utils.getRecordDetail(BL_EMAIL_Constants.USE_CASE_REQUEST_FIELDS, recordId);
                contact = BL_EMAIL_Contacts_Helper.getContactById((Id) record.get('clientId'));

                if(String.isNotEmpty((String) record.get('suppliedEmail'))){
                    Map<String, Object> defaultEmail = new Map<String, Object> {
                        'type' => 'Email',
                        'name' => record.get('suppliedName'),
                        'email' => record.get('suppliedEmail')
                    };
                    vars.put('defaultTo', defaultEmail);
                }else{
                    vars.put('defaultTo', contact);
                }
                vars.put('defaultContact', contact);

                String recordTypeId = (String) String.valueOf(record.get('recordTypeId'));
                Boolean isDPCA = (recordTypeId == requestDigitalPrivateCA)? true : false;

                setDataFromQueue((String) record.get('countryCode'), (String) record.get('queueName'), recordId, 'Case', isDPCA);
            }
            when 'Task' {
                record = BL_EMAIL_Utils.getRecordDetail(usecase, recordId);
                contact = BL_EMAIL_Contacts_Helper.getContactById((Id) record.get('accountId'));
                setDataFromQueue((String) record.get('country'), null, recordId, 'Task', false);
                vars.put('defaultTo', contact);
            }
            when 'Family_Member__c','CareService__c'{
                record = BL_EMAIL_Utils.getRecordDetail(usecase, recordId);
                contact = BL_EMAIL_Contacts_Helper.getContactById((Id) record.get('clientId'));
                vars.put('defaultTo', contact);
                if(objectType == 'CareService__c'){
                    String storeId = (String)record.get('store');
                    String iso3Code = getIso3CodeFromStore(storeId);
                    setDataFromQueue(iso3Code, null, recordId, 'CareService__c', false);
                }
            }
            when 'EmailMessage' {
                record = BL_EMAIL_Utils.getRecordDetail(usecase, recordId);
                String historyEmail = buildHistoryHTMLBody(record);

                Map<String, Object> defaultFrom = new Map<String, Object>();
                defaultFrom.put('name', '');
                defaultFrom.put('email', (String)record.get('toAddress'));
                defaultFrom.put('type', 'Custom');
                defaultFrom.put('id', '');
                contact.put('name', (String)record.get('fromName'));
                contact.put('email', (String)record.get('validatedFromAddress'));
                contact.put('type', 'Custom');
                contact.put('id', '');
               
                vars.put('defaultTo', contact);
                vars.put('defaultFrom', defaultFrom);
                vars.put('defaultHistory', historyEmail);
                vars.put('isDisplayHistoryButton', true);
                
            }
        }
        vars.put('recordId', recordId);
        vars.put('listFoldersTemplateName', getFoldersTemplateName(application, recordId));
    }

    public static String getFoldersTemplateName(String application, Id recordId) {
        String requestDigitalPrivateCA = String.valueOf(Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Digital_Private_CA')?.getRecordTypeId());    
        String defaultFolderTemplate ='ICONiCS_Templates';
        List<String> defaultList = new List<String>{'ICONiCS_Templates','Distant_Care_Service_template'};
        String objectType = recordId.getSObjectType().getDescribe().getName();    

        switch on application {
            when 'ICONICS' {
                switch on objectType {
                    when 'Account' {
                        // listFoldersTemplateName.addAll(defaultList);
                        listFoldersTemplateName.add(defaultFolderTemplate);
                    }
                    when 'CareService__c' {
                        listFoldersTemplateName.add('Distant_Care_Service_template');
                    }
                    when 'Family_Member__c' {
                        listFoldersTemplateName.add('Clean_Client_Database_Templates');
                    }
                    when 'Alias__c' {
                        listFoldersTemplateName.add(defaultFolderTemplate);
                    }
                    when 'Case' {
                        Map<String, Object> record = new Map<String, Object>();
                        record = BL_EMAIL_Utils.getRecordDetail(BL_EMAIL_Constants.USE_CASE_REQUEST_FIELDS, recordId);
                        String recordTypeId = (String) String.valueOf(record.get('recordTypeId'));
                        if(recordTypeId == requestDigitalPrivateCA) {
                            listFoldersTemplateName.add('DPCA_Templates');
                        }
                        else {
                            // listFoldersTemplateName.addAll(defaultList);
                            listFoldersTemplateName.add(defaultFolderTemplate);
                        }
                    }
                    when else {
                        listFoldersTemplateName.add(defaultFolderTemplate);
                    }
                }
            }
            when else {
                listFoldersTemplateName.add(defaultFolderTemplate);
            }
        }        
        return string.join(listFoldersTemplateName,';');
    }
    
    public static void setDataFromQueue(String countryIso3Code, String queueDeveloperName, Id recordId, String objectName, Boolean isDPCA){
        ICX_Queue__mdt queueMetadata;
        if (String.isNotBlank(queueDeveloperName)) {
            queueMetadata = getQueueMataByQueueDeveolperName(queueDeveloperName, objectName);
        } else if (String.isNotBlank(countryIso3Code)) {
            queueMetadata = getQueueMataByCountryCode(countryIso3Code, objectName);
        }

        if (queueMetadata != null){
            List<Object> emailTemplates = (isDPCA)? BL_EMAIL_EmailTemplates_Helper.getEmailTemplateByDeveloperName(queueMetadata.DPCA_Email_Template_DeveloperName__c, recordId):BL_EMAIL_EmailTemplates_Helper.getEmailTemplateByDeveloperName(queueMetadata.EmailTemplateDeveloperName__c, recordId);
            Map<String, Object> sender = BL_EMAIL_Config_Helper.getSenderAddressByEmail(queueMetadata.TargetEmail__c);
            vars.put('defaultFrom', sender);
            vars.put('defaultTemplate', !emailTemplates.isEmpty()  ? emailTemplates?.get(0) : null);
        }
    }

    public static String  getUseCaseByObject(String objectType){
        switch on objectType {
            when 'Account'  {
                return BL_EMAIL_Constants.USE_CASE_SEARCH_CLIENT;
            }
            when 'Case' {
                return BL_EMAIL_Constants.USE_CASE_REQUEST_FIELDS;
            }
            when 'CareService__c' {
                return BL_EMAIL_Constants.USE_CASE_CARESERVICE_FIELDS;
            }
            when 'Family_Member__c' {
                return BL_EMAIL_Constants.USE_CASE_FAMILY_FIELDS;
            }
            when 'Task' {
                return BL_EMAIL_Constants.USE_CASE_TASK_FIELDS;
            }
            when 'EmailMessage' {
                return BL_EMAIL_Constants.USE_CASE_EMAIL_MESSAGE_FIELDS;
            }
        }
        return null;
    }



    public static ICX_Queue__mdt getQueueMataByCountryCode(String countryIso3Code, String objectName) {
        return (ICX_Queue__mdt) getQueueMataData('CountryIso3Code__c',countryIso3Code, objectName);
    }

    public static ICX_Queue__mdt getQueueMataByQueueDeveolperName(String queueDeveloperName, String objectName) {
        return (ICX_Queue__mdt) getQueueMataData('QueueDeveloperName__c',queueDeveloperName, objectName);
    }

    public static SObject getQueueMataData(String field, String value, String objectName){
        String condition;
        if(objectName == 'CareService__c'){
            condition = 'isDCS__c = true';
        }else if(objectName == 'Case'){
            condition = 'IsCSC__c = true';
        }

        return new BL_EasyQuery()
            .objectName('ICX_Queue__mdt')
            .fields(new String[]{'Id', 'EmailTemplateDeveloperName__c', 'TargetEmail__c', 'DPCA_Email_Template_DeveloperName__c'})
            .condition(field + '= \'' + value + '\'')
            .addCondition(condition)
           // .addCondition('NOT QueueDeveloperName__c LIKE \'%Priority\'')
            .executeQuery()
            .getSObject();
    }

    public static String getIso3CodeFromStore(String storeId){
        String iso3Code;
       	List<Store__c> storeList = [SELECT Id, Store_CountryCode__c FROM Store__c WHERE Id =: storeId LIMIT 1];
        if(!storeList.isEmpty()){
            CountryMapping__mdt cm = (CountryMapping__mdt) getCountryMapping(storeList[0].Store_CountryCode__c);
            iso3Code = cm?.Iso3Code__c;
        }
        return iso3Code;
    }  

    public static SObject getCountryMapping(String countryIso2Code){
        return new BL_EasyQuery()
                                .objectName('CountryMapping__mdt')
                                .fields(new String[]{'Id', 'DeveloperName', 'Iso2Code__c', 'Iso3Code__c'})
                                .condition( 'Iso2Code__c = \'' + countryIso2Code + '\'')
                                .executeQuery()
                                .getSObject();
    }

    public static List<Map<String, Object>> getEmailTypeOption() {
        return new BL_EasyQuery()
            .useCase(BL_EMAIL_Constants.USE_CASE_EMAIL_TYPE)
            .executeQuery()
            .getMappedObjects();
    }

    public static String buildHistoryHTMLBody(Map<String, Object> record){
        String oldBody = removeReferenceFromHTML((String)record.get('HtmlBody'));
        String newBody = '<hr><br><br/><br/><p>--------------------------------Original Message--------------------------------</p>';
        newBody += '<p class="MsoNormal"><b><span style="font-size: 11pt">From:</span></b><span style="font-size: 11pt">'+ (String)record.get('validatedFromAddress') + '<br/>';
        newBody += '<b>To: </b>'+ (String)record.get('toAddress') + '<br />';
        newBody += '<b>Subject: </b>'+ (String)record.get('subject') + '</span></p><br/><br/><br/>';
		newBody += 	oldBody;  
        return newBody;
    }
    
    private static String removeReferenceFromHTML(String htmlBody){
        String refPattern = 'thread:[\\w\\W]+:';
        Pattern threadRef  = Pattern.compile(refPattern);
        Matcher m = threadRef.matcher(htmlBody);

        if(m.find()){
            htmlBody = m.replaceAll('');
        }
        
        return htmlBody;
    }
}