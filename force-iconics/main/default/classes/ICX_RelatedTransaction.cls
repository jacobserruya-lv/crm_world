//NI-1025
public with sharing class ICX_RelatedTransaction {
    @AuraEnabled
    public static Event getRelatedTransaction(Id recordId) {
        Event eventRet = [SELECT RelatedTicketNumber__c, SaleAmount__c, Currency__c, Transaction_Total_Converted_Amount_EUR__c, Purchased_Product__r.Image_Url__c, Purchased_Product__r.Amount__c, Purchased_Product__r.CurrencyCode__c, Purchased_Product__r.ConvertedAmountEUR__c FROM Event WHERE Id =: recordId ];
        return eventRet;
    }
}