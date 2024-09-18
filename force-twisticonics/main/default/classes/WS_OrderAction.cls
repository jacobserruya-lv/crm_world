/*

Send to KBRW the Order details for Depriorization/Priorization of an Order 
*/
public with sharing class WS_OrderAction {

    public static Map<String,object> sendOrderDetails(String body) {
        String endPoint = '/spl-eu/cust-orders-oms/v1/api/orders/v2/action/';
        HTTP_Utils request = new HTTP_Utils()
        .post('callout:MULESOFT_KBRW'+endpoint)
        .header('Content-Type', 'application/json')
        .header('Accept', 'application/json')
        .header('client_id', '{!$Credential.UserName}')
        .header('client_secret', '{!$Credential.Password}')
        .body(body)
        .timeout(120000)
        .call();

      Map<String, Object> response = request.getBodyResponse();
      response.put('statusCode', request.statusCode());

      system.debug('sendOrderDetails status : '+ request.statusCode());
      system.debug('sendOrderDetails response : '+ response);
      return response;
    }

     
    public static Map<String,Object> sendOrderReturn(String body) {
        String endPoint = '/customer-orders/api/orders/v1/return/submit/';
        // String endPoint = '/spl-eu/cust-orders-oms/v1/api/orders/v2/return/submit/';
        HTTP_Utils request = new HTTP_Utils()
        .post('callout:MULESOFT_KBRW'+endpoint)
        .header('Content-Type', 'application/json')
        .header('Accept', 'application/json')
        .header('client_id', '{!$Credential.UserName}')
        .header('client_secret', '{!$Credential.Password}')
        .body(body)
        .timeout(120000)
        .call();

      Map<String, Object> response = request.getBodyResponse();
      response.put('statusCode', request.statusCode());

      system.debug('sendOrderReturn status : '+ request.statusCode());
      system.debug('sendOrderReturn response : '+ response);
      return response;
    }             
  

    // public static Map<String,Object> sendOrderRefundShippingFees(Double amount, String paymentMethod, String employeeId, String orderNumber, String orderAction, String reasonCode, String shippingNumber,  Id shippingId) {

    //     Map<String,Object> response = new Map<String,Object>();
       
    //     Order_Action_Reason__mdt actionReason = OrderActionReasonService.getByReasonCode(orderAction, reasonCode);
       
    //     Map<String,Object> body = new Map<String,Object>{
    //         'id' => shippingNumber,
    //         'requesting_system' => 'ICONICS',
    //         'action_message' =>  actionReason?.MasterLabel,
    //         'payment_method' => paymentMethod,
    //         'action' => orderAction
    //         };

        
    //     response = sendOrderDetails(JSON.serialize(body));
    //     Account_OrderDetailsControllerLC.shippingToUpdate(orderAction,actionReason?.MasterLabel,shippingId);
        
    //     if(paymentMethod != 'BANK_TRANSFER') Account_OrderDetailsControllerLC.insertTraceability(orderAction,actionReason?.MasterLabel,shippingId, null, null, null);

    //     System.debug('sendOrderRefundShippingFees response '+response);

    //     if (response.get('status') == 'error') {
    //         return response;
    //     }
    //     else if (paymentMethod == 'BANK_TRANSFER') {
    //         return callFinor(null, 'REFUND', String.valueOf(amount),  paymentMethod,  employeeId, orderNumber, shippingNumber);
    //     }
    //     else {
    //         return response;
    //     }
    // }

    // Allow to create a "refund" or declare a "fund reception"
    public static Map<String,Object> callFinor(String requestingSystem, String transactionType, String amount, String paymentMethod, String employeeId, String orderId, String requestId) {

        Map<String,Object> body = new Map<String,Object>{
            'requesting_system' => requestingSystem != null ? requestingSystem : 'ICONICS',
            'order_id' => orderId,
            'amount' => Double.valueOf(amount),
            'payment_method' => paymentMethod,
            'transaction_type' => transactionType,
            'employee_id' => employeeId,
            'request_id' => requestId
            };

            // if(requestId != null) {
            //     body.put('request_id' , requestId);
            // } else body.put('request_id' , orderId + '_fees');


            string endPoint = '/eco-eu/chckt-finor/v1/api/settlement/v1/create_manual';
            HTTP_Utils request = new HTTP_Utils()
            .post('callout:MULESOFT_FINOR'+endpoint)
            .header('Content-Type', 'application/json')
            .header('Accept', 'application/json')
            .header('client_id', '{!$Credential.UserName}')
            .header('client_secret', '{!$Credential.Password}')
            .body(JSON.serialize(body))
            .timeout(120000)
            .call();
    
          Map<String, Object> response = request.getBodyResponse();
          response.put('statusCode', request.statusCode());
    
          system.debug('callFinor status : '+ request.statusCode());
          system.debug('callFinor response : '+ response);
          return response;
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
        system.debug('Body Exchange'+JSON.serialize(bodyToSend));  
         
        Map<String,Object> response = new Map<String,Object>();
        try { 
            CountryLanguage__c countryLang= ICX_TWIST_OOB.getCountryLanguage();            
            String mulesoftLocal = countryLang?.Mulesoft_Local__c!=null ? countryLang.Mulesoft_Local__c : 'eco-eu';            
            String accessToken = ICX_TWIST_OOB.getSFAgentAccessToken();
            String endPoint = '/' + mulesoftLocal + '/csc-shp-crt-eapi/v1/carts/' + countryLang.ATG_Locale__c + '/exchange';
            system.debug('sendOrderExchange endPoint : '+ endPoint);
            
            HTTP_Utils request = new HTTP_Utils()
            .post('callout:MULESOFT_KBRW'+endpoint)
            .header('Content-Type', 'application/json')
            .header('Encoding', 'UTF-8')
            .header('Accept', 'application/json')
            .header('client_id', '{!$Credential.UserName}')
            .header('client_secret', '{!$Credential.Password}')
            .header('Cookie', 'slas_access_token='+accessToken+';'+'cart_id')
            .body(JSON.serialize(bodyToSend))
            .timeout(60000)
            .call();
    
            response = request.getBodyResponse();

            response.put('statusCode', request.statusCode());
        
            system.debug('sendOrderExchange status : '+ request.statusCode());
            system.debug('sendOrderExchange response : '+ response);

            if (response.get('statusCode') == 200 || response.get('statusCode') == 504 ) {
                if(shippingId != null) {
                    system.debug('JGU-debug-1');
                    Order_Action_Reason__mdt actionReason = OrderActionReasonService.getByReasonCode(orderAction, reasonCode);                   
                    Account_OrderDetailsControllerLC.insertTraceability(orderAction, actionReason.MasterLabel , shippingId, null, orderNumber, null);
                    system.debug('JGU-debug-2');
                }
            }else {
                response.put('status', 'error');
                String error = (String)response.get('error') != null ? (String)response.get('error') :(String)response.get('message');
                String message = shippingId + ': ' + error;
                response.put('message', message);
            }
  
        } catch (Exception e) {
            system.debug('sendOrderExchange exception : '+ e);

            response = new Map<String,Object>{'status' => 'catch error',  'message' => e.getMessage()};   
        }
        return response;
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