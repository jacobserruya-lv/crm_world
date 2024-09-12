/***************************************************************************************************
* @File Name          : TR_Constants.cls
* @Description        : This class was created for the C360 
* @Author             : Imad.alsidchikh@vo2-consultant.com
* @Group              : VO2 
* @Last Modified By   : Imad.alsidchikh@vo2-consultant.com
* @Last Modified On   : 01-05-2022  
* @Modification Log   :
* Ver       Date               Author                            Modification
* 1.0       01-05-2022         Imad.alsidchikh@vo2-group.com     Initial Version
*****************************************************************************************************/

public with sharing  class TR_Constants {
    @testVisible
    public static  TR_Integration_Manager_Setting__c  getClientSetup = TR_Integration_Manager_Setting__c.getAll().get('C360_Client_Setup');
    public static  TR_Integration_Manager_Setting__c  getClientSyncSetup = TR_Integration_Manager_Setting__c.getAll().get('C360Synchrone_Client_Setup');
    public static  TR_Integration_Manager_Setting__c  getSMISetup = TR_Integration_Manager_Setting__c.getAll().get('C360_SocialMedia_Setup');
    public static  TR_Integration_Manager_Setting__c  getLogSetup = TR_Integration_Manager_Setting__c.getAll().get('Json Log 360 Manager');
    public static List<TR_C360_Field_Mapping__mdt > mappingRds = [SELECT SF_ObjectName__c ,SF_Field__c ,C360_Field__c,Is_Active__c,Is_From_C360__c FROM TR_C360_Field_Mapping__mdt WHERE SF_ObjectName__c = :TR_Constants.OBJECT_ACCOUNT];
    public static List<TR_C360_Field_Mapping__mdt > mappingSmi = [SELECT SF_ObjectName__c ,SF_Field__c ,C360_Field__c,Is_Active__c,Is_From_C360__c FROM TR_C360_Field_Mapping__mdt WHERE SF_ObjectName__c = :TR_Constants.OBJECT_SOCIALMEDIA];
    
    public final static String CREATE_CL360 = 'CREATE';
    public final static String UPDATE_CL360 = 'UPDATE';
    public final static String C360_ACCOUNT = 'C360_ACCOUNT';
    public final static String OBJECT_ACCOUNT = 'ACCOUNT';
    public final static String OBJECT_SOCIALMEDIA = 'Social_Media_Identifier__c';
    public final static String APP_NAME  = 'SALESCLOUD';
    public final static String APP_CODE ='7';
    public final static String SOURCEAPPCODE  = 'SALESFORCE';
    public static DateTime startTime;
    public final static String APPEVENT  = 'C360_EVENT_LOG';
    public final static String recordTypeClient = '012i0000000TUDGAA4';
    
    public static String getProfile(){
        List<Profile> profileName = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        String prof;
        if(profileName.size()>0){
            prof = profileName[0].Name;
        }else{
            prof = 'No_Profile';
        }
        return prof;
    }
    
    public static String getClientFields(){
        String acctFields;
        acctFields =  'FirstName,'; 
        acctFields += 'LastName,';
        acctFields += 'FirstName2__pc,';
        acctFields += 'Lastname2__pc,';
        acctFields += 'AttachedStore__pc,';
        acctFields += 'AttachedStoreCode__pc,';
        acctFields += 'Salutation,';
        acctFields += 'toLabel(Salutation)salutationLabel,';
        acctFields += 'NationalityCountryCode__pc,';
        acctFields += 'SPO_Country_code__pc,';
        acctFields += 'TypologyCode__pc,';
        acctFields += 'PreferredLanguage__pc,';
        acctFields += 'PassportNumber__pc,';
        acctFields += 'Company__pc,';
        acctFields += 'PrimaryAddressLine1__pc,';
        acctFields += 'PrimaryAddressLine2__pc,';
        acctFields += 'PrimaryAddressLine3__pc,';
        acctFields += 'PrimaryZipCode__pc,';
        acctFields += 'PrimaryCity__pc,';
        acctFields += 'SPO_Primary_Province_State__pc,';
        acctFields += 'PrimaryStateProvince__pc,';
        acctFields += 'HomePhoneCountryCode__pc,';
        acctFields += 'MobilePhoneCountryCode__pc,';
        acctFields += 'MobilePhoneCountryCallingCode__pc,';
        acctFields += 'WorkPhoneCountryCode__pc,';
        acctFields += 'LocalHomePhone__pc,';
        acctFields += 'LocalMobilePhone__pc,';
        acctFields += 'Phone,';
        acctFields += 'Can_Be_Contacted_By_Phone__pc,';
        acctFields += 'Can_Be_Contacted_By_SMS__pc,';
        acctFields += 'Can_Be_Contacted_By_Mail__pc,';
        acctFields += 'Can_Be_Contacted_By_Email__pc,';
        acctFields += 'PersonEmail,';
        acctFields += 'Status_RMSID__c,';
        acctFields += 'WW_RMSId__c,';
        acctFields += 'RMSId__pc,';
        acctFields += 'HomeAddressCountryCode__pc,';
        acctFields += 'DREAMID__c,';
        //@AyLame: CF-314 adding the new field C360GoldenID__c and masterC360GoldenID__c
        acctFields += 'C360GoldenID__c,';
        acctFields += 'masterC360GoldenID__c,';
        acctFields += 'LastModifiedDate,';
        acctFields += 'CreatedDate,';
        acctFields += 'PersonTitle,';
        acctFields += 'Gender__pc,';
        acctFields += 'Nationality__pc,';
        acctFields += 'Typology__pc,';
        acctFields += 'PersonBirthdate,';
        acctFields += 'Source__c,';
        acctFields += 'Title__pc,';
        acctFields += 'GenderCode__pc,';
        acctFields += 'SystemModstamp,';
        acctFields += 'LoginPhoneCallingCode__pc,';
        acctFields += 'PersonMobilePhone,';
        acctFields += 'PersonHomePhone,';
        acctFields += 'LocalWorkPhone__pc,';
        acctFields += 'CAName__c,';
        acctFields += 'PrimaryCountry__pc,';
        acctFields += 'AttachedStoreCountry__pc,';
        acctFields += 'TECH_OwnerManuallyChanged__c,';
        acctFields += 'TECH_ManualReassignmentDate__c,';
        acctFields += 'Store__pc,';        
        acctFields += 'Owner.WWEmployeeNumber__c,';
        
        
        
        
        
        return acctFields;
    }
    public static String getSocialFields(){
        return 'Id,Follow_Up_Date__c,Client__c,Opt_In__c,Social_Id__c,Social_Media_Type__c,Miniprogram_Source__c,CreatedDate,LastModifiedDate ';
    }
    
}