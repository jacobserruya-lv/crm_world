global with sharing class BL_IWA_SearchClient  extends BL_WS_Request implements BL_WS_Interfaces.DispatchableGET {
    
    global Object executeGET(){
        
        string  searchText = getQueryParameter('searchterm');
        integer pageSize = getQueryParameter('pageSize')  == null  ? 50 : integer.valueOf(getQueryParameter('pageSize'));
        integer pageIndex = getQueryParameter('pageIndex') == null ? 0  : integer.valueOf(getQueryParameter('pageIndex'));
           
        return new BL_WS_Response(searchByText(searchText, pageSize ,pageIndex));
    }

    public static Object searchByText(string searchText , integer pageSize, integer pageIndex ){
    
        return new BL_EasyQuery()
            .useCase(BL_ICON_Constants.USE_CASE_IW_CLIENT)
            .pagination(pageIndex, pageSize)
            .searchText(searchText)
            .executeSearch()
            .getMappedObjects();
    }     
}