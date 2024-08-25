public without sharing class Account_OrderDetailsControllerLC {
    
    @AuraEnabled
    public static JSON2KbrwOrder getOrderDetailsTwist(string orderId, boolean isRecordId){
        JSON2KbrwOrder orderDetails = new JSON2KbrwOrder(); 
       String orderNumber;
       try { 
           orderNumber = (isRecordId == true? getOrderNumber(orderId) : orderId);
           
           if(String.IsNotEmpty(orderNumber)){
                orderDetails = WS_OrderDetails.getOrderDetailsTwist(orderNumber);
           }
           system.debug(orderDetails);
           return orderDetails;
         
       } catch (Exception e) {
            System.debug('JGU-Error in AccountDetailsControllerLC');
           throw new AuraHandledException(e.getMessage());   
       } 
   }

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
            List<Order__c> orderRecord = [SELECT Id, OrderNumber__c FROM Order__c WHERE id = :orderId WITH SECURITY_ENFORCED limit 1];
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

    @AuraEnabled
    public static Map<String,Object> sendAction(Map<String,Object> body,Id shippingId){

        return WS_OrderAction.sendOrderDetails(body,shippingId);
    }

    @AuraEnabled
    public static Map<String,Object> sendActionReturn(Map<String,Object> body, String orderNumber, Id shippingId, String orderAction){

        system.debug('JGU-WS-sendActionReturn: '+orderNumber+'/'+shippingId+'/'+orderAction);
        return WS_OrderAction.sendOrderReturn(body, orderNumber, shippingId, orderAction);
    }

    @AuraEnabled
    public static Map<String,Object> sendActionFundsReception(Map<String,Object> body, String orderNumber, String orderAction){

        system.debug('JGU-WS-sendActionFundsReception: '+body+'/'+orderNumber+'/'+orderAction);
        return WS_OrderAction.sendOrderFundsReception(body, orderNumber, orderAction);
    }

    @AuraEnabled
    public static Map<String,Object> sendActionRefund(Double amount, String paymentMethod, String employeeId, String orderNumber, String orderAction, String reasonCode, String shippingNumber){
        system.debug('JGU-WS-sendActionRefund: '+amount+'/'+paymentMethod+'/'+employeeId+'/'+orderNumber+'/'+orderAction+'/'+reasonCode + '/' + shippingNumber);
       return WS_OrderAction.sendOrderRefund(amount, paymentMethod, employeeId, orderNumber, orderAction, reasonCode, shippingNumber);
       //return new Map<String,Object>();
    }

    @AuraEnabled
    public static Map<String,Object> sendActionRefundShippingFees(Double amount, String paymentMethod, String employeeId, String orderNumber, String orderAction, String reasonCode, String shippingNumber, Integer lineNumber, Id shippingId){
        system.debug('JGU-WS-sendActionRefundShippingFees: '+amount+'/'+paymentMethod+'/'+employeeId+'/'+orderNumber+'/'+orderAction + '/' + shippingNumber + '/' + lineNumber + '/' + shippingId);
        return WS_OrderAction.sendOrderRefundShippingFees(amount, paymentMethod, employeeId, orderNumber, orderAction, reasonCode, shippingNumber, lineNumber, shippingId);
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
        System.debug('getPicklistValue picklistValue : '+picklistValue);
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