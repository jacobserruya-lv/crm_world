/**
    About
    -----
    Description: Batch to Create Client List Members for Lists created on Targeted Client list page
    Create date: July 2016

    Details
    -------
    Test class for IC_BatchCreateListMembers

    Update History
    --------------
    July 2016 / Created by Balink
    
    Issues / TODOs
    --------------
*/
@isTest
public with sharing class IC_BatchCreateListMembers_Test {
    @TestSetup
    public static void setup() {
        String identityProfile = [SELECT Id FROM Profile WHERE Name = 'Identity User'][0].Id;
        insert new IC_Config__c(
            Name = 'Identity User',
            Value__c = identityProfile
        );
    }
    
    static testMethod void testLaunchSearch() {
        User u = IC_Test_Common.createTestUser();
        Account acc1 = IC_Test_Common.createPersonAccount('1515');
        Account acc2 = IC_Test_Common.createPersonAccount('1616');
        
        CLI_CliList__c clientList = IC_Test_Common.createClientList();
        clientList.TECH_TempAccountIds__c = '!' + acc1.id + '!' + acc2.id;
        clientList.Typology__c = 'Regular'; 
        clientList.Offer_Code__c = 'exclu_nba_1_2020 ';
        update clientList;
        
        
        //insert lAccount;
        System.runAs(u){ 
            Test.startTest();
        
            IC_BatchCreateListMembers testBatch = new IC_BatchCreateListMembers();
            Database.executeBatch(testBatch,1000);
            
            Test.stopTest();
        }
       
    }
}