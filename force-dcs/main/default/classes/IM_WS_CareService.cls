/*
CreatedDate: May 2018
Company: Balink
Author: Jeremy Martiano
Description:care Salesforce Object
*/

@RestResource(urlMapping='/CareService/*')
global without sharing class IM_WS_CareService {

    global static List<IconSetting__mdt> iconSettings = [Select Text__c, Boolean__c
            FROM IconSetting__mdt 
            WHERE QualifiedApiName ='Pilot_Store_Codes' AND Text__c != '' AND Text__c != null];

    global static CareService__c getCareService(String externalId){
        List<CareService__c> careServicesItems = [Select Id,Client__c From
        CareService__c
        Where ExternalId__c =: externalId];

        if(careServicesItems.size() > 0){
            return careServicesItems[0];
        }
        return null;
    } 

      
    /*=================================================================================================================*/
    //HTTP Request POST called From MyRepair

    @HttpPost
    global static void post() {
        RestRequest req = RestContext.request;
        String service = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
       
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type','application/json');
        res.statusCode = 200;
        string response;

        Map<String,Object> body = new Map<String,Object>();
        if (req.requestBody != null) {
            body = (Map<String,Object>)JSON.deserializeUntyped(req.requestBody.toString());
        }

        try{
            if(service == '' || service == 'CareService'){
                response = JSON.serialize(upsertCareService(body));
            }
            res.responseBody = Blob.valueOf(response);
            //UtilsLogs.addLog('ICON','IM_WS_CareService', JSON.serialize(body), JSON.serialize(req), response, '');
            new Logs.DEBUG('IM_WS_CareService','API',response);
        }
        catch(Exception ex){
            system.debug(ex.getMessage() + '\n\n' + ex.getLineNumber());
            ResponseHandler errorObject = new  ResponseHandler(null,null,null);
            if(ex.getTypeName() == 'DmlException' ){
                errorObject = new ResponseHandler(ex.getDmlType(0), ex.getMessage() + ' ' + ex.getLineNumber(), ex.getDmlFieldNames(0));
            } else {
                errorObject = new ResponseHandler(null, ex.getMessage() + ' ' + ex.getLineNumber(), null);
            }
            
            res.responseBody = Blob.valueOf(JSON.serialize(errorObject));
            res.statusCode = 400;

            //UtilsLogs.addLog('ICON', 'IM_WS_CareService', JSON.serialize(body), JSON.serialize(req),'', JSON.serialize(errorObject));
            new Logs.ERROR('IM_WS_CareService','API',ex);
        }
    }
    
    /*=================================================================================================================*/
    //HTTP Request GET called From MyRepair  - getting all Care Services for a user
    @HttpGet
    global static void get() {
        RestRequest req = RestContext.request;
        String service = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
        
        String userId = req.params.get('userId');
        String lvStatus = (req.params.get('statusFilter')!='')? req.params.get('statusFilter') :null;
            
        if(req.params.get('statusFilter')==null){
            lvStatus = '2';
        }
        
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type','application/json');
        res.statusCode = 200;
        
        string response;
        try{
            if(service == '' || service == 'CareService'){
                CareService__c[] careServicesList = getCareServices(userId, (lvStatus!= null && lvStatus.isNumeric())?Integer.valueOf(lvStatus):null);//if it's a number it will send, if not: null
                
                Map<string,object> responseData = new Map<string, object>();
                responseData.put('totalSize', (careServicesList!=null)?careServicesList.size():0);
                responseData.put('records', careServicesList);
                response = JSON.serialize(responseData);
            }
            res.responseBody = Blob.valueOf(response);
            new Logs.DEBUG('IM_WS_CareService','API',response);
        }
        catch(Exception ex){
            system.debug(ex.getMessage() + '\n\n' + ex.getLineNumber());
            ResponseHandler errorObject = new  ResponseHandler(null,null,null);
            errorObject = new ResponseHandler(null, ex.getMessage() + ' ' + ex.getLineNumber(), null);
            res.responseBody = Blob.valueOf(JSON.serialize(errorObject));
            res.statusCode = 400;
            new Logs.ERROR('IM_WS_CareService','API',ex);
        }
}

/*=================================================================================================================*/
    //Function to get care services:
    global static List<CareService__c> getCareServices(String userId, Integer statusFilterParam){
        CareService__c[] careServices;
        
         String query = 'Select Id, MYLV_Care_Status__c, TransactionId__c, MyRepair_CreatedDate__c, Product_Name__c, '+
         ' SKU__c,Delivery_Date__c, Updated_Delivery_Date__c, TotalAmount__c, CurrencyCode__c, TotalAmount_Updated__c,' +
         ' Product_Family__c, Is_Not_Repaired__c, Last_MyRepair_Status_Changed_Date__c, Type_of_Repair__c, Store__c, '+
         ' Store__r.Name, Store__r.StoreCountry__c,Store__r.Store_CountryCode__c, Is_Generic_SKU__c, Delivery_Store_Retail_Code__c, Delivery_Address__c  '+
         ' From CareService__c Where Client__c =:accountId AND MyRepairStatus__c != \'cancelled\'';
         
         String statusFilterToQueryAddition = '';
       
        switch on statusFilterParam {
            when 0 {
                statusFilterToQueryAddition = ' AND MYLV_Care_Status__c != \'History\' ';
            } 
            when 1 {
                statusFilterToQueryAddition = ' AND MYLV_Care_Status__c = \'History\' ';
            }
                
        }
        
       if(userId != '' && userId !=null && (statusFilterParam == 0 || statusFilterParam == 1 ||  statusFilterParam == 2)){
            User[] userObjList = [SELECT Id, AccountId from User WHERE Id =:userId];
            if(userObjList.size()>0){
                    String accountId = userObjList[0].AccountId;
                    if(accountId != null && accountId != '') {
                        careServices = (statusFilterToQueryAddition!= null)? Database.query(query + statusFilterToQueryAddition + ' ORDER BY MyRepair_CreatedDate__c DESC'):
                         Database.query(query + + ' ORDER BY MyRepair_CreatedDate__c DESC');
                    }
            }
        }
        for(CareService__c care : careServices){
            if( String.isNotEmpty(care.MYLV_Care_Status__c) ){
                care.MYLV_Care_Status__c = care.MYLV_Care_Status__c.toLowerCase();
            }
        }
        return careServices;
    } 
    
           
 /*=================================================================================================================*/
    //Main function to upsert Repair to CareService

    global static Object upsertCareService(Map<String,Object> bodyMap){

        Map<String,Object> clientMap = (Map<String,Object>)bodyMap.remove('Client');
        List<Object> instructionsListMap = (List<Object>)bodyMap.remove('Instructions');
        
        CareService__c newCS = (CareService__c) createObject(bodyMap, 'CareService__c', new CareService__c());
        system.debug(newCS.ExternalId__c);
        CareService__c existingCareService = getCareService(newCS.ExternalId__c);

        if(existingCareService == null  || existingCareService.Client__c == null){
            Account client = getClient(clientMap);

            newCS.Client__c = client != null ? client.Id :  null;
        }
        

        //match Store and CA if available

         if (newCS.StoreRetailCode__c != null){
            newCS.Store__r = new Store__c(RetailStoreId__c = newCS.StoreRetailCode__c);

            //Match CA relative to RMS ID AND STORE CODE
            if (newCS.CA_Code__c != null || newCS.WWEmployeeNumber__c != null){
                User ca = getCA(newCS.CA_Code__c, newCS.StoreRetailCode__c, newCS.WWEmployeeNumber__c);
                newCS.CA__c = ca != null ? ca.Id : null;
            } 
            else {
                newCS.CA__c = null;
            } 
        } 
        else {
            newCS.Store__c = null;
            newCS.CA__c = null;
        }

          

        if (newCS.SKU__c != null){
            List<ProductCatalogue__c> products = [ Select Id From ProductCatalogue__c Where SKU__c = :newCS.SKU__c];
            if(products.size() > 0){
                newCS.Product__r = new ProductCatalogue__c(SKU__c = newCS.SKU__c);
            }
            newCS.Is_Generic_SKU__c = isGenericSKU(newCS.SKU__c);
        } 
        else {
            newCS.Product__c = null;
        }  

        if ( newCS.Followup_Comments__c != null){            
            newCS.Followup_Comments__c = decode64(newCS.Followup_Comments__c);
            newCS.Followup_Comments__c = newCS.Followup_Comments__c.replace('}, {','\n\n');
            newCS.Followup_Comments__c = newCS.Followup_Comments__c.replace('" ,"', '\n');
            newCS.Followup_Comments__c = newCS.Followup_Comments__c.replace('" , "', '\n');
            newCS.Followup_Comments__c = newCS.Followup_Comments__c.replace('"', '');
            newCS.Followup_Comments__c = newCS.Followup_Comments__c.replace(']', '');
            newCS.Followup_Comments__c = newCS.Followup_Comments__c.replace('[', '');
            newCS.Followup_Comments__c = newCS.Followup_Comments__c.replace('}', '');
            newCS.Followup_Comments__c = newCS.Followup_Comments__c.replace('{', '');            
        }      
       
        if ( newCS.Client_Comments__c != null){
            newCS.Client_Comments__c = decode64(newCS.Client_Comments__c);
        } 
        if ( newCS.Repair_Center_Comments__c != null){
            newCS.Repair_Center_Comments__c = decode64(newCS.Repair_Center_Comments__c);
        } 
        if ( newCS.Store_Comment__c != null){
            newCS.Store_Comment__c = decode64(newCS.Store_Comment__c);
        }
        if ( newCS.Delivery_Address__c != null){
            newCS.Delivery_Address__c = decode64(newCS.Delivery_Address__c);
        }  

        if ( newCS.NS_Code__c != null){
            newCS.Is_Not_Repaired__c = isNotRepaired(newCS.NS_Code__c);
        }

        system.debug(newCS.ExternalId__c);
        Schema.SObjectField f = CareService__c.Fields.ExternalId__c;
        Database.UpsertResult upsertResult = Database.upsert(newCS, f, true);

        if(instructionsListMap != null &&  instructionsListMap.size() > 0 && newCS.Id != null)
            setInstructions(instructionsListMap, newCS.Id);

        return upsertResult;
    }

    /*=================================================================================================================*/
    //Create or Match Client using data sent in the body under key "Client"

    global static Account getClient(Map<String,Object> clientMap){
        if(clientMap != null){
            String email = (String)clientMap.get('PersonEmail');
            String phone = (String)clientMap.get('Phone');
            String firstName = (String)clientMap.get('FirstName');
            String lastName = (String)clientMap.get('LastName');
            String countryCode = (String)clientMap.get('NationalityCountryCode__pc');

            List<Account> accList = new List<Account>();


            if (!(String.isEmpty(email) && String.isEmpty(phone))){
                List<User> userIdentitys = database.query( 'Select AccountId From User Where Is_Identity_User__c = TRUE AND ('+ 
                (String.isEmpty(email)? '' : ' TECH_Email__c = : email '  )+  
                (String.isEmpty(email) || String.isEmpty(phone) ? '' : ' OR '  ) +
                (String.isEmpty(phone)? '' : ' TECH_MobilePhone__c = : phone '  )
                +' ) LIMIT 1');

                if ( userIdentitys.size() > 0) {
                    accList = [Select Id
                    From Account Where
                    Id = : userIdentitys[0].AccountId];
                } 
            } 
            if (accList.size() == 0){
                accList = [Select Id
                From Account Where
                PersonEmail=:email AND
                LastName=:lastName AND FirstName=:firstName AND PersonEmail != null AND PersonEmail != ''
                Order by LastTrans__pc desc];
            }
            if ( accList.size() > 0 ){
                return accList[0];
            }

            Account acc =  (Account) createObject(clientMap, 'Account', new Account());
            acc.IsProspect__pc = true;
            acc.ProspectForDream__c = true;
            acc.PrimaryCountry__pc = countryCode != null && countryCode != '' ? getCountry(countryCode) : null;
            acc.LocalHomePhone__pc = trimPhone(acc.LocalHomePhone__pc);
            acc.LocalMobilePhone__pc = trimPhone(acc.LocalMobilePhone__pc);
            acc.LocalWorkPhone__pc = trimPhone(acc.LocalWorkPhone__pc);
            if ( acc.PrimaryAddressLine1__pc != null){
                acc.PrimaryAddressLine1__pc = decode64(acc.PrimaryAddressLine1__pc);
            } 
            if ( acc.PrimaryAddressLine2__pc != null){
                acc.PrimaryAddressLine2__pc = decode64(acc.PrimaryAddressLine2__pc);
            } 
            if ( acc.PrimaryAddressLine3__pc != null){
                acc.PrimaryAddressLine3__pc = decode64(acc.PrimaryAddressLine3__pc);
            } 
            insert acc;
            system.debug(acc.FirstName);
            return acc;
        }
        

        return null;
    }

    /*=================================================================================================================*/
    //GET CA according to RMS ID AND STORE CODE received

    global static User getCA(String caCode, String storeCode, String WWCAcode){
        
        String storeName = '';
        List<Store__c> stores = [Select Id, Name From Store__c Where RetailStoreId__c = : storeCode];
        if(stores.size() > 0){
            storeName = '%'+stores[0].Name+'%';
        }
        String query = 'Select Id From User '+
        ' Where ' + (WWCAcode != null &&  WWCAcode != '' ? ' WWEmployeeNumber__c =:WWCAcode ': 
        ' RMS_ID__c = :caCode AND (DefaultStore__c = :storeCode OR User_Stores__c LIKE : storeName)') +
        '  AND '+
        ' IsActive = true';

        List<User> users = Database.query(query);

        if(users.size() == 1){
            return users[0];
        }
        
        
        return null;
    }

    /*=================================================================================================================*/
        //GET CLIENT COUNTRY

        global static String getCountry(String countryCode){
            
            List<Schema.PicklistEntry> pleList = Contact.SPO_Country_code__c
                .getDescribe()
                .getPicklistValues();
            for(Schema.PicklistEntry ple : pleList){
                if(ple.getValue() == countryCode){
                    return ple.getLabel();
                }
            }
            
            return null;
        }
    /*=================================================================================================================*/
        //GET GENERIC SKU

        global static Boolean isGenericSKU(String sku){
            List<IconSetting__mdt> iconSettings = [Select Text__c
            FROM IconSetting__mdt 
            WHERE QualifiedApiName ='GenericSKUs'];

            if( iconSettings.size() > 0){
                return iconSettings[0].Text__c.indexOf(sku) != -1;
            }
            
            return false;
        }


    /*=================================================================================================================*/
        //GET CLIENT COUNTRY

        global static Boolean isNotRepaired(String NSCode){
            List<IconSetting__mdt> iconSettings = [Select Text__c
            FROM IconSetting__mdt 
            WHERE QualifiedApiName ='NS_NOT_REPAIRED'];

            if( iconSettings.size() > 0){
                return iconSettings[0].Text__c.indexOf(NSCode) != -1;
            }
            
            return false;
        }


    /*=================================================================================================================*/
    
    /* Insert list of new CareServiceLineItem__c using data sent in the body under key "Instructions" 
    and delete old CareServiceLineItem__c related to the CareService__c */
    
    global static Void setInstructions(List<Object> instructionList, String careServiceId){
        List<CareServiceLineItem__c> toDelete = [Select Id From CareServiceLineItem__c Where CareService__c =: careServiceId];

        List<CareServiceLineItem__c> careServiceLIs = new List<CareServiceLineItem__c>();

        for(Object instructionObj: instructionList){
            Map<String, Object>  instructionMap = (Map<String, Object>)instructionObj;
            CareServiceLineItem__c csLI =  (CareServiceLineItem__c) createObject(instructionMap, 'CareServiceLineItem__c', new CareServiceLineItem__c());
            csLi.CareService__c = careServiceId;
            careServiceLIs.add(csLI);
        }

        if (careServiceLIs.size() > 0)
            insert careServiceLIs;

        if (toDelete.size() > 0){
            delete toDelete;
            Database.emptyRecycleBin(toDelete);
        }
    }
    

    /*=================================================================================================================*/
    //Genereic Function to create Sobject Instance using Map<String, Object>

    global static SObject createObject(Map<String,Object> csMap, String objectName,SObject sObj){
        for(String key : csMap.keySet()){

            String sObjectName = objectName;
            Schema.SObjectType t = Schema.getGlobalDescribe().get(sObjectName);
            Schema.DescribeSObjectResult r = t.getDescribe();

            if (r.fields.getMap().keySet().contains(key.toLowerCase())){
                Schema.DisplayType fieldType = getFieldType(key, objectName);

                if (fieldType == Schema.DisplayType.Date)
                    sObj.put(key, csMap.get(key) == ''  || csMap.get(key) == null ? null : Date.valueOf(String.valueOf(csMap.get(key))));

                else if(fieldType == Schema.DisplayType.DateTime)
                    sObj.put(key, csMap.get(key) == '' || csMap.get(key) == null ? null : (DateTime)Json.deserialize('"'+(String)csMap.get(key)+'"', DateTime.class));

                else if (fieldType == Schema.DisplayType.Percent || fieldType == Schema.DisplayType.Currency)
                    sObj.put(key, csMap.get(key) == '' || csMap.get(key) == null ? null : Decimal.valueOf(String.valueOf(csMap.get(key))));

                else if (fieldType == Schema.DisplayType.Double)
                    sObj.put(key, Double.valueOf(csMap.get(key)));

                else if (fieldType == Schema.DisplayType.Integer)
                    sObj.put(key, Integer.valueOf(csMap.get(key)));

                else if (fieldType == Schema.DisplayType.Base64)
                    sObj.put(key, Blob.valueOf(String.valueOf(csMap.get(key))));

                else
                    sObj.put(key, csMap.get(key));
            }
            
        }

        return sObj;
    }

    /*=================================================================================================================*/
    //Genereric function to get Field Type using fieldName

    global static Schema.DisplayType getFieldType(String fieldName, String objectName){
        String sObjectName = objectName;
        Schema.SObjectType t = Schema.getGlobalDescribe().get(sObjectName);
        Schema.DescribeSObjectResult r = t.getDescribe();

        if (r.fields.getMap().get(fieldName) == null){
            return null;
        }
        Schema.DescribeFieldResult f = r.fields.getMap().get(fieldName).getDescribe();

        return f.getType();
    }

    /*=================================================================================================================*/
    //Encode base64

    global static String decode64(String text){
        try{
            return EncodingUtil.base64Decode(text).toString();
        } catch(Exception e){
            return text;
        }
    }

        /*=================================================================================================================*/
    //Encode base64

    global static String trimPhone(String phone){
        try{
            string nondigits = '[^0-9]';
            string phoneDigits;
            // remove all non numeric
            phoneDigits = phone.replaceAll(nondigits,''); 
            return phoneDigits;
        } catch(Exception e){
            return phone;
        }
    }

    /*=================================================================================================================*/
    //ResponseWrapper

    global class ResponseHandler {
        public Boolean success {get; set;}
        public List<ErrorWrapper> errors {get;set;}
        public Boolean created {get;set;}

        public ResponseHandler(System.StatusCode statusCode, String message, List<String> fields){
            this.success = false;
            this.errors = new List<ErrorWrapper>{ new ErrorWrapper(statusCode, message, fields)};
            this.created = false;
        }
        
    } 

    global class ErrorWrapper {
        public System.StatusCode statusCode {get; set;}
        public String message {get;set;}
        public List<String> fields {get;set;}
        public ErrorWrapper(System.StatusCode statusCode, String message, List<String> fields){
            this.fields = new List<String>();
            this.statusCode = statusCode;
            this.message = message;
            this.fields = fields;
        }
    }


}