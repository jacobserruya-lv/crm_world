@isTest

public class TR_CleanParallelMarket_Batch_Test {
    @istest
    static void Test_cleanparallelMarket() {
        List<Account> accs = new List<Account>();
        Account acc1 = createAccount('test1', 'test1', 'Orange');
        accs.add(acc1);
        Account acc2 = createAccount('test2', 'test2', 'Orange');
        accs.add(acc2);
        Account acc3 = createAccount('test3', 'test3', 'red');
        accs.add(acc3); 
        insert accs;
        Transverse_Batchs_Setup__c setting = new Transverse_Batchs_Setup__c();
        setting.name = 'Batch Parallel Market Setup';
        setting.Created_Before_months__c = '0';
        setting.Limit__c = '10';
        insert setting;
        TR_CleanParallelMarket_Scheduler myScheduler = new TR_CleanParallelMarket_Scheduler();
        String sch = '0 0 23 L * ?';
        Test.startTest();
        // Id batchJobId = Database.executeBatch(new TR_CleanParallelMarket_Batch(), 200);
        system.schedule('Test check', sch, myScheduler);
        myScheduler.execute(null);
        Test.stopTest();
        accs=[ SELECT ID,ParallelMarket_StatusDate__pc,firstname,ParallelMarket_Status__pc 
              FROM Account order by FirstName asc];
        system.assertEquals(null, accs[0].ParallelMarket_Status__pc);
        system.assertEquals(null, accs[1].ParallelMarket_Status__pc);
        system.assertEquals(null, accs[2].ParallelMarket_Status__pc);
    }
    private static Account createAccount(String firstname, String lastname, String statAcc) {
        Account acc = new Account();
        acc.Firstname = firstname;
        acc.LastName = lastname;
        acc.PersonMobilePhone = '0100000000';
        acc.PersonEmail = 'email@email.com';
        acc.ParallelMarket_Status__pc= statAcc;
        acc.ParallelMarket_StatusDate__pc = System.now();
        system.debug(acc);
        return acc;
    }
}