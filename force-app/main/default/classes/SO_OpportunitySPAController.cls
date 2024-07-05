global with sharing class SO_OpportunitySPAController {

    @AuraEnabled
    public static User getUser() {
        return SO_UserServiceController.getUser();
    }

    @AuraEnabled
    public static String getStoreJson() {
        List<PicklistEntry> values = User.DefaultStore__c.getDescribe().getPicklistValues();

        return JSON.serialize(values);
    }

    @AuraEnabled
    public static Map<String, String> getSPAPersonalizationJson() {
        Map<String, String> picklistMap = new Map<String, String>();
        picklistMap.put('CREATIONTYPE', getCreationTypeJson());
        picklistMap.put('ISEXO', getIsExoJson());
        picklistMap.put('UNIT', getUnitJson());
        picklistMap.put('COLORMETALIC', getColorMetalicJson());
        //picklistMap.put('PAINTING', getPaintingJson());
        picklistMap.put('PAINTINGSTYLE', getPaintingStyleJson());
        picklistMap.put('PRODUCTCATEGORY', getProductCategoryJson());
        picklistMap.put('SPECIALEVENT', getSpecialEventJson());
        return picklistMap;
    }

    @AuraEnabled
    public static String getCreationTypeJson() {
        List<PicklistEntry> values = Opportunity.SPO_CreationType__c.getDescribe().getPicklistValues();
        return JSON.serialize(values);
    }

     @AuraEnabled
    public static String getIsExoJson() {
        List<PicklistEntry> values = Opportunity.SPO_Exo__c.getDescribe().getPicklistValues();
        return JSON.serialize(values);
    }

    
    @AuraEnabled
    public static String getUnitJson() {
        List<PicklistEntry> v = Opportunity.SPO_SizeUnit__c.getDescribe().getPicklistValues();
        List<PicklistEntry> values = new List<PicklistEntry> ();

        // Allowing only cm
        for (PicklistEntry pe : v){
            if (pe.getValue() == 'Cm'){
                values.add(pe);
            }
        }
        return JSON.serialize(values);        
    }

    @AuraEnabled
    public static String getColorMetalicJson() {
        List<PicklistEntry> values = Opportunity.SPO_ColorMetalicparts__c.getDescribe().getPicklistValues();
        return JSON.serialize(values);        
    }

    /*@AuraEnabled
    public static String getPaintingJson() {
        List<PicklistEntry> values = Opportunity.SPO_Painting__c.getDescribe().getPicklistValues();
        return JSON.serialize(values);        
    }*/

    @AuraEnabled
    public static String getPaintingStyleJson() {
        List<PicklistEntry> values = Opportunity.SPO_Patch__c.getDescribe().getPicklistValues();
        return JSON.serialize(values);        
    }

    @AuraEnabled
    public static String getProductCategoryJson() {
        List<PicklistEntry> values = Opportunity.SPO_ProductCategory__c.getDescribe().getPicklistValues();
        return JSON.serialize(values);        
    }
    
    @AuraEnabled
    public static String getSpecialEventJson() {
        List<PicklistEntry> values = Opportunity.SPO_SpecialEvents__c.getDescribe().getPicklistValues();
        return JSON.serialize(values);        
    }

    /*@AuraEnabled
    public static Opportunity saveOpp(Opportunity opp) {
        System.debug('opp=' + opp);
        insert opp;
        return opp;
    }

    @AuraEnabled
    public static Account saveAccount(Account acc) {
        System.debug('acc=' + acc);
        upsert acc;
        return acc;
    }*/

    // This method is used to with both buttons <Validate> and <Validate and Request for quotation> on Product Summary Component
    // The opportunity record is the same no matter which button is clicked, so no way to differentiate it when user click on the button
    // So we need to pass the button Id to know which button was clicked and create the opportunity.
    // If the button <Validate> is cliecked => Opp record type is <Special Order Brief> and Status <Brief in progress>
    // If the button <alidate and Request for quotation> is cliecked => Opp record type is <Special Order> and Status <Quotation in progress>
    @AuraEnabled 
    public static Opportunity saveOppWithFiles(Opportunity opp, Account acc, String listFilesJSON, String buttonName){
        Opportunity o;

        try {
            ID owner = opp.ownerID; // to avoid opportunity visibility error
            opp.ownerId = UserInfo.getUserId();
            o = saveOpp(opp, acc, buttonName);
            
            FileContent[] listfiles = (FileContent[])System.JSON.deserialize(listFilesJSON, FileContent[].class);
            
            System.debug('files : ' + listFiles.size());
            //List<ContentVersion> cvs = new List<ContentVersion>();
            List<Id> attachmentIds = new List<Id>();
            for (Integer i=0; i<listFiles.size(); i++){
                FileContent file = listFiles[i];
                System.debug('start attaching -> ' + file.fileName);

                attachmentIds.add(file.fileId);
                
                //ContentVersion cv = new ContentVersion ();
                //cv.title = file.fileName;
                //cv.versionData = EncodingUtil.base64Decode(EncodingUtil.urlDecode(file.base64Data, 'UTF-8'));
                //cv.pathOnClient = '/' + file.fileName;
                
                //cvs.add(cv);
            }
            
            List<Attachment> newAttachments = new List<Attachment>();
            List<Attachment> deleteAttachments = new List<Attachment>();
            List<ContentVersion> cvs = new List<ContentVersion>();
            List<Attachment> oldAttachments = [SELECT id, parentId, Description, Body, Name FROM Attachment WHERE id IN :attachmentIds];
            for (Attachment a : oldAttachments){

//                if (a.ParentId != o.id) {
//                    Attachment newAttachment = new Attachment (Name=a.Name, Description = a.Description, Body = a.Body);
//                    newAttachment.parentId = o.id;
//                    newAttachments.add(newAttachment);
//                    deleteAttachments.add(a);
//                }

                ContentVersion cv = new ContentVersion ();
                cv.title = a.Name;
                cv.versionData = a.Body;
                cv.pathOnClient = '/' + a.Name;
                
                cvs.add(cv);
            }

//            insert newAttachments;
//            delete deleteAttachments;

            insert cvs;
            Set<Id> cvsIds = new Set<Id>();
            for (ContentVersion cv : cvs){
                cvsIds.add(cv.id);
            }
            
            System.debug(cvsIds);
            
            cvs = [SELECT id, ContentDocumentId FROM ContentVersion WHERE Id IN :cvsIds];
            
            System.debug(cvs);
            System.debug('$$$$$ oId '+ o.id);
            List<ContentDocumentLink> cdls = new List<ContentDocumentLink>();
            for (ContentVersion cv : cvs){
                System.debug('$$$$ I am for loop line 156');
                ContentDocumentLink cdl = new ContentDocumentLink();
                System.debug('$$$$$ contentDocumentId' + cv.ContentDocumentId);
                System.debug('$$$$$ oId '+ o.id);
                cdl.ContentDocumentId = cv.ContentDocumentId;
                cdl.LinkedEntityId = o.id;
                cdl.ShareType='V';
                cdl.Visibility='AllUsers';
                
                cdls.add (cdl);
            }
            
            insert cdls;
            o.OwnerId = owner;
            update o;
        } catch(Exception exp) {
            AuraHandledException e = new AuraHandledException(exp.getMessage());
            e.initCause(exp);
            throw e;
        }

        return o;
    }

    @AuraEnabled
    public static void updateOpp (Opportunity opp){
        System.debug('Updating opp');
        update opp;
    }

    @AuraEnabled
    public static User getUserProfile() {
        return [SELECT Name, Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
    }

    @AuraEnabled
    public static Opportunity saveOpp(Opportunity opp, Account acc, String btn) {
        System.debug('saveOpp > opp=' + opp);
        System.debug('buttonName > Button=' + btn);
        if (!opp.SPO_DisplayOrder__c) {
            // upsert account - account can be created in duplicate but prospect fields are used to deduplicate by a tool with RMS
            acc.IsProspect__pc = true;
            acc.ProspectForDream__c = true;
            upsert acc;

            opp.AccountId = acc.Id;
            opp.SPO_RMSClientId__c = acc.RMSId__pc;
            opp.SPO_wwRMSClientId__c = acc.WW_RMSId__c; //MIY-1743
        }

        //opp.StageName = SO_Settings__c.getValues(SO_UTIL.NEW_OPPORTUNITY_STAGENAME_SETTINGS_NAME).Value__c;//SO_OrderPageSwitch.CREATION_IN_PROGRESS;
        // close date is Order date now (SO_Settings__c.NewOpportunityCloseDate) should be 0 day
        opp.CloseDate = Date.today().addDays(Integer.valueOf(SO_Settings__c.getValues(SO_UTIL.NEW_OPPORTUNITY_CLODEDATE_SETTINGS_NAME).Value__c));
        //    opp.StageName = 'Brief in progress';
        //opp.CloseDate = System.today();
        opp.ApplicationSource__c = 'SPO';
        // only Creation (and not possible to use MTO - Make to order anymore)

        //String rtNameForQuery = 'Special Order Brief';
        //RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType='Opportunity' AND Name LIKE :rtNameForQuery LIMIT 1];
        //System.debug (rt);

        //Id oppRecordTypeId = rt.id;

        /*if ('Watches'.equalsIgnoreCase(opp.SPO_ProductCategory__c)) {
            oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Special Order').getRecordTypeId();        
        } else if ('Accessories'.equalsIgnoreCase(opp.SPO_ProductCategory__c)) {
            oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Special Order').getRecordTypeId();
        } else {
            //oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Special Order').getRecordTypeId();
            oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('SPO Brief LG').getRecordTypeId();
        }*/

        //opp.SPO_OrderType__c = 'Creation (Hardsided & Soft)'; // Already initialized in JS

        if (opp.SPO_OrderType__c == 'Creation (Hardsided & Soft)'){
            if(btn == 'validate'){
                Id oppRecordTypeIdSPB = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Special Order Brief').getRecordTypeId();
                opp.recordTypeId = oppRecordTypeIdSPB;
                opp.stageName = 'Brief in progress';
            } else {
                Id oppRecordTypeIdSP = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Special Order').getRecordTypeId();
                opp.recordTypeId = oppRecordTypeIdSP;
                opp.stageName = 'Quotation in progress';
                opp.SPO_Date_Quotation_in_progress__c = Date.today();
            }
        } else { // MTO

            Id oppRecordTypeIdSPMTO = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Special Order').getRecordTypeId();
            opp.recordTypeId = oppRecordTypeIdSPMTO;

            if (opp.SPO_DisplayOrder__c){
                opp.stageName = 'Creation in progress';
                //opp.Send_to_ERP__c = true; // Deactivated for MTO
            } else {
                opp.stageName = 'Quotation Accepted';
            }
        }
        

        updateExo (opp);

        insert opp;

        if (opp.SPO_OrderType__c == 'MTO on Catalog (Hardsided)'){ // Adding order autonumber to name for MTO
            if (opp.stageName == 'Creation in progress'){               

                // Creating Firm Orders
                List<SPO_FirmOrder__c> foList = SPO_OpportunityActionButtonController.createFirmOrders(opp);
                insert foList;
            }

            Opportunity o = [SELECT id, Name, OrderNumber__c FROM Opportunity WHERE id = :opp.id LIMIT 1];
            
            System.debug('**** => ' + o.OrderNumber__c + ' - ' + o.Name);
            String newName = o.OrderNumber__c + ' - ' + o.Name;

            opp.Name = newName;
            update opp;
        }

        return opp;
    }

    @AuraEnabled
    global static String getSessionId() {
        System.debug('returning sessionID ' + UserInfo.getSessionId());
        return UserInfo.getSessionId();
    }

    private static void updateExo (Opportunity opp){
        opp.SPO_Exo__c = 'No';
        List < MIY_LeadTime__c > miyLTCollection = [SELECT Id, Name, Country__c, Product_Group__c, Exotic_Distribution_Lead_Time_in_days__c, Non_Exotic_Distribution_LT_in_days__c FROM MIY_LeadTime__c];//MIY-1757
        Store__c oppStore = [SELECT Id, Name, StoreCountry__c FROM Store__c WHERE id =: opp.SPO_Store__c LIMIT 1];//MIY-1757

        if (String.isNotBlank(opp.SPO_ExteriorMaterial1__c) && opp.SPO_ExteriorMaterial1__c.toUpperCase().contains('EXO') ||
            String.isNotBlank(opp.SPO_ExteriorMaterial2__c) && opp.SPO_ExteriorMaterial2__c.toUpperCase().contains('EXO') ||
            String.isNotBlank(opp.SPO_ExteriorMaterial3__c) && opp.SPO_ExteriorMaterial3__c.toUpperCase().contains('EXO') ||
            String.isNotBlank(opp.SPO_LiningInteriorMaterial1__c) && opp.SPO_LiningInteriorMaterial1__c.toUpperCase().contains('EXO') ||
            String.isNotBlank(opp.SPO_LiningInteriorMaterial2__c) && opp.SPO_LiningInteriorMaterial2__c.toUpperCase().contains('EXO')){
            opp.SPO_Exo__c = 'Yes';
        }

        //MIY-1757
        for (MIY_LeadTime__c m: miyLTCollection) {
            if(m.Country__c == oppStore.StoreCountry__c && m.Product_Group__c == opp.SPO_ProductCategory__c) {
                if(opp.SPO_Exo__c == 'Yes') {
                    opp.SPO_EstimatedLeadTimeTable__c = m.Exotic_Distribution_Lead_Time_in_days__c;
                } else {
                    opp.SPO_EstimatedLeadTimeTable__c = m.Non_Exotic_Distribution_LT_in_days__c;
                }
            }
        }
    }

    @AuraEnabled
    public static Store__c getStore(String storeCode) {
        System.debug('storeCode=' + storeCode);
        Store__c result;
        if (String.isNotBlank(storeCode)) {
            List<Store__c> storeList = [SELECT Id, Name, RetailStoreId__c, StoreCountry__c FROM Store__c WHERE RetailStoreId__c = :storeCode];
            if (!storeList.isEmpty()) {
                result = storeList[0];
            }
        }
        return result;
    }

    @AuraEnabled
    public static FileContent[] getFiles (Opportunity opp){
        Map<Id, ContentDocumentLink> cdl = new Map<Id, ContentDocumentLink> ([SELECT id FROM ContentDocumentLink WHERE LinkedEntityId =:opp.id]);
        List<ContentDocument> listFiles = [SELECT Id, title, createdDate, fileType FROM ContentDocument WHERE Id IN :cdl.keySet() ORDER BY LastModifiedDate DESC];

        FileContent[] listFileContents = new List<FileContent>();
        for (ContentDocument cd : listFiles){
            FileContent fc = new FileContent();
            fc.fileName = cd.title;
            fc.contentType = cd.fileType;
            fc.createdDate = cd.createdDate;
            fc.contentDocumentId = cd.id;

            listFileContents.add(fc);
        }

        return listFileContents;
    }

    @AuraEnabled
    public static Id saveTheFile (Id oppId, String fileName, String base64Data, String contentType){
        System.debug('saving : ' + fileName);
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        
        Attachment a = new Attachment();
        a.parentId = oppId;
 
        a.Body = EncodingUtil.base64Decode(base64Data);
        a.Name = fileName;
        a.ContentType = contentType;
        
        insert a;
        
        return a.Id;
    }

    @AuraEnabled
    public static Id saveTheChunk(Id parentId, String fileName, String base64Data, String contentType, String fileId) { 
        System.debug('Parent Id from Aura chunk' + parentId);
        if (fileId == '') {
            fileId = saveTheFile(parentId, fileName, base64Data, contentType);
        } else {
            appendToFile(fileId, base64Data);
        }
        
        return Id.valueOf(fileId);
    }
    
    private static void appendToFile(Id fileId, String base64Data) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        
        Attachment a = [
            SELECT Id, Body
            FROM Attachment
            WHERE Id = :fileId
        ];
        
        String existingBody = EncodingUtil.base64Encode(a.Body);
        a.Body = EncodingUtil.base64Decode(existingBody + base64Data); 
        
        update a;
    }



    @AuraEnabled
    public static FileContent getNewFile (){
        return new FileContent();
    }

    public class FileContent {
        @AuraEnabled
        public String fileName {get; set;}
        @AuraEnabled
        public Id fileId {get; set;}
        @AuraEnabled
        public String base64Data {get; set;}
        @AuraEnabled
        public String contentType {get; set;}
        @AuraEnabled
        public DateTime createdDate {get; set;}
        @AuraEnabled
        public Id contentDocumentId {get; set;}
    }

    @AuraEnabled
    public static ProductReferential__c getProductNotFound() {
        return SO_ProductController.getProductNotFound();
    }

    @AuraEnabled
    public static ProductReferential__c getProductBySku(String sku) {
        return SO_ProductController.findBySku(sku);
    }

    @AuraEnabled
    public static Account getAccountFromRMS(String storeCode, String rmsId, String wwRmsClientCode) {//, Account sfdcClient) {
        //Account acc = SO_CreateUpdateRMSCLient_Utils.syncClient(storeCode, rmsId, sfdcClient);
        return SO_WS_POSFacade.clientSearch(storeCode, rmsId, wwRmsClientCode);
    }

    @AuraEnabled
    public static Boolean validateCACodeInRMS (String storeCode, String caCode){
        return SO_WS_POSFacade.verifyCaCodeWS (storeCode, caCode);
//        return verifyCaCodeWS (storeCode, caCode);
    }

    /*public static Boolean verifyCaCodeWS(String storeCode, String caCode)
    {
        System.debug('SFDC verifyCaCodeWS');
        Boolean wsResult = false;

        System.debug('SFDC SPO_CACode__c: ' + caCode + ' newUser.DefaultStore__c: ' + storeCode);
        if(caCode != Null && storeCode != Null){
            SO_ClientAdvisorEnquiryRMS_Utils.SO_ClientAdvisorEnquiryResults calloutResult = SO_ClientAdvisorEnquiryRMS_Utils.VerifyClientAdvisorEnquiryRMS(caCode, storeCode);
            wsResult = calloutResult.calloutSuccessResult;
        }

        return wsResult;
    }*/
    
    @AuraEnabled
    public static Boolean saveAccountInRMS(Account sfdcClient, String storeCode) {
        
        // SPO doen't create or update in RMS (the user must go in MyCC app)
        /*sfdcClient.RecordTypeId = SO_UTIL.retRecordTypeIdByName('Account', SO_Settings__c.getValues(SO_UTIL.PERSON_ACCOUNT_RECORD_TYPE_SETTINGS_NAME).Value__c);
        //try {
        SO_CreateUpdateRMSCLient_Utils.SO_CreateUpdateRmsClientResult calloutResult = 
            SO_CreateUpdateRMSCLient_Utils.createUpdateSFDCAccountIntoRMS(sfdcClient, sfdcClient.RMSId__pc, storeCode);

        System.debug('calloutResult=' + calloutResult);
        if (calloutResult != NULL 
            && calloutResult.calloutSuccessResult == true 
            && calloutResult.calloutClientRmsId != NULL) {
                //upsert this.client;
                //this.opp.AccountId = this.client.Id;
                //this.opp.SPO_RMSClientId__c = calloutResult.calloutClientRmsId;
                //upsert this.opp;
                // TODO in creation, get Client RMS Id
                System.debug('sfdcClient' + sfdcClient);
                return true;
        }*/
        /*} catch (Exception ex) {
            SO_UTIL.addErrorMessage(ex);
        }*/

        return false;
    }

    /*private static Boolean isAddressValid(Account client) {
        Boolean addressValid = false;

        // If Brazil - check address format
        if ('BRA'.equalsIgnoreCase(client.SPO_Country_code__pc)) {
            // check address Format
            String address = client.PrimaryAddressLine1__pc;
            if (address!= null){
                String[] addressSplited = address.split(',');
                if (addressSplited.size() == 2){
                    try {
                        Integer addressNumber = Integer.valueOf( addressSplited[1].trim());
                        if (addressNumber > 0) {
                            addressValid= true;
                            client.PrimaryAddressLine1__pc = addressSplited[0].trim() + ', ' + addressSplited[1].trim();
                        }
                    }
                    catch(TypeException te)
                    {
                        //do nothing as this addressNumber remain false.
                    }
                }
            }
            if (!addressValid){
                System.debug('Client Save - addressValid: ' + addressValid);
                //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,Label.LV_SO_client_error_message));
                //this.showMessageOnTop = true;
                //return pageRef;
            }
        } 
        return addressValid;
    }*/
    
    /**
     * for Detail Page
     **/
    @AuraEnabled
    public static Opportunity findOppById(Id oppId) {
        Opportunity opp;

        List<Opportunity> oppList = [SELECT Name, StageName, isClosed, SPO_BaseSKURefmodelSKU__c, SPO_CACode__c, SPO_OrderType__c,
                                     SPO_ProductCategory__c, SPO_Store__c, ApplicationSource__c,
                                     SPO_ClientAccessoriesRequested__c, SPO_ColorMetalicPartsLocalComment__c,
                                     SPO_ColorMetalicparts__c, SPO_CommentClientAccessories__c,
                                     SPO_CreationType__c, SPO_DisplayOrder__c,
                                     SPO_LockNumber__c, SPO_Lock__c,
                                     SPO_PaintingYN__c, SPO_PatchFreeText__c, SPO_Patch__c,
                                     SPO_Sizewidth__c, SPO_SizeHeight__c, SPO_SizeLenght__c, SPO_SizeUnit__c, SPO_Dimension_comment__c, SPO_BeltSize__c
                                     FROM Opportunity WHERE Id = :oppId];
        if (!oppList.isEmpty()) {
            opp = oppList.get(0);
        }
        return opp;
    }

    @AuraEnabled
    public static List<User> getAllUsersDB(){
        return [Select Id, Email, Name From User];
    }
    
    // get Custom Settings OrderSettings__c record to set the absolute path pictures
    @AuraEnabled
    public static OrderSettings__c getOrderSettings() {
        return OrderSettings__c.getInstance();
    }

    @AuraEnabled
    public static String getDummyProductDB() {

        String dummyProductId;
        List<SO_Settings__c> dummyProduct=  [   Select Name,Value__c From SO_Settings__c 
                                                WHERE Name ='DummyProduct' Limit 1];

        for(Integer i = 0; i < dummyProduct.size(); i++){
            dummyProductId = dummyProduct[i].Value__c;
        }                                        
        System.debug('$$ Dummy Product Id :' + dummyProductId);
        return dummyProductId;
    }

    public class PriceResult {
        @AuraEnabled
        public Decimal articlePrice;
        @AuraEnabled
        public String storeCurrency;
        @AuraEnabled
        public Boolean calloutSuccessResult;
    }

    public static String getStoreCurrency (String storeCode){
        Store__c store = [SELECT id, currency__c FROM Store__c WHERE RetailStoreId__c = :storeCode LIMIT 1];

        String storeCurrency = '';
        if (store != null){
            storeCurrency = store.currency__c;
        }

        return storeCurrency;
    }

    @AuraEnabled
    public static PriceResult retrievePricesFromRMS (String storeCode, String baseSKU){
        
        SO_RetreiveArticlesPriceRMS_Utils.SO_ArticlePriceResults articlePriceResult = SO_RetreiveArticlesPriceRMS_Utils.RetrieveArticlePriceFromRMS(storeCode, baseSKU);

        PriceResult result = new PriceResult();
        result.articlePrice = Decimal.valueOf(articlePriceResult.calloutFinalArticlePrice);
        result.calloutSuccessResult = articlePriceResult.calloutSuccessResult;
        result.storeCurrency = getStoreCurrency(storeCode);

        return result;
    }

    @AuraEnabled
    public static Boolean getIsMTOEnabled (){
        SO_Settings__c s = SO_Settings__c.getInstance('isMTOEnabled');

        return s == null ? true : s.Value__c == 'true';
    }
    @AuraEnabled
    public static Id createAttachment(Id parentId,String fileName,String base64Data, String contentType){
          base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        
        Attachment a = new Attachment();
        a.parentId = parentId;

        a.Body = EncodingUtil.base64Decode(base64Data);
        a.Name = fileName;
        a.ContentType = contentType;
        
        insert a;
        
        return a.Id;
    }
}