/*	 * @author Keman WU
* @date creation 26/10/2022
* @description test class for Task_TriggerHandler
*/
@isTest
public with sharing class ICX_CSVImportCtrl_TEST {
     
    @isTest
    public static void testICX_CSVImportBatch(){

    Account a = new Account(DREAMID__c = '55555555', LastName = 'Test Account' , RecordTypeId='0120H000001YZKhQAO');
    insert a;

    Set<String> dreamid = new set<String>{'55555555'};

	List<Case>  listTechToInsert = new List<Case>();     
    Case myCase = new Case();
    myCase.Origin = 'File Import'; 
    myCase.Status = 'New';
    listTechToInsert.add(myCase);
    Test.startTest();  
    ICX_CSVImportBatch apc1 = new ICX_CSVImportBatch(listTechToInsert,dreamid);
    Id jobId = Database.executeBatch(apc1, 70); 
    Test.stopTest();  
    }

    @isTest
    public static void createDPCATestPreupload3(){
            
    List<Account> accounts = new List<Account>();

    for(Integer i = 0; i < 70; i++)
    {
        Account a = new Account(DREAMID__c = '55555555' + i, LastName = 'Test Account' + i, RecordTypeId='0120H000001YZKhQAO');
        accounts.add(a);
    }

    // insert the entire collection of 200 accounts
    insert accounts;
    
    Id profileId =[select Id from Profile where Name = 'ICONiCS_SA'].Id;
    User use = ICX_TestFactory.createUser(profileId);
    insert use;
    Id useId = use.id;

    User User1 = [select id from user limit 1];
    
    Account acc1 = ICX_TestFactory.createAccount();
    acc1.DREAMID__c = '12345678';
    insert acc1;

    Account acc2 = ICX_TestFactory.createAccount();
    acc1.DREAMID__c = '87654321';
    insert acc2;

    String str = 'DreamId,Country,213\r\n' +
    '12345678,France,'+useId+'\r\n' +
    '87654321,France,'+useId+'\r\n';
    
    String str2 = 'DreamId,Country,213\r\n'; 
    
    for(integer i = 2 ; i< 60; i++)
    {
        str2 += '55555555'+i+',France,'+useId+'\r\n';
    }

    ContentVersion contentVersionInsert = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.csv',
            VersionData = Blob.valueOf(str),
            IsMajorVersion = true
    );
        
    ContentVersion contentVersionInsert2 = new ContentVersion(
            Title = 'Test2',
            PathOnClient = 'Test2.csv',
            VersionData = Blob.valueOf(str2),
            IsMajorVersion = true
    );
    insert contentVersionInsert;
    insert contentVersionInsert2;

    Test.startTest();  

    try {    
        ContentVersion myContentVersion2 = [select id,ContentDocumentId from ContentVersion where Title ='Test2'] ;

        list<String> lstDPCA2 = ICX_CSVImportCtrl.createDPCAPreupload(myContentVersion2.ContentDocumentId);

    } catch(DmlException e) {
        System.debug('The following exception has occurred: ' + e.getMessage());
    }
    Test.stopTest();    
    }

         
    @isTest
    public static void createDPCATest2(){
    List<Account> accounts = new List<Account>();

    for(Integer i = 0; i < 100; i++)
    {
        Account a = new Account(DREAMID__c = '55555555' + i, LastName = 'Test Account' + i, RecordTypeId='0120H000001YZKhQAO');
        accounts.add(a);
    }
    // insert the entire collection of 200 accounts
    insert accounts;
        
    Id profileId =[select Id from Profile where Name = 'ICONiCS_SA'].Id;
    User use = ICX_TestFactory.createUser(profileId);
    insert use;
    Id useId = use.id;
    User User1 = [select id from user limit 1];
    
    Account acc1 = ICX_TestFactory.createAccount();
    acc1.DREAMID__c = '12345678';
    insert acc1;

    Account acc2 = ICX_TestFactory.createAccount();
    acc1.DREAMID__c = '87654321';
    insert acc2;

    String str = 'DreamId,Country,213\r\n' +
    '12345678,France,'+useId+'\r\n' +
    '87654321,France,'+useId+'\r\n';
    
    String str2 = 'DreamId,Country,213\r\n'; 
    
    for(integer i = 2 ; i< 80; i++)
    {
        str2 += '55555555'+i+',France,'+useId+'\r\n';
    }
    
    ContentVersion contentVersionInsert = new ContentVersion(
        Title = 'Test',
        PathOnClient = 'Test.csv',
        VersionData = Blob.valueOf(str),
        IsMajorVersion = true
    );
    
    ContentVersion contentVersionInsert2 = new ContentVersion(
        Title = 'Test2',
        PathOnClient = 'Test2.csv',
        VersionData = Blob.valueOf(str2),
        IsMajorVersion = true
    );
    
    insert contentVersionInsert;
    insert contentVersionInsert2;

    Test.startTest();  
    ContentVersion myContentVersion = [select id,ContentDocumentId from ContentVersion where Title ='Test'] ;
    ContentVersion myContentVersion2 = [select id,ContentDocumentId from ContentVersion where Title ='Test2'] ;

    list<Case> lstDPCA = ICX_CSVImportCtrl.createDPCA(myContentVersion.ContentDocumentId);
    Test.stopTest();   
    }

    @isTest
    public static void createDPCATest(){
            
    List<Account> accounts = new List<Account>();

    for(Integer i = 0; i < 70; i++)
    {
        Account a = new Account(DREAMID__c = '55555555' + i, LastName = 'Test Account' + i, RecordTypeId='0120H000001YZKhQAO');
        accounts.add(a);
    }

    // insert the entire collection of 200 accounts
    insert accounts;
    
    Id profileId =[select Id from Profile where Name = 'ICONiCS_SA'].Id;
    User use = ICX_TestFactory.createUser(profileId);
    insert use;
    Id useId = use.id;

    User User1 = [select id from user limit 1];
    
    Account acc1 = ICX_TestFactory.createAccount();
    acc1.DREAMID__c = '12345678';
    insert acc1;

    Account acc2 = ICX_TestFactory.createAccount();
    acc1.DREAMID__c = '87654321';
    insert acc2;

    String str = 'DreamId,Country,213\r\n' +
    '12345678,France,'+useId+'\r\n' +
    '87654321,France,'+useId+'\r\n';
    
    String str2 = 'DreamId,Country,213\r\n'; 
    
    for(integer i = 2 ; i< 60; i++)
    {
        str2 += '55555555'+i+',France,'+useId+'\r\n';
    }

    ContentVersion contentVersionInsert = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.csv',
            VersionData = Blob.valueOf(str),
            IsMajorVersion = true
    );
        
    ContentVersion contentVersionInsert2 = new ContentVersion(
            Title = 'Test2',
            PathOnClient = 'Test2.csv',
            VersionData = Blob.valueOf(str2),
            IsMajorVersion = true
    );
    insert contentVersionInsert;
    insert contentVersionInsert2;

    Test.startTest();  
    try {    
    ContentVersion myContentVersion2 = [select id,ContentDocumentId from ContentVersion where Title ='Test2'] ;
    list<Case> lstDPCA2 = ICX_CSVImportCtrl.createDPCA(myContentVersion2.ContentDocumentId);
    } catch(DmlException e) {
        System.debug('The following exception has occurred: ' + e.getMessage());
    }
    Test.stopTest();    
    }

    // @isTest
    // public static void createVideoSessionMemberTest(){
    //     Video_Session__c vs = new Video_Session__c();
    //     insert vs;
    //     Account acc1 = ICX_TestFactory.createAccount();
    //     acc1.DREAMID__c = '12345678';
    //     insert acc1;

    //     Account acc2 = ICX_TestFactory.createAccount();
    //     acc1.DREAMID__c = '87654321';
    //     insert acc2;

    //     String str = 'DreamId \r\n' +
    //     '12345678 \r\n' +
    //     '87654321 \r\n';
    // ContentVersion contentVersionInsert = new ContentVersion(
    //         Title = 'Test',
    //         PathOnClient = 'Test.csv',
    //         VersionData = Blob.valueOf(str),
    //         IsMajorVersion = true
    // );
    // insert contentVersionInsert;
    // Test.startTest();       
    // ContentVersion myContentVersion = [select id,ContentDocumentId from ContentVersion where Title ='Test'] ;
    
    // list<Video_Session_Member__c> lstVSM = ICX_CSVImportCtrl.createVideoSessionMember(myContentVersion.ContentDocumentId,vs.Id);
    // System.assertEquals(2, lstVSM.size());
    // Test.stopTest();
    // }
}