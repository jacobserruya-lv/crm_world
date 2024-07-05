/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-05-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class ICX_Client360_API_Helper {


	public class WrapperLabelValueList {
        @AuraEnabled
		public List<WrapperLabel_Value> item = new List<WrapperLabel_Value>() ;
        @AuraEnabled
        public String Id;
	}
    public class WrapperProductDetails {
        @AuraEnabled
		public List<WrapperLabel_Value> productDetails = new List<WrapperLabel_Value>() ;
        @AuraEnabled
        public String productImage;
        @AuraEnabled
        public String productName;
        @AuraEnabled
        public Integer Id;
    }

    public class WrapperAccountKeyInfo{
        @AuraEnabled
        public accountWrapper account;
        @AuraEnabled
        public WrapperLabelValueList clientKeyInfo;

    }


    public class WrapperClientInfo {
        

        @AuraEnabled
		public List<WrapperLabel_Value> clientInformation = new List<WrapperLabel_Value>() ;
        @AuraEnabled
		public List<WrapperLabel_Value> eventGift = new List<WrapperLabel_Value>() ;
        @AuraEnabled
		public List<WrapperLabel_Value> address1 = new List<WrapperLabel_Value>() ;
        @AuraEnabled
		public List<WrapperLabel_Value> address2 = new List<WrapperLabel_Value>() ;
        @AuraEnabled
		public List<WrapperLabel_Value> otherContactInformation = new List<WrapperLabel_Value>() ;
        @AuraEnabled
        public Integer Id;

	}
	public class WrapperLabel_Value {
        @AuraEnabled
		public String label;	
        @AuraEnabled
		public String value;
        @AuraEnabled
        public String type;
        @AuraEnabled	
        public String Id;
	}

    
public class CareServiceObject{
	public String careServiceNumber;	
	public String repaireNumber;	
	public String depositDate;	
	public String myRepairStatus;	
	public String sku;	
	public String productName;	
	public String productImage;	
 
}


public class SurveyObject{
	public String surveyNumber;	
	public String store;	
	public String surveyScore;	
	public String productName;	
	public String answerDate;	

}


public class CustomTagObject{
    public String tagsCateories;
    public String source;
    public String tagCreation;
 
}

public class ClientInformationsObject{
	public ClientInformation clientInformation;
	public EventGift eventGift;
	public Address address1;
	public Address address2;
    public OtherContactInformation otherContactInformation;

}

public class ClientInformation {
    public String clientName;	
    public String salutation;	
    public String age;	
    public String birthdate;	
    public String nationality;	
    public String contactPreference;
    public String lastSegmentation;	
    public String typology;	
    public String preferredCA;	
    public String attachedStore;	
    public String dreamdID;
    public String xStoreID;	
    public String passport;
    public String comment;
}
public class EventGift {
    public String invitedToAPCREvent;	
    public String giftsOfferedForThisClient;	
}
public class Address {
    public String addressLine1;	
    public String addressLine2;	
    public String addressLine3;	
    public String postalCode;	
    public String townCity;	
    public String provinceState;	
    public String country;	
    public String mail;	
}

public class OtherContactInformation {
    public String email;	
    public String phoneCountryCode;	
    public String homePhone;	
    public String workPhone;	
    public String mobilePhone;	
    public String canBeContactedByEmail;	
    public String canBeContactedByPhone;	
    public String canBeContactedBySMS;	
    public String preferredLanguage;	
}



public class SearchResultObject {
    public String clientName;
    public String firstName;
    public String lastName;
    public String salesforceId;	
    public String dreamID;	
    public String segmentation;	
    public String typology;	
    public String workPhone;	
    public String mobilePhone;	
    public String personalEmail;	
    public String postalCode;	
    public String birthdate;	
}


public class PurchasesProductsObj {
    public String datePurchased;
    public String type;
    public String storeName;
    public String category;
    public String sku;
    public String size;
    public String product;
    public String clientAdvisor;
    public String quantity;
    public String price;
    public String paymentMethode;
    public String transactionNumber;
    public String imageUrl;
}

public class productDetailsObj {
    public String designation;	
    public String techTransationConso;	
    public String techTransactionId;	
    public String sku;	
    public String currencyCode;	
    public String price;	
    public String convertedAmount;	
    public String productGender;
    public String productCategory;	
    public String line;	
    public String subline;	
    public String function;	
    public String subfunction;	
    public String ticketNumber;	
    public String transactionRmsId;	
    public String material;	
    public String purchasedDateTime;	
    public String totalTransactionAmount;	
    public String codeCourt;	
    public String storeRetailCode;	
    public String client;	
    public String CA;	
    public String caName;	
    public String store;	
    public String purchaseDate;	
    public String quantity;	
    public String season;	
    public String transactionClickCollect;	
    public String productImage;
    public String productName;
   
}




public class accountWrapper{
    @AuraEnabled
	public Boolean hasdateIdentity;
	@AuraEnabled
	public Boolean isActiveUser;
    @AuraEnabled
	public String firstName;
    @AuraEnabled
	public String lastName;	
    @AuraEnabled
	public String firstName2;	
    @AuraEnabled
	public String lastName2;	
    @AuraEnabled
	public String Name;
    @AuraEnabled
	public String salutation;	
    @AuraEnabled
	public String title;	
    @AuraEnabled
	public String dreamID;	
    @AuraEnabled
	public String country;	
    @AuraEnabled
	public String email;	
    @AuraEnabled
	public String myLVemail;	
    @AuraEnabled
	public String PersonMobilePhone;	
    @AuraEnabled
	public String PersonHomePhone;	
    @AuraEnabled
	public String Phone;	
    @AuraEnabled
	public boolean Can_Be_Contacted_By_Phone;
    @AuraEnabled
	public boolean Can_Be_Contacted_By_SMS;
    @AuraEnabled
	public boolean Can_Be_Contacted_By_Email;
    @AuraEnabled
	public boolean Can_Be_Contacted_By_Address;
    @AuraEnabled
	public String address;	
    @AuraEnabled
	public String Gender;	
    @AuraEnabled
	public String Gender_IMG;	
    @AuraEnabled
	public String Language_IMG;	
    @AuraEnabled
	public String Prefered_Language;	
    @AuraEnabled
	public String Parallel_Market_IMG;	
    @AuraEnabled
	public String greyMarketStatus;	
    @AuraEnabled
	public String greyMarketStatusDate;	
    @AuraEnabled
	public String Birthday_Cake_IMG;	
    @AuraEnabled
	public String birthdate;	
    @AuraEnabled
	public String age;	
    @AuraEnabled
	public boolean isUserIdentity;
    @AuraEnabled
	public String StoreName;	
    @AuraEnabled
	public String StoreID;	
    @AuraEnabled
	public String StoreRetailID;	
    @AuraEnabled
	public String OwnerName;	
    @AuraEnabled
	public String OwnerID;	
    @AuraEnabled
	public String segmentationClient;
    //displayedSegment: CF-298 [Client form] Display new segmentation
    @AuraEnabled
	public String displayedSegment;
    @AuraEnabled
	public String indic10KImg;	
    @AuraEnabled
	public String firstPurchaseDate;
    @AuraEnabled
	public String lastPurchaseDate;	
    @AuraEnabled
	public String lastContact;	
    @AuraEnabled
	public String lastActivity;
    @AuraEnabled
	public String lastActivityDate;
    @AuraEnabled
	public Boolean Subscribed_to_Digital_Concierge;
}

public class clientKeyInfoObj{
    @AuraEnabled
	public String XStoreID;	
    @AuraEnabled
	public String Type;	
    @AuraEnabled
	public String Typology;	
    @AuraEnabled
	public String Nationality;	
    @AuraEnabled
	public String Birthdate;	
    @AuraEnabled
	public String Gender;	
    @AuraEnabled
	public String Email;	
    @AuraEnabled
	public String MobilePhone;	
    @AuraEnabled
	public String Address;	
    @AuraEnabled
	public String Country;
}

public class OrderWrapper{
    @AuraEnabled
	public String Id;
    @AuraEnabled
	public Datetime orderDate;
    @AuraEnabled
	public String orderNumber;		
    @AuraEnabled
	public String sku;	
    @AuraEnabled
	public String storeName;
    @AuraEnabled
	public String retailStoreId;	
    @AuraEnabled
	public String status;		
    @AuraEnabled
	public String productImage;
    @AuraEnabled
	public String type;

}



public static ICX_Client360_API_Helper.WrapperLabel_Value Create_WrapperLabel_Value(String label, String value,String type)
{
    ICX_Client360_API_Helper.WrapperLabel_Value currentWrapperLabel_Value = new ICX_Client360_API_Helper.WrapperLabel_Value();
    currentWrapperLabel_Value.label =label;
    currentWrapperLabel_Value.value = value;
    

    currentWrapperLabel_Value.type =  type;
    currentWrapperLabel_Value.Id = ICX_Utils.getUUID();             


    return currentWrapperLabel_Value;
}

// All classes to provide the profile data // 

public class profileObj
{
    public codeLabel clientType;
	public String greyMarketStatus;	
	public emailAddress emailAddress;
	public residencePostalAddress residencePostalAddress;
	public codeLabel preferredLanguage;
	public boolean isGloballyOptin;
	public clientAdvisorForcedAttachment clientAdvisorForcedAttachment;
	public boolean isOptinToReceiveMails;
	public boolean isOptinToReceiveMarketingEmails;
	public storeWhereClientWasCreated storeWhereClientWasCreated;
	public storeWhereClientWasLastModified storeWhereClientWasLastModified;
	public boolean canBeContactedByMail;
	public String[] passportNumbers;	
	public boolean is50kytm;
	// public Integer historicalTurnOverUsd;	
	public boolean canBeContactedByEmail;
	public String firstTransactionDate;	
	public boolean isOptinToReceiveSms;
	public String lastName2;	
	public String isChineseTraveller;	
	// public residencePostalAddress[] deliveryPostalAddresses;	
	public identifiers identifiers;
	public String lastName;	
	public String birthDate;	
	public boolean isOptinToReceiveNewsletterEmails;
	public PhoneNumber mobilePhoneNumber;
	// public Integer historicalTurnOverEuro;	
	public String lastTransactionDate;	
	public boolean is10kytm;
	public boolean isOptinToReceiveCalls;
	public codeLabel title;
	//public String productIdentificationNumbers;	
	public String dseCreationTimestamp;
	// public residencePostalAddress[] billingPostalAddresses;	
	public codeLabel civility;
	public String firstName;	
	public String greyMarketStatusDate;	
	public account[] accounts;	
	public boolean isPep;
	// public Integer historicalTurnOverYen;	
	public String interestsCalculated;	
	public attachment attachment;
	public boolean canBeContactedBySms;
	public boolean isOptinToReceiveRepairCaseEmails;
	public boolean hasSharedEmail;
	// public socialMediaConsents socialMediaConsents;	
	public PhoneNumber homePhoneNumber;
	public PhoneNumber workPhoneNumber;
	public String modificationDate;	
	public boolean isActiveInSalesForce;
	public boolean is50k;
	public String segmentation;	
	public String sifNumbers;	
	public boolean canBeContactedByPhoneCall;
	public String dseModificationTimestamp;	
	// public Integer historicalTurnOverYuan;	
	public boolean hasHardside;
	public String lastContactDate;	
	// public residencePostalAddress[] otherPostalAddresses;	
	public String creationDate;	
	public boolean isACelebrity;
	public boolean hasSharedPhone;
	// public auditTrail auditTrail;
	public String firstName2;	
	public boolean isSignificantClient;
	public codeLabel gender;
	public boolean canBeReachedGlobally;
	// public String interestCenterClientAdvisorPlaces;	
	public codeLabel nationality;
	public storeForcedAttachment storeForcedAttachment;
	public String[] fiscalNumbers;
	// public String channelSubscriptions;	
    // public channelSubscriptions[] channelSubscriptions;

}
	class channelSubscriptions {
		public codeLabel channel;
		public String subscriptionDate;	
	}

public class account {
    public String emailAddress;
    public String creationDate;
    public String lastLoginDate;
}

public class emailAddress {
    public String emailAddress;	
}
public class residencePostalAddress {
    // public String id;	
    public String addressLine1;	
    public String addressLine2;	
    public String addressLine3;	
    public String postalCode;	
    public String city;	
    public String state;	
    public String countryCodeIso;	
    public Integer stateStatus;
}

public class clientAdvisorForcedAttachment {
    public clientAdvisor clientAdvisor;
    public String forcedAttachmentDate;	
}
public class clientAdvisor {
    public String worldwideId;	
    public String name;	
}
public class storeWhereClientWasCreated {
    public String code;	
    public String label;	
    public String countryCodeIso;	
}
public class storeWhereClientWasLastModified {
    public String code;	
    public String label;	
    public String countryCodeIso;	
}
public class identifiers {
    public String c360GoldenId;
    public String salesforceId;	
    public String atgId;	
    public String dreamId;	
    public String userIdentitySalesforceId;	
    public String worldwideId;	
    public rmsLocalIds[] rmsLocalIds;
}
public class rmsLocalIds {
    public String rmsLocalId;	
    public String countryCodeIso;	
}
public class PhoneNumber {
    public String phoneNumber;	
    public String countryCodeIso;	
    public String internationalPrefix;	
}
public class codeLabel {
    public String code;	
    public String label;	
}

public class attachment {
    public clientAdvisor clientAdvisor;
    public String forcedAttachmentDate;	
    public String forcedAttachmentStore;
    public String forcedAttachmentStoreCountryCodeIso;
}

public class auditTrail {
    public String sourceApplicationCode;	
    public String touchApplicationCode;	
    public String touchApplicationLabel;	
    public String userLogin;	
    public String userName;	
    public String clientTimestamp;	
    public String storeCode;	
    public String countryCodeIso;	
    public String clientServiceCenterCode;	
    public String deviceNumber;	
}


public class storeForcedAttachment {
    public store store;
    public String forcedAttachmentDate;	
}
public class store {
    public String code;	
    public String label;	
    public String countryCodeIso;	
}


// THe next four classes provide the purchases data

public class purchasesWrapper{
    @AuraEnabled
    public List<purchases> purchases = new List<purchases>();
    @AuraEnabled
    public String refSaleID;
}
public class purchases{
    @AuraEnabled
    public String productName;
    @AuraEnabled
    public String purchasedProductDate;
    @AuraEnabled
    public String type;
    @AuraEnabled
    public String StoreName;
    @AuraEnabled
    public String categorie;
    @AuraEnabled
    public String sku;
    @AuraEnabled
    public String size;
    @AuraEnabled
    public String article;
    @AuraEnabled
    public String OwnerName;
    @AuraEnabled
    public String quantity;
    @AuraEnabled
    public String sales;
    @AuraEnabled
    public String currencyCode;
    @AuraEnabled
    public String paymentMethod;
    @AuraEnabled
    public String transactionNumber;
    @AuraEnabled
    public String productImage;
 

}
public class purchasesObj{
	public String returnCode;	
	public String errorMessage;	
	public String lastRecord;	
	public String firstRecord;	
	public String nbrRcrdRetrieved;	
	public String numberOfRecords;	
	public data[] data;
    
}
public class data {
    public String wwsid;	
    public String purchaseDate;	
    public String purchaseType;	
    public String purchaseStoreCode;	
    public String purchaseStorelabel;	
    public String purchaseStoreCountry;	
    public String ticketNumber;	
    public String salesCurrency;	
    public purchaseDetail[] purchaseDetail;
    public paymentMethod[] paymentMethod;
}
public class purchaseDetail {
    public Integer purchaseDetailLineNumber;	
    public String purchaseType;	
    public String productSKU;	
    public Integer quantity;	
    public String clientAdvisorWWid;	
    public Integer amountTTC;	
    public Integer amountHT;	
    public product product;

}

public class product {
    public String name;	
    public String image;	
    public String identifier;	
    public String size;	
    public String url;	
    public String[] categoryIdentifier;
}
public class paymentMethod {
    public String paymentMode;	
}


//error

public class errorObj{
	public Integer status;	
	public String responseId;	
	public String transactionDate;		
    public errorData data;
}
public class errorData {
		public String errorCode;	
		public String errorType;	
		public String errorDescription;	
	}

public class Client360Exception extends Exception {
}

public class SurveyWrapper{
    @AuraEnabled
	public String id;
    @AuraEnabled
	public String createdDate;
    @AuraEnabled
	public String surveyType;		
    @AuraEnabled
	public Decimal globalScore;	
    @AuraEnabled
	public Decimal CAScore;	
    @AuraEnabled
	public String CAName;
    @AuraEnabled
	public String advisorCSRole;
    @AuraEnabled
	public String storeName;	
    @AuraEnabled
	public String status;		
    @AuraEnabled
	public String clientName;		
    @AuraEnabled
	public String segmentation;		

}



}