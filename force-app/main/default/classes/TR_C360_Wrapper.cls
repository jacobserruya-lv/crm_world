/***************************************************************************************************
* @File Name          : TR_C360_Utils.cls
* @Description        : This class was created for the C360 project 
* @Author             : Imad.alsidchikh@vo2-consultant.com
* @Group              : VO2
* @Last Modified By   : Imad.alsidchikh@vo2-consultant.com
* @Last Modified On   : 02-22-2022
* @Modification Log   :
* Ver       Date               Author                                 Modification
* 1.0       03-07-2022        Imad.alsidchikh@vo2-group.com           Initial Version
* 1.1       21-05-2024        ayoub.lameghaizi.ext@louisvuitton.com   Adding the new fields C360goldenId & masterC360GoldenId
*****************************************************************************************************/
public class TR_C360_Wrapper {
    public String isOptInToReceiveMarketingEmails{get;set;}
    public String emailAddress{get;set;}
    public String workPhoneNumber_number{get;set;}
    public String passportNumber{get;set;}
    public String workPhoneNumber_countryCodeIso2{get;set;}
    public String clientType_label{get;set;}
    public String workPhoneNumber_international{get;set;}
    public String clientType_code{get;set;}
    public String homePhoneNumber_number{get;set;}
    public String preferredLanguage_code{get;set;}
    public String homePhoneNumber_countryCodeIso2{get;set;}
    public String nationality_code{get;set;}
    public String homePhoneNumber_international{get;set;}
    public String nationality_label{get;set;}
    public String mobilePhoneNumber_number{get;set;}
    public String civility_code{get;set;}
    public String mobilePhoneNumber_countryCodeIso2{get;set;}
    public String gender_label{get;set;}
    public String mobilePhoneNumber_international{get;set;}
    public String gender_code{get;set;}
    public String mobilePhoneNumber_internationalPrefix{get;set;}
    public String title_code{get;set;}
    public String isOptInToReceiveSms{get;set;}
    public String birthDate{get;set;}
    public String isOptInToReceiveCalls{get;set;}
    public String firstName2{get;set;}
    public String isOptInToReceiveMails{get;set;}
    public String lastName2{get;set;}
    public String residencePostalAddress_addressLine1{get;set;}
    public String firstName{get;set;}
    public String residencePostalAddress_addressLine2{get;set;}
    public String lastName{get;set;}
    public String residencePostalAddress_addressLine3{get;set;}
    public String toDelete{get;set;}
    public String residencePostalAddress_countryCodeIso3{get;set;}
    public String masterDreamId{get;set;}
    public String masterSalesforceId{get;set;}
    public String residencePostalAddress_state{get;set;}
    public String dreamId{get;set;}
    public String residencePostalAddress_city{get;set;}
    public String worldwideId{get;set;}
    public String residencePostalAddress_postalCode{get;set;}
    public String salesforceId{get;set;}
    public String creationDate{get;set;}
    public String residencePostalAddress_country{get;set;}
    public String clientTimestamp{get;set;}
    public String touchApplicationCode{get;set;}
    public String requesting_location  {get;set;}
    public String countryCodeIso {get;set;}
    public String c360GoldenId {get;set;}
    public String masterC360GoldenId {get;set;}
    
    public static TR_C360_Wrapper parse(String json){
        return (TR_C360_Wrapper) System.JSON.deserialize(json, TR_C360_Wrapper.class);
    }
}