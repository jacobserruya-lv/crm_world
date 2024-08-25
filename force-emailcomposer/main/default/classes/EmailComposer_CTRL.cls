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
   
    public static void setDatas(Id recordId, string application){
        Map<String,Object> defaultValues = new  Map<String,Object>();
        Map<String, Object> contact ;
        List<Map<String,Object>> emailTypeOptions;
        String objectType = recordId.getSObjectType().getDescribe().getName();
        vars.put('objectType', objectType);
        String usecase = getUseCaseByObject(objectType);
        Map<String, Object> record = new Map<String, Object>();


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

                setDataFromQueue((String) record.get('countryCode'), (String) record.get('queueName'), recordId);
            }
            when 'Task' {
                record = BL_EMAIL_Utils.getRecordDetail(usecase, recordId);
                contact = BL_EMAIL_Contacts_Helper.getContactById((Id) record.get('accountId'));
                setDataFromQueue((String) record.get('country'), null, recordId);
                vars.put('defaultTo', contact);
            }
            when 'Family_Member__c','CareService__c'{
                record = BL_EMAIL_Utils.getRecordDetail(usecase, recordId);
                contact = BL_EMAIL_Contacts_Helper.getContactById((Id) record.get('clientId'));
                vars.put('defaultTo', contact);
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
    
    public static void setDataFromQueue(String countryIso3Code, String queueDeveloperName, Id recordId){
        ICX_Queue__mdt queueMetadata;
        if (String.isNotBlank(queueDeveloperName)) {
            queueMetadata = getQueueMataByQueueDeveolperName(queueDeveloperName);
        } else if (String.isNotBlank(countryIso3Code)) {
            queueMetadata = getQueueMataByCountryCode(countryIso3Code);
        }

        if (queueMetadata != null){
            List<Object> emailTemplates = BL_EMAIL_EmailTemplates_Helper.getEmailTemplateByDeveloperName(queueMetadata.EmailTemplateDeveloperName__c, recordId);
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
        }
        return null;
    }



    public static ICX_Queue__mdt getQueueMataByCountryCode(String countryIso3Code) {
        return (ICX_Queue__mdt) getQueueMataData('CountryIso3Code__c',countryIso3Code);
    }

    public static ICX_Queue__mdt getQueueMataByQueueDeveolperName(String queueDeveloperName) {
        return (ICX_Queue__mdt) getQueueMataData('QueueDeveloperName__c',queueDeveloperName);
    }

    public static SObject getQueueMataData(String field, String value){
        return new BL_EasyQuery()
            .objectName('ICX_Queue__mdt')
            .fields(new String[]{'Id', 'EmailTemplateDeveloperName__c', 'TargetEmail__c'})
            .condition(field + '= \'' + value + '\'')
            //.addCondition('IsCSC__c = true')
           // .addCondition('NOT QueueDeveloperName__c LIKE \'%Priority\'')
            .executeQuery()
            .getSObject();
    }

    public static List<Map<String, Object>> getEmailTypeOption() {
        return new BL_EasyQuery()
            .useCase(BL_EMAIL_Constants.USE_CASE_EMAIL_TYPE)
            .executeQuery()
            .getMappedObjects();
    }
}