/*

Send to KBRW the Order details for Depriorization/Priorization of an Order 
*/
public with sharing class WS_OrderAction {

    public static Map<String,Object> sendOrderDetails(Map<String,Object> body,Id shippingId) {
        return sendOrderDetails(body, shippingId, true);
    }

    
    public static Map<String,Object> sendOrderDetails(Map<String,Object> body,Id shippingId, Boolean insertTraceability) {

        Map<String,Object> responseToDisplay = new Map<String,String>();
        String parser = JSON.serialize(body);
        String responseField ;
         try { 
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            String endPoint = '/customer-orders/api/orders/v1/action/';
            request.setEndpoint('callout:MULESOFT_KBRW' + endPoint);
            
            request.setMethod('POST');
            request.setTimeout(60000);
            request.setHeader('Encoding', 'UTF-8');
            request.setHeader('Accept', 'application/json');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('client_id', '{!$Credential.UserName}');
			request.setHeader('client_secret', '{!$Credential.Password}');
    
            request.setBody(parser);

            HttpResponse response = http.send(request);               
            system.debug('WS_OrderAction-sendOrderDetails: response.getBody()'+JSON.deserializeUntyped(response.getBody()));
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());

            if (response.getStatusCode() == 200) {
                responseToDisplay = new Map<String,Object>{'status' => 'success',  'message' => 'The Order modification attempt has been submitted successfully \n Please check order status for action confirmation'};                 
                
                // workaround, in order to prevent to record twice traceability records in case of "refund shipping fees" via BANK TRANSFER (because in this case we have to call FINOR too)
                if (insertTraceability) {
                    if(shippingId != null)  shippingToUpdate(body , shippingId);

                    List<OrderShipping__c> os = [Select Order__c From OrderShipping__c Where id = :shippingId];

                    Traceability__c traceability = new Traceability__c();
                    traceability.SubmitedBy__c = UserInfo.getUserId();
                    traceability.SubmitedDate__c = Datetime.now();
                    traceability.Action__c = (String)body.get('action');
                    traceability.Reason__c = (String)body.get('action_message');
                    traceability.AdditionalInformation__c = '';
                    traceability.Order__c = os.get(0)?.Order__c;
                    traceability.OrderShipping__c = shippingId;

                    insert traceability;
                }

            }else {

                system.debug(response.getStatusCode());
                String error1 = 'The submission is rejected, order not found in KBRW';
                String error2 = 'The submission is rejected, order is not longer available for action';

                String error = String.isNotEmpty((String)results.get('error')) ? (String)results.get('error') :(String)results.get('message');

                String message = (response.getStatusCode() == 404 ? error1 : response.getStatusCode() == 400 ? error2 : error  );

                responseToDisplay = new Map<String,Object>{'status' => 'error',  'message' => message};
                handleLightningError(message);
            }
  
          } catch (Exception e) {
              responseToDisplay = new Map<String,Object>{'status' => 'error',  'message' => e.getMessage()};
              handleLightningError(e.getMessage());
              
          }
        return responseToDisplay;
    }

    /**
     *                     
     *  Map<String,Object> body = {
            requesting_system: 'ICONICS',
            channel: "CSC",
            order_type: "SALE",
            employee_id: USER.WWEmployeeNumber__c,
            requesting_location: STORE.RetailStoreId__c,
            request_id_to_return: OrderShipping__c.ShippingNumber__c,
            reason_code: Order_Action_Reason__mdt.Reason_Code__c
            }
     */
    public static Map<String,Object> sendOrderReturn(Map<String,Object> body, String orderNumber, Id shippingId, String orderAction) {

        system.debug('JGU-sendOrderReturn: '+orderNumber+'/'+shippingId+'/'+orderAction);
        system.debug('JGU-sendOrderReturn - body: '+body);
        Map<String,Object> responseToDisplay = new Map<String,String>();

        // IF orderAction = 'DeclareNoShow'
        // THEN the reasoncode must be empty
        // if (orderAction == 'declareNoShowCOD') {
        //     body.remove('reason_code');
        // }

        String parser = JSON.serialize(body);
        
        String responseField ;
        try { 
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            String endPoint = '/customer-orders/api/orders/v1/return/submit/';
            request.setEndpoint('callout:MULESOFT_KBRW' + endPoint);
            
            request.setMethod('POST');
            request.setTimeout(60000);
            request.setHeader('Encoding', 'UTF-8');
            request.setHeader('Accept', 'application/json');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('client_id', '{!$Credential.UserName}');
			request.setHeader('client_secret', '{!$Credential.Password}');
    
            request.setBody(parser);

            Map<String, Object> results;
            HttpResponse response = http.send(request);               
            if (response.getBody() != null) {
                results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            }

            system.debug('JGU-WS_OrderAction results: '+ results);

            if (response.getStatusCode() == 200 || response.getStatusCode() == 504 ) {
                if (response.getStatusCode() == 200) {
                    responseToDisplay = new Map<String,Object>{'status' => 'success',  'message' => 'The Order modification attempt has been submitted successfully \n Please check order status for action confirmation'};
                }
                else {
                    responseToDisplay = new Map<String,Object>{'status' => 'success',  'message' => 'The Order modification attempt has been submitted \n Please check order status for action confirmation'};
                }
                if(shippingId != null) {
                    system.debug('JGU-debug-1');
                    shippingToUpdate(body , shippingId);

                    system.debug('JGU-debug-2');
                    system.debug('JGU-debug-2 - employee_id:' + (String)body.get('employee_id'));
                    system.debug('JGU-debug-2 - reason_code:' + (String)body.get('reason_code'));
                    Order_Action_Reason__mdt actionReason = OrderActionReasonService.getByReasonCode(orderAction, (String)body.get('reason_code'));

                    
                    system.debug('JGU-debug-3');
                    Traceability__c traceability = new Traceability__c();
                    traceability.SubmitedBy__r = new User(WWEmployeeNumber__c=(String)body.get('employee_id'));
                    traceability.SubmitedDate__c = Datetime.now(); //Date.today();
                    traceability.Action__c = orderAction;
                    traceability.Reason__c = actionReason.MasterLabel;
                    traceability.AdditionalInformation__c = '';
                    traceability.Order__r = new Order__c(OrderNumber__c = orderNumber);
                    traceability.OrderShipping__c = shippingId;

                    system.debug('JGU-debug-4');
                    insert traceability;
                    
                    system.debug('JGU-debug-5');
                }
            }else {

                system.debug(response.getStatusCode());
                String error = String.isNotEmpty((String)results.get('error')) ? (String)results.get('error') :(String)results.get('message');

                String message = body.get('request_id_to_return') + ': ' + error;
                
                responseToDisplay = new Map<String,Object>{'status' => 'error',  'message' => message};
            }
  
        } catch (Exception e) {
              responseToDisplay = new Map<String,Object>{'status' => 'catch error',  'message' => e.getMessage()};
        }
        return responseToDisplay;
    }

    public static Map<String,Object> sendOrderFundsReception(Map<String,Object> body, String orderNumber, String orderAction) {
        Map<String,Object> responseToDisplay = new Map<String,String>();
        system.debug('JGU-WS_OrderAction body: '+ body);

        JsonOrderFundsReception bodyToSend = new JsonOrderFundsReception();
        bodyToSend.order_id = (String)body.get('order_id');
        bodyToSend.requesting_system = (String)body.get('requesting_system');
        bodyToSend.amount = (Double)body.get('amount');
        bodyToSend.payment_method = (String)body.get('payment_method');
        bodyToSend.transaction_type = (String)body.get('transaction_type');
        bodyToSend.employee_id = (String)body.get('employee_id');        

        String parser = JSON.serialize(bodyToSend);
        system.debug('JGU-WS_OrderAction parser: '+ parser);
        String responseField ;
        try { 
            Http http = new Http();
            HttpRequest request = new HttpRequest();
string endPoint = '/eco-eu/chckt-finor/v1/api/settlement/v1/create_manual';
            request.setEndpoint('callout:MULESOFT_FINOR' + endPoint);

            request.setMethod('POST');
            request.setTimeout(60000);
            request.setHeader('Encoding', 'UTF-8');
            request.setHeader('Accept', 'application/json');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('client_id', '{!$Credential.UserName}');
			request.setHeader('client_secret', '{!$Credential.Password}');
    
            request.setBody(parser);

            HttpResponse response = http.send(request);               
            //Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());

            //system.debug('JGU-WS_OrderAction results: '+ results);

            if (response.getStatusCode() == 204 || response.getStatusCode() == 504 ) {
                if (response.getStatusCode() == 204) {
                    responseToDisplay = new Map<String,Object>{'status' => 'success',  'message' => 'The Order modification attempt has been submitted successfully \n Please check order status for action confirmation'};
                }
                else {
                    responseToDisplay = new Map<String,Object>{'status' => 'success',  'message' => 'The Order modification attempt has been submitted \n Please check order status for action confirmation'};
                }

                if(orderNumber != null) {
                    system.debug('JGU-debug-3');
                    Traceability__c traceability = new Traceability__c();
                    traceability.SubmitedBy__r = new User(WWEmployeeNumber__c=(String)body.get('employee_id'));
                    traceability.SubmitedDate__c = Datetime.now(); //Date.today();
                    traceability.Action__c = orderAction;
                    traceability.Reason__c = null;
                    traceability.AdditionalInformation__c = (String)body.get('payment_method');
                    traceability.Order__r = new Order__c(OrderNumber__c = orderNumber);

                    system.debug('JGU-debug-4');
                    insert traceability;
                    
                    system.debug('JGU-debug-5');
                }
            }else {
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());

                system.debug(response.getStatusCode());
                String error = String.isNotEmpty((String)results.get('error')) ? (String)results.get('error') :(String)results.get('message');

                String message = orderNumber + ': ' + error;
                
                responseToDisplay = new Map<String,Object>{'status' => 'error',  'message' => message};
            }
  
        } catch (Exception e) {
              responseToDisplay = new Map<String,Object>{'status' => 'catch error',  'message' => e.getMessage()};
        }
        return responseToDisplay;
    }

    public static Map<String,Object> sendOrderRefund(Double amount, String paymentMethod, String employeeId, String orderNumber, String orderAction, String reasonCode, String shippingNumber) {
        return callFinor(amount, paymentMethod, 'REFUND', employeeId, orderNumber, orderAction, reasonCode,shippingNumber);
    }

    public static Map<String,Object> sendOrderRefundShippingFees(Double amount, String paymentMethod, String employeeId, String orderNumber, String orderAction, String reasonCode, String shippingNumber, Integer LineNumber, Id shippingId) {
        Map<String,Object> response = new Map<String,Object>();
        Map<String,Object> body = new Map<String,Object>();
        body.put('id', shippingNumber);
        //body.put('item_id', shippingNumber);
        body.put('requesting_system', 'ICONICS');
        body.put('line_number', lineNumber);
        body.put('action', orderAction);

        Order_Action_Reason__mdt actionReason = OrderActionReasonService.getByReasonCode(orderAction, reasonCode);
        body.put('action_message', actionReason?.MasterLabel);
        
        
 
        response = sendOrderDetails(body, shippingId, !(paymentMethod == 'BANK_TRANSFER'));

        if (response.get('status') == 'error') {
            return response;
        }
        else if (paymentMethod == 'BANK_TRANSFER') {
            return callFinor(amount, paymentMethod, 'REFUND', employeeId, orderNumber, orderAction, reasonCode, shippingNumber);
        }
        else {
            return response;
        }
    }

    // Allow to create a "refund" or declare a "fund reception"
    private static Map<String,Object> callFinor(Double amount, String paymentMethod, String transactionType, String employeeId, String orderNumber, String orderAction, String reasonCode, String shippingNumber) {
        Map<String,Object> responseToDisplay = new Map<String,String>();

        JsonFINOR bodyToSend = new JsonFINOR();
        bodyToSend.order_id = orderNumber;
        bodyToSend.requesting_system = 'ICONICS';
        bodyToSend.amount = amount;
        bodyToSend.payment_method = paymentMethod;
        bodyToSend.transaction_type = transactionType;
        bodyToSend.employee_id = employeeId;
        //add request_id by Keman WU
        bodyToSend.request_id = shippingNumber;

        String parser = JSON.serialize(bodyToSend);
        system.debug('JGU-WS_OrderAction parser: '+ parser);
        String responseField ;
        try { 
            Http http = new Http();
            HttpRequest request = new HttpRequest();
string endPoint = '/eco-eu/chckt-finor/v1/api/settlement/v1/create_manual';
            request.setEndpoint('callout:MULESOFT_FINOR' + endPoint);

            request.setMethod('POST');
            request.setTimeout(60000);
            request.setHeader('Encoding', 'UTF-8');
            request.setHeader('Accept', 'application/json');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('client_id', '{!$Credential.UserName}');
			request.setHeader('client_secret', '{!$Credential.Password}');
    
            request.setBody(parser);

            HttpResponse response = http.send(request);

            if (response.getStatusCode() == 204 || response.getStatusCode() == 504 ) {
                if (response.getStatusCode() == 204) {
                    responseToDisplay = new Map<String,Object>{'status' => 'success',  'message' => 'The Order modification attempt has been submitted successfully \n Please check order status for action confirmation'};
                }
                else {
                    responseToDisplay = new Map<String,Object>{'status' => 'success',  'message' => 'The Order modification attempt has been submitted \n Please check order status for action confirmation'};
                }

                Order_Action_Reason__mdt actionReason = OrderActionReasonService.getByReasonCode(orderAction, reasonCode);

                if(orderNumber != null) {
                    Traceability__c traceability = new Traceability__c();
                    traceability.SubmitedBy__r = new User(WWEmployeeNumber__c=employeeId);
                    traceability.SubmitedDate__c = Datetime.now(); //Date.today();
                    traceability.Action__c = orderAction;
                    traceability.Reason__c = actionReason?.MasterLabel;
                    traceability.AdditionalInformation__c = paymentMethod;
                    traceability.Order__r = new Order__c(OrderNumber__c = orderNumber);

                    insert traceability;
                    
                }
            }else {
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());

                system.debug(response.getStatusCode());
                String error = String.isNotEmpty((String)results.get('error')) ? (String)results.get('error') :(String)results.get('message');

                String message = orderNumber + ': ' + error;
                
                responseToDisplay = new Map<String,Object>{'status' => 'error',  'message' => message};
            }
  
        } catch (Exception e) {
              responseToDisplay = new Map<String,Object>{'status' => 'catch error',  'message' => e.getMessage()};
        }
        return responseToDisplay;
    }

     public static void shippingToUpdate(Map<String,Object> body ,Id shippingId) {

        OrderShipping__c shipping = new OrderShipping__c(Id = shippingId);

        shipping.SubmitedDate__c = System.Now();
        shipping.SubmitedBy__c = UserInfo.getuserid();
        shipping.Reason__c = String.valueOf(body.get('action_message'));
        shipping.Action__c = String.valueOf(body.get('action'));
        
        update shipping;
     }

     public static void handleLightningError(String message){
        AuraHandledException ex = new AuraHandledException(message);
        ex.setMessage(message);
        throw ex;


     }

     // deprecated ?
     public static Map<String,Object> sendOrderExchange(String orderNumber, Id shippingId, String reasonCode,String orderAction) {

        system.debug('JGU-sendOrderExchange: '+orderNumber+'/'+shippingId+'/'+reasonCode);
        Map<String,Object> responseToDisplay = new Map<String,String>();

        JsonExchange bodyToSend = new JsonExchange();
        ExchangeCart myExchangeCart = new ExchangeCart();
        myExchangeCart.exchange_orderId = orderNumber;
        ShippingGroup myShippingGroup = new ShippingGroup();
        myShippingGroup.shipping_group_id = shippingId;
        myShippingGroup.ReasonCode =  reasonCode;           
        myExchangeCart.exchange_shippingGroups = myShippingGroup;       
        bodyToSend.exchangeCart = myExchangeCart;
        String parser = JSON.serialize(bodyToSend);   
        system.debug('Body Exchange'+parser);  
         
        try { 
            Http http = new Http();
            HttpRequest request = new HttpRequest();

            CountryLanguage__c countryLang= ICX_TWIST_OOB.getCountryLanguage();
            String mulesoftLocal = countryLang?.Mulesoft_Local__c!=null ? countryLang.Mulesoft_Local__c : 'eco-eu';

            String endPoint = '/' + mulesoftLocal + '/csc-shp-crt-eapi/v1/carts/' + countryLang.ATG_Locale__c + '/exchange';
            
            request.setEndpoint('callout:MULESOFT_KBRW' + endPoint);
            
            request.setMethod('POST');
            request.setTimeout(60000);
            request.setHeader('Encoding', 'UTF-8');
            request.setHeader('Accept', 'application/json');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('client_id', '{!$Credential.UserName}');
			request.setHeader('client_secret', '{!$Credential.Password}');
            String accessToken = ICX_TWIST_OOB.getSFAgentAccessToken();
            //access token + old cartId
            request.setHeader('Cookie', 'slas_access_token='+accessToken+';'+'cart_id'//+cart_id
            );
    
            request.setBody(parser);

            Map<String, Object> results;
            HttpResponse response = http.send(request);               
            if (response.getBody() != null) {
                results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            }

            system.debug('JGU-WS_OrderActionExchange results: '+ results);

            if (response.getStatusCode() == 200 || response.getStatusCode() == 504 ) {
                if (response.getStatusCode() == 200) {
                   }
                else {
                    }
                if(shippingId != null) {
                    system.debug('JGU-debug-1');
                   // shippingToUpdate(body , shippingId);

                    system.debug('JGU-debug-2');
                    Order_Action_Reason__mdt actionReason = OrderActionReasonService.getByReasonCode(orderAction, reasonCode);

                    system.debug('JGU-debug-3');
                    Traceability__c traceability = new Traceability__c();
                    traceability.SubmitedBy__c = UserInfo.getUserId();
                    traceability.SubmitedDate__c = Datetime.now(); 
                    traceability.Action__c = orderAction;
                    traceability.Reason__c = actionReason.MasterLabel;
                    traceability.AdditionalInformation__c = '';
                    traceability.Order__r = new Order__c(OrderNumber__c = orderNumber);
                    traceability.OrderShipping__c = shippingId;

                    system.debug('JGU-debug-4');
                    insert traceability;
                    
                    system.debug('JGU-debug-5');
                }
            }else {

                system.debug(response.getStatusCode());
                String error = String.isNotEmpty((String)results.get('error')) ? (String)results.get('error') :(String)results.get('message');

                String message = shippingId+ ': ' + error;
                
                responseToDisplay = new Map<String,Object>{'status' => 'error',  'message' => message};
            }
  
        } catch (Exception e) {
              responseToDisplay = new Map<String,Object>{'status' => 'catch error',  'message' => e.getMessage()};
        }
        return responseToDisplay;
    }



     private class JsonOrderFundsReception {
        String order_id;
        String requesting_system;
        Double amount;
        String payment_method;
        String transaction_type;
        String employee_id;
       
     }

     private class JsonFINOR {
        String order_id;
        String requesting_system;
        Double amount;
        String payment_method;
        String transaction_type;
        String employee_id;
        //add request_id by Keman WU
        String request_id;
     }

     private class JsonExchange {
        ExchangeCart exchangeCart;
     }
     private class ExchangeCart{
        String exchange_orderId;
        ShippingGroup exchange_shippingGroups;
     }
     private class ShippingGroup{
        String shipping_group_id;
        String ReasonCode;
     }

}