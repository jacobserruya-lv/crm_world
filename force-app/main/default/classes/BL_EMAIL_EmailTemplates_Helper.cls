public with sharing class BL_EMAIL_EmailTemplates_Helper {    

    static List<String> folders = new List<String>{'Email','EmailTemplate'};


    public static List<Object> getEmailTemplateList(String application, integer pageSize, integer pageIndex, List<String> listFoldersTemplateName) {
        return new BL_EasyQuery()
            .useCase(BL_EMAIL_Constants.USE_CASE_EMAIL_TEMPLATE)
            .condition('IsActive = true')
            .addCondition('Folder.DeveloperName IN ' + BL_Utils.convertToString(listFoldersTemplateName)) 
            .addCondition('Folder.Type IN ' + BL_Utils.convertToString(folders) )
            .pagination(pageIndex, pageSize)
            .executeQuery()
            .getMappedObjects();
    }

    public static List<Object> searchEmailTemplate(String searchText, String application ,integer pageSize, integer pageIndex, List<String> listFoldersTemplateName){
        return new BL_EasyQuery()
            .useCase(BL_EMAIL_Constants.USE_CASE_EMAIL_TEMPLATE)
            .condition('IsActive = true')
            .addCondition('Folder.DeveloperName IN ' + BL_Utils.convertToString(listFoldersTemplateName))
            .addCondition('Folder.Type IN ' + BL_Utils.convertToString(folders) )
            .pagination(pageIndex, pageSize)
            .searchText(searchText)
            .executeSearch()
            .getMappedObjects();
    }

    public static List<Object> getEmailTemplateById(String emailTemplateId , Id recordId) {
        return getEmailTemplateByCondtion('Id',emailTemplateId, recordId);
    }

    public static List<Object> getEmailTemplateByDeveloperName(String developerName, Id recordId) {
        return getEmailTemplateByCondtion('DeveloperName',developerName, recordId);
    }

    public static List<Map<String,Object>> getEmailTemplateByCondtion(String field, String value, Id recordId) {
        List<Map<String,Object>> records =  new BL_EasyQuery()
            .useCase(BL_EMAIL_Constants.USE_CASE_EMAIL_TEMPLATE_DETAILS)
            .condition(field + ' = \'' + value + '\'')
            .executeQuery()
            .getMappedObjects();

            if(recordId != null) {
                for (Map<String, Object> emailTemplate : records) { 
                    emailTemplate.put('htmlValue', BL_EMAIL_QuickText_Helper.getMergeFields(String.ValueOf(emailTemplate.get('htmlValue')), recordId));
                }
            }

        return records;
    }
}