public without sharing class Account_OrderDetailsControllerLC {

    @AuraEnabled
    public static JSON2KbrwOrderV2 getOrderDetailsTwistV2(string orderId, boolean isRecordId){
        system.debug('getOrderDetailsTwistV2 orderId and isRecordId : '+orderId + ' ' + isRecordId);
        
        JSON2KbrwOrderV2 orderDetails = new JSON2KbrwOrderV2(); 
        String orderNumber;
        try { 
            orderNumber = (isRecordId == true? getOrderNumber(orderId) : orderId);
            system.debug('getOrderDetailsTwistV2 orderNumber : '+orderNumber );
           
           if(String.IsNotEmpty(orderNumber)){
                orderDetails = WS_OrderDetails.getOrderDetailsTwistV2(orderNumber);
           }
           system.debug(orderDetails);
           return orderDetails;
         
       } catch (Exception e) {
            System.debug('JGU-Error in AccountDetailsControllerLC-getOrderDetailsTwistV2');
           throw new AuraHandledException(e.getMessage());   
       } 
    }

//     @AuraEnabled
//     public static JSON2KbrwOrder getOrderDetailsTwist(string orderId, boolean isRecordId){

//         JSON2KbrwOrder orderDetails = new JSON2KbrwOrder(); 
//        String orderNumber;
//        try { 
//            orderNumber = (isRecordId == true? getOrderNumber(orderId) : orderId);
           
//            if(String.IsNotEmpty(orderNumber)){
//                 orderDetails = WS_OrderDetails.getOrderDetailsTwist(orderNumber);
//            }
//            system.debug('Account_OrderDetailsControllerLC getOrderDetailsTwist orderDetails : '+orderDetails);
//            return orderDetails;
         
//        } catch (Exception e) {
//             System.debug('JGU-Error in AccountDetailsControllerLC');
//            throw new AuraHandledException(e.getMessage());   
//        } 
//    }

     @AuraEnabled
     public static Object getOrderDetails(string orderId, boolean isRecordId){
        Map<String,Object> orderDetails = new Map<String,Object> (); 
        String orderNumber;
        try { 
            orderNumber = (isRecordId == true? getOrderNumber(orderId) : orderId);
            
            if(String.IsNotEmpty(orderNumber)){
                 orderDetails = WS_OrderDetails.getOrderDetails(orderNumber);
            }
            system.debug(orderDetails);
            return orderDetails;
          
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());   
        } 
    }

    // Get OrderNumber for the Web Service 
    @AuraEnabled(cacheable=true)
    public static string  getOrderNumber(String orderId){
        String orderNumber;
        if(Id.Valueof(orderId).getSObjectType().getDescribe().getName() == 'Order__c'){
            List<Order__c> orderRecord = [SELECT Id, OrderNumber__c FROM Order__c WHERE id = :orderId  limit 1];
            orderNumber = (orderRecord.isEmpty() ? null : orderRecord.get(0).OrderNumber__c);
        }
        return orderNumber;
    }

    // Get Order Id For redirection from OrderLine or OrderShipping Page
    @AuraEnabled(cacheable=true)
    public static String getOrderId(String orderLineId){
        String sobjectType;
        String orderId ;

        if(String.IsNotEmpty(orderLineId) && (Id.Valueof(orderLineId).getSObjectType().getDescribe().getName() == 'OrderShipping__c' || Id.Valueof(orderLineId).getSObjectType().getDescribe().getName() == 'OrderLine__c')){
            sobjectType = Id.Valueof(orderLineId).getSObjectType().getDescribe().getName();
            SObject s =	 Database.query(  
                                  ' SELECT Id , order__c'
                                + ' FROM '+ String.escapeSingleQuotes(sobjectType)
                                + ' WHERE Id = \'' + String.escapeSingleQuotes(orderLineId) + '\''
                                );
                              
            orderId = String.ValueOf(s.get('order__c'));
        }
        return orderId;
    }

    @AuraEnabled(cacheable=true)
    public static Boolean backOfficeUser(){
        Id userId = UserInfo.getuserid();
        Id teamRoleId = IconicsSettings__c.getInstance().BackOfficeId__c;

        List<AggregateResult> backOfficeUser =[SELECT COUNT(id) Number
                                                      FROM CaseTeamTemplateMember 
                                                      WHERE TeamRoleId =:  teamRoleId AND MemberId=:userId];

        Object NumberBackOffice = backOfficeUser[0].get('Number');   
        if(Integer.valueOf(NumberBackOffice) > 0) {
            return true ;
        }                                          
        return false ;
    }

    @AuraEnabled(cacheable=true)
    public static Boolean backOfficeUser2(){
        Profile profileIdBO = [Select Id From Profile Where Name='ICONiCS_Back_Office' LIMIT 1];

        return UserInfo.getProfileId()==profileIdBO.Id;
    }


    @AuraEnabled(cacheable=true)
    public static Map<String,List<String>>  reasonPicklist(){
      // return getPicklistValue('OrderShipping__c', 'Reason__c').values(); 
       return DependentPicklistBitset.GetDependentOptions('OrderShipping__c' ,'Action__c' ,'Reason__c');
    }


    @AuraEnabled(cacheable=true)
    public static Map<String ,String> actionPicklist(){
       return getPicklistValue('OrderShipping__c', 'Action__c');
    }


    public static void shippingToUpdate(String orderAction, String actionMessage ,Id shippingId) {
        OrderShipping__c shipping = new OrderShipping__c(Id = shippingId);

        shipping.SubmitedDate__c = System.Now();
        shipping.SubmitedBy__c = UserInfo.getuserid();
        shipping.Reason__c = actionMessage;
        shipping.Action__c = orderAction;
        
        update shipping;
     }


     public static void insertTraceability(String orderAction, String actionMessage ,Id shippingId, String employeeId, String orderNumber, String additionnalInformation) {
        System.debug('insertTraceability params : '+orderAction+' / ' + actionMessage+' / ' + shippingId+' / ' + employeeId + ' / ' + orderNumber+' / ' + additionnalInformation) ;  

        List<OrderShipping__c> orderShippingList = new List<OrderShipping__c>();
       
        if (shippingId != null && orderNumber == null) {
            orderShippingList = [Select Order__c From OrderShipping__c Where id = :shippingId];
        }

        Traceability__c traceability = new Traceability__c();
        if(employeeId != null ) traceability.SubmitedBy__r = new User(WWEmployeeNumber__c=employeeId);
        else traceability.SubmitedBy__c = UserInfo.getUserId();
        traceability.SubmitedDate__c = Datetime.now();
        traceability.Action__c = orderAction != null ? orderAction : null;
        traceability.Reason__c = actionMessage != null ? actionMessage : null;
        traceability.AdditionalInformation__c = additionnalInformation != null ? additionnalInformation : '';
        if(orderNumber != null ) traceability.Order__r = new Order__c(OrderNumber__c = orderNumber);
        else if(shippingId != null ) traceability.Order__c = orderShippingList.get(0)?.Order__c;
        if(shippingId != null ){
            traceability.OrderShipping__c = shippingId;
        }

        System.debug('Account_OrderDetailsControllerLC insertTraceability : '+traceability);

        insert traceability;
     }
   
     

    @AuraEnabled
    public static Map<String,Object> sendAction(String orderId, String requestingSystem, String actionMessage, String orderAction ,Id shippingId, String lineNumber){
        Map<String,Object> body = new Map<String,Object>{
                                    'id' => orderId,
                                    'requesting_system' => requestingSystem != null ? requestingSystem : 'ICONICS',
                                    'action_message' => actionMessage != null ? actionMessage : '',
                                    'action' => orderAction != null ? orderAction : ''
                                    };
        if(lineNumber != null) body.put('line_number',lineNumber);
        System.debug('sendOrderDetails body : '+body);

        Map<String, Object> response = new Map<String, Object>();

        try { 
            response  = WS_OrderAction.sendOrderDetails(JSON.serialize(body));

            if(response.get('statusCode') == 200) {
                response.put('status', 'success');
                response.put('message', 'The Order modification attempt has been submitted successfully \n Please check order status for action confirmation');
                if(shippingId != null)  shippingToUpdate(orderAction, actionMessage , shippingId);
                insertTraceability(orderAction, actionMessage , shippingId, null, null, null);
            }
            if(response.get('statusCode') == 400) {
                response.put('message', 'The submission is rejected, order is not longer available for action');
            }
            if(response.get('statusCode') == 404) {
                response.put('message', 'The submission is rejected, order not found in KBRW');
            }
            if(response.get('statusCode') != 200) {
                handleLightningError(String.valueOf(response.get('message')));
            }
        }
        catch (Exception e ) {
            response = new Map<String,Object>{'status' => 'error',  'message' => e.getMessage()};
            handleLightningError(String.valueOf(response.get('message')));
        }
        System.debug('sendAction responseResponse : '+ response);
        return response;
    }

    public static void handleLightningError(String message){
        AuraHandledException ex = new AuraHandledException(message);
        ex.setMessage(message);
        throw ex;
     }

     

    @AuraEnabled
    public static Map<String,Object> sendActionReturn(
        String requestingSystem, 
        String channel, 
        String orderType, 
        String employeeId, 
        String requestingLocation, 
        String requestIdToReturn, 
        String reasonCode,
        String orderNumber, 
        Id shippingId, 
        String orderAction) {
    
            Map<String,Object> body = new Map<String,Object>{
                                'requesting_system' => requestingSystem != null ? requestingSystem : 'ICONICS',
                                'channel' => channel != null ? channel : 'CSC',
                                'order_type' => orderType,
                                'requesting_location' => requestingLocation,
                                'request_id_to_return' => requestIdToReturn,
                                'reason_code' => reasonCode
                                };
            System.debug('sendActionReturn body : '+body);
    
            Map<String, Object> response = new Map<String, Object>();
    
            try { 
                response  = WS_OrderAction.sendOrderReturn(JSON.serialize(body));
                if(response.get('statusCode') == 200) {
                    response.put('status', 'success');
                    response.put('message', 'The Order modification attempt has been submitted successfully \n Please check order status for action confirmation');
                    if(shippingId != null) {
                        Order_Action_Reason__mdt actionReason = OrderActionReasonService.getByReasonCode(orderAction, reasonCode);
                        shippingToUpdate(orderAction, actionReason.MasterLabel , shippingId);
                        insertTraceability(orderAction, actionReason.MasterLabel , shippingId, employeeId,orderNumber,null);
                    }
                } else if(response.get('statusCode') == 504) {
                    response.put('status', 'success');
                    response.put('message', 'The Order modification attempt has been submitted \n Please check order status for action confirmation');
                    if(shippingId != null) {
                        Order_Action_Reason__mdt actionReason = OrderActionReasonService.getByReasonCode(orderAction, reasonCode);
                        shippingToUpdate(orderAction, actionReason.MasterLabel , shippingId);
                        insertTraceability(orderAction, actionReason.MasterLabel , shippingId, employeeId, orderNumber, null);
                    }
                } else {
                    response.put('status', 'error');
                    String error = (String)response.get('error') != null ? (String)response.get('error') :(String)response.get('message');
                    String message = requestIdToReturn + ': ' + error;
                    response.put('message', message);
                }
            }
            catch (Exception e ) {
                response = new Map<String,Object>{'status' => 'catch error',  'message' => e.getMessage()};
            }
            System.debug('sendActionReturn Response : '+ response);
            return response;
    }

    @AuraEnabled
    public static Map<String,Object> sendActionFundsReception(String requestingSystem, String amount, String paymentMethod, String transactionType, String employeeId, String orderAction, String orderNumber, String requestId){
        System.debug('sendActionFundsReception params : '  + amount + ' / ' +paymentMethod+ ' / ' + transactionType + ' / ' + employeeId + ' / ' + orderAction+ ' / ' + orderNumber);

        Map<String, Object> response = new Map<String, Object>();

        try {
            response = callToFinor(requestingSystem,transactionType, amount,paymentMethod,employeeId,orderNumber,requestId);     
            if(response.get('statusCode') == 204 || response.get('statusCode') == 504 ) insertTraceability(orderAction,null,null, employeeId, orderNumber, paymentMethod);
        } catch (Exception e) {
            response = new Map<String,Object>{'status' => 'catch error',  'message' => e.getMessage()};   
        }
        System.debug('sendActionFundsReception Response : '+ response);

        return response;
    }


    @AuraEnabled
    public static Map<String,Object> sendActionRefund(String requestingSystem, String amount, String paymentMethod, String employeeId, String orderNumber, String orderAction, String reasonCode, Id shippingId, String requestId){
        System.debug('sendActionRefund params : ' + amount + ' / ' +paymentMethod+ ' / ' + reasonCode + ' / ' + employeeId + ' / ' + orderNumber + ' / ' + orderAction+ ' / ' + requestId + ' / ' +shippingId);
       
        Map<String, Object> response = new Map<String, Object>();
        try {
            Order_Action_Reason__mdt actionReason = OrderActionReasonService.getByReasonCode(orderAction, reasonCode); 

            response = callToFinor(requestingSystem,'REFUND', amount,paymentMethod,employeeId,orderNumber,requestId);     
            if(response.get('status') != 'error' ) insertTraceability(orderAction, actionReason.MasterLabel , shippingId, employeeId, orderNumber, paymentMethod);
        } catch (Exception e) {
            response = new Map<String,Object>{'status' => 'catch error',  'message' => e.getMessage()};   
        }
        System.debug('sendActionRefund Response : '+ response);

        return response;
    }

    @AuraEnabled
    public static Map<String,Object> sendActionManualRefundShippingFees(String requestingSystem, String amount, String paymentMethod, String employeeId, String orderNumber, String orderAction){
        System.debug('sendActionRefund params : ' + amount + ' / ' +paymentMethod + ' / ' + employeeId + ' / ' + orderNumber + ' / ' + orderAction);
       
        Map<String, Object> response = new Map<String, Object>();
        try {
            

            String requestId = orderNumber+'_fees'; //special request id for refund shipping fees

           response = callToFinor(requestingSystem,'REFUND', amount,paymentMethod,employeeId,orderNumber,requestId);     
           if(response.get('status') != 'error' ) insertTraceability(orderAction, null , null, employeeId, orderNumber, paymentMethod);
        } catch (Exception e) {
            response = new Map<String,Object>{'status' => 'catch error',  'message' => e.getMessage()};   
        }
        System.debug('sendActionRefund Response : '+ response);

        return response;
    }

    @AuraEnabled
    public static Map<String,Object> sendActionRefundShippingFees(String requestingSystem, Double amount, String paymentMethod, String employeeId, String orderNumber, String orderAction, String reasonCode, String shippingNumber, Id shippingId, String lineNumber){
        system.debug('JGU-WS-sendActionRefundShippingFees: '+amount+'/'+paymentMethod+'/'+employeeId+'/'+orderNumber+'/'+orderAction + '/' + shippingNumber + '/' + '/' + shippingId);
        Map<String,Object> response = new Map<String,Object>();
       
        Order_Action_Reason__mdt actionReason = OrderActionReasonService.getByReasonCode(orderAction, reasonCode);

        try {
            //send shipping number for id param to OMS
            response = sendAction(shippingNumber,null,actionReason?.MasterLabel,orderAction,shippingId, lineNumber);
            shippingToUpdate(orderAction,actionReason?.MasterLabel,shippingId);
            // if (paymentMethod == 'BANK_TRANSFER') { 
            //     response = callToFinor(requestingSystem,'REFUND', String.valueOf(amount),paymentMethod,employeeId,orderNumber,null);  
            //     System.debug('sendActionRefundShippingFees response FINOR : '+response) ;  
            //     insertTraceability(orderAction, actionReason?.MasterLabel , shippingId, employeeId, orderNumber, paymentMethod);
            // } else {
            //     System.debug('sendActionRefundShippingFees else actionReason?.MasterLabel : '+actionReason?.MasterLabel) ;  
            //     insertTraceability(orderAction,actionReason?.MasterLabel,shippingId, employeeId, orderNumber, paymentMethod);
            // }
            insertTraceability(orderAction,actionReason?.MasterLabel,shippingId, employeeId, orderNumber, paymentMethod);

            
        } catch (Exception e) {
            response = new Map<String,Object>{'status' => 'catch error',  'message' => e.getMessage()};   
        }
        System.debug('sendOrderRefundShippingFees response '+response);
        return response;   
    }

    @AuraEnabled
    public static Map<String,Object>  callToFinor(String requestingSystem,String transactionType, String amount,  String paymentMethod, String employeeId, String orderNumber, String requestId){
        System.debug('callToFinor params : '+ transactionType + ' / ' + amount + ' / ' +paymentMethod+  ' / ' + employeeId +  ' / '+ requestId);        
        Map<String,Object> response = new Map<String,Object>();
        try {

            response = WS_OrderAction.callFinor(requestingSystem, transactionType, amount,  paymentMethod,  employeeId, orderNumber, requestId);
            
            if(response.get('statusCode') == 204) {
                response.put('status', 'success');
                response.put('message', 'The Order modification attempt has been submitted successfully \n Please check order status for action confirmation');
            } else if(response.get('statusCode') == 504) {
                response.put('status', 'success');
                response.put('message', 'The Order modification attempt has been submitted \n Please check order status for action confirmation');
            } else {
                response.put('status', 'error');
                String error = (String)response.get('error') != null ? (String)response.get('error') :(String)response.get('message');
                String message = orderNumber + ': ' + error;
                response.put('message', message);
            } 

        } catch (Exception e) {
            response = new Map<String,Object>{'status' => 'catch error',  'message' => e.getMessage()};   
        }
        System.debug('callToFinor Response : '+ response);

        return response;
    }

   //Order Exchange Action Add by Keman  
    @AuraEnabled
    public static Map<String,Object> sendActionExchange(String orderNumber, Id shippingId,String reasonCode,String orderAction){
        system.debug('JGU-WS-sendActionExchange: '+orderNumber+'/'+shippingId+'/'+reasonCode+'/'+orderAction);
        return WS_OrderAction.sendOrderExchange(orderNumber, shippingId, reasonCode,orderAction);
    }

    private static Map<String ,String> getPicklistValue(String selectedObject, String selectedField){
        Map<String ,String> picklistValue = new  Map<String ,String>();
        DescribeSObjectResult objResult = Schema.getGlobalDescribe().get(selectedObject).getDescribe();
        DescribeFieldResult fieldResult = objResult.fields.getMap().get(selectedField).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple) {
            picklistValue.put(f.getValue(),f.getLabel());
        }  
        return  picklistValue;
    }
    @AuraEnabled
    public static Object getProductMap(List<String> SKUList){
        return Account_DigitalOrderListControllerLWC.getProductMap(SKUList);
    }
    @AuraEnabled
    public static string getStoreType(Id storeId){
       return [select StoreType__c from Store__c where id =: storeId].StoreType__c;
    }

}