global with sharing class BL_EMAIL_EmailTemplates extends BL_WS_Request implements BL_WS_Interfaces.DispatchableGET {
    
    enum UseCase {EMAIL_TEMPLATE_LIST, EMAIL_TEMPLATE}

    private UseCase getUseCase(){
        switch on path {
            when '/templates' {
                return UseCase.EMAIL_TEMPLATE_LIST;
            }
            when '/templates/{id}' {
                return UseCase.EMAIL_TEMPLATE;
            }
        }
        return null;
    }

    global Object executeGET(){
        Integer pageSize = getQueryParameter('limit') != null ? Integer.valueOf(getQueryParameter('limit')) : null;
        Integer pageIndex = getQueryParameter('offset') != null ? Integer.valueOf(getQueryParameter('offset')) : null;
        
        switch on getUseCase() {
            
            when EMAIL_TEMPLATE_LIST {
                String searchText = (getQueryParameter('searchText') != null ? getQueryParameter('searchText') : null);
                String application = (getQueryParameter('application') != null ? getQueryParameter('application') : null);
                List<String> listFoldersTemplateName = getQueryParameter('folders') != null ? getQueryParameter('folders').split(';') : new List<String> {'ICONICS_Templates'};

                if(String.isNotEmpty(searchText)) {
                    return new BL_WS_Response( 
                        BL_EMAIL_EmailTemplates_Helper.searchEmailTemplate(searchText, application, pageSize, pageIndex, listFoldersTemplateName)
                    );
                }
                return new BL_WS_Response( 
                    BL_EMAIL_EmailTemplates_Helper.getEmailTemplateList(application, pageSize, pageIndex, listFoldersTemplateName)
                );
            }
            when EMAIL_TEMPLATE {
                String emailTemplateId = (getPathParameter('id') != null ? getPathParameter('id') : null);
                Id recordId = (getQueryParameter('recordId') != null ? Id.valueOf(getQueryParameter('recordId')) : null);
                
                return new BL_WS_Response( 
                    BL_EMAIL_EmailTemplates_Helper.getEmailTemplateById(emailTemplateId, recordId)
                );
            }
        }
        return new Map<String,Object>();
    }

   
}