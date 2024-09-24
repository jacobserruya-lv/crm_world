/***************************************************************************************************
* @File Name          : TR_JSON-Generator.cls
* @Description        : This class was created for the C360 project for generate a Json
* @Author             : Imad.alsidchikh@vo2-consultant.com
* @Group              : VO2
* @Last Modified By   : Imad.alsidchikh@vo2-consultant.com
* @Last Modified On   : 06-12-2021
* @Modification Log   :
* Ver       Date               Author                            Modification
* 1.0       06-12-2021         Imad.alsidchikh@vo2-group.com     Initial Version
*****************************************************************************************************/
public class TR_JSON_Generator {
    
    
    //TODO Add parameters to this method
    public static String generateJSONContent(Account account,List<User> usIdentity,List<Social_Media_Identifier__c> smi,TECH_IntegrationManager__c tim,user CurrentUser) {
        JSONGenerator gen = JSON.createGenerator(true);
        Map<String,String> genSalVal = TR_C360_Utils.salValue;
        Map<String,String> gentitleVal = TR_C360_Utils.titleValue;
        Map<String,String> genPrefLangVal = TR_C360_Utils.PrefLanValue;
        Map<String,String> GlobalCountryValISO2ISO3 = TR_C360_Utils.GlobalCountryValISO2ISO3;
        Map<String,String> GlobalCountryValISO3 = TR_C360_Utils.GlobalCountryValISO3;
        Map<String,String> GlobalCountryVal = TR_C360_Utils.GlobalCountryVal;
        Map<String,String> defaultStoreValue = TR_C360_Utils.defaultStoreValue;     
        Map<String,String> StoreCountryValisoValue = TR_C360_Utils.storeCodeValue;
        
        
        
        Account acc = new Account();
        acc = account;
        gen.writeStartObject();
        if (acc.LastName !=   null)  gen.writeStringField('lastName', acc.LastName); else gen.writeNullField('lastName'); 
        if (acc.FirstName !=   null)  gen.writeStringField('firstName', acc.FirstName); else gen.writeNullField('firstName'); 
        if (acc.Lastname2__pc !=   null)  gen.writeStringField('lastName2', acc.Lastname2__pc); else gen.writeNullField('lastName2'); 
        if (acc.Firstname2__pc !=   null)  gen.writeStringField('firstName2', acc.Firstname2__pc); else gen.writeNullField('firstName2'); 
        gen.writeFieldName('identifiers');
        gen.writeStartObject();
        if (acc.Id !=   null)  gen.writeStringField('salesforceId', acc.Id); else gen.writeNullField('salesforceId'); 
        gen.writeNullField('atgId');  
        if (acc.DREAMID__c !=   null)  gen.writeStringField('dreamId', acc.DREAMID__c); else gen.writeNullField('dreamId');
        //@AyLame: CF-314 adding the new field C360GoldenID__c
        if (acc.C360GoldenID__c !=   null) gen.writeStringField('c360GoldenId', acc.C360GoldenID__c); else gen.writeNullField('c360GoldenId');
        //if (acc.masterC360GoldenID__c !=   null) gen.writeStringField('masterC360GoldenId', acc.masterC360GoldenID__c); else gen.writeNullField('masterC360GoldenId');
        if(usIdentity != null && !usIdentity.isEmpty() && usIdentity.Size()>0){
            if(usIdentity[0] != null && String.isNotBlank(usIdentity[0].Id)){
                gen.writeStringField('userIdentitySalesforceId',usIdentity[0].Id);  
            }else{
                gen.writeNullField('userIdentitySalesforceId');   
            }
        }else{
            gen.writeNullField('userIdentitySalesforceId');    
        }
        if (acc.WW_RMSId__c !=   null)  gen.writeStringField('worldwideId', acc.WW_RMSId__c); else gen.writeNullField('worldwideId'); 
        gen.writeEndObject();
        gen.writeFieldName('passportNumbers');
        gen.writeStartArray();
        if(String.isNotBlank(acc.PassportNumber__pc)) gen.writeString(acc.PassportNumber__pc);   
        gen.writeEndArray();
        gen.writeFieldName('accounts');
        gen.writeStartArray();
        if(usIdentity != null && !usIdentity.isEmpty() && usIdentity.Size()>0){
            gen.writeStartObject();
            if (usIdentity[0] != null && usIdentity[0].Email !=   null)  gen.writeStringField('email', usIdentity[0].Email); else gen.writeNullField('email'); 
            if (usIdentity[0] != null && usIdentity[0].CreatedDate !=   null)  gen.writeDateTimeField('creationDate', usIdentity[0].CreatedDate); else gen.writeNullField('creationDate'); 
            if (usIdentity[0] != null && usIdentity[0].LastLoginDate !=   null)  gen.writeDateTimeField('lastLoginDate', usIdentity[0].LastLoginDate); else gen.writeNullField('lastLoginDate'); 
            gen.writeEndObject();
        }
        gen.writeEndArray();
        gen.writeBooleanField('isOptInToReceiveMarketingEmails',acc.Can_Be_Contacted_By_Email__pc);
        gen.writeBooleanField('isOptInToReceiveSms',acc.Can_Be_Contacted_By_SMS__pc);
        gen.writeBooleanField('isOptInToReceiveCalls',acc.Can_Be_Contacted_By_Phone__pc);
        gen.writeBooleanField('isOptInToReceiveMails',acc.Can_Be_Contacted_By_Mail__pc);  
        gen.writeDateTimeField('creationDate', acc.CreatedDate);
        gen.writeDateTimeField('modificationDate', acc.LastModifiedDate);
        if (acc.PersonBirthdate !=   null)  gen.writeDateField('birthDate', acc.PersonBirthdate); else gen.writeNullField('birthDate');
        gen.writeFieldName('auditTrail');  
        gen.writeStartObject();
        if (currentUser.DefaultStore__c !=   null)  gen.writeStringField('storeCode', currentUser.DefaultStore__c); else gen.writeNullField('storeCode'); 
        if (acc.Source__c !=null && acc.source__c=='Manual' && !GlobalCountryVal.isEmpty() && String.isNotBlank(GlobalCountryVal.get(currentUser.Country__c))){           
            gen.writeStringField('countryCodeIso', GlobalCountryVal.get(currentUser.Country__c)); 
        }
        else if(acc.Source__c !=null && acc.source__c=='MyCC'){
            if(acc.PrimaryCountry__pc!=null && !GlobalCountryVal.isEmpty() && String.isNotBlank(GlobalCountryVal.get(acc.PrimaryCountry__pc))){
                gen.writeStringField('countryCodeIso', GlobalCountryVal.get(acc.PrimaryCountry__pc));     
            }else{
                gen.writeNullField('countryCodeIso');
            }         
        }else if(acc.Source__c !=null && acc.source__c=='KBRW'){
            if(acc.AttachedStoreCode__pc !=null && !StoreCountryValisoValue.isEmpty() && String.isNotBlank(StoreCountryValisoValue.get(acc.AttachedStoreCode__pc) )){
                gen.writeStringField('countryCodeIso', StoreCountryValisoValue.get(acc.AttachedStoreCode__pc)); 
            }else {
                gen.writeNullField('countryCodeIso');     
            }
        }else if(acc.Source__c !=null && acc.source__c=='Kakaotalk'){
            if(acc.AttachedStoreCountry__pc  !=null) gen.writeStringField('countryCodeIso',acc.AttachedStoreCountry__pc ); else  gen.writeNullField('countryCodeIso');
        }else if(acc.Source__c !=null && acc.source__c=='MyLV' ||acc.source__c=='On App'){
            if(acc.PrimaryCountry__pc !=null && !GlobalCountryVal.isEmpty() &&String.isNotBlank(GlobalCountryVal.get(acc.PrimaryCountry__pc) )){
                gen.writeStringField('countryCodeIso', GlobalCountryVal.get(acc.PrimaryCountry__pc)); 
            }else if(acc.PrimaryCountry__pc =='CHINA' || acc.PrimaryCountry__pc =='CN' || acc.PrimaryCountry__pc =='CHN'){
                gen.writeStringField('countryCodeIso', 'CHN');
            }else {
                gen.writeNullField('countryCodeIso');     
            }
        }
        else {
            if(acc.AttachedStoreCountry__pc!=null){
                gen.writeStringField('countryCodeIso', acc.AttachedStoreCountry__pc); 
            }
            else if(acc.AttachedStoreCode__pc !=null){
                if(!StoreCountryValisoValue.isEmpty() && acc.AttachedStoreCode__pc != null &&String.isNotBlank(StoreCountryValisoValue.get(acc.AttachedStoreCode__pc) ))
                    gen.writeStringField('countryCodeIso', StoreCountryValisoValue.get(acc.AttachedStoreCode__pc)); 
            }
            else if(acc.AttachedStore__pc !=null){
                if(!StoreCountryValisoValue.isEmpty() && String.isNotBlank(StoreCountryValisoValue.get(acc.AttachedStore__pc) ))
                    gen.writeStringField('countryCodeIso', StoreCountryValisoValue.get(acc.AttachedStore__pc)); 
            }
            else {
                if (acc.store__pc != null){
                    Store__c store = [Select Store_CountryCode__c, StoreCountry__c, ISO3_Code__c from Store__c where id =: acc.Store__pc];
                    if (store!= null && store.ISO3_Code__c != null){
                        gen.writeStringField('countryCodeIso', store.ISO3_Code__c);
                    }
                    else if (store != null && GlobalCountryValISO2ISO3.get(store.Store_CountryCode__c) != null){
                        gen.writeStringField('countryCodeIso', GlobalCountryValISO2ISO3.get(store.Store_CountryCode__c));
                    }
                    else if (store != null && GlobalCountryVal.get(store.StoreCountry__c) != null){ 
                        gen.writeStringField('countryCodeIso', GlobalCountryVal.get(store.StoreCountry__c));
                    }
                    else  if (store != null && store.Store_CountryCode__c != null){
                        gen.writeStringField('countryCodeIso', store.Store_CountryCode__c);
                    }else{
                        gen.writeNullField('countryCodeIso');
                    }
                }else if(acc.PrimaryCountry__pc =='CHINA' || acc.PrimaryCountry__pc =='CN' || acc.PrimaryCountry__pc =='CHN'){
                    gen.writeStringField('countryCodeIso', 'CHN');
                }              
            }
        }
        
        gen.writeStringField('sourceApplicationCode',TR_Constants.SOURCEAPPCODE);
        gen.writeStringField('touchApplicationLabel',(acc.Source__c !=   null) ? acc.Source__c : TR_Constants.APP_CODE);
        gen.writeStringField('userLogin',currentUser.Username);  
        gen.writeStringField('userName',currentUser.Name); 
        gen.writeDateTimeField('clientTimestamp', acc.SystemModstamp);
        gen.writeEndObject(); 
        gen.writeFieldName('clientAdvisorForcedAttachment');  
        gen.writeStartObject();
        gen.writeFieldName('clientAdvisor');        
        gen.writeStartObject();
        system.debug('#### ok ');
        // start Fix Attempt to de-reference a null object (CF-66)
        if (acc.TECH_OwnerManuallyChanged__c  &&  acc.Owner.WWEmployeeNumber__c != null ) gen.writeStringField('worldwideId',acc.Owner.WWEmployeeNumber__c);  else gen.writeNullField('worldwideId');
        gen.writeStringField('name',(acc.TECH_OwnerManuallyChanged__c && acc.CAName__c != null? acc.CAName__c : ''));
        gen.writeEndObject();
        if (acc.TECH_OwnerManuallyChanged__c && acc.TECH_ManualReassignmentDate__c != null)  
        gen.writeDateField('forcedAttachmentDate', date.newinstance(acc.TECH_ManualReassignmentDate__c.year(), acc.TECH_ManualReassignmentDate__c.month(), acc.TECH_ManualReassignmentDate__c.day()));
        //end Fix Attempt to de-reference a null object (CF-66)
        gen.writeBooleanField('isChangedManually',acc.TECH_OwnerManuallyChanged__c);
        gen.writeEndObject();
        gen.writeFieldName('title');
        gen.writeStartObject();
        if (acc.Title__pc !=   null)  gen.writeStringField('code', acc.Title__pc); else gen.writeNullField('code');
        if(!gentitleVal.isEmpty() && String.isNotBlank(gentitleVal.get(acc.Title__pc))) gen.writeStringField('label',gentitleVal.get(acc.Title__pc)); else gen.writeNullField('label');
        gen.writeEndObject();
        gen.writeFieldName('gender');
        gen.writeStartObject();
        if (acc.GenderCode__pc !=   null)  gen.writeStringField('code', acc.GenderCode__pc); else gen.writeNullField('code');
        if (acc.Gender__pc !=   null)  gen.writeStringField('label', acc.Gender__pc); else gen.writeNullField('label');
        gen.writeEndObject();
        gen.writeFieldName('civility');
        gen.writeStartObject();
        if (acc.Salutation !=   null)  gen.writeStringField('code', acc.Salutation); else gen.writeNullField('code');
        if (!genSalVal.isEmpty() && String.isNotBlank(genSalVal.get(acc.Salutation)))   gen.writeStringField('label',genSalVal.get(acc.Salutation)); else gen.writeNullField('label');
        gen.writeEndObject();
        gen.writeFieldName('nationality');
        gen.writeStartObject();
        if (acc.NationalityCountryCode__pc !=   null)  gen.writeStringField('code', acc.NationalityCountryCode__pc); else gen.writeNullField('code');
        if (acc.Nationality__pc !=   null)  gen.writeStringField('label', acc.Nationality__pc); else gen.writeNullField('label');
        gen.writeEndObject();
        gen.writeFieldName('clientType');
        gen.writeStartObject();
        if (acc.TypologyCode__pc !=   null)  gen.writeStringField('code', acc.TypologyCode__pc); else gen.writeNullField('code');
        if (acc.Typology__pc !=   null)  gen.writeStringField('label', acc.Typology__pc); else gen.writeNullField('label');
        gen.writeEndObject();
        gen.writeFieldName('preferredLanguage');
        gen.writeStartObject();
        if (acc.PreferredLanguage__pc !=   null)  gen.writeStringField('code', acc.PreferredLanguage__pc); else gen.writeNullField('code');
        if (!genPrefLangVal.isEmpty() && String.isNotBlank(genPrefLangVal.get(acc.PreferredLanguage__pc)))   gen.writeStringField('label',genPrefLangVal.get(acc.PreferredLanguage__pc)); else gen.writeNullField('label');
        gen.writeEndObject();
        gen.writeFieldName('socialMediaConsents');
        gen.writeStartArray();
        if(smi != null && smi.size()>0){
            for(Social_Media_Identifier__c s : smi){
                gen.writeStartObject();
                gen.writeFieldName('socialMedia');
                gen.writeStartObject();
                if (s.Miniprogram_Source__c !=   null)  gen.writeStringField('code', s.Miniprogram_Source__c); else gen.writeNullField('code');
                if (s.Social_Media_Type__c !=   null)  gen.writeStringField('label', s.Social_Media_Type__c); else gen.writeNullField('label');
                gen.writeEndObject();  
                gen.writeBooleanField('isOptin',s.Opt_In__c);
                if (s.Follow_Up_Date__c !=   null)  gen.writeDateField('followUpDate', s.Follow_Up_Date__c); else gen.writeNullField('followUpDate');
                if (s.Social_Id__c !=   null)  gen.writeStringField('identifier', s.Social_Id__c); else gen.writeNullField('identifier');
                gen.writeDateTimeField('creationDate', s.CreatedDate);
                gen.writeDateTimeField('modificationDate', s.LastModifiedDate); 
                gen.writeStringField('salesforceId', s.Id);
                gen.writeEndObject();                
            }
        }
        gen.writeEndArray();
        gen.writeFieldName('storeWhereClientWasCreated');
        gen.writeStartObject();
        if (currentUser.DefaultStore__c !=   null)  gen.writeStringField('code', currentUser.DefaultStore__c); else gen.writeNullField('code');
        if(!defaultStoreValue.isEmpty() && String.isNotBlank(defaultStoreValue.get(currentUser.DefaultStore__c))) gen.writeStringField('label',defaultStoreValue.get(currentUser.DefaultStore__c)); else gen.writeNullField('label');
        gen.writeEndObject();
        gen.writeFieldName('storeWhereClientWasLastModified');
        gen.writeStartObject();
        if (currentUser.DefaultStore__c !=   null)  gen.writeStringField('code', currentUser.DefaultStore__c); else gen.writeNullField('code');
        if(!defaultStoreValue.isEmpty() && String.isNotBlank(defaultStoreValue.get(currentUser.DefaultStore__c))) gen.writeStringField('label',defaultStoreValue.get(currentUser.DefaultStore__c)); else gen.writeNullField('label');
        gen.writeEndObject();  gen.writeFieldName('emailAddress');
        gen.writeStartObject();
        if (acc.PersonEmail !=   null)  gen.writeStringField('emailAddress', acc.PersonEmail); else gen.writeNullField('emailAddress');
        gen.writeEndObject(); 
        gen.writeFieldName('workPhoneNumber');
        gen.writeStartObject();   
        gen.writeNullField('internationalPrefix');   
        if (acc.WorkPhoneCountryCode__pc !=   null)  gen.writeStringField('countryCodeIso', acc.WorkPhoneCountryCode__pc); else gen.writeNullField('countryCodeIso');
        if (acc.Phone !=   null)  gen.writeStringField('phoneNumber', acc.Phone); else if(acc.LocalWorkPhone__pc !=   null) gen.writeStringField('phoneNumber', acc.LocalWorkPhone__pc); else gen.writeNullField('phoneNumber');
        gen.writeEndObject(); 
        gen.writeFieldName('homePhoneNumber');
        gen.writeStartObject();
        gen.writeNullField('internationalPrefix');      
        if (acc.HomePhoneCountrycode__pc !=   null)  gen.writeStringField('countryCodeIso', acc.HomePhoneCountrycode__pc); else gen.writeNullField('countryCodeIso');
        if (acc.PersonHomePhone !=   null)  gen.writeStringField('phoneNumber', acc.PersonHomePhone); else if(acc.LocalHomePhone__pc !=   null) gen.writeStringField('phoneNumber', acc.LocalHomePhone__pc); else gen.writeNullField('phoneNumber');
        gen.writeEndObject(); 
        gen.writeFieldName('mobilePhoneNumber');
        gen.writeStartObject();
        if (acc.MobilePhoneCountryCallingCode__pc !=   null)  gen.writeStringField('internationalPrefix', acc.MobilePhoneCountryCallingCode__pc); else gen.writeNullField('internationalPrefix');
        if (acc.MobilePhoneCountryCode__pc !=   null)  gen.writeStringField('countryCodeIso', acc.MobilePhoneCountryCode__pc);  else gen.writeNullField('countryCodeIso');
        if (acc.PersonMobilePhone !=   null)  gen.writeStringField('phoneNumber', acc.PersonMobilePhone); else if(acc.LocalMobilePhone__pc !=   null) gen.writeStringField('phoneNumber', acc.LocalMobilePhone__pc); else gen.writeNullField('phoneNumber');
        gen.writeEndObject(); 
        gen.writeFieldName('residencePostalAddress');
        gen.writeStartObject();
        if (acc.PrimaryAddressLine1__pc !=   null)  gen.writeStringField('addressLine1', acc.PrimaryAddressLine1__pc); else gen.writeNullField('addressLine1');
        if (acc.PrimaryStateProvince__pc !=   null)  gen.writeStringField('state', acc.PrimaryStateProvince__pc); else gen.writeNullField('state');
        if (acc.PrimaryAddressLine3__pc !=   null)  gen.writeStringField('addressLine3', acc.PrimaryAddressLine3__pc); else gen.writeNullField('addressLine3');
        if (acc.PrimaryCity__pc !=   null)  gen.writeStringField('city', acc.PrimaryCity__pc); else gen.writeNullField('city');
        if (acc.PrimaryAddressLine2__pc !=   null)  gen.writeStringField('addressLine2', acc.PrimaryAddressLine2__pc); else gen.writeNullField('addressLine2');
        if (acc.PrimaryZipCode__pc !=   null)  gen.writeStringField('postalCode', acc.PrimaryZipCode__pc); else gen.writeNullField('postalCode');
        if (acc.HomeAddressCountryCode__pc !=   null){
            gen.writeStringField('countryCodeIso', acc.HomeAddressCountryCode__pc);
            //handle all cases regardless of the source (cf-25). Remove acc.Source__c !=null && acc.source__c=='KBRW'
        } else if(acc.AttachedStoreCountry__pc != null) {
            gen.writeStringField('countryCodeIso', acc.AttachedStoreCountry__pc);    
        }else{
            gen.writeNullField('countryCodeIso');
        }
        gen.writeEndObject();
        gen.writeEndObject();
        String pretty = gen.getAsString();
        return pretty;
    }
    
}