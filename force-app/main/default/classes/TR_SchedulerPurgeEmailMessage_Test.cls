@istest
public class TR_SchedulerPurgeEmailMessage_Test {

    
      static testMethod void testBatch() {
          
                  User compteclient= [select id from user where id='005i0000008NEdWAAW' limit 1];
        
        System.runAs(compteclient){
        EmailMessage email = new EmailMessage();
        email.FromAddress = 'test@abc.org';
        email.Incoming = True;
        email.CreatedDate= system.today() - 90;
        email.ToAddress= 'test@xyz.org';
        email.Subject = 'Test email';
        email.RelatedToId=null;
        email.HtmlBody = 'Test email body';
    String[] toIds = new String[]{'005i0000008NEdWAAW'};
    email.toIds = toIds;    
        insert email;
        }
             Test.startTest();
     String cron = '0 0 23 * * ?';
        TR_SchedulerPurgeEmailMessage schd = new TR_SchedulerPurgeEmailMessage();
        String jobId = System.schedule('test schedule relate transaction to messaging', cron, schd);
        schd.execute(null);
        
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
       
        Test.stopTest();   
      }
}