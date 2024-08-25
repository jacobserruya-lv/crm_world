public with sharing class TraceabilityService {

    @AuraEnabled(cacheable=true)
    public static List<Traceability__c> selectByOrderNumber(String orderNumber, Boolean includeOrderShipping) {
        List<Traceability__c> traceabilities =  [SELECT Action__c, Order__c, Order__r.OrderNumber__c, OrderShipping__c, OrderShipping__r.ShippingNumber__c, Reason__c, AdditionalInformation__c, SubmitedBy__c, Tech_SubmitedBy_Name__c, SubmitedDate__c 
                                                FROM Traceability__c 
                                                WHERE Order__r.OrderNumber__c = :orderNumber
                                                ORDER BY SubmitedDate__c desc];
        return traceabilities;
    }

    // @AuraEnabled(cacheable=true)
    // public static void insertTraceability(List<Traceability__c> newTraceabilities) {
    //     // Check Mandatory fields
    //     // for(Traceability__c traceability : newTraceabilities) {

    //     // }

    //     insert newTraceabilities;
    // }

    @AuraEnabled
    public static Traceability__c insertTraceability(String action, String reason, String additionalInformation,String orderNumber,String shippingNumber) {
        // Check Mandatory fields
        // for(Traceability__c traceability : newTraceabilities) {

        // }

        system.debug('insertTraceability: '+ action +', '+ reason+', '+ additionalInformation+', '+ orderNumber+', '+ shippingNumber);

        Traceability__c traceability = new Traceability__c();
        traceability.Action__c = action;
        traceability.Reason__c = reason;
        traceability.AdditionalInformation__c = additionalInformation;
        traceability.Order__r = (orderNumber != null?(new Order__c(OrderNumber__c=orderNumber)):null);
        traceability.OrderShipping__r = (shippingNumber != null?(new OrderShipping__c(ShippingNumber__c=shippingNumber)):null);
        traceability.SubmitedBy__c = UserInfo.getUserId();
        traceability.SubmitedDate__c = Datetime.now();

        System.debug('traceability: '+traceability);
        
        insert traceability;

        return traceability;
    }

    // TWIST-30762 : Johan Guinot
    @AuraEnabled
    public static List<Traceability__c> insertFromCases(List<Case> cases) {
        Traceability__c traceability;
        List<Traceability__c> traceabilityList = new List<Traceability__c>();

        for(Case c: cases) {
            traceability = new Traceability__c();
            traceability.Action__c = c.Status;
            traceability.Reason__c = c.Rejection_Type__c;
            traceability.AdditionalInformation__c = c.Approval_Type__c;
            traceability.Order__c = c.Order__c;
            traceability.OrderShipping__c = c.Order_Shipping__c;
            traceability.SubmitedBy__c = UserInfo.getUserId();
            traceability.SubmitedDate__c = Datetime.now();
            System.debug('TraceabilityService.insertFromCases: cases='+cases);
            System.debug('TraceabilityService.insertFromCases: traceability='+traceability);

            traceabilityList.add(traceability);
        }
        
        insert traceabilityList;

        return traceabilityList;
    }

    @AuraEnabled
    public static List<Traceability__c> insertFromTasks(List<Task> tasks) {
        Traceability__c traceability;
        List<Traceability__c> traceabilityList = new List<Traceability__c>();
        Set<Id> orderShippingIds = new Set<Id>();
        Map<ID, OrderShipping__c> orderIdByShippingId;

        for(Task t: tasks) {            
            If (t.Subject.contains('PRICE_ADJUSTMENT') || t.Subject.contains('CLIENTELING_EXCEPTION')) {
                orderShippingIds.add(t.WhatId);
            }
        }

        if(orderShippingIds.size() > 0) {
            orderIdByShippingId = new Map<ID, OrderShipping__c>([Select Id, Order__c From OrderShipping__c WHERE id = :orderShippingIds]);
        }

        for(Task t: tasks) {
            traceability = new Traceability__c();
            traceability.Action__c = t.Status;
            //traceability.Reason__c = c.Rejection_Type__c;
            traceability.AdditionalInformation__c = 'Client informed';
            If (t.Subject.contains('PRICE_ADJUSTMENT') || t.Subject.contains('CLIENTELING_EXCEPTION')) {
                traceability.OrderShipping__c = t.WhatId;
                traceability.Order__c = orderIdByShippingId.get(t.WhatId)?.order__c;
            }
            else {
                traceability.Order__c = t.WhatId;
            }
            traceability.SubmitedBy__c = UserInfo.getUserId();
            traceability.SubmitedDate__c = Datetime.now();
            System.debug('TraceabilityService.insertFromTasks: tasks='+tasks);
            System.debug('TraceabilityService.insertFromTasks: traceability='+traceability);

            traceabilityList.add(traceability);
        }
        
        insert traceabilityList;

        return traceabilityList;
    }
}