/**
About
-----
Description: Test Factory class
Created for: SOW: IC001 ICON project
Create date: Feb 2013

Details
-------
Methodes for test classes to create Account, Events

Update History
--------------
Feb 2013 / IC001/ Created by Axel KAMALAK 

Issues / TODOs
--------------
*/

public class IC_TestFactory {
    
    //-- PROFILE NAMES by their IDs (see static initializer)
    public static final String PROFILE_ICON_SA_NAME = 'ICON_SA';
    public static final String PROFILE_ICON_SA_MANAGER_NAME = 'ICON_SA Manager';
    public static final String PROFILE_ICON_CORPORATE_NAME = 'ICON_Corporate';
    public static final String PROFILE_ICON_DREAM_NAME = 'ICON_Interface DREAM';
    public static final String PROFILE_LV_ADMIN_NAME = 'ICON_LV Administrator';
    public static final String IC_KOREAN_FILTER_CODE = 'KOR';
    
    //-- IDs of those profiles for convenience
    public static ID PROFILE_ICON_SA;
    public static ID PROFILE_ICON_SA_MANAGER;
    public static ID PROFILE_ICON_CORPORATE;
    public static ID PROFILE_ICON_DREAM;
    public static ID PROFILE_LV_ADMIN;
    
    /**
* Map that contains all the profiles by their IDs
**/
    public static final Map<String,Id> PROFILE_MAP;
    
    /** Unique identifier (resets for each scope) **/
    public static Integer UUID = 0;
    
    /** Creates a new unique value within a testing scope **/
    public static Integer getUUID(){ return( ++UUID ); }
    
    /** Makes a string unique by appending a unique identifier **/
    public static String makeUnique( String str ){
        return( '' + str + getUUID() );
    }
    
    //-- Static initializer that converts the profile names later available in tests
    static {
        PROFILE_MAP = new Map<String,String>();
        
        String[] profileNames = new String[]{
            PROFILE_ICON_CORPORATE_NAME,
                PROFILE_ICON_DREAM_NAME,
                PROFILE_ICON_SA_MANAGER_NAME,
                PROFILE_ICON_SA_NAME,
                PROFILE_LV_ADMIN_NAME
                };
                    for( Profile p : [
                        select id, name
                        from Profile
                        where name in :profileNames
                    ]){
                        PROFILE_MAP.put( p.Name, p.id );
                        
                        //System.debug( 'putting profile[' + p.Name + ']:' + p.Id );
                        
                        //-- CONVENIENCE to place them in static constants
                        //-- instead of IC_TestFactory.PROFILE_MAP.get( IC_TestFactory.PROFILE_ICON_CORPORATE_NAME )
                        if( PROFILE_ICON_CORPORATE_NAME.equalsIgnoreCase( p.Name )){
                            PROFILE_ICON_CORPORATE = p.id;
                        } else if( PROFILE_ICON_DREAM_NAME.equalsIgnoreCase( p.Name )){
                            PROFILE_ICON_DREAM = p.Id;
                        } else if( PROFILE_ICON_SA_MANAGER_NAME.equalsIgnoreCase( p.Name )){
                            PROFILE_ICON_SA_MANAGER = p.Id;
                        } else if( PROFILE_ICON_SA_NAME.equalsIgnoreCase( p.Name )){
                            PROFILE_ICON_SA = p.Id;
                        } else if( PROFILE_LV_ADMIN_NAME.equalsIgnoreCase( p.Name )){
                            PROFILE_LV_ADMIN = p.Id;
                        }
                    }
    }
    
    public static User createUser( String uName, Id profileId ){
        String alias = makeUnique( 'atest_' );
        String email = '' + alias + '@test.com';
        uName= '' + UserInfo.getOrganizationId() + System.now().millisecond() + uName;
        return( new User(
            username = uName,
            email = email,
            alias = alias,
            profileId = profileId,
            emailEncodingKey = 'UTF-8',
            firstName = 'John',
            lastName = alias,
            localeSIDKey = 'en_US',
            languageLocaleKey = 'en_US',
            timezoneSIDKey = 'America/Los_Angeles'
        ));
    }
    
    /**
*  Determines if a specific person matches a specific profile.
*  <p>This is a convenience function as opposed to simply comparing against PROFILE_MAP( profileName )</p>
*  @param profileName (String)
*  @param u (User)
*  @return Boolean - true if they match, false if they do not.
**/
    public static Boolean isUserProfile( String profileName, User u ){
        System.debug( '[' + profileName + ']:' + PROFILE_MAP.get( profileName ) );
        System.debug( '[expected]:' + u.id );
        return( PROFILE_MAP.get( profileName ) == u.profileId );
    }
    
