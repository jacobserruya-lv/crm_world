public with sharing class ICX_WS_NewsletterSubscription_Helper {


    public class requestBodySubscription {
        public String firstName;
        public String lastName;
        public String firstName2;
        public String lastName2;
        public String clientEmail;
        public String clientPhone;
        public String title;
        public String countryCode;
        public String nationalityCode;
        public String local;
        public String rmsId;
    }

    public class requestBodyUnsubscription {
        public String clientEmail;
        public String clientPhone;
        public String local;
    }

    public class responseClass {

        public Integer statusCode;
        public Boolean success;
        public String message;
        public String exceptionMessage;
    }

    public class MarketingCloudRequestBody{
        public String contactKey;	
        public String eventDefinitionKey;	
        public data data;
    }
    public class data {
        public String Email;	
        public String SubscriberKey;	
        public String Lastname;	
        public String FirstName;	
        public String Civility;
        public String MessageType;	
        public String CountryCode;	
        public String Language;	
        public String PreferredLanguage;	
        public String Channel;	
        public String HasMyLVAccount;	
        public String TriggeredDate;	
        public String EmailAddress;	
        public String MobilePhoneInternational;	
        public String URL;
        public String NewsLetterOptin; 	

    }
   
}