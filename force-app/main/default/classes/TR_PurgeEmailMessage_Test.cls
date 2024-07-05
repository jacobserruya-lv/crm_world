@isTest
public class TR_PurgeEmailMessage_Test {

   
    
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
        String compteclientid=compteclient.id;
        String query = 'select id from EmailMessage where RelatedToId = null and createddate < LAST_MONTH   and CreatedById =:compteclientid';
      
          Test.startTest();
         TR_PurgeEmailMessage myBatch = new TR_PurgeEmailMessage();
       ID batchprocessid = Database.executeBatch(myBatch,200);
       
        Test.stopTest();   
         List<EmailMessage> emaillist= Database.query(query);
        System.assertEquals(0, emaillist.size(),'Emails messages deleted');
    }
}