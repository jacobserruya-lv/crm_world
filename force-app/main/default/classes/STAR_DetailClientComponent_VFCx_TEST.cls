@isTest
public class STAR_DetailClientComponent_VFCx_TEST {

    
    public static testMethod void testGetHasNoPicture()
    {
        
		STAR_DetailClientComponent_VFCx ctrl = new STAR_DetailClientComponent_VFCx();
        //Create new Account
        Account account1 = IC_TestFactory.createAccount();
        account1.firstName='FirstName1';
        account1.lastName='LastName1';
        insert account1;
        
        ctrl.currClient = account1;
        ctrl.getHasPicture();
        system.assertEquals(Null, ctrl.file);
        system.assertEquals(false, ctrl.hasPicture);
    }
    
    public static testMethod void testGetHasPicture()
    {
        
		STAR_DetailClientComponent_VFCx ctrl = new STAR_DetailClientComponent_VFCx();
        
        //Create new Account
        Account account1 = IC_TestFactory.createAccount();
        account1.firstName='FirstName1';
        account1.lastName='LastName1';
        insert account1;
        
        //Create a picture
        Attachment att = new Attachment(ParentID = account1.id, Name = 'Contact Picture', ContentType = 'jpg');
        att.Body = Blob.valueOf('Unit Test Attachment Body');
        insert att;
        
        //ctrl.currClient = account1;
        List<Account> clients  = [Select Id, Gender__pc, Salutation,lastname, firstname, DREAMID__c, DreamSA__pc, Title__pc, ownerId, Segmentation__pc,
         						Nationality__pc, Typology__pc, AttachedStore__pc, Star_CommentPhotoBook__pc, Spouse__pc, Anniversary__pc, Children__pc, 
         						Pets__pc, PersonalInterest2__pc, PersonalInterest1__pc, PersonalInterest3__pc, HistoricalSpendEUR__pc, Occupation__pc, Company__pc, YTDSpendEUR__pc, IsPersonAccount,
         						(Select ParentId, Name, Id, ContentType, BodyLength 
                                        From Attachments 
                                        where name = 'Contact Picture' limit 1)                          
         						FROM Account WHERE id =: account1.id];
        ctrl.currClient = clients[0];
        ctrl.getHasPicture();
        system.assertNotEquals(Null, ctrl.file);
        system.assertEquals(true, ctrl.hasPicture);
    }
}