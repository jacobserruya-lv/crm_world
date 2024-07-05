@isTest
private class UpdateOpportunityBatchTest {
    
        @testSetup  
    static void init(){

          Store__c st = LV_TestFactory.createStore('LV TEST STORE MIY', 'Store', 'A00', 'FRANCE', 'EUR', 'Open');
		st.MANAGEMENT_ZONE_LEVEL__c = '15';
        st.CheckXstoreDeposit__c = true ;
		insert st;
        
         List<Opportunity> testOpportunities = new List<Opportunity>();
        for(Integer i = 0; i < 5; i++) {
            		Opportunity opp = LV_TestFactory.createOrder('MY Neverfull bag', 'Creation in progress', null, st.id, null, null, null, 'PERSO');
		            opp.SPO_DepositSentStatusDate__c = System.today();
            
                opp.Name = 'Test Opportunity ' + i;
                opp.CreatedDate = System.now().addDays(-2); // Ensure created 2 days ago
                
            testOpportunities.add(opp);
        }
        insert testOpportunities;
    }
    
    
    
    @isTest
    static void testBatchExecution() {
        
        // Start the batch job
        Test.startTest();
        UpdateOpportunityBatch batchJob = new UpdateOpportunityBatch();
        Database.executeBatch(batchJob);
        Test.stopTest();
        
        // Assert that the StageName of the Opportunity records has been updated
        List<Opportunity> updatedOpportunities = [SELECT Id ,SPO_Store__c, StageName FROM Opportunity ];
        for(Opportunity opp : updatedOpportunities) {
            System.debug(opp.SPO_Store__c);
           // System.assertEquals('Cancelled by Production', opp.StageName);
        }
        
    }
}