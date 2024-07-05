/**
    @Author : 	deborah.marciano
    Desc 	:   test class for BatchPurgeEmailMessage class 
    V 1.0 	:   21/02/2024
*/

@isTest
private class BatchPurgeEmailMessage_Test {
      
    @TestSetup
    private static void setup() {
       // PurgeEmailMessages__mdt setting = new PurgeEmailMessages__mdt();
       // setting.numberOfDayBefore__c = 90;
       // setting.Limit__c = 500;
       // setting.ClauseWhere__c = 'ActivityId = null and RelatedToId =null';
       // INSERT setting;
        
        //List Email Message
        List<EmailMessage> lem = new List<EmailMessage>();
        Datetime validDateTime = Datetime.newInstanceGmt(2018, 8, 14, 6, 30, 0);
        Datetime validDateTime2 = Datetime.newInstanceGmt(2023, 1, 14, 6, 30, 0);
        Datetime validDateTime3 = Datetime.newInstanceGmt(2023, 1, 18, 6, 30, 0);
        Datetime validDateTime4 = Datetime.newInstanceGmt(2023, 12, 12, 6, 30, 0);
        
        EmailMessage em1 = new EmailMessage( CcAddress ='ipd@fr.lvmh-fashion.com',
                                             activityId = null,
                                             relatedToId = null,
                                             Subject = 'This is an email',
                                             TextBody = 'This the email body',
                                             HTMLBody = '<HTML><p> This is the HTML body </p></HTML>',
                                             CreatedDate = validDateTime );
         lem.add(em1);
        
         EmailMessage em2 = new EmailMessage( CcAddress ='ipd.cn@louisvuitton.com',
                                              activityId = null,
                                              relatedToId = null,
                                              Subject = 'This is an email of test',
                                              TextBody = 'This the email body',
                                              HTMLBody = '<HTML><p> This is the HTML body </p></HTML>',
                                              CreatedDate = validDateTime2 );
        lem.add(em2);
        
        // Data lorsque activityID != 0
         EmailMessage em3 = new EmailMessage( //Name = 'TestDebo',
                                            //activityId = '00T6S00006YG5cgUAD',
                                            relatedToId = null,
                                            Subject = 'This is an email of test',
                                            TextBody = 'This the email body',
                                            HTMLBody = '<HTML><p> This is the HTML body </p></HTML>',
         									CreatedDate = validDateTime3);
        lem.add(em3);
        
        // Data lorsque le Record Email Message a ete cre avant 3 mois
        EmailMessage em4 = new EmailMessage( 
                                            //activityId = '00T6S00006YG5cgUAD',
                                            relatedToId = null,
                                            Subject = 'This is an email of test',
                                            TextBody = 'This the email body',
                                            HTMLBody = '<HTML><p> This is the HTML body </p></HTML>',
        									CreatedDate = validDateTime4);
        lem.add(em4);

        INSERT lem;
        system.debug('lem: '+ lem); 
    }
  

     
    @isTest
    private static void test(){
        Test.startTest();
        String query = '';
        BatchPurgeEmailMessage batch = new BatchPurgeEmailMessage();
        Id batchId = Database.executeBatch(batch);
        Test.stopTest();

       Integer emailMessageCount = [SELECT COUNT() FROM EmailMessage WHERE (CcAddress In ('ipd@fr.lvmh-fashion.com','ipd.cn@louisvuitton.com')) and CreatedDate <= LAST_N_DAYS:90];
       System.assertEquals(0, emailMessageCount, 'Tous les enregistrements ont été supprimés.');
    }
    
    //emailMessageLimit = null
    @isTest
    private static void test2(){
        Test.startTest();
        String query = '';
        BatchPurgeEmailMessage batch = new BatchPurgeEmailMessage();
        Id batchId = Database.executeBatch(batch);
        Test.stopTest();

       Integer emailMessageCount = [SELECT COUNT() FROM EmailMessage WHERE (CcAddress In ('ipd@fr.lvmh-fashion.com','ipd.cn@louisvuitton.com')) and CreatedDate <= LAST_N_DAYS:90];
       System.assertEquals(0, emailMessageCount, 'Tous les enregistrements ont été supprimés.');
    }
}