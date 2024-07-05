global without sharing class BL_ICON_Transactions extends BL_WS_Request implements BL_WS_Interfaces.DispatchableGET{

    global Object executeGET(){
        String clientId = getPathParameter('clientId');
        String eventId = getQueryParameter('eventId');
        Date endRangeDate = (getQueryParameter('endRangeDate') == null ? null : Date.valueOf(getQueryParameter('endRangeDate')));
        return new BL_WS_Response(BL_ICON_Transactions_Helper.getAllValidTransactions(eventId,clientId,me));
    }
}