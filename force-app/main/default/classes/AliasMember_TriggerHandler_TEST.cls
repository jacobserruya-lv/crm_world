/*	 * @author Keman WU
* @date creation 15/06/2022
* @description test class for AliasMember_TriggerHandler
*/

@isTest
public class AliasMember_TriggerHandler_TEST {

    
    @isTest static void testMethod1() {         
        Account acc = ICX_TestFactory.createAccount();
        insert acc;
        Alias__c a = new Alias__c (Name = 'test');
        Insert a;
       
        test.startTest();  
        
        Alias_Member__c am = new Alias_Member__c(Client__c = acc.Id, Alias__c = a.Id );
        insert am; 

        Alias_Member__c myAM = [select Unique_ID__c from Alias_Member__c ];

      
        system.assertEquals( myAM.Unique_ID__c, acc.Id + '-' + a.Id);
       
        test.stopTest();
    
    }

}