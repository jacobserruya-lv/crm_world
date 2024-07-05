public class IxopayNotificationJson{
	public String result;	//OK
    public String message;	//STOLEN_CARD
	public String code;	//2016
	public String adapterMessage;	//Transaction was rejected
	public String adapterCode;	//1234
	public String uuid;	//524fea6f5ed864b06741
	public String merchantTransactionId;	//20230413155356
	public String purchaseId;	//20230525-524fea6f5ed864b06741
	public String transactionType;	//PREAUTHORIZE
	public String paymentMethod;	//Creditcard
	public String amount;	//9.99
	public String currency_x;	//EUR
	public String merchantMetaData;	//00002711
	public cls_customer customer;
	public cls_returnData returnData;

public class cls_customer {
    public String identification;	//00003001
    public String firstName;	//Max
    public String lastName;	//Mustermann
    public String billingPhone;	//0679258098
    public String billingAddress1;	//3 rue Bailleul
    public String billingCity;	//Paris
    public String billingPostcode;	//75001
    public String billingState;	//Ile-de-france
    public String billingCountry;	//FR
    public String shippingFirstName;	//Max
    public String shippingLastName;	//Mustermann
    public String shippingAddress1;	//3 rue Bailleul
    public String shippingCity;	//Paris
    public String shippingPostcode;	//75001
    public String shippingState;	//Ile-de-france
    public String shippingCountry;	//EN
    public String email;	//Max.Mustermann.ext@louisvuitton.com
    public String ipAddress;	//165.225.20.239
}
public class cls_returnData {
    public String x_TYPE;	//cardData
    public String type;	//visa
    public String cardHolder;	//marouen bachoual
    public String expiryMonth;	//05
    public String expiryYear;	//2023
    public String binDigits;	//41111111
    public String firstSixDigits;	//411111
    public String lastFourDigits;	//1111
    public String fingerprint;	//FNjYSZpHtQLgKuqvvOJ7+u+cmvgRets0jEwL1SZrgXXvPTPiPYlqb9oSy+ps7OB9HwLZYFx3SK05Zl5saVHMsA
	public String threeDSecure; //OFF
    public String eci;	//05
    public String binBrand;	//VISA
    public String binBank;	//JPMORGAN CHASE BANK N.A.
    public String binType;	//
    public String binLevel;	//
    public String binCountry;	//US
}
}