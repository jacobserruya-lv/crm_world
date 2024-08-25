@isTest
public with sharing class ICX_RelatedTransaction_TEST {

    @isTest 
    static void createTestData() {
        Event evt = new Event();

        evt.RelatedTicketNumber__c = '1234';
        evt.SaleAmount__c = 990;
        evt.Currency__c = 'EUR';
        evt.Transaction_Total_Converted_Amount_EUR__c = 990;
        
        evt.Description='Un event de test';
        evt.ActivityDate = Date.today().addDays(-6);
        evt.StartDateTime = Date.today().addDays(-6);
        evt.EndDateTime=Date.today().addDays(3);
        evt.Subject='Sujet du test';
        //evt.Occasion__c='Travel';
        evt.Location='Paris';
        evt.IsAllDayEvent=false;
        evt.ShowAs='Free';
        evt.Source__c='Unexcepted';
        evt.Service__c='Test';
        
        insert evt;

        Event event;        
        event = ICX_RelatedTransaction.getRelatedTransaction(evt.Id);

        System.assertEquals(evt.Id, event.Id);
    }
}