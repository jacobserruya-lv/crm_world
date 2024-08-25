/**
*  @About
*  Test methods for ICX_EscalationAction
*    Author : Naomi Baroghel
*
*/

@isTest
public class ICX_EscalationAction_TEST {



    @isTest
    public static void AssignedCaseTeam()
    {


        Case CaseEscalation = createCaseEscalation('KOREA');
        CaseEscalation.Product_Sku_unknown__c = 'Unknwon SKU';

        insert CaseEscalation;

        Test.startTest();
        ICX_EscalationAction.getEscalationTeamByCountry(new List<String> {CaseEscalation.Id});
        Test.stopTest();

     


    }


   


    private static Case createCaseEscalation(String Country)
    {
        Account acc = ICX_TestFactory.createAccount();
        insert acc;
        Case CaseEscalation = ICX_TestFactory.createCase(acc.Id);

        CaseEscalation.Resolution__c='Escalation';
        CaseEscalation.isEscalated = true;
        CaseEscalation.Escalation_Type__c = 'Manual';
        CaseEscalation.Escalation_Status__c='New';
        CaseEscalation.Type_of_Support_Escalation__c='Advice';
        CaseEscalation.Country__c = Country;
        CaseEscalation.Escalation_Opening_Date__c =Date.Today();

        CaseEscalation.Product_Sku_unknown__c = 'Unknwon SKU';


        return CaseEscalation;
    }

 



}