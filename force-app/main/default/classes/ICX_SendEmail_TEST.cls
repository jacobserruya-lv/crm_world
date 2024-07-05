/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 08-02-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class ICX_SendEmail_TEST {
     @testSetup static void setup() {
        
        Profile profile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User user = ICX_TestFactory.createUser(profile.id);
        insert User;

        Id personAccountRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ACC_PersonAccount').getRecordTypeId();
        Account client = ICX_TestFactory.createAccount();
        client.RecordTypeId = personAccountRTId;
        insert client;
   
        Id DistantCareRTId = Schema.SObjectType.CareService__c.getRecordTypeInfosByDeveloperName().get('DistantCareService').getRecordTypeId();     
        CareService__c dcs = new CareService__c(recordTypeId = DistantCareRTId, Client__c =client.Id, StoreRetailCode__c = 'UE4', SKU__c='M9999');
        insert dcs;  

        Family__c f = new Family__c();
        insert f;
        Family_Member__c fm = new Family_Member__c(Client__c = client.Id,Family__c = f.id);
        insert fm;

        ICX_Queue__mdt queueMdt = [SELECT Id, EmailTemplateDeveloperName__c, TargetEmail__c FROM ICX_Queue__mdt WHERE QueueDeveloperName__c = 'France'];
        String queueDevName = 'France';

        BusinessHours businessHours = [select id from BusinessHours where Name = 'France CSC'];
        Case request = ICX_TestFactory.createCase(client.id);
        request.BusinessHoursId = businessHours.ID;
        request.Origin = 'Email';
        request.TECH_Queue__c = queueDevName;

        Case request2 = ICX_TestFactory.createCase(client.id);
        request2.BusinessHoursId = businessHours.ID;
        request2.Origin = 'Email';

        insert  new List<Case>{request, request2};


        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = 'Penguins';
        contentVersion.PathOnClient = 'Penguins.jpg';
        contentVersion.VersionData = Blob.valueOf('Test Content');
        contentVersion.IsMajorVersion = true;
        contentVersion.origin = 'H';
        insert contentVersion;

        ContentVersion contentVersion2 = new ContentVersion();
        contentVersion2.Title = 'Penguins2';
        contentVersion2.PathOnClient = 'Penguins2.jpg';
        contentVersion2.VersionData = Blob.valueOf('a'.repeat(5242880));
        contentVersion2.IsMajorVersion = true;
        contentVersion2.origin = 'H';
        insert contentVersion2;
                  
        Task task = ICX_TestFactory.creatCallTaskOnAccount(client.id);
        insert task;
    
        IconicsSettings__c settings = new IconicsSettings__c();
        settings.CurrentYearLegalNotices__c ='2019';
        insert settings;
    }

    @isTest static void testMethod0() {
        Test.startTest();
        ContentVersion CvTestBigFile = [SELECT Id, Title, ContentSize, ContentDocumentId FROM ContentVersion WHERE ContentSize >= 3000000 limit 1];

        List<Id> contentDocumentIds = new list<id>();
        contentDocumentIds.add(CvTestBigFile.id);

        try {
            ICX_SendEmail.contentDocumentAsAttachement(contentDocumentIds);                
        } 
        catch (Exception e) {
            System.debug('Testmethod0 sendEmailtest: ' + e);
        }
        Test.stopTest();
    }

   @isTest static void testMethod1() {
        Test.startTest();

        try {
            User user = [SELECT id from User LIMIT 1];
            List<ICX_SendEmail.FromEmailAddress> fromEmailAddress = ICX_SendEmail.allFromEmailOptions();           
            List<EmailTemplate> emailTemplates = ICX_SendEmail.getEmailTemplateList('ICONiCS_Templates');

            Case request = [select Id from Case  where TECH_Queue__c != null Limit 1];
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            
            ICX_SendEmail.EmailMessageWrapper emailMessageWrapper = ICX_SendEmail.getDefaultReplyEmail(request.Id);
            String emailBody = '<p> Test Body <p>';
            String signature = 'signature';
            ICX_SendEmail.previewEmail(emailMessageWrapper.emailTemplate.id,emailBody,request.Id,signature);
            string instance = '{' +
                                '"emailSubject":"'+ emailMessageWrapper.emailTemplate.Subject + '",' +
                                '"emailBody":"' + emailBody + '",' +
                                '"emailSignature":"' + signature + '",' +
                                '"emailFromAddress":"' + fromEmailAddress[0].Id + '",'+
                                '"emailToAddresses":[' +
                                    '"'+ emailMessageWrapper.ToAddress + '"'+
                                '],' +
                                '"emailCcAddresses":[],'+
                                '"emailBccAddresses":[],'+
                                '"emailattachments":['+
                                    '"'+ documents[0].Id  + '"'+
                                '],'+
                                '"requestRecordId":"' + request.Id +'",'+
                                '"emailTemplate":{'+
                                    '"Id":"' + emailMessageWrapper.emailTemplate.id + '",'+
                                    '"Name":"' + emailMessageWrapper.emailTemplate.Name + '",'+
                                    '"Subject":"' + emailMessageWrapper.emailTemplate.Subject + '"'+
                                '}'+
                              '}';
            Boolean status = ICX_SendEmail.sendMailMethod(instance);
            Test.stopTest();      
            system.assertEquals(status,true);
        } catch (Exception  e) {
            System.assert(e.getMessage().contains('Script-thrown exception'));
        }    
    }

    @isTest static void testMethod2() {
        Test.startTest();
           List<ICX_SendEmail.FromEmailAddress> fromEmailAddress = ICX_SendEmail.searchFromEmail('csc');
           Case request =[select Id from Case  where TECH_Queue__c = null Limit 1];
           ICX_SendEmail.EmailMessageWrapper emailMessageWrapper = ICX_SendEmail.getDefaultReplyEmail(request.Id);
       Test.stopTest();
       system.AssertNotEquals(emailMessageWrapper,null);
    }

    @isTest static void testMethod3() {
        Test.startTest();
           List<ICX_SendEmail.FromEmailAddress> fromEmailAddress = ICX_SendEmail.searchFromEmail('csc');
           Task task = [select Id, Account.PersonEmail, ICX_Country__c ,whatID,AccountId  from Task Limit 1];
                   
           ICX_SendEmail.EmailMessageWrapper emailMessageWrapper = ICX_SendEmail.getDefaultReplyEmail(task.Id);
           String emailBody = '<p> Test Body <p>';
           string instance = '{' +
                                '"emailSubject":"'+  'test'+ '",' +
                                '"emailBody":"' + emailBody + '",' +
                                '"emailFromAddress":"' + fromEmailAddress[0].name + '",'+
                                '"emailToAddresses":[' +
                                    '"'+ emailMessageWrapper.ToAddress + '"'+
                                '],' +
                                '"emailCcAddresses":[],'+
                                '"emailBccAddresses":[],'+
                                '"emailattachments":[],'+
                                '"requestRecordId":"' + task.Id +'"'+
                              '}';
            // ICX_SendEmail.sendMailMethod(instance);
            Boolean status = ICX_SendEmail.sendMailMethod(instance);
            Test.stopTest();      
            system.assertEquals(status,true); 
    }

    @isTest static void testMethod4() {
        Test.startTest();
           List<ICX_SendEmail.FromEmailAddress> fromEmailAddress = ICX_SendEmail.searchFromEmail('csc');
           CareService__c cs = [SELECT Client__c,client__r.PersonEmail,client__r.PersonContactId FROM CareService__c Limit 1];
                   
           ICX_SendEmail.EmailMessageWrapper emailMessageWrapper = ICX_SendEmail.getDefaultReplyEmail(cs.Id);
           String emailBody = '<p> Test Body <p>';
           string instance = '{' +
                                '"emailSubject":"'+  'test'+ '",' +
                                '"emailBody":"' + emailBody + '",' +
                                '"emailFromAddress":"' + fromEmailAddress[0].name + '",'+
                                '"emailToAddresses":[' +
                                    '"'+ emailMessageWrapper.ToAddress + '"'+
                                '],' +
                                '"emailCcAddresses":[],'+
                                '"emailBccAddresses":[],'+
                                '"emailattachments":[],'+
                                '"requestRecordId":"' + cs.Id +'"'+
                              '}';
            // ICX_SendEmail.sendMailMethod(instance);
            Boolean status = ICX_SendEmail.sendMailMethod(instance);
            Test.stopTest();      
            system.assertEquals(status,true); 
    }

    @isTest static void testMethod5() {
        Test.startTest();
           List<ICX_SendEmail.FromEmailAddress> fromEmailAddress = ICX_SendEmail.searchFromEmail('csc');
           Family_Member__c fm = [SELECT client__r.PersonEmail,client__r.PersonContactId FROM Family_Member__c Limit 1];
                   
           ICX_SendEmail.EmailMessageWrapper emailMessageWrapper = ICX_SendEmail.getDefaultReplyEmail(fm.Id);
           String emailBody = '<p> Test Body <p>';
           string instance = '{' +
                                '"emailSubject":"'+  'test'+ '",' +
                                '"emailBody":"' + emailBody + '",' +
                                '"emailFromAddress":"' + fromEmailAddress[0].name + '",'+
                                '"emailToAddresses":[' +
                                    '"'+ emailMessageWrapper.ToAddress + '"'+
                                '],' +
                                '"emailCcAddresses":[],'+
                                '"emailBccAddresses":[],'+
                                '"emailattachments":[],'+
                                '"requestRecordId":"' + fm.Id +'"'+
                              '}';
            // ICX_SendEmail.sendMailMethod(instance);
            Boolean status = ICX_SendEmail.sendMailMethod(instance);
            Test.stopTest();      
            system.assertEquals(status,true); 
    }

    @isTest static void testMethod6() {
        Test.startTest();
           List<ICX_SendEmail.FromEmailAddress> fromEmailAddress = ICX_SendEmail.searchFromEmail('csc');
           Account acc = [SELECT PersonEmail,PersonContactId FROM Account Limit 1];
                   
           ICX_SendEmail.EmailMessageWrapper emailMessageWrapper = ICX_SendEmail.getDefaultReplyEmail(acc.Id);
           String emailBody = '<p> Test Body <p>';
           string instance = '{' +
                                '"emailSubject":"'+  'test'+ '",' +
                                '"emailBody":"' + emailBody + '",' +
                                '"emailFromAddress":"' + fromEmailAddress[0].name + '",'+
                                '"emailToAddresses":[' +
                                    '"'+ emailMessageWrapper.ToAddress + '"'+
                                '],' +
                                '"emailCcAddresses":[],'+
                                '"emailBccAddresses":[],'+
                                '"emailattachments":[],'+
                                '"requestRecordId":"' + acc.Id +'",'+
               					'"isRemoteConsent":true'+
                              '}';
            // ICX_SendEmail.sendMailMethod(instance);
            Boolean status = ICX_SendEmail.sendMailMethod(instance);
            Test.stopTest();      
            system.assertEquals(status,true); 
    }
    
    @isTest static void testMethod7() {
        Test.startTest();
            String testStr = '0D2';
            case caseID = [select id from case limit 1];
            try {
                ICX_SendEmail.setQueue(testStr,caseID.id);
            } catch (Exception e) {
                System.debug('Testmethod01 sendEmailtest: ' + e);
            }
        Test.stopTest();
    }
    
    @isTest static void remoteConsentAccess_TEST() {
        /*
        String roles = IconicsSettings__c.getOrgDefaults().ICX_RemoteConsentRoleAccess__c;
        List<String> rolesList = roles.split(';');
        
        User u = ICX_TestFactory.createUser(ICX_TestFactory.PROFILE_ICONICS_SA_NAME);
        u.userRoleId = rolesList.get(0);     

        System.runAs(u) {
    	
        }*/
        Boolean haveAccess = ICX_SendEmail.remoteConsentAccess();
        Assert.isFalse(haveAccess);
    
    }

    @isTest
    public static void formatImageInEmailBody_Test() {
        //Create Document
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        insert cv;
 
        //Get Content Version
        List<ContentVersion> cvList = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        System.assertEquals(cvList.size(), 1);
 
        List<ContentDocument> cdList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE Id = :cvList[0].ContentDocumentId];
        System.assertEquals(cdList.size(), 1);

        // String val = '<html><img src="https://louisvuitton.content.force.com/sfc/servlet.shepherd/version/download/' + cvList[0].Id + '?asPdf=false&amp;operationContext=CHATTER"></html>';
        String val = '<html><img src="https://louisvuitton.file.force.com/sfc/servlet.shepherd/version/download/' + cvList[0].Id + '?asPdf=false&amp;operationContext=CHATTER"></html>'; 

        Test.startTest();
        String result = ICX_SendEmail.formatImageInEmailBody(val);
        Test.stopTest();

        List<ContentAsset> assetList = [SELECT Id, DeveloperName FROM ContentAsset WHERE ContentDocumentId IN :cdList];
        System.assertEquals(assetList.size(), 1);

        Id orgId = UserInfo.getOrganizationId();
        // String expected = '<html><img src="https://louisvuitton.content.force.com/file-asset-public/' + assetList[0].DeveloperName + '?oid=' + orgId + '\" style=\"max-width: 640px;height: auto; display: block;\"></html>';
        String expected = '<html><img src="https://louisvuitton.file.force.com/file-asset-public/' + assetList[0].DeveloperName + '?oid=' + orgId + '\" style=\"max-width: 640px;height: auto; display: block;\"></html>'; 

        System.assertEquals(expected, result);
        //Get Content Documents
        //List<ContentDocument> cdList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        //System.assertEquals(cdList.size(), 1);
        //String val = '<html><img src="https://louisvuitton--iconics--c.cs70.content.force.com/sfc/servlet.shepherd/version/download/0683D000000hG1h?asPdf=false&amp;operationContext=CHATTER"><br/><div style="display:none ; color:#fff">ref:_00D3DCypS._5003D3q27d:ref</div><img src="https://louisvuitton--iconics--c.cs70.content.force.com/sfc/servlet.shepherd/version/download/0683D000000hG1cQAE?asPdf=false&amp;operationContext=CHATTER"></html>';

    }
    
     @isTest static void searchTemplateTest() {
        Test.startTest();

        try {
            User user = [SELECT id from User LIMIT 1];

            List<ICX_SendEmail.FromEmailAddress> fromEmailAddress = ICX_SendEmail.searchFromEmail('csc');
            List<EmailTemplate> emailTemplates = ICX_SendEmail.findTemplates('csc', 'ICONiCS_Templates');

            Case request = [select Id from Case  where TECH_Queue__c != null Limit 1];
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            
            ICX_SendEmail.EmailMessageWrapper emailMessageWrapper = ICX_SendEmail.getDefaultReplyEmail(request.Id);
            String emailBody = '<p> Test Body <p>';
            String signature = 'signature';
            ICX_SendEmail.previewEmail(emailMessageWrapper.emailTemplate.id,emailBody,request.Id,signature);
            string instance = '{' +
                                '"emailSubject":"'+ emailMessageWrapper.emailTemplate.Subject + '",' +
                                '"emailBody":"' + emailBody + '",' +
                                '"emailSignature":"' + signature + '",' +
                                '"emailFromAddress":"' + fromEmailAddress[0].Id + '",'+
                                '"emailToAddresses":[' +
                                    '"'+ emailMessageWrapper.ToAddress + '"'+
                                '],' +
                                '"emailCcAddresses":[],'+
                                '"emailBccAddresses":[],'+
                                '"emailattachments":['+
                                    '"'+ documents[0].Id  + '"'+
                                '],'+
                                '"requestRecordId":"' + request.Id +'",'+
                                '"emailTemplate":{'+
                                    '"Id":"' + emailMessageWrapper.emailTemplate.id + '",'+
                                    '"Name":"' + emailMessageWrapper.emailTemplate.Name + '",'+
                                    '"Subject":"' + emailMessageWrapper.emailTemplate.Subject + '"'+
                                '}'+
                              '}';
            Boolean status = ICX_SendEmail.sendMailMethod(instance);
            Test.stopTest();      
            system.assertEquals(status,true);
        } catch (Exception  e) {
            System.assert(e.getMessage().contains('Script-thrown exception'));
        }    
    }
}