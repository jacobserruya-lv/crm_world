/***************************************************************************************************
* @File Name          : TR_c360_wrapper_Test.cls
* @Description        : This class was created for the C360 project 
* @Author             : Frank PP
* @Group              : VO2
* @Last Modified By   : Imad.alsidchikh@vo2-consultant.com
* @Last Modified On   : 08-31-2022
* @Modification Log   :
* Ver       Date               Author                            Modification
* 1.0       08-22-2022        Frank PP                            Initial Version
*****************************************************************************************************/

@isTest
public class TR_C360_Wrapper_TEST {
    
    static testMethod void myUnitTest() {
        TR_C360_Wrapper c360wrapper = new TR_C360_Wrapper();
        c360wrapper.isOptInToReceiveMarketingEmails='true';
        c360wrapper.emailAddress='test@email.com';
        c360wrapper.workPhoneNumber_number='07899999';
        c360wrapper.passportNumber='07899999';
        c360wrapper.workPhoneNumber_countryCodeIso2='FR';
        c360wrapper.clientType_label='test';
        c360wrapper.workPhoneNumber_international='test@email.com';
        c360wrapper.clientType_code='test@email.com';
        c360wrapper.homePhoneNumber_number='test@email.com';
        c360wrapper.preferredLanguage_code='test@email.com';
        c360wrapper.homePhoneNumber_countryCodeIso2='test@email.com';
        c360wrapper.nationality_code='test@email.com';
        c360wrapper.homePhoneNumber_international='test@email.com';
        c360wrapper.nationality_label='test@email.com';
        c360wrapper.mobilePhoneNumber_number='test@email.com';
        c360wrapper.civility_code='test@email.com';
        c360wrapper.mobilePhoneNumber_countryCodeIso2='test@email.com';
        c360wrapper.title_code='test@email.com';
        c360wrapper.birthDate='test@email.com';
        c360wrapper.isOptInToReceiveCalls='test@email.com';
        c360wrapper.firstName2='test@email.com';
        c360wrapper.gender_label='test@email.com';
        c360wrapper.mobilePhoneNumber_international='test@email.com';
        c360wrapper.gender_code='test@email.com';
        c360wrapper.mobilePhoneNumber_internationalPrefix='test@email.com';
        c360wrapper.isOptInToReceiveMails='test@email.com';
        c360wrapper.lastName2='test@email.com';
        c360wrapper.residencePostalAddress_addressLine1='test@email.com';
        c360wrapper.firstName='test@email.com';
        c360wrapper.residencePostalAddress_addressLine2='test@email.com';
        c360wrapper.lastName='test@email.com';
        c360wrapper.residencePostalAddress_addressLine3='test@email.com';
        c360wrapper.toDelete='test@email.com';
        c360wrapper.residencePostalAddress_countryCodeIso3='test@email.com';
        c360wrapper.masterDreamId='test@email.com';
        c360wrapper.residencePostalAddress_state='test@email.com';
        c360wrapper.dreamId='test@email.com';
        c360wrapper.residencePostalAddress_city='test@email.com';
        c360wrapper.worldwideId='test@email.com';
        c360wrapper.residencePostalAddress_postalCode='test@email.com';
        c360wrapper.salesforceId='test@email.com';
        c360wrapper.creationDate='test@email.com';
        c360wrapper.residencePostalAddress_country='test@email.com';
        c360wrapper.clientTimestamp='test@email.com';
        c360wrapper.touchApplicationCode='test@email.com';
                c360wrapper.isOptInToReceiveSms='test@email.com';
            String json='{"Zip_Code":null}';
        TR_C360_Wrapper.parse(json);


        
    }

}