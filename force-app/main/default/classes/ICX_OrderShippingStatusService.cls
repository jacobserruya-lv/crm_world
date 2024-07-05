/**
 * Shipping Group Status is a Custom Metadata
 * It is used to parameter the calculation of the "Status Iconics"
 */
public with sharing class ICX_OrderShippingStatusService {

    /**
     * This inner class is used to calculate the "Status Iconics" from generic source
     */
    public class IconicsStatusWrapper {
        String status;
        Store__c source_location;
        Store__c pickup_location;
        String deliveryType;
        String statusIconics;
        String statusIconicsColor;
        String statusIconicsMessage;
    }

    /**
     * Return a Map of parameters by Status OMS
     */
    public static Map<String, List<ShippingGroupStatus__mdt>> getSGSByStatus() {
        Map<String, List<ShippingGroupStatus__mdt>> sgsByStatus = new map<String, List<ShippingGroupStatus__mdt>>();
        String keyMap;

        List<ShippingGroupStatus__mdt> sgsList = new List<ShippingGroupStatus__mdt>();

        // Retrieve custom metadata records
        //CSC-241 Replace the SOQL query by getAll() method to avoid 'Too many SOQL query error'
        List<ShippingGroupStatus__mdt> records = ShippingGroupStatus__mdt.getAll().values();
        //List<ShippingGroupStatus__mdt> records = [SELECT Id,Status_OMS__c, Source_Location__c, Fulfillment_Type__c, Source_Pickup_Location__c, MasterLabel, Information_to_display__c,html_color__c, toLabel(html_color__c) htmlColorLabel FROM ShippingGroupStatus__mdt];
        for (ShippingGroupStatus__mdt sgs : records) {
            keyMap = sgs.Status_OMS__c.toLowerCase();

            if (!sgsByStatus.containsKey(keyMap)) {
                sgsByStatus.put(keyMap, new List<ShippingGroupStatus__mdt>());
            }
            sgsByStatus.get(keyMap).add(sgs);
        }

        return sgsByStatus;
    }

    /**
     * Apply the differents rules to calculate the appropriate value for Status Iconics 
     */
    public static void setIconicsStatus(IconicsStatusWrapper isw) {
        List<ShippingGroupStatus__mdt> sgsList = new List<ShippingGroupStatus__mdt>();
        ShippingGroupStatus__mdt sgsRef;

        // get the Map of Status configuration
        Map<String, List<ShippingGroupStatus__mdt>> sgsByStatus = getSGSByStatus();
           
        sgsRef = null;
        // get a list of Status configuration mapping the specific status 
        sgsList = sgsByStatus.get(isw?.status?.toLowerCase());

        system.debug('JGU- sgsByStatus:'+sgsList);
        system.debug('JGU- isw:'+isw);
        system.debug('JGU- isw.status:'+isw.status);

    // Step 1 - What is the rule to apply ?
        // IF 1 record found
        if (sgsList?.size() ==  1) {
            sgsRef = sgsList.get(0);
        }
        // ELSE IF more than 1 records found
        else if (sgsList?.size() >  1) {
            // We search the configuration that matches with the current record
            for(ShippingGroupStatus__mdt sgs: sgsList) {
                if (
                    ((sgs.Source_Location__c == null) || (sgs.Source_Location__c == 'N/A')
                        || (sgs.Source_Location__c != null && sgs.Source_Location__c != 'N/A' && sgs.Source_Location__c == isw.source_location.StoreType__c)
                    )
                    && (sgs.Fulfillment_Type__c == null || sgs.Fulfillment_Type__c == 'N/A' 
                        || (sgs.Fulfillment_Type__c != null && sgs.Fulfillment_Type__c != 'N/A' && sgs.Fulfillment_Type__c == isw.deliveryType)
                    )
                    && (sgs.Source_Pickup_Location__c == null || sgs.Source_Pickup_Location__c == 'N/A' 
                    || (sgs.Source_Pickup_Location__c != null && sgs.Source_Pickup_Location__c != 'N/A' && sgs.Source_Pickup_Location__c == 'Yes' && isw.source_location.RetailStoreId__c != isw.pickup_location.RetailStoreId__c)
                    || (sgs.Source_Pickup_Location__c != null && sgs.Source_Pickup_Location__c != 'N/A' && sgs.Source_Pickup_Location__c == 'No' && isw.source_location.RetailStoreId__c == isw.pickup_location.RetailStoreId__c)
                    )                   
                ) {
                    sgsRef = sgs;
                }
            }
        }

    // Step 2 - Once the rule to apply is found,
    //          we set the appropriates values for : status, color, message
        if (sgsRef != null) {
            //get html color picklist value
            List<Schema.PicklistEntry> values = ShippingGroupStatus__mdt.html_color__c.getDescribe().getPicklistValues();
            Map<String, String> htmlColorPicklistMap = new Map<String, String>();
            for(Schema.PicklistEntry value: values){
                htmlColorPicklistMap.put(value.getValue(), value.getLabel());
            }
            isw.statusIconics = (sgsRef?.MasterLabel!=null?sgsRef.MasterLabel:isw.status+' (OMS)');
            //isw.statusIconicsColor = (String)sgsRef?.get('htmlColorLabel');
            isw.statusIconicsColor = htmlColorPicklistMap.get(sgsRef?.html_color__c);
            if (sgsRef.Information_to_display__c == 'SOURCE_LOCATION' && isw.source_location != null) {
                isw.statusIconicsMessage = isw.source_location.ShortName__c + ' - ' + isw.source_location.RetailStoreId__c;
            }
            else if (sgsRef.Information_to_display__c == 'PICKUP_LOCATION' && isw.pickup_location != null) {
                isw.statusIconicsMessage = isw.pickup_location.ShortName__c + ' - ' + isw.pickup_location.RetailStoreId__c;
            }
            else if (sgsRef.Information_to_display__c == 'REASON_CODE') {
                isw.statusIconicsMessage = ''; //'orderLine.reason?.Reason__c';
            }
        }
        else {
            if (isw.source_location != null) {
                isw.statusIconicsMessage = isw.source_location.ShortName__c + ' / ' + isw.source_location.RetailStoreId__c;
            }
            isw.statusIconics = isw.status;
        }
        system.debug('JGU- isw:'+isw);
    }

    /**
     * Calculate the Status Iconics at Shipping Group History level
     */
    public static void setIconicsShippingGroupStatusHistory(JSON2KbrwOrder order){
        IconicsStatusWrapper isw;
        List<String> rmsIds = new List<String>();
        for(JSON2KbrwOrder.Order_lines orderLine: order.order_lines) { 
            for(JSON2KbrwOrder.Logs log: orderLine?.logs) {
                if (log.location?.rms_id != null) {
                    rmsIds.add(log.location.rms_id);
                }
                else system.debug('ERROR - ICX_OrderShippingStatusService.setIconicsShippingGroupStatusHistory - missing log.location.rms_id');
                rmsIds.add(orderLine.reason.Pickup_Location__c);
            }
            if (orderLine.reason?.Pickup_Location__c != null) {
                rmsIds.add(orderLine.reason.Pickup_Location__c);
            }
        }
        Map<String, Store__c> storeByRmsId = getStoreByRmsId(rmsIds); 
        for(JSON2KbrwOrder.Order_lines orderLine: order.order_lines) { 
            for(JSON2KbrwOrder.Logs log: orderLine?.logs) {
                isw = new IconicsStatusWrapper();
                isw.status = log.status;
                // isw.source_location = storeByRmsId?.get(log.location.rms_id)?.StoreType__c;
                if (String.isNotEmpty(log.location?.rms_id)) {
                    isw.source_location = storeByRmsId?.get(log.location.rms_id);
                }
                system.debug('xxx-log.status:'+log.status);
                system.debug('xxx-orderLine.reason:'+log.status + '/' +orderLine.reason);
                system.debug('xxx-orderLine.reason.Pickup_Location__c:'+log.status + '/' +orderLine.reason.Pickup_Location__c);
                if (String.isNotEmpty(orderLine.reason.Pickup_Location__c)) {
                    isw.pickup_location = storeByRmsId?.get(orderLine.reason.Pickup_Location__c);
                }
                isw.deliveryType = orderLine.fulfillment_type;

                setIconicsStatus(isw);
                
                log.statusIconics   = isw.statusIconics;
                log.messageIconics  = isw.statusIconicsMessage; 
                log.statusColor     = isw.statusIconicsColor;

            }
        }
	}
    
    
    /**
     * Calculate the Status Iconics at Shipping Group level
     */
    public static void setIconicsOrderShippingStatus(OrderShipping__c orderShipping) {
        IconicsStatusWrapper isw = new IconicsStatusWrapper();

        List<String> rmsIds = new List<String>();
        rmsIds.add(orderShipping.Source_Location__c);
        rmsIds.add(orderShipping.Pickup_Location__c);
        Map<String, Store__c> storeByRmsId = getStoreByRmsId(rmsIds);


        
        isw.status = orderShipping.Status__c;
        isw.source_location = storeByRmsId?.get(orderShipping.Source_Location__c);
        isw.pickup_location = storeByRmsId?.get(orderShipping.Pickup_Location__c);
        isw.deliveryType = orderShipping.DeliveryType__c;

        setIconicsStatus(isw);
        
        orderShipping.statusIconics__c   = isw.statusIconics;
    }


    /**
     * 
     */
    public static Map<String, Store__c> getStoreByRmsId(List<String> rmsIds) {
        Map<String, Store__c> storeByRmsId = new Map<String, Store__c>();
        system.debug('JGU-getStoreByRmsId:rmsIds:'+rmsIds);
        
        List<Store__c> stores = [SELECT RetailStoreId__c, Name,ShortName__c, StoreType__c FROM store__c WHERE RetailStoreId__c in :rmsIds and RetailStoreId__c != null];
        system.debug('JGU-getStoreByRmsId:stores:'+stores);

        for(Store__c store: stores ) {
            storeByRmsId.put(store.RetailStoreId__c, store);
        }
        system.debug('JGU-getStoreByRmsId:storeByRmsId:'+storeByRmsId);
        return storeByRmsId;
    }

}