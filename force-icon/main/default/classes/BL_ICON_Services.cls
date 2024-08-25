/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-16-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   03-16-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
global with sharing class BL_ICON_Services extends BL_WS_Request implements BL_WS_Interfaces.DispatchableGET, BL_WS_Interfaces.DispatchablePUT{
    global Object executeGET(){
        String feature = (getPathParameter('feature') != null ? getPathParameter('feature') : null);
        String featureId = (getPathParameter('featureId') != null ? getPathParameter('featureId') : null);

        return new BL_WS_Response(getFeatureByFeatureId(featureId, feature));
    }

    global Object executePUT(){
        String feature = (getPathParameter('feature') != null ? getPathParameter('feature') : null);
        String featureId = (getPathParameter('featureId') != null ? getPathParameter('featureId') : null);
        Object record = getRequestRecord();
        return new BL_WS_Response(updateFeatureByFeatureId(featureId, feature, record));
    }

    global Object getFeatureByFeatureId(String featureId,String feature){
        switch on feature{
            when 'repairs' {
                return  new BL_EasyQuery()
                .useCase(BL_ICON_Constants.USE_CASE_CARE_SERVICES_FULL)
                .condition('Id = \''+ featureId + '\'')
                .executeQuery()
                .getMappedObject();
            }

            when 'surveys' {
                Map<String, Object> record =  new BL_EasyQuery()
                    .useCase(BL_ICON_Constants.USE_CASE_SURVEY_FULL)
                    .condition('Id = \''+ featureId + '\'')
                    .executeQuery()
                    .getMappedObject();
                
				 if(record.get('feedbackID') != null){
                    Object answers = new BL_EasyQuery()
                        .useCase(BL_ICON_Constants.USE_CASE_VOICE_ANSWERS)
                        .condition('due__Diduenjoy_Feedback__r.due__InternalId__c = \''+ record.get('feedbackID') + '\'')
                        .orderBy('due__Step__c, due__Position__c')
                        .executeQuery()
                        .getMappedObjects();

                    record.put('answers', answers);
                }
                
                if(record.get('idTransaction') != null){
                    Object transactions = new BL_EasyQuery()
                        .useCase(BL_ICON_Constants.USE_CASE_PURSHASE)
                        .condition('TransactionRMSId__c = \''+ record.get('idTransaction') + '\'')
                        .executeQuery()
                        .getMappedObjects();

                    record.put('transactions', transactions);
                }
                return record;
            }

            when 'requests' {
                
                // ---- remove after china mediator Swagger update 
        		// ---- start feature
                if( (getQueryParameter('feature') == 'xstoreOrders' || getQueryParameter('feature') == 'nyorders')  && getQueryParameter('uqp') == 'true'){
                    
                    Object records =  new BL_EasyQuery()
                    .useCase( getQueryParameter('feature') == 'xstoreOrders' ? BL_ICON_Constants.USE_CASE_XSTORE_ORDERS_FULL : BL_ICON_Constants.USE_CASE_NY_ORDERS_FULL)
                    .condition('Id = \''+ featureId + '\'')
                    .orderBy('CreatedDate DESC')
                    .executeQuery()
                    .getMappedObject();
                   
                    return records;
                }
        		// ---- end feature


                Map<String,Object>  records = new BL_EasyQuery()
                .useCase(BL_ICON_Constants.USE_CASE_CLIENT_REQUEST_FULL)
                .condition('Id = \''+ featureId + '\'')
                .executeQuery()
                .getMappedObject();
                
                List<Object> contentDocument = (List<Object>)new BL_EasyQuery()
                .useCase(BL_ICON_Constants.USE_CASE_CONTENT_DOCUMENT)
                .condition('LinkedEntityId IN (SELECT Id FROM EmailMessage WHERE  ParentId = \''+ featureId + '\')') 
                .executeQuery()
                .getResponseMappedObjects()
                .get('records');
    
    
                if(!contentDocument.isEmpty()){
                    if(records.containsKey('contentDocumentLinks')){     
                        contentDocument.addAll((List<Object>)records.get('contentDocumentLinks'));
                    }
                    records.put('contentDocumentLinks',contentDocument);
                }
    
                
                return records;

                
            }
            when 'xstoreOrders' {

                Map<String,Object> record =  new BL_EasyQuery()
                .useCase(BL_ICON_Constants.USE_CASE_XSTORE_ORDERS_FULL)
                .condition('Id = \''+ featureId + '\'')
                .orderBy('CreatedDate DESC')
                .executeQuery()
                .getMappedObject();
                
                List<Map<String,Object>> shippingRecords = (List<Map<String,Object>>) record.get('shippings') ;
                                
              	List<Map<String,Object>> commissionedCARecords =  new BL_EasyQuery()
                            .useCase(BL_ICON_Constants.USE_CASE_COMMISSIONED_CA)
                            .condition('Order_Shipping__r.Order__c = \''+ featureId + '\'')
                            .executeQuery()
                            .getMappedObjects();
                
               	Map<String, List<Object>> commissionedCAbyShipping = new Map<String, List<Object>>();
                for(Map<String,Object> recordCa : commissionedCARecords){
                    String shippingId = (String)recordCa.get('shippingId');
                    
                    if(!commissionedCAbyShipping.containsKey(shippingId)){
                        commissionedCAbyShipping.put(shippingId ,new List<Object>());
                    }
                    commissionedCAbyShipping.get(shippingId).add(recordCa);
                }
                
                for(Map<String,Object> shipping : shippingRecords){
             
                    String shippingId = (String)shipping.get('id');
                    shipping.put('commissionedCA' , commissionedCAbyShipping.get(shippingId));
                }
               
                record.put('shippings', shippingRecords);     

                return record;

            }
            when 'nyorders' {


                Object records =  new BL_EasyQuery()
                .useCase(BL_ICON_Constants.USE_CASE_NY_ORDERS_FULL)
                .condition('Id = \''+ featureId + '\'')
                .orderBy('CreatedDate DESC')
                .executeQuery()
                .getMappedObject();
               
                return records;

            }
        }

        throw new BL_Exceptions.CLTException('FEATURE IS MISSING');
    }

    global Object updateFeatureByFeatureId(String featureId,String feature, Object record){

        Object response = null;
        Map<String, Object> obj = ((Map<String, Object>) record);
        obj.put('id', featureId);
        
        switch on feature{

            when 'repairs' {
                response =  new BL_EasyQuery()
                .useCase(BL_ICON_Constants.USE_CASE_CARE_SERVICES_FULL)
                .upsertWrappersWithChilds(new List<Object>{obj}, null, null);
            }

            when 'surveys' {
                new BL_EasyQuery()
                .useCase(BL_ICON_Constants.USE_CASE_SURVEY_FULL)
                .upsertWrappersWithChilds(new List<Object>{obj}, null, null);

                response =  getFeatureByFeatureId(featureId,feature);
            }

            when 'requests' {
                response =   new BL_EasyQuery()
                .useCase(BL_ICON_Constants.USE_CASE_CLIENT_REQUEST_FULL)
                .upsertWrappersWithChilds(new List<Object>{obj}, null, null);
            }
            when 'xstoreOrders' {
                response =   new BL_EasyQuery()
                .useCase(BL_ICON_Constants.USE_CASE_XSTORE_ORDERS)
                .upsertWrappersWithChilds(new List<Object>{obj}, null, null);
            }
            when 'nyorders' {
                response =   new BL_EasyQuery()
                .useCase(BL_ICON_Constants.USE_CASE_NY_ORDERS)
                .upsertWrappersWithChilds(new List<Object>{obj}, null, null);
            }
        }

        if((String) obj.get('status') == 'Closed' || (Boolean) obj.get('isClosedByIcon')){

            BL_ICON_Todos_Helper.closeToDoAssistant(featureId, (String) obj.get('to_do_type'));

        }
        return  response;



    }
    
}