/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-22-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   02-22-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public without sharing class WS_DigitalOrders {
/**
 * 
 * As for retail, we will retrieve digital orders coming from ATG.
 * When a user opens a client page on ICONiCS application, the web service will be called WITH the client ID
 * The web service returns all the Digital orders for the specified Client .
 * we displayed all the Orders except orders with the status NO_PENDING_ACTION
 * The web service returns a lot of data so we are mapping only the necessary fields
 * 
 * 
 * The userName or the salesForceId should be present in the parameters
 * the parameter can be the userName (email or the mobile number for china) or salesForce account Id
 * The parameters field should contains the parameter name and the value 
 * ex: if the parameter is userName -> the expected value is userName=<email/phone> else salesForceId=<accountId> 

 * 
 **/ 
    public static Object getOrderDetails(String parameter) {
        
	   List<Object> aTGOrders = new List<Object>();
	   Orders ord = null;
        try { 
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            string endPoint = '/ws/ATG_OrderAPI/1.0/restricted-api/order/eng-us/history?'+parameter;
            request.setEndpoint('callout:EAI' + endPoint);
            request.setMethod('GET');
            request.setTimeout(60000);
            request.setHeader('Encoding', 'UTF-8');
			request.setHeader('Accept', 'application/json');
			request.setHeader('Content-Type', 'application/json');
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200 ) {
               Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());

		   		Set<String> storeListCode = new Set<String>();
				
            	List<Object>  ordersWS = (List<Object>)results.get('orders');
				for (Object order : ordersWS) {

					Map<String,Object> mapOrder =	(Map<String,Object>) order;
					List<Object> orderDetails = getShippingDetails(mapOrder);  
					StoreListCode.add(String.valueOf(mapOrder.get('rmsStoreCode')));

					ATGOrders.addall(orderDetails);
					System.debug(ATGOrders.size());
				} 

				ord = new Orders(getStoreName(storeListCode),aTGOrders); 
		    }
			return ord;


        } catch (Exception e) {
            system.debug(e.getMessage());

        }

	    return ord ;     
	   
	}
	
    public static List<Object> getShippingDetails(Map<String,Object> orderWS){


        List<Object> shippingsWS = (List<Object>)orderWS.get('shippingGroups');
        List<Object> productsWS = ((Object) orderWS.get('commerceItem') == null ?  new List<Object>() : (List<Object>)orderWS.get('commerceItem')); 
        if((List<Object>)orderWS.get('commerceItemOutOfStock') != null) {
            List<Object> productsHaveOutOfStockWS = (List<Object>)orderWS.get('commerceItemOutOfStock');
            productsWS.addAll(productsHaveOutOfStockWS);
        }
        List<Object> paymentsWS = (List<Object>) orderWS.get('paymentGroups');

        Map<String,Object> productByShppingID = new Map<String,Object> ();
        Map<String,Object> paymentByShppingID = new Map<String,Object> ();

        for (Object paymentWS : paymentsWS) {

            Map<String,Object> payment = (Map<String,Object>)paymentWS;
            Map<String,Object> paymentInfo = new Map<String,Object>{'PaymentMethod' =>payment.get('paymentMethod')};

            paymentByShppingID.put((String)payment.get('shippingGroupId'),paymentInfo);
        }

        for (Object productWS : productsWS) {

            Map<String,Object> product = (Map<String,Object>)productWS;
            Map<String,Object> productInfo = new Map<String,Object>();

            productInfo.put('ProductName',product.get('productDisplayName'));
            productInfo.put('Quantity',product.get('quantity'));
            productInfo.put('SKU',product.get('catalogRefId'));
            productInfo.put('ProductImage',product.get('imageURL'));

            productByShppingID.put((String)product.get('shippingGroupId'),productInfo);
        }
        List<Object> shippingsOrder = new List<Object>();

        for(Object shippingWS : shippingsWS){

            Map<String,Object> shipping = (Map<String,Object>)shippingWS;
            Map<String,Object> shippingDetails = new Map<String,Object>();
            
            String status = (String)shipping.get('state');
            //Order Details Linked to the shipping
            shippingDetails.put('OrderNumber',orderWS.get('identifier'));
            shippingDetails.put('OrderStatus',orderWS.get('state'));
            shippingDetails.put('OrderDate',orderWS.get('submittedDate'));
            shippingDetails.put('LastUpdate',orderWS.get('lastModifiedDate'));
            shippingDetails.put('OrderDate',orderWS.get('submittedDate'));
            shippingDetails.put('StoreCode',orderWS.get('rmsStoreCode'));
            shippingDetails.put('Origin',orderWS.get('orderOrigin'));
            shippingDetails.put('WWEmployeeId','');
            shippingDetails.put('DeliveryType',shipping.get('shippingMethod'));

            //Shipping Details

            shippingDetails.put('ShippingNumber',shipping.get('identifier'));
            shippingDetails.put('Status',shipping.get('state'));
            shippingDetails.put('MyPersoNumber',shipping.get('myPersoId'));
            shippingDetails.put('TrackingNumbers',shipping.get('trackingNumbers'));
            shippingDetails.put('ClientDetails',shipping.get('shippingAddress'));
            if(productByShppingID.containsKey((String)shipping.get('identifier'))){
                shippingDetails.put('Product',productByShppingID.get((String)shipping.get('identifier')));
            }
            else{
                Map<String,Object> noProduct = new Map<String,Object>{'ProductName' => 'N/A',  'Quantity' => 'N/A',  'SKU' => 'N/A' , 'ProductImage'=>'N/A'};
                shippingDetails.put('Product',noProduct);
            }
            shippingDetails.put('Payment',paymentByShppingID.get((String)shipping.get('identifier')));

            shippingsOrder.add(shippingDetails);
        }
        return shippingsOrder;

	}
	public static Map<String,Store__c> getStoreName(Set<String> storeID){
        //get name of the store  
        Map<String,Store__c> storeList = new Map<String,Store__c>();
        for (Store__c store :  [SELECT id,Name,RetailStoreId__c ,StoreType__c FROM Store__c WHERE RetailStoreId__c IN:storeID]){
            if(!storeList.containsKey(store.RetailStoreId__c)){
                storeList.put(store.RetailStoreId__c,store);
            }
        }
        return storeList;
	}
	
	public class Orders {

		@AuraEnabled
		public Map<String,Store__c> listStore;
		@AuraEnabled
		public List<Object> listOrder;
		public orders(Map<String,Store__c> listStore, List<Object> listOrder){

			this.listStore = listStore ;
			this.listOrder = listOrder ;
		}
    }
}