    /**
*  Determines if the current user matches a specific profile.
*  <p>This is a convenience function as opposed to simply comparing against PROFILE_MAP( profileName )</p>
*  @param profileName (String)
*  @return Boolean - true if they match, false if they do not.
**/
    public static Boolean isUserProfile( String profileName ){
        return( PROFILE_MAP.get( profileName ) == UserInfo.getProfileId() );
    }
    
    
    public static User createUser(String uName)
    {
        String alias = makeUnique( 'atest_' );
        String email = '' + alias + '@test.com';
        uName= '' + UserInfo.getOrganizationId() + System.now().millisecond() + uName;
        User u = new User(
            username = uName,
            email ='test123456789QW@fr.lv.test.com',
            localeSidKey = 'en_US',
            languageLocaleKey = 'en_US',
            lastname='test',
            TimeZoneSidKey='GMT',
            EmailEncodingKey='UTF-8',
            alias='userlv');
        
        return u;
    }
    
    
    public static Account createAccount()
    {  
        Account a = new Account();
        a.LastName = 'Europe' + String.valueOf(System.now());
        a.FirstName='Louis';
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
        return a;
    }
    
    public static Account createAccount(Date lastContactDate)
    {  
        Account a = new Account();
        a.LastName = 'Europe' + String.valueOf(System.now());
        a.FirstName='Louis';
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
        a.LastContactDate__pc=lastContactDate;
        
        return a;
    }
    
    
    
    public static Event createEvent(Account acc) 
    {
        Event evt = new Event();
        evt.Description='Un event de test';
        evt.StartDateTime = Date.today().addDays(1);
        evt.EndDateTime=Date.today().addDays(3);
        evt.Subject='Sujet du test';
        //evt.Occasion__c='Travel';
        evt.Location='Paris';
        evt.IsAllDayEvent=false;
        evt.ShowAs='Free';
        evt.Source__c='Unexcepted';
        evt.Service__c='Test';
        evt.SaleAmount__c=1;
        evt.WhatId=acc.Id;
        //evt.WhoId=null;
        //evt.AccountId=acc.Id; 
        return evt;
    }
    
    
    
    public static Event createEvent(Date aDate)
    {
        Event evt = new Event();
        evt.Description='Un event de test';
        evt.StartDateTime = aDate;
        evt.EndDateTime=Date.today().addDays(3);
        evt.ActivityDate=aDate;
        evt.Subject='Sujet du test';
        //evt.Occasion__c='Travel';
        evt.Location='Paris';
        evt.IsAllDayEvent=false;
        evt.ShowAs='Free';
        evt.Source__c='Unexcepted';
        evt.Service__c='Test';
        evt.SaleAmount__c=1;
        return evt;
    }
    
    public static Event eventEndByDuration( Event evt, Integer hours )
    {
        evt.EndDateTime = DateTime.newInstance( evt.StartDateTime.getTime() ).addHours( hours );
        return evt;
    }
    
    public static Event createEvent()
    {
        Event evt = new Event();
        evt.Description='Un event de test';
        evt.StartDateTime = Date.today().addDays(1);
        evt.EndDateTime=Date.today().addDays(3);
        evt.Subject='Sujet du test';
        //evt.Occasion__c='Travel';
        evt.Location='Paris';
        evt.IsAllDayEvent=false;
        evt.ShowAs='Free';
        evt.Source__c='Unexcepted';
        evt.Service__c='Test';
        evt.SaleAmount__c=1;
        return evt;
    }
    
    public static Task createTask(Account acc)
    {
        Task tsk = new Task();
        tsk.Subject='TEST ' + String.valueOf(System.now());
        tsk.ActivityDate=Date.today().addDays(-6);
        tsk.WhatId=acc.Id;
        tsk.Priority='Low';
        tsk.Status='To Do';
        tsk.Description='Description du jour' + String.valueOf(System.now());
        tsk.ActionType__c='Email';
        return tsk;
    }
    
    public static Task createTask()
    {
        Task tsk = new Task();
        tsk.Subject='TEST ' + String.valueOf(System.now());
        tsk.ActivityDate=Date.today().addDays(6);
        tsk.Priority='Low';
        tsk.Status='To Do';
        tsk.Description='Description du jour' + String.valueOf(System.now());
        tsk.ActionType__c='Email';
        return tsk;
    }
    
    public static Task createTask(String actionType,id recordTid,Date activityDte){
        
        Task tsk = new Task();
        tsk.Subject='TEST ' + String.valueOf(System.now());
        tsk.Priority='Low';
        tsk.Status='To Do';
        tsk.Description='Description du jour' + String.valueOf(System.now());
        tsk.ActionType__c = actionType;
        tsk.RecordTypeId = recordTid;
        tsk.ActivityDate = activityDte;
        return tsk;
    }
    
    public static CLI_CliList__c  clientlistMembers()
    {
        CLI_CliList__c  clm = new CLI_CliList__c();
        clm.Name ='Client 1';
        clm.Description__c ='Description test';
        clm.Active__c = true;
        return clm;
    }
    
    public static Folder createFolder()
    {
        //Select f.Type, f.Name, f.DeveloperName, f.AccessType From Folder f
        Folder fld = new Folder();
        fld.Name='Email';
        fld.DeveloperName='Mobile123';
        fld.Type='Email';
        fld.AccessType='Public';
        return fld;
    }
    
    
    public static EmailTemplate  createEmailTemplate(List<Folder> f)
    {
        EmailTemplate myEmail = new EmailTemplate();
        myEmail.Description = ' TEST GOOD YEAR WITH SALESFORCE';
        myEmail.Subject = 'GOOD YEAR';
        myEmail.Body='DESC ' +  myEmail.Description + Date.today();
        myEmail.TemplateType = 'text';
        myEmail.TemplateStyle ='none';
        myEmail.Name = 'TEMPLATE NEW YEAR TEST ';
        myEmail.FolderId=f[0].Id;
        myEmail.DeveloperName = 'Mobile123';
        return myEmail;
    }
    
