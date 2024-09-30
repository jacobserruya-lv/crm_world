global with sharing class BL_EMAIL_Contacts extends BL_WS_Request implements BL_WS_Interfaces.DispatchableGET {
    
    static final Integer MAX_RESULTS = 10;
    enum UseCase {CONTACT_LIST, CONTACT}

    private UseCase getUseCase(){
        switch on path {
            when '/contacts' {
                return UseCase.CONTACT_LIST;
            }
            when '/contacts/{id}' {
                return UseCase.CONTACT;
            }
        }
        return null;
    }

    global Object executeGET(){
        Integer pageSize = getQueryParameter('limit') != null ? Integer.valueOf(getQueryParameter('limit')) : MAX_RESULTS;
        Integer pageIndex = getQueryParameter('offset') != null ? Integer.valueOf(getQueryParameter('offset')) : 0;
        
        switch on getUseCase() {
            when CONTACT_LIST {
                String searchTerm = (getQueryParameter('searchText') != null ? getQueryParameter('searchText') : null);   
                return new BL_WS_Response( 
                    BL_EMAIL_Contacts_Helper.searchClientOrUser(searchTerm, pageSize, pageIndex)
                );
            }
            when CONTACT {
                String idContact = (getPathParameter('id') != null ? getPathParameter('id') : null);
                return new BL_WS_Response( 
                    BL_EMAIL_Contacts_Helper.getContactById(idContact)
                );
            }
        }
        return null;
    }
}


