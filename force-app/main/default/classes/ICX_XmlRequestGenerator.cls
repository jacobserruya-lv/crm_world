/*@author Keman WU
* @date creation 04/08/2021
* @description Generate XML request body
*/
public class ICX_XmlRequestGenerator {      
    public static Dom.Document doc;
    public static Dom.XMLNode envelope;
    public static Dom.XMLNode header;
    public static Dom.XMLNode security;
    public static Dom.XMLNode usernameToken;
    public static Dom.XMLNode parameters;
    public static Dom.XMLNode body;
    public static Dom.XMLNode ShippingParameter;
    
    public static String SOAPENV_NAMESPACE = 'http://schemas.xmlsoap.org/soap/envelope/';
    public static String SOAPENV_PREFIX_METAPACK = 'SOAP-ENV';
    public static String SOAPENV_PREFIX_MYREPAIR = 'soapenv';   
    
    public static String SECURITY_NAMESPACE = 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd';
    public static String SECURITY_PREFIX = 'wsse';
    
    public static String TNS_NAMESPACE = 'http://xlogics.eu/blackbox';
    public static String TNS_PREFIX = 'tns';

    public static String WEB_NAMESPACE = 'http://www.atg.com/webservices';
    public static String WEB_PREFIX = 'web';
    
    //[select id,ICONiCS_Status_Detail__c,TransactionId__c,Dangerous_Product__c,Parcel_Length__c,Parcel_Height__c,Parcel_Width__c,SKU__c,CurrencyCode__c,Product_Sku_unknown__c,Category__c,packingListNumber__c,StoreRetailCode__c,Client__r.LastName, Client__r.FirstName, Shipping_Address_Line_1__c, Shipping_Address_Line_2__c, Shipping_Address_Line_3__c, Shipping_Zip_Postal_Code__c, Shipping_City__c, Shipping_State_Province__c, Shipping_Country__c, Client__r.PersonMobilePhone, Client__r.PersonHomePhone, Client__r.PersonEmail,Product__r.Price__c from CareService__c where id='a1I3D000000fXtTUAU'];
    public static String MetapackRequestBuilder(String action, CareService__c Care) {
        ICX_Repair_Store__mdt repairStore = ICX_Repair_Store__mdt.getInstance(String.valueOf(care.get('StoreRetailCode__c')));
        ICX_Repair_Center__mdt repairCenter = ICX_Repair_Center__mdt.getInstance(String.valueOf(care.get('StoreRetailCode__c'))+String.valueOf(care.get('Destination__c')));
       
        // Created SOAP envelope
        doc = new Dom.Document();
        envelope = doc.createRootElement('Envelope', SOAPENV_NAMESPACE, SOAPENV_PREFIX_METAPACK);
        
        // Created SOAP Header
        header = envelope.addChildElement('Header', SOAPENV_NAMESPACE, SOAPENV_PREFIX_METAPACK);
        security = header.addChildElement('Security', SECURITY_NAMESPACE, SECURITY_PREFIX);
        // security.setAttribute(SECURITY_PREFIX2, SECURITY_NAMESPACE2);
        // security.setAttribute('SOAP-ENV:mustUnderstand', '1');
        usernameToken = security.addChildElement('UsernameToken', SECURITY_NAMESPACE, SECURITY_PREFIX);
        // usernameToken.setAttribute('wsu:Id', 'UsernameToken-6458');
        usernameToken.addChildElement('Username', SECURITY_NAMESPACE, SECURITY_PREFIX).addTextNode(repairStore.Username__c);
        usernameToken.addChildElement('Password', SECURITY_NAMESPACE, SECURITY_PREFIX).addTextNode(repairStore.Password__c);
        
        // Created SOAP Body
        body = envelope.addChildElement('Body', SOAPENV_NAMESPACE, SOAPENV_PREFIX_METAPACK);
        String req = null;
        if(action=='ImportData'){
            
            parameters = body.addChildElement('ImportDataMultiRequest', TNS_NAMESPACE, TNS_PREFIX).addChildElement('InputParameters', TNS_NAMESPACE, TNS_PREFIX).addChildElement('ImportItem', TNS_NAMESPACE, TNS_PREFIX).addChildElement('Parameters', TNS_NAMESPACE, TNS_PREFIX);
            
            if(care.get('ICONiCS_Status_Detail__c')=='Preliminary Quote Validated'){
                
                //Sender(Client) info                
                if(care.get('Shipping_Address_Last_Name__c')!=null)
                createElementAndTextNodeMetapack('Receiver.Name1',care.get('Shipping_Address_Last_Name__c'));
                else
                createElementAndTextNodeMetapack('Receiver.Name1',care.getSobject('Client__r').get('LastName'));
                if(care.get('Shipping_Address_First_Name__c')!=null)
                createElementAndTextNodeMetapack('Receiver.Name2',care.get('Shipping_Address_First_Name__c'));
                else
                createElementAndTextNodeMetapack('Receiver.Name2',care.getSobject('Client__r').get('FirstName'));

                createElementAndTextNodeMetapack('Receiver.Street',care.get('Shipping_Address_Line_1__c'));
                createElementAndTextNodeMetapack('Receiver.Building',care.get('Shipping_Address_Line_2__c'));
                createElementAndTextNodeMetapack('Receiver.AddressDetails',care.get('Shipping_Address_Line_3__c'));
                createElementAndTextNodeMetapack('Receiver.Postcode',care.get('Shipping_Zip_Postal_Code__c'));
                createElementAndTextNodeMetapack('Receiver.City',care.get('Shipping_City__c'));
                createElementAndTextNodeMetapack('Receiver.Province',care.get('Shipping_State_Province__c'));
                createElementAndTextNodeMetapack('Receiver.Country',care.get('Shipping_Country__c'));
                createElementAndTextNodeMetapack('Receiver.Mobile',care.getSobject('Client__r').get('PersonMobilePhone'));
                createElementAndTextNodeMetapack('Receiver.Telephone',care.getSobject('Client__r').get('PersonHomePhone'));
                createElementAndTextNodeMetapack('Receiver.Email',care.getSobject('Client__r').get('PersonEmail'));
                
                //Repair Center info
               
                createElementAndTextNodeMetapack('Sender.RefNo',repairCenter.Store__c);   
                createElementAndTextNodeMetapack('Sender.CompanyName',repairCenter.Name__c);  
                createElementAndTextNodeMetapack('Sender.Name1',repairCenter.Name__c);                              
                createElementAndTextNodeMetapack('Sender.Street',repairCenter.Address__c); 
                createElementAndTextNodeMetapack('Sender.Postcode',repairCenter.Zip__c);
                createElementAndTextNodeMetapack('Sender.City',repairCenter.City__c);
                createElementAndTextNodeMetapack('Sender.Province',repairCenter.State__c);
                createElementAndTextNodeMetapack('Sender.Country',repairCenter.Country__c);                
                createElementAndTextNodeMetapack('Sender.Telephone',repairCenter.Phone__c);
                createElementAndTextNodeMetapack('Sender.Telephone',repairCenter.Email__c);
                //BusinessParameters
                createElementAndTextNodeMetapack('DeliveryType','RC');
                
           } else if(care.get('ICONiCS_Status_Detail__c')=='Payment Confirmed'){
                //Sender(Repair Center) info
                
                createElementAndTextNodeMetapack('Sender.RefNo',repairCenter.Store__c);   
                createElementAndTextNodeMetapack('Sender.CompanyName',repairCenter.Name__c);                
                createElementAndTextNodeMetapack('Sender.Street',repairCenter.Address__c); 
                createElementAndTextNodeMetapack('Sender.Postcode',repairCenter.Zip__c);
                createElementAndTextNodeMetapack('Sender.City',repairCenter.City__c);
                createElementAndTextNodeMetapack('Sender.Province',repairCenter.State__c);
                createElementAndTextNodeMetapack('Sender.Country',repairCenter.Country__c);                
                createElementAndTextNodeMetapack('Sender.Telephone',repairCenter.Phone__c); 
                createElementAndTextNodeMetapack('Sender.Telephone',repairCenter.Email__c);

                //Receiver(Client) info
                if(care.get('Shipping_Address_Last_Name__c')!=null)
                createElementAndTextNodeMetapack('Receiver.Name1',care.get('Shipping_Address_Last_Name__c'));
                else
                createElementAndTextNodeMetapack('Receiver.Name1',care.getSobject('Client__r').get('LastName'));
                if(care.get('Shipping_Address_First_Name__c')!=null)
                createElementAndTextNodeMetapack('Receiver.Name2',care.get('Shipping_Address_First_Name__c'));
                else
                createElementAndTextNodeMetapack('Receiver.Name2',care.getSobject('Client__r').get('FirstName'));

               
                createElementAndTextNodeMetapack('Receiver.Street',care.get('Shipping_Address_Line_1__c'));
                createElementAndTextNodeMetapack('Receiver.Building',care.get('Shipping_Address_Line_2__c'));
                createElementAndTextNodeMetapack('Receiver.AddressDetails',care.get('Shipping_Address_Line_3__c'));
                createElementAndTextNodeMetapack('Receiver.Postcode',care.get('Shipping_Zip_Postal_Code__c'));
                createElementAndTextNodeMetapack('Receiver.City',care.get('Shipping_City__c'));
                createElementAndTextNodeMetapack('Receiver.Province',care.get('Shipping_State_Province__c'));
                createElementAndTextNodeMetapack('Receiver.Country',care.get('Shipping_Country__c'));
                createElementAndTextNodeMetapack('Receiver.Mobile',care.getSobject('Client__r').get('PersonMobilePhone'));
                createElementAndTextNodeMetapack('Receiver.Telephone',care.getSobject('Client__r').get('PersonHomePhone'));
                createElementAndTextNodeMetapack('Receiver.Email',care.getSobject('Client__r').get('PersonEmail'));              
                 //BusinessParameters
                createElementAndTextNodeMetapack('DeliveryType','HD');

                //CSC-376 Japan Send Total Amount and Currency 
                if(care.get('StoreRetailCode__c') == 'VJ3' && care.get('TotalAmountWithTax__c') != null){
                    createElementAndTextNodeMetapack('Shipment.CODAmount',care.get('TotalAmountWithTax__c'));
                    createElementAndTextNodeMetapack('Shipment.CODCurrency','JPY');
                }
            }
            
            
            //parcel info                 
            createElementAndTextNodeMetapack('Parcel.RefNo',care.get('TransactionId__c'));
            //Product info
            createElementAndTextNodeMetapack('Product.Code.1',care.get('SKU__c'));
            createElementAndTextNodeMetapack('Product.Value.1',care.get('Package_Declared_Value__c'));
            createElementAndTextNodeMetapack('Product.ValueCurrency.1',care.get('CurrencyCode__c'));
            createElementAndTextNodeMetapack('Product.Quantity.1', 1);                 
            createElementAndTextNodeMetapack('Product.Description.1',care.get('Product_Sku_unknown__c'));
            createElementAndTextNodeMetapack('Product.TypeDescription.1',care.get('Category__c'));
            //Shipment info
            createElementAndTextNodeMetapack('Shipment.RefNo','REPAIR'+system.now().format('yyyyMMdd'));           
            //BusinessParameters
            createElementAndTextNodeMetapack('Channel','Repairs');            
            createElementAndTextNodeMetapack('Service','SD');
            createElementAndTextNodeMetapack('packinglist',care.get('packingListNumber__c'));

            req = doc.toXmlString();
            system.debug('### ImportData Request Body : '+req) ;
            
        }else if(action=='UpdateImportedDataSendAndPrint'){
            parameters = body.addChildElement('UpdateImportedDataSendAndPrintRequest', TNS_NAMESPACE, TNS_PREFIX).addChildElement('InputParameters', TNS_NAMESPACE, TNS_PREFIX);
            createElementAndTextNodeMetapack('Shipment.Selection','Parcel.RefNo');
            createElementAndTextNodeMetapack('Shipment.Identifier',care.get('TransactionId__c'));
            createElementAndTextNodeMetapack('Shipment.DangerousGoods',care.get('Dangerous_Product__c'));
            createElementAndTextNodeMetapack('Printer','NOPRINT');
            createElementAndTextNodeMetapack('Parcel.Weight',1);
            createElementAndTextNodeMetapack('Parcel.Length',care.get('Parcel_Length__c'));
            createElementAndTextNodeMetapack('Parcel.Width',care.get('Parcel_Width__c'));
            createElementAndTextNodeMetapack('Parcel.Height',care.get('Parcel_Height__c'));
            createElementAndTextNodeMetapack('Service','SD');
            createElementAndTextNodeMetapack('ImportData.DeleteAfterSend',true);
            req = doc.toXmlString();
            system.debug('### UpdateImportedDataSendAndPrint Request Body : '+req) ;

        }
      
       return req;
    }
    
