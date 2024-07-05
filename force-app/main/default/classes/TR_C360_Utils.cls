/***************************************************************************************************
* @File Name          : TR_C360_Utils.cls
* @Description        : This class was created for the C360 project 
* @Author             : Imad.alsidchikh@vo2-consultant.com
* @Group              : VO2
* @Last Modified By   : Imad.alsidchikh@vo2-consultant.com
* @Last Modified On   : 02-22-2022
* @Modification Log   :
* Ver       Date               Author                            Modification
* 1.0       02-22-2022        Imad.alsidchikh@vo2-group.com     Initial Version
*****************************************************************************************************/
public class TR_C360_Utils {
    
    public static Map<String,String> salValue;
    public static Map<String,String> titleValue;
    public static Map<String,String> GlobalCountryVal;
    public static Map<String,String> GlobalCountryValISO3; 
    public static Map<String,String> GlobalCountryValISO2ISO3; 
    
    public static Map<String,String> PrefLanValue;
    public static Map<String,String> defaultStoreValue;
    public static Map<String,String> storeCodeValue;
    public static boolean runC360 = true;
    
    public static user getCurrentUserInfos(){
        List<User> userRecord = [SELECT Id,Profile.Name,Primary_App__c,TECH_DefaultStoreName__c ,DefaultStore__c,Country__c,Username,Name FROM user WHERE Id=:userinfo.getUserId() LIMIT 1];
        User us = new User();
        if(userRecord.size()>0){
            us = userRecord[0];
        }
        return us;
    }
     public static boolean runOnceC360() {
        if(runC360) {
            runC360 = false;
            System.debug(' runOnceC360 runC360 1 ==>  ' +  runC360);
            return true;
        } else {
            System.debug(' runOnceC360 runC360 2 ==> ' +  runC360);
            return runC360;
        }
    }
    public static void setSalutationVal(){
        Map<String,String> salVal = new Map<String,String>();  
        Schema.DescribeFieldResult objFieldDescribe = Account.Salutation.getDescribe();
        List<Schema.PicklistEntry> lstPickListValues = objFieldDescribe.getPickListValues(); 
        for(Schema.PicklistEntry ps : lstPickListValues){
            salVal.put(ps.getValue(),ps.getLabel()); 
        }
        salValue = salVal;
    }
    public static void setTitleVal(){
        Map<String,String> salVal = new Map<String,String>();  
        Schema.DescribeFieldResult objFieldDescribe = Account.Title__pc.getDescribe();
        List<Schema.PicklistEntry> lstPickListValues = objFieldDescribe.getPickListValues();  
        for(Schema.PicklistEntry ps : lstPickListValues){
            salVal.put(ps.getValue(),ps.getLabel());
        }
        titleValue = salVal;
    }
    public static void setCountryVal(){
        Map<String,String> countryVal = new Map<String,String>(); 
        Map<String, String> countryValISO3 = new Map<String,String>(); 
        Map<String, String> CountryValISO2ISO3 = new Map<String,String>(); 

        List<CountryMapping__mdt > cmm = [SELECT Picklist__c,Iso2Code__c,Iso3Code__c FROM CountryMapping__mdt];
        for (CountryMapping__mdt mdt : cmm){
            countryVal.put(mdt.Picklist__c, mdt.Iso3Code__c);
            countryValISO3.put(mdt.Iso3Code__c, mdt.Picklist__c);
            CountryValISO2ISO3.put(mdt.Iso2Code__c, mdt.Iso3Code__c);
        }
        GlobalCountryVal =  countryVal;
        GlobalCountryValISO3 = countryValISO3;
        GlobalCountryValISO2ISO3 =  CountryValISO2ISO3;
    }
    public static void setPreLangVal(){
        Map<String,String> PreLan = new Map<String,String>();  
        Schema.DescribeFieldResult objFieldDescribe = Account.PreferredLanguage__pc.getDescribe();
        List<Schema.PicklistEntry> lstPickListValues = objFieldDescribe.getPickListValues(); 
        for(Schema.PicklistEntry ps : lstPickListValues){
            PreLan.put(ps.getValue(),ps.getLabel());
        }
        PrefLanValue = PreLan;
    }
        public static void setDefaultStoreVal(){
        Map<String,String> storeVal = new Map<String,String>();  
        Schema.DescribeFieldResult objFieldDescribe = User.DefaultStore__c.getDescribe();
        List<Schema.PicklistEntry> lstPickListValues = objFieldDescribe.getPickListValues(); 
        for(Schema.PicklistEntry ps : lstPickListValues){
            storeVal.put(ps.getValue(),ps.getLabel());
        }
        defaultStoreValue = storeVal;
    }
        public static void setStoreCodeVal(){
            Map<String,String> storeCodeVal = new Map<String,String>();  
            List<Store__c > storelist = [SELECT RetailStoreId__c,ISO3_Code__c,StoreCountry__c    FROM Store__c];

            for(Store__c o : storelist){
                storeCodeVal.put( o.RetailStoreId__c,o.ISO3_Code__c);
            }
            storeCodeValue=storeCodeVal;
        }