    public static PPR_PurchProduct__c createPurchaseProduct(String accId) {
        PPR_PurchProduct__c pp = new PPR_PurchProduct__c();
        pp.DreamIdSA__c = '123';
        pp.Client__c = accId;
        pp.TicketNumber__c = '789';
        pp.Amount__c = 4000;
        pp.ConvertedAmountEUR__c = 4000;
        pp.ConvertedAmountUSD__c = 4000;
        pp.ConvertedAmountYEN__c = 4000;
        pp.ConvertedAmountYUAN__c = 4000;
        pp.OrderATGId__c = 'test';
        pp.TransactionRMSId__c = 'transacRMSId';
        pp.TransactionTotalAmount__c = 400.00;
        return pp;
    }
    
    
    public static Case createCase(Account acc, PPR_PurchProduct__c ppr){
        Case cse = new Case();
        cse.Status = 'New';
        cse.Priority = 'Medium';
        cse.AccountId = acc.Id;
        cse.PprLinked__c = ppr.Id;
        cse.Transaction_Id__c = ppr.OrderATGId__c;
        cse.Origin = 'Email';
        cse.Description = ' Un case de Test';
        return cse;
    }
    
    
    public static Case createCase(Account acc){
        Case cse = new Case();
        cse.Status = 'New';
        cse.Priority = 'Medium';
        cse.AccountId = acc.Id;
        cse.Origin = 'Email';
        cse.Description = ' Un case de Test';
        return cse;
    }
    
    public static Exclusive_Experience__C createExclusiveExperience(Account acc){
        
        Exclusive_Experience__C xxpr = new Exclusive_Experience__C();
        
        // Get XXPR Picklist values according to Org
        Schema.DescribeFieldResult XXPR_Typology = Exclusive_Experience__c.Typology__c.getDescribe();
        Schema.sObjectField fieldTypology = XXPR_Typology.getSObjectField();
        List<PicklistEntry> picklistValuesTypology = fieldTypology.getDescribe().getPicklistValues();        
        
        Schema.DescribeFieldResult XXPR_OfferCode = Exclusive_Experience__c.Offer_Code__c.getDescribe();
        Schema.sObjectField fieldOfferCode = XXPR_OfferCode.getSObjectField();
        List<PicklistEntry> picklistValuesOfferCode = fieldOfferCode.getDescribe().getPicklistValues();
        
        // Create XXPR
        xxpr.Account_Id__c = acc.Id;
        xxpr.Dream_Id__c = acc.DREAMID__c;
        xxpr.Typology__c = picklistValuesTypology[0].getValue();
        xxpr.Offer_Code__c = picklistValuesOfferCode[0].getValue();           
        return xxpr;
    }
    public static Exclusive_Campaign_Order__c createExclusiveCampaignOrder (Account acc,Exclusive_Campaign__c ec,Exclusive_Campaign_Product__c ecp,String techUnique){
        
        Exclusive_Campaign_Order__c eco = new Exclusive_Campaign_Order__c();
        
        // Get eco recordType 
        Schema.DescribeSObjectResult d = Schema.SObjectType.Exclusive_Campaign_Order__c; 
        Id recordTypeId = d.getRecordTypeInfosByName().get('Exclusive Campaign Order').getRecordTypeId();
        
        // createExclusiveCampaignOrder
        eco.recordTypeId =  recordTypeId;
        eco.Exclusive_Campaign__c  = ec.Id;
        eco.Product__c  = ecp.Id; 
        eco.Client__c  = acc.Id;
        eco.TECH_UniqueOrderNumber__c = techUnique;
        return eco;
    }
    public static Exclusive_Campaign__c  createExclusiveCampaign(String varTe){
        datetime now =  datetime.now();
        datetime nextDate = now.addDays(5);
        Exclusive_Campaign__c ec = new Exclusive_Campaign__c();
        ec.Name  = 'campaign'+varTe;
        ec.Start_Date__c = now;
        ec.End_Date__c = nextDate;
        return ec;
    }
    public static Exclusive_Campaign_Product__c   createExclusiveCampaignProduct(String varTe){
        Exclusive_Campaign_Product__c ecp = new Exclusive_Campaign_Product__c();
        ecp.Name  = 'Product'+varte;
        ecp.Status__c  = 'Available';
        return ecp;
    }
    public static Social_Media_Identifier__c   createSocialMediaIdentifier(String AccId,String typeSMI){
        Social_Media_Identifier__c smi = new Social_Media_Identifier__c();
        smi.Client__c=AccId;
        smi.Social_Media_Type__c =typeSMI;
        smi.Social_Id__c = 'ojqn705KaSYOAiMfmC1ar_'+ String.valueOf(System.now()) ;
        return smi;
    }
}