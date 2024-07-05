@isTest 
private class ICX_OrderNoteCleanerBatch_TEST {
  
    static final string EXISTING_ORDER_NUMBER = '1234567898000000';

    @testSetup  
    static void makeData(){

        List<Order_Note__c> orderNoteToInsert = new List<Order_Note__c>();
        orderNoteToInsert.add(createOrderNote('PAYMENT_LINK'));
        orderNoteToInsert.add(createOrderNote('EXTENDED_PAYMENT_LINK'));
        insert orderNoteToInsert;


    }


    @isTest static void orderNoteCleanerBath() {


        Test.startTest();

        try{
        ICX_OrderNoteCleanerBatch b = new ICX_OrderNoteCleanerBatch();
        database.executebatch(b,100);   
        }
        catch(Exception e)
        {
            System.debug('ICX_OrderNoteCleanerBatch_TEST ERROR ' + e);
        } 
        Test.stopTest();

    }

    private static Order_Note__c createOrderNote(String type)
    {

    Order_Note__c orderNoteNew = new Order_Note__c();
    orderNoteNew.Type__c = type;
    orderNoteNew.Tech_OrderNumber__c = EXISTING_ORDER_NUMBER;
    return orderNoteNew;

    }
}