public with sharing class ICX_RelatedOrderShipping {


    @AuraEnabled(cacheable=true)
    public static OrderShipping__c getOrderShipping(Id recordId, String objectApiName, String OrderShippingFieldName,String OrderShippingFieldToDisplay)
    {

        Case currentCase;
        OrderShipping__c currentOrderShipping;
        String query ='SELECT Id,' + OrderShippingFieldName + ' FROM ' + objectApiName + ' WHERE ID =\''+ recordId+'\'';

        List<Case> currentCaseList = Database.query(query);
        if(!currentCaseList.isEmpty())
        {
            currentCase = currentCaseList[0];
            

           OrderShippingFieldToDisplay = calculateFieldToDisplay(OrderShippingFieldToDisplay);
            query = 'SELECT '+OrderShippingFieldToDisplay+' FROM OrderShipping__c WHERE Id =\''+currentCase.Order_Shipping__c+'\'';
            List <OrderShipping__c> currentOrderShippingList =Database.query(query);
        

            if(!currentOrderShippingList.isEmpty())
            {
                currentOrderShipping = currentOrderShippingList[0];
                String OrderShippingFieldToDisplayLowerCase = OrderShippingFieldToDisplay.toLowerCase();
                if(OrderShippingFieldToDisplayLowerCase.contains('source_location__c') &&  currentOrderShipping.Source_Location__c!=null)
                {
                    currentOrderShipping.Source_Location__c = calculateStoreLabelRetailId(currentOrderShipping.Source_Location__c);
                }
                if( OrderShippingFieldToDisplayLowerCase.contains('pickup_location__c') && currentOrderShipping.Pickup_Location__c!=null)
                {

                    currentOrderShipping.Pickup_Location__c = calculateStoreLabelRetailId(currentOrderShipping.Pickup_Location__c);
                }
            }
        }

        return currentOrderShipping;

    }

    // helper function
    public static String calculateStoreLabelRetailId(String RetailID)
    {
        String storeLabelRetailId;
        if(String.isNotBlank(RetailID))
        {
            List<Store__c> currentStoreList =  [SELECT Id, RetailStoreId__c,Name FROM Store__c WHERE RetailStoreId__c =:RetailID ];
            if(!currentStoreList.isEmpty())
            {
                Store__c currentStore = currentStoreList[0];
                storeLabelRetailId = currentStore.Name + ' - ' + currentStore.RetailStoreId__c;
            }
            else
            {
                storeLabelRetailId = RetailID;
            }
        }

        return storeLabelRetailId;
    }

    public static String calculateFieldToDisplay(String OrderShippingFieldToDisplay)
    {

        List<String> OrderShippingFieldToDisplayList = OrderShippingFieldToDisplay.split(',');

        for(Integer i = 0 ; i<OrderShippingFieldToDisplayList.size(); i++)
        {
            OrderShippingFieldToDisplayList[i]=OrderShippingFieldToDisplayList[i].toLowerCase();
        }


        if(!OrderShippingFieldToDisplayList.contains('id'))
        {
            OrderShippingFieldToDisplay+=',id';
        }

        if(OrderShippingFieldToDisplayList.contains('order__c')&& !OrderShippingFieldToDisplayList.contains('order__r.name'))
        {
            OrderShippingFieldToDisplay+=',order__r.name';
        }
        else if (OrderShippingFieldToDisplayList.contains('order__c')&& !OrderShippingFieldToDisplayList.contains('order__r.name'))
        {
            OrderShippingFieldToDisplay+=',order__c';
        }

        if(OrderShippingFieldToDisplayList.contains('createdbyid')&& !OrderShippingFieldToDisplayList.contains('createdby.name'))
        {
            OrderShippingFieldToDisplay+=',createdby.name';
        }
        else if (!OrderShippingFieldToDisplayList.contains('createdbyid')&& OrderShippingFieldToDisplayList.contains('createdby.name'))
        {
            OrderShippingFieldToDisplay+=',createdbyid';

        }

        OrderShippingFieldToDisplay =OrderShippingFieldToDisplay.replace('DeliveryType__c','TOLABEL(DeliveryType__c)');

        return OrderShippingFieldToDisplay;
    }
}