    public static  Map<String,String> getMappingFields(){
        Map<String,String> sfFields = new Map<String,String>(); 
        List<TR_C360_Field_Mapping__mdt > mappingRds = TR_Constants.mappingRds;
        if(mappingRds.size()>0){
            for(TR_C360_Field_Mapping__mdt flds : mappingRds){
                if(flds.C360_Field__c	!=null){
                    sfFields.put(flds.C360_Field__c, flds.SF_Field__c);
                }    
            }
            
        }
        return sfFields;
    }
    public static String getCountry(String CountryCode){
        List<Country__c> ctr = new List<Country__c>();
        if (String.isNotBlank(CountryCode)){
            ctr = [SELECT Name from Country__c where Iso3Code__c =: CountryCode];
        }
        if(ctr.size()>0){
            return ctr[0].Name;
        }
        return null;
    }
    public static String getDateTime(Date dateToconvert){
        Datetime DT = datetime.newInstance(dateToconvert.year(), dateToconvert.month(),dateToconvert.day());
        String DTF = DT.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX');
        return DTF;
    }
    public static C360_Logs__c CreateLog(Map<String, String> params){
        Decimal Dur;
        C360_Logs__c log;  
        if(params != null){
            system.debug(params.get('duration'));
            if(String.isNotBlank(params.get('duration')))  Dur = Decimal.valueOf(params.get('duration')); else Dur = 0;
            log = new C360_Logs__c(
                TR_Apex_Class__c = params.get('apex_class'),
                TR_APEX_Limits__c = params.get('apex_Limits'),
                TR_Application__c = params.get('application'),
                TR_Duration__c = Dur,
                TR_Error__c = params.get('error_Message'),
                TR_EventUuidLog__c = params.get('eventUuidLog'),
                TR_Has_Error__c  = Boolean.valueOf(params.get('hasError')),
                TR_JSON__c = params.get('json'),
                TR_Level__c = params.get('logLevel'),
                TR_Message__c = params.get('logMessage'),
                TR_Object_Type__c = params.get('Object_Type'),
                TR_Record_Id__c = params.get('record_Id'),
                TR_Type__c = params.get('logType'),
                TR_Apex_Method__c = params.get('apex_Method'),
                DreamId__c = params.get('DreamID'),
                SalesForceId__c = params.get('SalesforceID')
            );
        }               
        return log;
    }
    public static String getC360Json(String name) {
        
        String json = '{';
        json +=  '"activeFlag": "0",';
        json +=  '"residencePostalAddress_addressLine3": "444 Rue de Paris",';
        json +=  '"residencePostalAddress_addressLine2": "23 Rue de Paris",';
        json +=  '"residencePostalAddress_addressLine1": "123 Rue de Paris",';
        json +=  '"touchApplicationCode": "C361",';
        json +=  '"dreamId": "",';
        json +=  '"passportNumbers": "00000002",';
        json +=  '"workPhoneNumber_internationnal": "3315456545454",';
        json +=  '"preferredLanguage_code": "FRA",';
        json +=  '"City_of_Residence": "Oran",';
        json +=  '"residencePostalAddress_countryCodeIso": "FRA",';
        json +=  '"birthDate": "1989-03-21",';
        json +=  '"clientTimestamp": "2022-06-27T10:35:42.923+02:00",';
        json +=  '"clientType_code": "02",';
        json +=  '"clientType_libelle": "Client",';
        json +=  '"dreamId_master": "",';
        json +=  '"firstName": "IASC'+name+'",';
        json +=  '"firstName2": "Paris",';
        json +=  '"gender_code": "M",';
        json +=  '"gender_libelle": "Male",';
        json +=  '"homePhoneNumber_countryCodeIso2": "FR",';
        json +=  '"homePhoneNumber_internationnal": "+33100000000",';
        json +=  '"lastName": "IASC'+name+'",';
        json +=  '"lastName2": '+name+',';
        json +=  '"homePhoneNumber_number": "0100000000",';
        json +=  '"mobilePhoneNumber_internationnalPrefixe": "33",';
        json +=  '"mobilePhoneNumber_countryCodeIso2": "FR",';
        json +=  '"mobilePhoneNumber_internationnal": "+33700000000",';
        json +=  '"mobilePhoneNumber_number": "0700000000",';
        json +=  '"nationality_code": "FRA",';
        json +=  '"nationality_libelle": "French",';
        json +=  '"isOptInToReceiveMarketingEmails": "true",';
        json +=  '"emailAddress": "IASC'+name+'@IASCtest.com",';
        json +=  '"isOptInToReceiveMails": "true",';
        json +=  '"isOptInToReceiveCalls": "true",';
        json +=  '"State_of_Residence": "Paris",';
        json +=  '"Zip_Code": "75001",';
        json +=  '"civility_code": "02",';
        json +=  '"salesforceId": "",';
        json +=  '"title_code": "02",';
        json +=  '"workPhoneNumber_countryCodeIso2": "FR",';
        json +=  '"workPhoneNumber_number": "0100000000",';
        json +=  '"worldwideId": "",';
        json +=  '"isOptInToReceiveSms": "true",';
        json +=  '"residencePostalAddress_country": "French"';
        json += '}';
        return json;
    }
}