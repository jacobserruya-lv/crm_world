global with sharing class BL_ICON_Client  extends BL_WS_Request implements BL_WS_Interfaces.DispatchableGET, BL_WS_Interfaces.DispatchablePOST, BL_WS_Interfaces.DispatchablePUT{

    global Object executeGET(){
        
        String pathId = getPathParameter('clientId');
        String wcwid;
        if(getQueryParameter('wcwid') != null){
            wcwid = getQueryParameter('wcwid'); 
        }

        try {

            BL_ICON_Client_Helper.isTypedTimeline = getQueryParameter('typedTimeline') != null;
            String clientId = BL_ICON_Client_Helper.checkParameters(pathId, wcwid);
            Integer featuresSampleLimit  = (getQueryParameter('featuresSampleLimit') != null ? Integer.valueof(getQueryParameter('featuresSampleLimit')) : 10);
            Integer pageIndex = getQueryParameter('pageIndex') != null ? Integer.valueOf(getQueryParameter('pageIndex')) :null;
            Integer pageSize = getQueryParameter('pageSize') != null  ? Integer.valueOf(getQueryParameter('pageSize')) : null;
            String features;
            

            if(getQueryParameter('features') != null){
                features = getQueryParameter('features'); 
            }
            else if(getPathParameter('feature') != null){
                features = (String)getPathParameter('feature'); 
                if(getQueryParameter('featuresSampleLimit') == null){
                    featuresSampleLimit = -1;
                }
            }
            
            String featureId  = (getPathParameter('featureId') != null ? (String)getPathParameter('featureId') : null); 
            
            // ---- remove after china mediator Swagger update 
            // ---- start feature
            if(String.isNotEmpty(clientId) && getQueryParameter('feature') != null && getQueryParameter('featureId') != null && getQueryParameter('uqp') == 'true'){
                String mfeature = getQueryParameter('feature'); 
                String mfeatureId  = getQueryParameter('featureId');
                return BL_ICON_Client_Helper.getClientByFeatures(clientId, mfeature, featuresSampleLimit, mfeatureId, me, pageIndex, pageSize);
            }
            // ---- end feature
    
            if (String.isNotEmpty(clientId) && features == null)
                return BL_ICON_Client_Helper.getAllClientDetails(clientId, featuresSampleLimit, me);
            else if(String.isNotEmpty(clientId) && features != null){
                return BL_ICON_Client_Helper.getClientByFeatures(clientId, features, featuresSampleLimit, featureId, me, pageIndex, pageSize);
            }
            
        } catch (BL_Exceptions.RouterException e) {
            if(String.isNotEmpty(wcwid)) 
                return new Map<String,string>{'message'=> 'Client not Bound / Found'}; 
            throw e; 
        }
        throw new BL_Exceptions.RouterException('Invalid Client REST Method - Parameter is missing');   
              
    
    }

    global Object executePOST(){
        String clientId = getPathParameter('clientId');
        Object record = getRequestRecord();
        Object records = getRequestRecords();
        String feature = getPathParameter('feature');

        //Interactive Wardrobing
        if(path == '/list-clients' ){ //&& String.isEmpty(clientId)
            return BL_ICON_Client_Helper.getClientsByClientIds( (Map<String,Object>)record ,0,0);
        }
        if(path == '/clients-data' ){ 
            return BL_ICON_Client_Helper.getClientsByDreamIds( (Map<String,Object>)record ,0,0);
        }
        if(path == '/assign-clients'){
            return BL_ICON_Client_Helper.assignClients( (Map<String,Object>)record );
        }
        return BL_ICON_Client_Helper.upsertFeatureByClient(clientId, feature, records != null ? records : record, me);
    }

    global Object executePUT(){
        String clientId = getPathParameter('clientId');
        Object record = getRequestRecord();
        String feature = getPathParameter('feature'); 
        String featureId = getPathParameter('featureId'); 
        
        // ---- remove after china mediator Swagger update 
        // ---- start feature
        if (feature == 'requests' && getQueryParameter('uqp') == 'true' && getQueryParameter('feature') != ''){
            feature = getQueryParameter('feature');
        }
        System.debug('Use feature');
        System.debug(feature);
        // ---- end feature
        return BL_ICON_Client_Helper.updateFeatureByFeatureId(clientId, featureId, feature, record, me);
    }
}