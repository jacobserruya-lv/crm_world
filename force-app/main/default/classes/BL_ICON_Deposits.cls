global with sharing class BL_ICON_Deposits extends BL_WS_Request implements BL_WS_Interfaces.DispatchableGET, BL_WS_Interfaces.DispatchablePOST, BL_WS_Interfaces.DispatchablePUT{
    global Object executeGET(){
        String clientId = (getQueryParameter('clientId') != null ? getQueryParameter('clientId') : null);
        // String featureId = (getPathParameter('featureId') != null ? getPathParameter('featureId') : null);
        String status = (getQueryParameter('status') != null ? getQueryParameter('status') : null);
        String despositId = (getPathParameter('despositId') != null ? getQueryParameter('despositId') : null);


        if (String.isNotEmpty(clientId) && status == null)
            return BL_ICON_Deposits_Helper.getAllMyClientDeposits(clientId, me);
        else if(String.isNotEmpty(clientId) && status != null){
            return BL_ICON_Deposits_Helper.getMyClientDepositsByStatus(clientId, status, me);
        } else if(status != null){
            return BL_ICON_Deposits_Helper.getMyDepositsByStatus(status, me);
        } else if (String.isNotBlank(despositId)){
            return new BL_WS_Response(BL_ICON_Deposits_Helper.getDepositById(despositId, me));
        } else {
            return new BL_WS_Response(BL_ICON_Deposits_Helper.getAllMyDeposits(me));
        }
    }

    global Object executePOST(){
        Map<String, Object> record = (Map<String, Object>)getRequestRecord();
        return BL_ICON_Deposits_Helper.insertDeposit(record);
    }

    global Object executePUT(){
        Map<String, Object> record = (Map<String, Object> )getRequestRecord();
        String depositId = (getPathParameter('depositId') != null ? getPathParameter('depositId') : null);
        record.put('id', depositId);
        return  new BL_EasyQuery()
                .useCase(BL_ICON_Constants.USE_CASE_DEPOSIT)
                .upsertWrappersWithChilds(new List<Object>{record}, null, null);
    }

}