@isTest
public class IC_BatchPurgeClient_TEST {
    
    
    static Account createAccount(){  
        Account a = new Account();
        a.LastName = 'Europe' + String.valueOf(System.now());
        a.FirstName='John';
        a.Salutation = 'Ms';
        a.Segmentation__pc='VIC';
        a.PrimaryAddressLine1__pc='Adresse ligne 1';
        a.PrimaryAddressLine2__pc='Adresse ligne 2';
        a.PrimaryAddressLine3__pc ='Adresse ligne 3';
        a.PrimaryCity__pc='Paris';
        a.PersonEmail='sylvie@lv.com';
        a.PrimaryZipCode__pc='75000';
        a.PrimaryCountry__pc='France';
        a.PassportNumber__pc='ABC12345';
        a.LastTrans__pc = null;
        a.isprospect__pc = false;
        a.ownerid = '005i0000007UUZP';
        return a;
    }
    
    static testMethod void testBatch() {

        ID batchprocessid;
       //test for Case caseCltId    
        List<Account> accs = new List<Account>();
        Account acc1 = createAccount();
        Account acc2 = createAccount();
        Account acc3 = createAccount();
        Account acc4 = createAccount();
        accs.add(acc1);
        accs.add(acc2);
        accs.add(acc3);
        accs.add(acc4);
        insert accs;
        Case cas = new Case(); 
        cas.Status = 'New';
        cas.Priority = 'Medium';
        cas.AccountId = acc1.Id;
        cas.Origin = 'Email';
        cas.Description = ' Un case de Test'; 
        insert cas;       	

		//test for Program__c prgCltId
     
        
        Event__c eve = new Event__c(); 
        eve.Start_Date__c = Date.today();
        eve.End_Date__c = Date.today().addDays(3);
        eve.Location__c = 'Paris';
        eve.Level__c = 'International';
        eve.Theme__c = 'Store';
        insert eve;
        Program__c pro = new Program__c(); 
        pro.AccountId__c = acc2.id;
        pro.EventId__c = eve.id;
        insert pro;
        
		
        
        //test for Opportunity oppCltId      	
       
        Opportunity opp = new Opportunity();
        opp.AccountID = acc3.id;
        opp.Name = 'Test';
        opp.CloseDate = Date.today().addDays(2);
        opp.StageName = 'In progress';
        insert opp;
        
       
        
        //test for CareService__c csCltId     
      
        CareService__c car = new CareService__c();
        car.StoreRetailCode__c = 'V13';
        car.Followup_Status__c = 'New';
        car.Client__c = acc4.Id;
        insert car;
        
            
        
        
        Account acc5 = createAccount();
        insert acc5;
        Account acc6 = createAccount();
        insert acc6;
        
        
        IC_BatchPurgeClient myBatch = new IC_BatchPurgeClient();
        
      	Test.startTest();
        batchprocessid = Database.executeBatch(myBatch,1000);
        Test.stopTest();
        
        list<account> lstAcc = [select id from Account where PeakSeasonPurge__c='0' ];
        system.assertequals(lstAcc.size(),2);

    }
}