    public static void createElementAndTextNodeMetapack(String name, Object value) {
        if (value != null) {
            ShippingParameter = parameters.addChildElement('ShippingParameter', TNS_NAMESPACE, TNS_PREFIX);
            ShippingParameter.addChildElement('Name', TNS_NAMESPACE, TNS_PREFIX).addTextNode((String) name);
            if (value instanceof String) {                
                ShippingParameter.addChildElement('Value', TNS_NAMESPACE, TNS_PREFIX).addTextNode((String) value);
            } else if (value instanceof Date) {
                Date d = (Date) value;
                DateTime dt = DateTime.newInstance(d.year(), d.month(), d.day());
                ShippingParameter.addChildElement('Value', TNS_NAMESPACE, TNS_PREFIX).addTextNode(dt.format('yyyy-MM-dd\'T\'HH:mm:ss'));
            } else if (value instanceof Decimal) {
                Decimal dc = (Decimal) value;
                ShippingParameter.addChildElement('Value', TNS_NAMESPACE, TNS_PREFIX).addTextNode(String.valueOf(dc));
            } else if (value instanceof Boolean) {
                Boolean b = (Boolean) value;
                ShippingParameter.addChildElement('Value', TNS_NAMESPACE, TNS_PREFIX).addTextNode(String.valueOf(b));
            } 
        }
    }
    
