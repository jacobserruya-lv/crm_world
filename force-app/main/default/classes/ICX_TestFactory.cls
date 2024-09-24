/**
 *   @About
 *   Description: Test Factory class
 *   Created for: ICONiCS project
 *
 *  @Details
 *  Methodes for test classes to create Case, Account...
*/
@isTest
public class ICX_TestFactory {

    //-- PROFILE NAMES by their IDs (see static initializer)
    public static final String PROFILE_ICONICS_SA_NAME = 'ICONiCS_SA';
    public static final String PROFILE_ICONICS_SA_MANAGER_NAME = 'ICONiCS_SA_Manager';
    public static final String PROFILE_ICONICS_CORPORATE_NAME = 'ICONiCS_Corporate';
    public static final String PROFILE_SYSTEM_ADMINNISTRATOR_NAME = 'System Administrator';

    //-- IDs of those profiles for convenience
    public static ID PROFILE_ICONICS_SA;
    public static ID PROFILE_ICONICS_SA_MANAGER;
    public static ID PROFILE_ICONICS_CORPORATE;
    public static ID PROFILE_SYSTEM_ADMINNISTRATOR;
    
    static final string EXISTING_ORDER_NUMBER = '1234567898000000';
    static final string EXISTING_SHIPPING_NUMBER = '0123456789-1';
    
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
            PROFILE_ICONICS_CORPORATE_NAME,
            PROFILE_ICONICS_SA_MANAGER_NAME,
            PROFILE_ICONICS_SA_NAME,
            PROFILE_SYSTEM_ADMINNISTRATOR_NAME
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
            if( PROFILE_ICONICS_CORPORATE_NAME.equalsIgnoreCase( p.Name )){
                PROFILE_ICONICS_CORPORATE = p.id;
            } else if( PROFILE_ICONICS_SA_MANAGER_NAME.equalsIgnoreCase( p.Name )){
                PROFILE_ICONICS_SA_MANAGER = p.Id;
            } else if( PROFILE_ICONICS_SA_NAME.equalsIgnoreCase( p.Name )){
                PROFILE_ICONICS_SA = p.Id;
            } else if( PROFILE_SYSTEM_ADMINNISTRATOR_NAME.equalsIgnoreCase( p.Name )){
                PROFILE_SYSTEM_ADMINNISTRATOR = p.Id;
            }
        }
    }

    public static User createUser(Id profileId ) {
        String alias = makeUnique( 'atest_' );
        String email = '' + alias + '@test.com';
       
        return( new User(
            username = email,
            email = email,
            alias = alias,
            profileId = profileId,
            emailEncodingKey = 'UTF-8',
            firstName = 'John',
            lastName = alias,
            localeSIDKey = 'en_US',
            languageLocaleKey = 'en_US',
            timezoneSIDKey = 'America/Los_Angeles',
            Country__c = 'USA'
        ));
    }

    public static Account createAccount() {  
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
        a.SPO_Country__pc = 'France';
        a.SPO_Country_code__pc = 'FRA';
        a.PassportNumber__pc='ABC12345';
        //a.LastContactDate__pc=lastContactDate;
        return a;
    }

    public static Account createAccount2(Id userId) {  
        Account a = new Account();
        a.LastName = 'Europe' + String.valueOf(System.now());
        a.FirstName='Louis';
        a.Salutation = 'Ms';
        a.Segmentation__pc='VIC';
        a.PrimaryAddressLine1__pc='Adresse ligne 1';
        a.PrimaryAddressLine2__pc='Adresse ligne 2';
        a.PrimaryAddressLine3__pc ='Adresse ligne 3';
        a.PrimaryCity__pc='Paris';
        a.OwnerId = userId;
        a.DREAMID__c = '48976638';
        a.PersonEmail='sylvie@lv.com';
        a.PrimaryZipCode__pc='75000';
        a.PrimaryCountry__pc='France';
        a.SPO_Country__pc = 'France';
        a.SPO_Country_code__pc = 'FRA';
        a.PassportNumber__pc='ABC12345';
        //a.LastContactDate__pc=lastContactDate;
        return a;
    }


    public static Family__c createFamily()
    {
            Family__c famil = new Family__c();
            famil.Family_ID__c = '001020000E9kHGCH';
            famil.Status__c = 'Closed';
        
         return famil;
    } 

    public static List<Family_Member__c> createFamily_MemberList(integer familyNumber,ID accountId,ID familyId)
    {
      List<Family_Member__c> familyTsetList = new List<Family_Member__c>();

     for(integer i =0; i < familyNumber; i++)
     {
         Family_Member__c famil = new Family_Member__c();
         famil.Client__c = accountId;
         famil.Family__c = familyId;
         familyTsetList.add(famil);
     }
        
         return familyTsetList;
    } 

    public static Alias__c createAlias()
    {
        Alias__c alia = new Alias__c();
        alia.Name = '15HJH654548';
        alia.Status__c = 'Closed';
        return alia;
    } 

    public static Alias_Member__c createAlias_Member(ID accountId , ID AliasId)
    {
        Alias_Member__c alia = new Alias_Member__c();
        alia.Client__c = accountId;
        alia.Alias__c = AliasId;
        return alia;

    }


    public static Case createCase(Id accountId) {//, Map<String, Object> fieldMap) {
        Case cas = new Case();
        cas.Type = 'Product Information';
        cas.Category__c = 'Availability';
        cas.Status = 'New';
        cas.Country__c = 'France';
        if (String.isNotBlank(accountId)) {
            cas.AccountId = accountId;
        }
        
        // record type
        Id emailRecordTypeId = [select Id, SobjectType, DeveloperName from recordtype where SobjectType='Case' and DeveloperName ='Web_Email_Case' LIMIT 1].Id;
        cas.RecordTypeId = emailRecordTypeId;
        return cas;
    }

    public static PPR_PurchProduct__c createPurchases(Id accountId)
    {
        PPR_PurchProduct__c purch = new PPR_PurchProduct__c();
        purch.Client__c = accountId;
        purch.Name ='LP0005';
        purch.Quantity__c = 155 ;
        purch.Amount__c = 3 ;
        purch.SKU__c = 'M45788';
        purch.StoreRetailCode__c = '156FGkj54';
        purch.Store__c = 'Man Shoes';
        purch.StoreCountry__c ='CA';
        purch.TicketNumber__c = 'JHGFD65434';
        purch.PurchasedDate__c=Date.newInstance(2022, 8, 17); 
        purch.CAName__c = 'Bar';

        return purch;

    }

    public static Calling_Campaign__c createCallingCampaign(Id accountId)
    {
        Calling_Campaign__c callc = new Calling_Campaign__c();
        callc.Client__c = accountId;
        callc.Status__c = 'Reached / Informed';
        callc.Product_Name__c = 'Weman Rings';
        return callc;
    }

    public static Order__c createOrder(Id accountId)
    {
        Order__c ord = new Order__c();
        Date ordDate;
        ord.Account__c = accountId;
       // ord.OrderDate__c = ordDate.format('15-8-2022');
        ord.OrderNumber__c	= '65465465';
        return ord;
    }

    public static OrderShipping__c createOrderShipping(Id orderId)
    {
        OrderShipping__c ordShi = new OrderShipping__c();
        ordShi.Status__c = 'Reached';
        ordShi.Order__c = orderId;
        ordShi.ShippingNumber__c = '12345666';
        return ordShi;
    }

    public static OrderLine__c createOrderLine(Id orderId, Id ordshiId)
    {
        OrderLine__c ordL = new OrderLine__c();
        ordL.Order__c = orderId;
        ordL.SKU__c ='654654';
        ordL.OrderShipping__c = ordshiId;
        return ordL;
    }

    public static CareService__c createCareService(Id accountId,Id recordType)
    {
        CareService__c careServ = new CareService__c();
        careServ.Client__c = accountId;
        //no need created/ last modify
        // careServ.CreatedById = useId;
        // careServ.LastModifiedById = useId;
        careServ.RecordTypeId = recordType;
        return careServ;
    }

    public static VO_Survey__c createSurvey(Id accountId)
    {
    //     VO_Survey__c surv = new VO_Survey__c();
    //     surv.ClientDreamID__c = accountId;
    //     //no need created/ last modify
    //    // surv.CreatedById = useId;
    //     //surv.LastModifiedById = useId;
    //     return surv;

        Test.loadData(VO_Config__c.sobjectType, 'VO_Config_TestCLS');
        VO_Survey__c srv = new VO_Survey__c(SurveyType__c = VO_Utils.VOICE_WEB_SALES, StoreID__c = 'P3', DreamIDText__c = '14712', IDTransaction__c = '123', ClientDreamID__c = accountId);
        return srv;

    }

    public static List<ContentVersion> createContentVersion(Integer listLength,Id userId){
        List<ContentVersion> contentTest = new List<ContentVersion>();
        for(Integer i =0; i < listLength;i++)
        {
            ContentVersion conv = new ContentVersion();
            conv.Title = 'testFile';
            conv.PathOnClient = 'testFile';
            conv.VersionData = Blob.valueOf('string');
            conv.OwnerId = userId;
            contentTest.add(conv);
        }
        return contentTest;
    }

    public static List<Export_Purchases_Tracability__c> createExportPurchasesTracability(Integer listLength,String dreamId,Id userId,Id versionId){
        List<Export_Purchases_Tracability__c> ExportTest = new List<Export_Purchases_Tracability__c>();
        for(Integer i =0; i<listLength;i++)
        {
            Export_Purchases_Tracability__c Exp = new Export_Purchases_Tracability__c();
            Exp.CreatedById = userId;
            Exp.LastModifiedById = userId;
            Exp.versionId__c = versionId;
            Exp.OwnerId = userId;
            Exp.Status__c ='Ready To Download';
            Exp.DreamId__c = dreamId;
            ExportTest.add(Exp);
        }
        return ExportTest;
    }

    public static Interests__c createTags(Id accountId,Id useId)
    {
        Interests__c tag = new Interests__c();
        tag.Client__c = accountId;
        //no need created/ last modify

        tag.CreatedById = useId;
        tag.LastModifiedById = useId;
        tag.Source__c = 'Iconics';
        return tag;
    }

    public static CountryMapping__mdt getCountryCode()
    {
       CountryMapping__mdt countrCode = new CountryMapping__mdt();
       countrCode.Picklist__c = 'ISRAEL';
       countrCode.Iso3Code__c  = 'ISR';
       return countrCode;
    }

    public static CountryMapping__mdt getPhoneCallCode()
    {
       CountryMapping__mdt phoneCode = new CountryMapping__mdt();
       phoneCode.Picklist__c = 'ISRAEL';
       phoneCode.Iso3Code__c  = 'ISR';
       phoneCode.Calling_Code__c = 972;
       return phoneCode;
    }

    
    public static Store__c createStore(String storeName, String storeCode)
    {
        Store__c st = new Store__c (Name = storeName,
                                 	RetailStoreId__c = storeCode,
                                 	Status__c = 'Open',
                                 	StoreType__c = 'Store');
        return st;
        
    }

    public static Task createEmailTaskOnCase(String caseID)
    {
        Task t = new Task(Subject = 'Email: this is the subject',
                          Description = 'Email: Here goes the task description',
                          Status = 'New',
                          whatid = caseID );
        return t;

    }

    public static Task creatCallTaskOnAccount(Id accountId) {
        Task t = new Task(Subject = 'Call 2018-04-17 17:16:15',
                          CallObject = 'VOICE.83917129.1523978169173.0050H000009JXM6QAO',
                          cnx__CTIInfo__c = 'ANI: +33664309999, DNIS: 19112224, DialedNumber: 19101099',
                          cnx__UniqueId__c = 'VOICE.83917129.1523978169173.0050H000009JXM6QAO',
                          Description = 'Email: Here goes the task description',
                          Status = 'Completed',
                          //TaskSubtype = 'Task',
                          CallType = 'Inbound',
                          //AccountId = accountId,
                          whatid = accountId );
        return t;
    }
    
    public static EmailMessage createEmailOnCase(String caseid, String fromAdd, String toAdd, Boolean incoming)
    {
        EmailMessage em = new EmailMessage(parentId = caseid,
                                            relatedToId = caseid,
                                            Subject = 'This is an email',
                                            TextBody = 'This the email body',
                                            HTMLBody = '<HTML><p> This is the HTML body </p></HTML>',
                                            FromAddress = fromAdd,
                                            ToAddress = toAdd,
                                            Incoming = incoming);
        return em;
    }

    public static CareService__c createCareService(Id accountId) {
        CareService__c care = new CareService__c();
        care.Client__c = (String.isNotBlank(accountId) ? accountId : null);
        care.StoreRetailCode__c = 'A06';
        return care;
    }

    public static ProductCatalogue__c createProductCatalogue(String name, String sku) {
        ProductCatalogue__c prod = new ProductCatalogue__c();
        prod.Name = name;
        prod.SKU__c = sku;
        return prod;
    }

    public static ICX_ProductEnquired__c createProductEnquired(Id productCatalogueId, Id recordId) {
        ICX_ProductEnquired__c prod = new ICX_ProductEnquired__c();
        prod.Product__c = productCatalogueId;
        prod.RelatedTo__c = recordId;
        return prod;
    }

    public static ICX_ProductEnquired__c createUnknownProductEnquired(Id recordId, String comment, String productGender, String productCategory, String productCollection) {
        ICX_ProductEnquired__c prod = new ICX_ProductEnquired__c();
        prod.Product_Unknown__c = comment;
        prod.ProductGender__c = productGender;
        prod.ProductCategory__c = productCategory;
        prod.ProductCollection__c = productCollection;
        prod.RelatedTo__c = recordId;
        return prod;
    }

    public static LiveChatTranscript createLiveChatTranscript() {
        LiveChatVisitor lcv = new LiveChatVisitor();
        insert lcv;

        LiveChatTranscript lct = new LiveChatTranscript();
        lct.LiveChatVisitorid = lcv.id;
        return lct;
    }

    public static Country__c createCountry(String iso2, String iso3, String name) {
        Country__c country = new Country__c();
        country.Name = name;
        country.CannotEditClient__c = true;
        country.HasOtherValue__c = false;
        country.Iso2Code__c = iso2;
        country.Iso3Code__c = iso3;
        country.Law_settings__c = false;
        country.Line__c = false;
        country.SecondName__c = false;
        country.tech_duplicate__c = name;
        country.Wechat__c = false;
        country.WhatsApp__c = false;

        return country;
    }

    public static Region__c createRegion(String internationalCode, String localCode, String name, Id countryId) {
        Region__c region = new Region__c();
        region.International_code__c = internationalCode;
        region.Label__c = name;
        region.regional_code__c = localCode;
        region.Country__c = countryId;

    	return region;
    }

    public static Calling_Campaign__c createCallingCampaign(String clientID, String Status) {
        Calling_Campaign__c callingCampaign = new Calling_Campaign__c(Client__c = clientID,
        Status__c = Status
        );
        return callingCampaign;

    }

     /*private static MessagingEndUser createMessagingEndUser(Id messagingChannelId, Id accountId) {
        MessagingEndUser enduser = new MessagingEndUser();
        endUser.Name = '+33699999999';
        endUser.messagingChannelId = messagingChannelId;
        endUser.MessageType = 'Text';
        endUser.MessagingPlatformKey = '+33699999999';
        endUser.AccountId = accountId;

        return endUser;
    }

    public static MessagingSession createMessagingSession(Id accountId, Id channelId) {
        //MessagingChannel chan = createMessagingChannelText();//[SELECT Id FROM MessagingChannel WHERE MessageType='Text' LIMIT 1];
        //insert chan;

        MessagingSession mess = new MessagingSession();
        mess.Status = 'New';
        mess.MessagingChannelId = channelId;
        
        MessagingEndUser enduser =  createMessagingEndUser(channelId, accountId);
        insert enduser;
        mess.MessagingEndUserId = endUser.Id; 
        
        //QueueSobject queue =  [select Id, QueueId ,SobjectType from QueueSobject where SobjectType = 'MessagingSession' limit 1];
        //mess.OwnerId = queue.QueueId;
        
        return mess;
    }

    // Need access to avoid System.DmlException: Insert failed. First exception on row 0; 
    // first error: MIXED_DML_OPERATION, DML operation on setup object is not permitted after you have updated a non-setup object (or vice versa): MessagingChannel, original object: Account: []
    public static MessagingChannel createMessagingChannelText() {
        MessagingChannel channel = new MessagingChannel();
        channel.MessageType='Text';
        channel.DeveloperName = 'ICXTestFactoryCreateMessagingChannel';
        channel.MasterLabel = 'ICXTestFactoryCreateMessagingChannel';
        channel.MessagingPlatformKey = '+3933999999';
        return channel;
    }*/
    public static ProductReferential__c createProductReferential(String sku) {
        ProductReferential__c prod = new ProductReferential__c();
        prod.SKUCode__c = sku;
        prod.Name = 'DEMO PRODUCT';
        return prod;
    }
    
    
      public static Order__c createOrder(Account acc) {
        Order__c orderRecord = new Order__c();
        orderRecord.OrderNumber__c = EXISTING_ORDER_NUMBER;
        orderRecord.Account__c = acc.id;
        return orderRecord;
    }
    public static OrderShipping__c createOrderShipping(Order__c orderId) {
        OrderShipping__c orderShippingRecord = new OrderShipping__c();
        orderShippingRecord.Name ='test';
        orderShippingRecord.ShippingNumber__c = EXISTING_SHIPPING_NUMBER;
        orderShippingRecord.Order__c = orderId.id;
        orderShippingRecord.DeliveryType__c ='express';
        orderShippingRecord.Status__c='New';
        orderShippingRecord.StatusDate__c=System.now();
        orderShippingRecord.Pickup_Location__c='A08';
        
        return orderShippingRecord;
      
    }
    public static OrderLine__c createOrderLine(Order__c orderId) {
        OrderLine__c orderLineRecord = new OrderLine__c();
        orderLineRecord.Name = EXISTING_ORDER_NUMBER+'-1';
        orderLineRecord.Order__c = orderId.id;
        return orderLineRecord;
    }
    
        public static Order_Note__c creatOrderNotePriceAdjusment() {
        Order_Note__c orderNoteNew = new Order_Note__c();
        // PRICE ADJUSTMENT
        orderNoteNew.Type__c = 'PRICE_ADJUSTMENT';
        orderNoteNew.Description__c = 'This is the price adjustment';
        orderNoteNew.Reason__c = 'None of above';
        orderNoteNew.Tech_OrderNumber__c = EXISTING_ORDER_NUMBER;
        orderNoteNew.Tech_ShippingNumber__c = EXISTING_SHIPPING_NUMBER;

        return orderNoteNew;
        }
    
    public static Order_Note__c creatOrderNoteBankTransfert() {
        Order_Note__c orderNoteNew = new Order_Note__c();
        // BANK TRANSFER
        orderNoteNew.Type__c = 'BANK_TRANSFER';
        orderNoteNew.Description__c = 'This is bank transfert';
        orderNoteNew.Reason__c = 'None of above';
        orderNoteNew.Tech_OrderNumber__c = EXISTING_ORDER_NUMBER;

        return orderNoteNew;
        }


    public static CountryLanguage__c createCountryLanguage(Id countryId, Id languageId) {
        CountryLanguage__c countryLanguageRecord = new CountryLanguage__c(
            Country__c = countryId,
            Language__c = languageId,
            Salesforce_Language__c = 'en_us',
            VoiceAPILanguages__c = 'it',
            Default__c = true
        );
        return countryLanguageRecord;
    }


    public static Language2__c createLanguage(String Iso2Code, String Iso3Code) {
        Language2__c languageRecord = new Language2__c(
            Iso2Code__c = Iso2Code,
            Iso3Code__c = Iso3Code
        );
        return languageRecord;
    }

    public static Campaign__c createCampaign(){
        Campaign__c camRecord = new Campaign__c(
            Name = 'Test Campaign',
            Country__c = 'FRA',
            Description__c = 'test test',
            StartDate__c = 	Date.today(),
            EndDate__c = Date.today().addDays(30),
            Priority__c = '8',
            Status__c = 'New'
        );
        
        return camRecord;
    }
    
    public static CampaignMember__c createCampaignMember(Id CampaignId, Id CAId, Id ClientId){
        CampaignMember__c camMember= new CampaignMember__c(
            Name = 'Test Member',
            Status__c = 'New',
            Member__c = ClientId,
            Interested__c = 'No',
            Contacted__c = 'No',
            AssignedCA__c = CAId,
            Campaign__c = CampaignId); 
            return camMember;
        }

    public static ContentVersion createSingleContentVersion(){
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true,
            origin = 'H'
        );
        return contentVersion;
    }

}