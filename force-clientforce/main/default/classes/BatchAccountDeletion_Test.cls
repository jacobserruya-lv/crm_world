@isTest
    public with sharing class BatchAccountDeletion_Test {
        static testMethod void myUnitTest() {
            CLI_CliList__c clientList = IC_TestFactory.clientlistMembers();
            insert clientList;
            User u = IC_TestFactory.createUser('D1MIntegration@gmail.com',UserInfo.getProfileId());
            u.LastName='D1MIntegration09876';
            u.UserName='d1m1ntegration76@lv.com';
            u.FirstName='';
            u.BypassVR__c = true;
            insert u;
            list<Account> accs = new list<Account>();
            list<PPR_PurchProduct__c> pprs = new list<PPR_PurchProduct__c>();
            list<Case> cs = new list<Case>();
            Account acc,acc2;
            Case cas,cas2;
            PPR_PurchProduct__c ppr,ppr2;
            system.runAs(u){
                acc = IC_testFactory.createAccount();
                acc.DreamIdMasterClient__c = '';
                acc.Date_Identity__pc = null;
                accs.add(acc);
                acc2 = IC_testFactory.createAccount();
                acc2.FirstName = 'anonymize_IM';
                accs.add(acc2);
                insert accs;
                //Added By Imad for Code Covrage
                ppr = IC_testFactory.createPurchaseProduct(acc.Id);
                 pprs.Add(ppr);
                ppr2 = IC_testFactory.createPurchaseProduct(acc2.Id);
                pprs.Add(ppr2);
                insert pprs;
                cas = IC_testFactory.createCase(acc, ppr);
                cs.Add(cas);
                cas2 = IC_testFactory.createCase(acc2, ppr);
                cs.Add(cas2);
                cas2.ContactId = acc.PersonContactId;
                Datetime dateToC = Datetime.now().addYears(-6);
                insert cs;
                Test.setCreatedDate(cas.Id, dateToC);
                Test.setCreatedDate(ppr.Id, dateToC);
            }
            BatchAccountDeletionScheduler myRun = new BatchAccountDeletionScheduler();
            String sch = '0 0 23 L * ?';
            Test.startTest();
            system.schedule('Test check1', sch, myRun);
            myRun.execute(null);
            AccountDeletion__c setting = new AccountDeletion__c();
            setting.Name = 'Account Deletion Batch';
            setting.Last_account_Id__c = '001000000000000000';
            setting.Max_number_of_analysed_accounts__c = 64;
            setting.Created_before_years__c = 0;
            setting.Nb_run_per_day__c = 1;
            setting.job_Id__c= null;
            setting.Admin_emails__c = 'test@test.com';
            insert setting;
            myRun = new BatchAccountDeletionScheduler();
            sch = '0 0 23 L * ?';
            system.schedule('Test check2', sch, myRun);
            myRun.execute(null);
            setting.job_Id__c= '001000000000000000';
            update setting;
              system.schedule('Test check3', sch, myRun);
            myRun.execute(null);
            Test.stopTest();
            List<Account> lstCompte = [Select Id From Account Where Id = :acc.Id];
            System.assertequals(0, lstCompte.size());
        }
    }