global with sharing class BL_ICON_Ca_Consent extends BL_WS_Request implements BL_WS_Interfaces.DispatchableGET, BL_WS_Interfaces.DispatchablePUT , BL_WS_Interfaces.DispatchablePOST {


    global Object executeGET(){

       Integer pageIndex = getQueryParameter('pageIndex') != null ? Integer.valueOf(getQueryParameter('pageIndex')) :null;
       Integer pageSize = getQueryParameter('pageSize') != null  ? Integer.valueOf(getQueryParameter('pageSize')) : null;

       return BL_ICON_Ca_Consent_Helper.getConsentUserStore(pageIndex,pageSize,me);
             
    }

    global Object executePOST(){

        Object record =  getRequestRecord();
        return BL_ICON_Ca_Consent_Helper.updateConsentUser(record);
    }

    global Object executePUT(){
        String Id = getPathParameter('Id');
        Object record =  getRequestRecord();
        return BL_ICON_Ca_Consent_Helper.updateConsentUser(record);
    }


}