    public static String MyRepairRequestBuilder(String action, CareService__c Care) {
        
        doc = new Dom.Document();
        String req = null;
        envelope = doc.createRootElement('Envelope', SOAPENV_NAMESPACE, SOAPENV_PREFIX_MYREPAIR);
        envelope.setAttribute('xmlns:web',WEB_NAMESPACE);
        envelope.setAttribute('soapenv:encodingStyle','http://schemas.xmlsoap.org/soap/encoding/');
        if(action=='handleSalesForceOrder'){
         // Created SOAP Body
         Dom.XMLNode CustomerInformation = envelope.addChildElement('Body', SOAPENV_NAMESPACE, SOAPENV_PREFIX_MYREPAIR).addChildElement('handleSalesForceOrder',WEB_NAMESPACE,WEB_PREFIX).addChildElement('pSalesForceOrderCustomerInformationImpl', null, null);
        createElementAndTextNodeMyRepair(CustomerInformation,'address1',care.get('Shipping_Address_Line_1__c'));
        createElementAndTextNodeMyRepair(CustomerInformation,'address2',care.get('Shipping_Address_Line_2__c'));       
        createElementAndTextNodeMyRepair(CustomerInformation,'zipCode',care.get('Shipping_Zip_Postal_Code__c'));
        createElementAndTextNodeMyRepair(CustomerInformation,'city',care.get('Shipping_City__c'));
        createElementAndTextNodeMyRepair(CustomerInformation,'countryState',care.get('Shipping_State_Province__c'));
        createElementAndTextNodeMyRepair(CustomerInformation,'countryCodeIso2',care.get('Shipping_Country__c'));        
        createElementAndTextNodeMyRepair(CustomerInformation,'email',care.getSobject('Client__r').get('PersonEmail'));
        if(care.getSobject('Client__r').get('Salutation')!=null)
            createElementAndTextNodeMyRepair(CustomerInformation,'civility',care.getSobject('Client__r').get('Salutation'));
        else
        createElementAndTextNodeMyRepair(CustomerInformation,'civility','02');           
        createElementAndTextNodeMyRepair(CustomerInformation,'atgId',care.getSobject('Client__r').get('ECO_ClientId__c'));
        createElementAndTextNodeMyRepair(CustomerInformation,'familyName', care.getSobject('Client__r').get('LastName'));
        createElementAndTextNodeMyRepair(CustomerInformation,'familyName2',care.getSobject('Client__r').get('Lastname2__pc'));
        createElementAndTextNodeMyRepair(CustomerInformation,'givenName',care.getSobject('Client__r').get('FirstName'));
        createElementAndTextNodeMyRepair(CustomerInformation,'givenName2',care.getSobject('Client__r').get('Firstname2__pc'));
        createElementAndTextNodeMyRepair(CustomerInformation,'homePhoneNumber',care.getSobject('Client__r').get('PersonHomePhone'));
        createElementAndTextNodeMyRepair(CustomerInformation,'homePhoneNumberCountryCodeIso2',care.getSobject('Client__r').get('HomePhoneCountrycode__pc'));
        createElementAndTextNodeMyRepair(CustomerInformation,'nationality',care.getSobject('Store__r').get('Store_CountryCode__c'));
        createElementAndTextNodeMyRepair(CustomerInformation,'phoneNumber',care.getSobject('Client__r').get('PersonMobilePhone'));
        createElementAndTextNodeMyRepair(CustomerInformation,'phoneNumberCountryCodeIso2',care.getSobject('Client__r').get('MobilePhoneCountryCode__pc'));
        if(care.getSobject('Client__r').get('AttachedStoreCode__pc')!=null)
        createElementAndTextNodeMyRepair(CustomerInformation,'rmsCountryClientCode',care.getSobject('Client__r').get('AttachedStoreCode__pc')); 
        else
        createElementAndTextNodeMyRepair(CustomerInformation,'rmsCountryClientCode',care.getSobject('Client__r').get('AttachedStore__pc')); 
        createElementAndTextNodeMyRepair(CustomerInformation,'rmsCountryClientId',care.getSobject('Client__r').get('RMSId__pc')); 
        createElementAndTextNodeMyRepair(CustomerInformation,'workPhoneNumber',care.getSobject('Client__r').get('Phone'));
        createElementAndTextNodeMyRepair(CustomerInformation,'workPhoneNumberCountryCodeIso2',care.getSobject('Client__r').get('WorkPhoneCountryCode__pc'));
    

        Dom.XMLNode OrderInformation = CustomerInformation.addChildElement('salesForceOrderInformation', null, null);
        createElementAndTextNodeMyRepair(OrderInformation,'creationDate', care.get('CreatedDate'));
        createElementAndTextNodeMyRepair(OrderInformation,'externalComments', care.get('Client_Comments__c'));
        createElementAndTextNodeMyRepair(OrderInformation,'followUpEmail', care.get('FollowupBy_Email__c'));
        if(care.get('FollowupBy_Call__c')==true)
        createElementAndTextNodeMyRepair(OrderInformation,'followUpPhone', care.get('FollowupBy_Call__c'));
        if(care.get('FollowupBy_Video_Call__c')==true)
        createElementAndTextNodeMyRepair(OrderInformation,'followUpPhone', care.get('FollowupBy_Video_Call__c'));
        createElementAndTextNodeMyRepair(OrderInformation,'followUpSms', care.get('FollowupBy_Chat__c'));        
        createElementAndTextNodeMyRepair(OrderInformation,'genericSkuCategory', care.get('Category__c'));
        createElementAndTextNodeMyRepair(OrderInformation,'internalComments', care.get('Repair_Center_Comments__c'));
        createElementAndTextNodeMyRepair(OrderInformation,'orderStatus','draft');
       // createElementAndTextNodeMyRepair(OrderInformation,'promiseDeliveryDate', care.get('Delivery_Date__c'));
        createElementAndTextNodeMyRepair(OrderInformation,'quantity', 1);
        createElementAndTextNodeMyRepair(OrderInformation,'rmsStoreCode', care.get('StoreRetailCode__c'));       
        createElementAndTextNodeMyRepair(OrderInformation,'saCode', care.get('CA_Code__c')); 
        createElementAndTextNodeMyRepair(OrderInformation,'salesForceOrderId', care.get('id'));        
        createElementAndTextNodeMyRepair(OrderInformation,'genericSku', care.get('SKU__c'));
        if(care.getSobject('Product__r')!=null)
        createElementAndTextNodeMyRepair(OrderInformation,'sku', care.getSobject('Product__r').get('SKU__c'));
        else
        createElementAndTextNodeMyRepair(OrderInformation,'sku', care.get('SKU__c'));
        createElementAndTextNodeMyRepair(OrderInformation,'destination', care.get('Destination__c'));
        Dom.XMLNode MapPropertiesImpl = OrderInformation.addChildElement('mapProperties', null, null);
        createElementAndTextNodeMyRepair(MapPropertiesImpl,'addFieldFuture1',care.getSobject('Client__r').get('C360GoldenID__c'));
        req = doc.toXmlString();
        system.debug('### handleSalesForceOrder Request Body : '+req) ;

        }else if(action=='handleSalesForceOrderStatus'){
       
        Dom.XMLNode StautusInformation = envelope.addChildElement('Body', SOAPENV_NAMESPACE, SOAPENV_PREFIX_MYREPAIR).addChildElement('handleSalesForceOrderStatus',WEB_NAMESPACE,WEB_PREFIX).addChildElement('pSalesForceOrderStatus', null, null);
          
            createElementAndTextNodeMyRepair(StautusInformation,'address1', care.get('Shipping_Address_Line_1__c'));
            createElementAndTextNodeMyRepair(StautusInformation,'address2', care.get('Shipping_Address_Line_2__c'));
            createElementAndTextNodeMyRepair(StautusInformation,'city', care.get('Shipping_City__c'));
            if(care.getSobject('Client__r').get('Salutation')!=null)
            createElementAndTextNodeMyRepair(StautusInformation,'civility', care.getSobject('Client__r').get('Salutation'));
            else 
            createElementAndTextNodeMyRepair(StautusInformation,'civility', '02'); 
            createElementAndTextNodeMyRepair(StautusInformation,'countryCodeIso2', care.get('Shipping_Country__c'));  
            createElementAndTextNodeMyRepair(StautusInformation,'countryState', care.get('Shipping_State_Province__c'));
            createElementAndTextNodeMyRepair(StautusInformation,'myRepairOrderId', care.get('TransactionId__c'));
            createElementAndTextNodeMyRepair(StautusInformation,'rmsStoreCode', care.get('StoreRetailCode__c'));
            createElementAndTextNodeMyRepair(StautusInformation,'salesForceOrderId', care.get('id'));
            createElementAndTextNodeMyRepair(StautusInformation,'salesForceOrderStatus', care.get('MyRepairStatus__c'));
            createElementAndTextNodeMyRepair(StautusInformation,'zipCode', care.get('Shipping_Zip_Postal_Code__c'));
            if(care.get('MyRepairStatus__c')=='receivedAndAcceptedInStore'){
            createElementAndTextNodeMyRepair(StautusInformation,'price', care.get('TotalAmount_Updated__c'));
            createElementAndTextNodeMyRepair(StautusInformation,'reasonCode', care.get('Price_Update_Reason__c'));
        }
            req = doc.toXmlString();
            system.debug('### handleSalesForceOrderStatus Request Body : '+req) ;
        }
        
        return req;
    }

    public static void createElementAndTextNodeMyRepair(Dom.XMLNode element,String name, Object value) {
        if (value != null) {
            
            if (value instanceof String) {                
                element.addChildElement(name, null,null ).addTextNode((String)value);
            } else if (value instanceof DateTime) {
                DateTime dt = (DateTime) value;               
                element.addChildElement(name, null,null ).addTextNode(dt.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS'));
            } else if (value instanceof Decimal) {
                Decimal dc = (Decimal) value;
                element.addChildElement(name, null,null ).addTextNode(String.valueOf(dc));
            } else if (value instanceof Boolean) {
                Boolean b = (Boolean) value;
                element.addChildElement(name, null,null ).addTextNode(String.valueOf(b));
            } 
        }
    }
}