global with sharing class BL_IWA_Users  extends BL_WS_Request implements BL_WS_Interfaces.DispatchableGET {
    
    global Object executeGET(){
        
        String  searchText = getQueryParameter('searchterm');
        Integer pageSize = getQueryParameter('pageSize')  == null  ? 200 : Integer.valueOf(getQueryParameter('pageSize'));
        Integer pageIndex = getQueryParameter('pageIndex') == null ? 0  : Integer.valueOf(getQueryParameter('pageIndex'));
        String  storeCode = getQueryParameter('storeCode');

        if(String.isNotEmpty(storeCode))
            return new BL_WS_Response(getUsersByStoreCode(storeCode, pageSize ,pageIndex));

        if(String.isNotEmpty(storeCode))
            return new BL_WS_Response(searchByText(searchText, pageSize ,pageIndex));

        return null;
    }

    public static Object searchByText(String searchText, Integer pageSize, Integer pageIndex ){
    
        return new BL_EasyQuery()
            .useCase(BL_IWA_Constants.USE_CASE_SEARCH_USER)
            .pagination(pageIndex, pageSize)
            .searchText(searchText)
            .executeSearch()
            .getMappedObjects();
    }  
    
    public static Object getUsersByStoreCode(String storeCode, Integer pageSize, Integer pageIndex ){
    
        return new BL_EasyQuery()
            .useCase(BL_IWA_Constants.USE_CASE_SEARCH_USER)
            .condition('DefaultStore__c = \''+  storeCode + '\'')
            .pagination(pageIndex, pageSize)
            .executeQuery()
            .getMappedObjects();
    }  
}