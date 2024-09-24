global with sharing class BL_IWA_Client extends BL_WS_Request implements BL_WS_Interfaces.DispatchableGET {
    
    global Object executeGET(){

        String pathId = getPathParameter('clientId');

        return getClient(pathId);
    }


    public static Object getClient(String clientId) {
        List<Map<String, Object>> clientData = (List<Map<String, Object>>) new BL_EasyQuery()
        .useCase(BL_IWA_Constants.USE_CASE_IW_CLIENT)
        .condition('Id = \'' + clientId + '\'')
        .usage(BL_EasyQuery.Usage.FOR_REFERENCE)
        .limitCount(1)
        .executeQuery()
        .getResponseMappedObjects()
        .get('records');
        
         
        return clientData[0];
    }
}