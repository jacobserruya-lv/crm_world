global with sharing class BL_ICON_SearchClient extends BL_WS_Request implements BL_WS_Interfaces.DispatchableGET{
    
    global Object executeGET(){
        
        string  searchText = getQueryParameter('searchterm');
        integer pageSize = 50;
        integer pageIndex = 0;
           
        pageSize =  (getQueryParameter('pageSize')  == null   ?  pageSize : integer.valueOf(getQueryParameter('pageSize')));
        pageIndex =  (getQueryParameter('pageIndex') == null   ?  null       : integer.valueOf(getQueryParameter('pageIndex')));
        return new BL_WS_Response(BL_ICON_SearchClient_Helper.searchByText(searchText, getQueryParameter('filters'), pageSize ,pageIndex, me.userDetails));
    }
    
    /*global override void checkValidityRequest(){
        BL_WS_Log.addLogNotes('search check');
        if (String.isBlank(getQueryParameter('text'))){
            throw new BL_Exceptions.CLTException('INVALID SEARCH METHOD');
        }
        if (getQueryParameter('text').length() < 2){
            throw new BL_Exceptions.CLTException('Search Text must be longer than 3 characters');
        }

        if (queryParams.containskey('pageIndex')){
            if(String.isBlank(getQueryParameter('pageIndex')))
                throw new BL_Exceptions.CLTException('PageIndex PARAMETER CANNOT BE EMPTY');
            if(!getQueryParameter('pageIndex').isNumeric())
                throw new BL_Exceptions.CLTException('INVALID PageIndex PARAMETER');
        }
        
        if (queryParams.containskey('pageSize')){
            if(String.isBlank(getQueryParameter('pageSize')))
                throw new BL_Exceptions.CLTException('PAGESIZE PARAMETER CANNOT BE EMPTY');
            if(!getQueryParameter('pageSize').isNumeric())
                throw new BL_Exceptions.CLTException('INVALID PAGESIZE PARAMETER');
        }
    }*/
}