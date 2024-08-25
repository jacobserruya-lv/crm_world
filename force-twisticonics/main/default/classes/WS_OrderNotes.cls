@RestResource(urlMapping='/orderNotes/*')
global with sharing class WS_OrderNotes {

    @HttpPost
    global static void upsertOrderNotes() {
        
        RestRequest httpRequest = RestContext.request;
        RestResponse httpResponse = RestContext.response;        
        httpResponse.addHeader('Content-Type','application/json');

        String body = httpRequest.requestBody.toString();

        JSON2OrderNotes orderNotesWS;

        Map<String,Map<String, JSON2OrderNotes.OrderNote>> orderNotesMap = new Map<String,Map<String, JSON2OrderNotes.OrderNote>>();
        
        try {
            orderNotesWS = JSON2OrderNotes.parse(body);
            system.debug(orderNotesWS);
            // To store the orderNumbers
            List<String> orderNumbers = new List<String>();
            List<String> shippingNumbers = new List<String>();
            String keyMap;
            if (orderNotesWS?.orderNotes == null) throw new WSOrderNotesException('Exception in WS_OrderNotes. Missing attribute "orderNotes"');
            
            for(JSON2OrderNotes.OrderNote orderNote : orderNotesWS.orderNotes) {
                // ****************************************** //
                // STEP 1 - CHECK mandatory values            //
                // ****************************************** //
                WS_OrderNotes.checkMandatoryFields(orderNote);

                // ***************************************************** //
                // STEP 2 - Construct MAP in order to identify duplicate //
                // ***************************************************** //                
                keyMap = orderNote.orderNumber+(orderNote.shippingNumber!=null?'_'+orderNote.shippingNumber:'');
                
                if (orderNotesMap.get(keyMap) == null) {
                    orderNotesMap.put(keyMap, new Map<String, JSON2OrderNotes.OrderNote>());
                }
                
                if (orderNotesMap.get(keyMap).get(orderNote.orderType) == null) {
                    orderNotesMap.get(keyMap).put(orderNote.orderType, orderNote);                    
                }
                else {
                    // We can create only one record for same OrderNumber/shippingNumber and OrderType
                    throw new WSOrderNotesException('Exception in WS_OrderNotes. Duplicate "orderType": '+orderNote+' AND '+(orderNotesMap.get(keyMap)).get(orderNote.orderType));
                }
                
                // List of "orderNumber"
                orderNumbers.add(orderNote.orderNumber);
                // List of "shippingNumber"
                if (orderNote.shippingNumber!=null) shippingNumbers.add(orderNote.shippingNumber);
            }

            // ****************************************** //
            // STEP 3 - Create Order Note                 //
            // ****************************************** //
            List<Order_note__c> orderNotesToAdd = new List<Order_Note__c>();
            Order_note__c newOrderNote;
            for(JSON2OrderNotes.OrderNote orderNote : orderNotesWS.orderNotes) {
                newOrderNote = new Order_Note__c();
                
                // if (orderNote.shippingNumber == null) {
                //     newOrderNote.Tech_OrderNumber__c = orderNote.OrderNumber;
                //     newOrderNote.Type__c            = orderNote.orderType.name();
                //     newOrderNote.Description__c     = orderNote.description;

                //     orderNotesToAdd.add(newOrderNote);                        
                //    }
                // else {
                    newOrderNote.Tech_OrderNumber__c = orderNote.OrderNumber;
                    newOrderNote.Tech_shippingNumber__c = orderNote.shippingNumber;
                    newOrderNote.Type__c            = orderNote.orderType;
                    newOrderNote.Description__c     = orderNote.description;
                    newOrderNote.Reason__c          = orderNote.reasonCode;

                    orderNotesToAdd.add(newOrderNote);
                //   }

                system.debug('newOrderNote: ' + newOrderNote);

                
            }


            // // ****************************************** //
            // // STEP 4 - Insert Order Notes                //
            // // ****************************************** //
            Database.SaveResult[] srList = Database.insert(orderNotesToAdd, true);


            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully inserted Order Note. Order Note ID: ' + sr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Order Note fields that affected this error: ' + err.getFields());
                    }
                }
            }

            // // ****************************************** //
            // // STEP 5a - Response OK                       //
            // // ****************************************** //
            WS_OrderNotesHttpResponse response = new WS_OrderNotesHttpResponse();
            httpResponse.responseBody = Blob.valueOf(JSON.serialize(response));
            httpResponse.statusCode = 200;

            
            OrderNoteService.syncWithOrder(orderNumbers, shippingNumbers);
        }
        Catch(Exception ex) {
            // // ****************************************** //
            // // STEP 5b - Response Error                   //
            // // ****************************************** //
            WS_OrderNotesHttpResponseError response = new WS_OrderNotesHttpResponseError(ex);
            httpResponse.responseBody = Blob.valueOf(JSON.serialize(response));
            httpResponse.statusCode = 400;
        }
        finally{
        }

        // return response;
    }

    public static void checkMandatoryFields(JSON2OrderNotes.OrderNote orderNote) {
        // Common mandatory fields

        // ** orderType **
        if (orderNote.orderType == null) throw new WSOrderNotesException('Exception in WS_OrderNotes. Missing "orderType": '+orderNote);
        // ** orderNumber **
        if (orderNote.orderNumber == null) throw new WSOrderNotesException('Exception in WS_OrderNotes. Missing "orderNumber": '+orderNote);
        
        // ** description **
        if (orderNote.isAttachedNote() || orderNote.isPaymentLink() || orderNote.isExtendedPaymentLink() || orderNote.isPayAfterAgreement()) {
           if (orderNote.description == null) throw new WSOrderNotesException('Exception in WS_OrderNotes. Missing "description": '+orderNote);
        }

        // ** shippingNumber **
        if (orderNote.isClientelingException() || orderNote.isPriceAdjustment()) {
            if (orderNote.shippingNumber == null) throw new WSOrderNotesException('Exception in WS_OrderNotes. Missing "shippingNumber": '+orderNote);
        }
        else {
            if (orderNote.shippingNumber != null) throw new WSOrderNotesException('Exception in WS_OrderNotes. "shippingNumber" not allowed: '+orderNote);
        }

        // ** reasonCode **
        if (orderNote.isClientelingException() || orderNote.isPriceAdjustment() || orderNote.isFreeShipping()) {
            if (orderNote.reasonCode == null) throw new WSOrderNotesException('Exception in WS_OrderNotes. Missing "reasonCode": '+orderNote); 
            // ** description ** If Reason is None of Above
           if (orderNote.reasonCode == 'NoneOfAbove' && orderNote.description == null) throw new WSOrderNotesException('Exception in WS_OrderNotes. Missing "description": '+orderNote);
        }
        else if (!orderNote.isPersoProductRefused()) {            
            if (orderNote.reasonCode != null) throw new WSOrderNotesException('Exception in WS_OrderNotes. "reasonCode" not allowed: '+orderNote);
        }

        // Specific mandatory fields 
        // if (orderNoteWS.orderType.equals(JSON2OrderNotes.OrderType.CLIENTELING_EXCEPTION)) {    
        // }
        // else if (orderNoteWS.orderType.equals(JSON2OrderNotes.OrderType.PRICE_ADJUSTMENT)) {                
        // }
    }

    
    public class WSOrderNotesException extends Exception {}

    // global static void upsertOrderNotes() {
        
    //     RestRequest httpRequest = RestContext.request;
    //     RestResponse httpResponse = RestContext.response;        
    //     httpResponse.addHeader('Content-Type','application/json');

    //     String body = httpRequest.requestBody.toString();

    //     JSON2OrderNotes orderNotesWS;

    //     Map<String,Map<String, JSON2OrderNotes.OrderNote>> orderNotesMap = new Map<String,Map<String, JSON2OrderNotes.OrderNote>>();

    //     try {
    //         orderNotesWS = JSON2OrderNotes.parse(body);
    //         system.debug(orderNotesWS);
    //         // To store the orderNumbers
    //         Set<String> orderNumberSet = new Set<String>();
    //         Set<String> shippingNumberSet = new Set<String>();
    //         String keyMap;
    //         if (orderNotesWS?.orderNotes == null) throw new WSOrderNotesException('Exception in WS_OrderNotes. Missing attribute "orderNotes"');
            
    //         for(JSON2OrderNotes.OrderNote orderNote : orderNotesWS.orderNotes) {
    //             // ****************************************** //
    //             // STEP 1 - CHECK mandatory values            //
    //             // ****************************************** //
    //             WS_OrderNotes.checkMandatoryFields(orderNote);

    //             // ***************************************************** //
    //             // STEP 2 - Construct MAP in order to identify duplicate //
    //             // ***************************************************** //                
    //             keyMap = orderNote.orderNumber+(orderNote.shippingNumber!=null?'_'+orderNote.shippingNumber:'');
                
    //             if (orderNotesMap.get(keyMap) == null) {
    //                 orderNotesMap.put(keyMap, new Map<String, JSON2OrderNotes.OrderNote>());
    //             }
                
    //             if (orderNotesMap.get(keyMap).get(orderNote.orderType.name()) == null) {
    //                 orderNotesMap.get(keyMap).put(orderNote.orderType.name(), orderNote);                    
    //             }
    //             else {
    //                 // We can create only one record for same OrderNumber/shippingNumber and OrderType
    //                 throw new WSOrderNotesException('Exception in WS_OrderNotes. Duplicate "orderType": '+orderNote+' AND '+(orderNotesMap.get(keyMap)).get(orderNote.orderType.name()));
    //             }
                
    //             // List of "orderNumber"
    //             orderNumberSet.add(orderNote.orderNumber);
    //             // List of "shippingNumber"
    //             if (orderNote.shippingNumber!=null) shippingNumberSet.add(orderNote.shippingNumber);
    //         }
            
    //         // Does the OrderNumber exists in Salesforce ?
            
    //         Map<String, Order__c> existingOrderMap = new Map<String, Order__c>();
    //         Map<String, OrderShipping__c> existingOrderShippingMap = new Map<String, OrderShipping__c>();

    //         system.debug('orderNumberSet: '+orderNumberSet);
    //         Order__c[] orders = [SELECT id, orderNumber__c, ownerId FROM Order__c WHERE orderNumber__c in :orderNumberSet];
    //         for(Order__c order: orders) {
    //             existingOrderMap.put(order.orderNumber__c,order);
    //         }

    //         system.debug('shippingNumberSet: '+shippingNumberSet);
    //         OrderShipping__c[] orderShippings = [SELECT id, shippingNumber__c, order__c FROM OrderShipping__c WHERE shippingNumber__c in :shippingNumberSet];
    //         for(OrderShipping__c orderShipping: orderShippings) {
    //             existingOrderShippingMap.put(orderShipping.shippingNumber__c, orderShipping);
    //         }

    //         system.debug('existingOrderMap: '+existingOrderMap);
    //         system.debug('existingOrderShippingMap: '+existingOrderShippingMap);

    //         // ****************************************** //
    //         // STEP 3 - Create Order Note                 //
    //         // ****************************************** //
    //         List<Order_note__c> orderNotesToAdd = new List<Order_Note__c>();
    //         Order_note__c newOrderNote;
    //         for(JSON2OrderNotes.OrderNote orderNote : orderNotesWS.orderNotes) {
    //             newOrderNote = new Order_Note__c();
                
    //             if (orderNote.shippingNumber == null) {
    //                 // Order hasn't yet been created
    //                 if (!existingOrderMap.containsKey(orderNote.orderNumber)) {                        
    //                     System.debug('Order hasn\'t yet been created');
    //                     newOrderNote.Tech_OrderNumber__c = orderNote.OrderNumber;
    //                     newOrderNote.Type__c            = orderNote.orderType.name();
    //                     newOrderNote.Description__c     = orderNote.description;

    //                     orderNotesToAdd.add(newOrderNote);                        
    //                 }
    //                 // Order already exists
    //                 else {
    //                     newOrderNote.Order__c       = existingOrderMap.get(orderNote.OrderNumber).Id;
    //                     newOrderNote.Type__c        = orderNote.orderType.name();
    //                     newOrderNote.Description__c = orderNote.description;
    //                     newOrderNote.OwnerId        = existingOrderMap.get(orderNote.OrderNumber).OwnerId;

    //                     orderNotesToAdd.add(newOrderNote);
    //                 }
    //             }
    //             else {
    //                 // OrderShipping hasn't yet been created
    //                 if (!existingOrderShippingMap.containsKey(orderNote.shippingNumber)) {
    //                     System.debug('OrderShipping hasn\'t yet been created');
    //                     //newOrderNote.Tech_OrderNumber__c = orderNote.OrderNumber;
    //                     newOrderNote.Tech_shippingNumber__c = orderNote.shippingNumber;
    //                     newOrderNote.Type__c            = orderNote.orderType.name();
    //                     newOrderNote.Description__c     = orderNote.description;
    //                     newOrderNote.Reason__c          = orderNote.reasonCode;

    //                     orderNotesToAdd.add(newOrderNote);
    //                 }
    //                 // OrderShipping already exists
    //                 else {
    //                     // Check if orderNumber matches with shippingNumber
    //                     if (existingOrderMap.get(orderNote.OrderNumber).Id != existingOrderShippingMap.get(orderNote.shippingNumber).Order__c) {
    //                         throw new WSOrderNotesException('Exception in WS_OrderNotes. "orderNumber" doesn\'t match with "shippingNumber". '+orderNote);      
    //                     }
    //                     else {
    //                         //newOrderNote.Order__c           = existingOrderMap.get(orderNote.OrderNumber).Id;
    //                         newOrderNote.Order_Shipping__c  = existingOrderShippingMap.get(orderNote.shippingNumber).Id;
    //                         newOrderNote.Type__c            = orderNote.orderType.name();
    //                         newOrderNote.Description__c     = orderNote.description;
    //                         newOrderNote.OwnerId            = existingOrderMap.get(orderNote.OrderNumber).OwnerId;
    //                         newOrderNote.Reason__c          = orderNote.reasonCode;

    //                         orderNotesToAdd.add(newOrderNote);
    //                     }
    //                 }
    //             }

    //             system.debug('newOrderNote: ' + newOrderNote);

                
    //         }


    //         // // ****************************************** //
    //         // // STEP 4 - Insert Order Notes                //
    //         // // ****************************************** //
    //         Database.SaveResult[] srList = Database.insert(orderNotesToAdd, true);


    //         for (Database.SaveResult sr : srList) {
    //             if (sr.isSuccess()) {
    //                 // Operation was successful, so get the ID of the record that was processed
    //                 System.debug('Successfully inserted Order Note. Order Note ID: ' + sr.getId());
    //             }
    //             else {
    //                 // Operation failed, so get all errors                
    //                 for(Database.Error err : sr.getErrors()) {
    //                     System.debug('The following error has occurred.');                    
    //                     System.debug(err.getStatusCode() + ': ' + err.getMessage());
    //                     System.debug('Order Note fields that affected this error: ' + err.getFields());
    //                 }
    //             }
    //         }

    //         // // ****************************************** //
    //         // // STEP 5a - Response OK                       //
    //         // // ****************************************** //
    //         WS_OrderNotesHttpResponse response = new WS_OrderNotesHttpResponse();
    //         httpResponse.responseBody = Blob.valueOf(JSON.serialize(response));
    //         httpResponse.statusCode = 200;
    //     }
    //     Catch(Exception ex) {
    //         // // ****************************************** //
    //         // // STEP 5b - Response Error                   //
    //         // // ****************************************** //
    //         WS_OrderNotesHttpResponseError response = new WS_OrderNotesHttpResponseError(ex);
    //         httpResponse.responseBody = Blob.valueOf(JSON.serialize(response));
    //         httpResponse.statusCode = 400;
    //     }
    //     finally{

    //     }

    //     // return response;
    // }

}