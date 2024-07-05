global with sharing class BL_EMAIL_QuickText  extends BL_WS_Request implements BL_WS_Interfaces.DispatchableGET {
    
    static final Integer MAX_RESULTS = 10;
    enum UseCase {QUICK_TEXT_LIST, QUICK_TEXT }

    private UseCase getUseCase(){
        switch on path {
            when '/quick-texts' {
                return UseCase.QUICK_TEXT_LIST;
            }
            when '/quick-texts/{id}' {
                return UseCase.QUICK_TEXT;
            }
        }
        return null;
    }
    
    global Object executeGET(){
        Integer pageSize = getQueryParameter('limit') != null ? Integer.valueOf(getQueryParameter('limit')) : MAX_RESULTS;
        Integer pageIndex = getQueryParameter('offset') != null ? Integer.valueOf(getQueryParameter('offset')) : 0;
        String feature = getQueryParameter('feature') != null ? String.valueOf(getQueryParameter('feature')) : 'recent';
     
        switch on getUseCase() {
            when QUICK_TEXT_LIST {
                String searchTerm = (getQueryParameter('searchText') != null ? getQueryParameter('searchText') : null);
                String parentId = getQueryParameter('parentId') != null ? String.valueOf(getQueryParameter('parentId')) : null;

                if(String.isNotEmpty(searchTerm)) 
                    return new BL_WS_Response( 
                        BL_EMAIL_QuickText_Helper.searchQuickText(searchTerm, pageSize, pageIndex)
                    );
                
                switch on feature {
                    when 'all' {
                        return new BL_WS_Response(     
                            BL_EMAIL_QuickText_Helper.getQuickText(parentId, pageSize, pageIndex) 
                        );
                    }
                    when 'recent' {
                        return new BL_WS_Response(     
                            BL_EMAIL_QuickText_Helper.getRecentQuickText(pageSize)
                        );
                    }
                }
            }
            when QUICK_TEXT {
                Id quicktextId = (getPathParameter('id') != null ? Id.valueOf(getPathParameter('id')) : null);
                Id recordId = (getQueryParameter('recordId') != null ? Id.valueOf(getQueryParameter('recordId')) : null);
                return new BL_WS_Response(     
                    BL_EMAIL_QuickText_Helper.getQuickTextById(quicktextId, recordId)
                );
            }
        }
        return null;
    }
}