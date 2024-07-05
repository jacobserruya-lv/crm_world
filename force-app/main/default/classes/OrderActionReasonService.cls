public with sharing class OrderActionReasonService {
    
    @AuraEnabled(cacheable=true)
    public static List<Order_Action_Reason__mdt> getByAction(String action) {
        List<Order_Action_Reason__mdt> orderActionReasons = new List<Order_Action_Reason__mdt>();
        if (action != null) {
            orderActionReasons = [SELECT DeveloperName, Reason_Code__c, action__c, MasterLabel
                                FROM Order_Action_Reason__mdt
                                WHERE action__c = :action ORDER BY DeveloperName asc];
        }

        return orderActionReasons;
    }

    /**
     * Return the detail of 1 record filtered by reason code
     */
    @AuraEnabled(cacheable=true)
    public static Order_Action_Reason__mdt getByReasonCode(String action, String reasonCode) {
        List<Order_Action_Reason__mdt> orderActionReasons = new List<Order_Action_Reason__mdt>();
        Order_Action_Reason__mdt orderActionReason;

        if (action != null && reasonCode != null) {
            orderActionReasons = [SELECT DeveloperName, Reason_Code__c, action__c, MasterLabel
                                FROM Order_Action_Reason__mdt
                                WHERE action__c = :action
                                and Reason_Code__c = : reasonCode ORDER BY DeveloperName asc];
        }

        if (orderActionReasons.size() == 1) {
            orderActionReason = orderActionReasons.get(0);
        }

        return orderActionReason;
    }
}