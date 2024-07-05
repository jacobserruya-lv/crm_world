@isTest
public class STAR_MultiClientViewPdf_TEST {
    
    public static testMethod void testSTAR_MultiClientViewPdf()
    {
        //Create new Account
        Account account1 = IC_TestFactory.createAccount();
        account1.firstName='FirstName1';
        account1.lastName='LastName1';
        insert account1;
        
        //Create new Account
        Account account2 = IC_TestFactory.createAccount();
        account1.firstName='FirstName2';
        account1.lastName='LastName2';
        insert account2;
        
        List<String> IDList = new List<String>{account1.id, account2.id};
        String JSONString = JSON.serialize(IDList);
        PageReference pageRef = Page.STAR_MultiClientViewPdf;
        pageRef.getParameters().put('listid',JSONString);
        Test.setCurrentPage(pageRef);
        STAR_MultiClientViewPdf_VFCx ctrl = new STAR_MultiClientViewPdf_VFCx();
        Account[] Clients = ctrl.getClients();
        system.assertEquals(2, Clients.size());


    }

}