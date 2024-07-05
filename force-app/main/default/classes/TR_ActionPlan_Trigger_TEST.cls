/**
* @File Name          : TR_C360Integration_TriggerHandler.trigger
* @Description        : 
* @Author             : hamza.bouzid.ext@louisvuitton.com
* @Group              : 
* @Last Modified By   : hamza.bouzid.ext@louisvuitton.com
* @Last Modified On   : 16-09-2022
* @Modification Log   : 
* Ver       Date            Author      		                     Modification
* 1.0       16-09-2022       hamza.bouzid.ext@louisvuitton.com     Initial Version
**/
@isTest
public class TR_ActionPlan_Trigger_TEST {
    @isTest static void test_executeSpamDeletion() {
        ActionPlan__c action = new ActionPlan__c();
        action.name = 'test';
        insert action;
        
        action.name = 'halal 2 ';
        update action;
        
        ActionPlan__c action2 = new ActionPlan__c();
        action2.name = 'halal';
        insert action2;

    }
    
}