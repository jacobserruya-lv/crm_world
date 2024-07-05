/*	 * @author Keman WU
* @date creation 03/08/2021
* @description Create shipping order to Metapack	// generate shipping label 
*/
public with sharing class ICX_WS_Metapack {
    
    @future (callout=true)
    public static void createShippingOrderMetapack(set<ID> careIds) {
      
        List<CareService__c> listCare =[select id,ICONiCS_Status_Detail__c,MYLV_Care_Status__c,Destination__c,TransactionId__c,Dangerous_Product__c,Package_Declared_Value__c,Parcel_Length__c,Parcel_Height__c,Parcel_Width__c,SKU__c,CurrencyCode__c,Product_Sku_unknown__c,Category__c,packingListNumber__c,StoreRetailCode__c,Shipping_Label_filename__c,Shipping_Label_Base64_code__c,Shipping_Label_creation_date__c,Client__r.LastName, Client__r.FirstName, Shipping_Address_First_Name__c,Shipping_Address_Last_Name__c,Shipping_Address_Line_1__c, Shipping_Address_Line_2__c, Shipping_Address_Line_3__c, Shipping_Zip_Postal_Code__c, Shipping_City__c, Shipping_State_Province__c, Shipping_Country__c, Client__r.PersonMobilePhone, Client__r.PersonHomePhone, Client__r.PersonEmail,Product__r.Price__c from CareService__c where id IN:careIds];
        List<CareService__c> listCareToUpdate = new List<CareService__c>() ;
        Set<Id> setCareIdsToGenerateShippingLabel = new Set<Id>() ;
        
        MuleSoft_API_Callout__mdt ApiCallout = MuleSoft_API_Callout__mdt.getInstance('Metapack_ImportData');
        
        for(CareService__c care : listCare){     
            //Request
            HttpRequest req = new HttpRequest();       
            req.setHeader('Content-Type', ApiCallout.ContentType__c);         
            req.setHeader('client_id', ApiCallout.ClientId__c);   
            req.setHeader('client_secret', ApiCallout.ClientSecret__c);    
            req.setHeader('SOAPAction', ApiCallout.SoapAction__c);           
            req.setEndpoint(ApiCallout.Endpoint__c);  
            req.setMethod(ApiCallout.Method__c);
            req.setTimeout(Integer.valueOf(ApiCallout.Timeout__c));
            req.setBody(ICX_XmlRequestGenerator.MetapackRequestBuilder('ImportData',care));
            
            
            //Reponse
            HttpResponse response = new HttpResponse();
            try {
                Http http = new Http();            
                response = http.send(req);
                System.debug('### ImportData Reponse Body : '+response.getBody());
                care.Metapack_Request_Body__c =  req.getBody();
                care.Metapack_Response_Body__c =  response.getBody();
                care.Metapack_Error__c ='';
                Dom.Document doc = response.getBodyDocument();
                Dom.XMLNode root = doc.getRootElement();
                Dom.XMLNode body = root.getChildElement('Body','http://schemas.xmlsoap.org/soap/envelope/');
                
                if(body.getChildElement('ImportDataMultiResponse','http://xlogics.eu/blackbox')!= null){
                    //success msg
                    Dom.XMLNode ImportDataMultiResponse = body.getChildElement('ImportDataMultiResponse','http://xlogics.eu/blackbox');
                    
                    Dom.XMLNode ExitStatus = ImportDataMultiResponse.getChildElement('ExitStatus','http://xlogics.eu/blackbox');
                    Dom.XMLNode Status = ExitStatus.getChildElement('Status','http://xlogics.eu/blackbox');
                    System.debug('### ImportData Shipment Order Creation Status: ' + Status.getText());
                    if(Status.getText()=='Success') {
                        Dom.XMLNode OutputParameters = ImportDataMultiResponse.getChildElement('OutputParameters','http://xlogics.eu/blackbox');
                        Dom.XMLNode ImportItem = OutputParameters.getChildElement('ImportItem','http://xlogics.eu/blackbox');
                        Dom.XMLNode Parameters = ImportItem.getChildElement('Parameters','http://xlogics.eu/blackbox');
                        Dom.XMLNode ShippingParameter = Parameters.getChildElement('ShippingParameter','http://xlogics.eu/blackbox');
                        Dom.XMLNode Value = ShippingParameter.getChildElement('Value','http://xlogics.eu/blackbox');
                        System.debug('### ImportData Shipment Order Value: ' + Value.getText());  
                        if(care.MYLV_Care_Status__c == 'preliminary_assessment_acc')   
                        generateShippingLabelMetapack(listCare);                                              
                    }else{
                        //Order Creation Error
                        Dom.XMLNode StatusDetail = ExitStatus.getChildElement('StatusDetails','http://xlogics.eu/blackbox').getChildElement('StatusDetail','http://xlogics.eu/blackbox');
                        system.debug('### ImportData Metapack ErrorCode'+StatusDetail.getChildElement('Code','http://xlogics.eu/blackbox').getText());
                        system.debug('### ImportData '+care.id+' MetaPack ErrorMessage: '+StatusDetail.getChildElement('Message','http://xlogics.eu/blackbox').getText());           
                        care.Metapack_Error__c = 'Order Creation Error : '+ StatusDetail.getChildElement('Message','http://xlogics.eu/blackbox').getText();
                    }
                } else{
                    //Callout Erreur 
                    Dom.XMLNode Fault = body.getChildElement('Fault','http://schemas.xmlsoap.org/soap/envelope/');
                    System.debug('### ImportData Callout Fault: ' + Fault.getChildElement('faultcode',null).getText());
                    System.debug('### ImportData '+care.id+' Callout Fault: ' + Fault.getChildElement('faultstring',null).getText());
                    care.Metapack_Error__c = 'Order Creation Error : '+ Fault.getChildElement('faultstring',null).getText();
                } 
                listCareToUpdate.add(care);
            } catch (CalloutException e) {
                throw  new CalloutException(e.getMessage());
            }
        }
        update listCareToUpdate;       
    }
    
    public static void generateShippingLabelMetapack(List<CareService__c> listCare) {
        List<CareService__c> listCareToUpdate = new List<CareService__c> ();
        List<ContentVersion> listContentVersionToInsert = new List<ContentVersion>() ; 
        
        MuleSoft_API_Callout__mdt ApiCallout = MuleSoft_API_Callout__mdt.getInstance('Metapack_UpdateImportedDataSendAndPrint');
        for(CareService__c care : listCare){
            //Request
            HttpRequest req = new HttpRequest();       
            req.setHeader('Content-Type', ApiCallout.ContentType__c);         
            req.setHeader('client_id', ApiCallout.ClientId__c);   
            req.setHeader('client_secret', ApiCallout.ClientSecret__c);    
            req.setHeader('SOAPAction', ApiCallout.SoapAction__c);           
            req.setEndpoint(ApiCallout.Endpoint__c);  
            req.setMethod(ApiCallout.Method__c);
            req.setTimeout(Integer.valueOf(ApiCallout.Timeout__c));
            req.setBody(ICX_XmlRequestGenerator.MetapackRequestBuilder('UpdateImportedDataSendAndPrint',care));
            
            
            //Reponse
            HttpResponse response = new HttpResponse();
            try {
                Http http = new Http();            
                response = http.send(req);
                System.debug('### UpdateImportedDataSendAndPrint Reponse Body : '+response.getBody());
                care.Metapack_Request_Body__c =  req.getBody();
                if(response.getBody().length() < 131072)
                care.Metapack_Response_Body__c =  response.getBody();
                care.Metapack_Error__c ='';
                Dom.Document doc = response.getBodyDocument();
                Dom.XMLNode root = doc.getRootElement();
                Dom.XMLNode body = root.getChildElement('Body','http://schemas.xmlsoap.org/soap/envelope/');
                
                if(body.getChildElement('UpdateImportedDataSendAndPrintResponse','http://xlogics.eu/blackbox')!= null){
                    //success msg
                    Dom.XMLNode ImportDataMultiResponse = body.getChildElement('UpdateImportedDataSendAndPrintResponse','http://xlogics.eu/blackbox');
                    
                    Dom.XMLNode ExitStatus = ImportDataMultiResponse.getChildElement('ExitStatus','http://xlogics.eu/blackbox');
                    Dom.XMLNode Status = ExitStatus.getChildElement('Status','http://xlogics.eu/blackbox');
                    System.debug('### UpdateImportedDataSendAndPrint Shipping Label Creation Status: ' + Status.getText());
                    if(Status.getText()=='Success') {
                        Dom.XMLNode OutputParameters = ImportDataMultiResponse.getChildElement('OutputParameters','http://xlogics.eu/blackbox');
                        Dom.XMLNode ShippingParameter = OutputParameters.getChildElement('ShippingParameter','http://xlogics.eu/blackbox');
                        Dom.XMLNode Value = ShippingParameter.getChildElement('Value','http://xlogics.eu/blackbox');
                        System.debug('### UpdateImportedDataSendAndPrint Shipping Label Value: ' + Value.getText());
                        //generate shipping label value, update Careservice        
                        ContentVersion sl = new ContentVersion();
                        sl.FirstPublishLocationId = care.id;
                        sl.Title = 'Shipping Label-'+ care.TransactionId__c;
                        sl.PathOnClient = 'Shipping Label-'+ care.TransactionId__c +'.pdf';
                        sl.VersionData = EncodingUtil.base64Decode(Value.getText());                       
                        listContentVersionToInsert.add(sl);
                        
                        care.Shipping_Label_creation_date__c = system.today();
                        if(Value.getText().length() <131072)
                        care.Shipping_Label_Base64_code__c = Value.getText();
                        else{
                            care.Shipping_Label_Base64_code__c = Value.getText().substring(0, 131072);
                            care.Shipping_Label_Base64_code_suite__c = Value.getText().substring(131072);
                        }
                        care.Shipping_Label_filename__c = 'Shipping Label-'+ care.TransactionId__c +'.pdf'; 
                    }else{
                        //Print Shipping Label Error
                        Dom.XMLNode StatusDetail = ExitStatus.getChildElement('StatusDetails','http://xlogics.eu/blackbox').getChildElement('StatusDetail','http://xlogics.eu/blackbox');
                        system.debug('### UpdateImportedDataSendAndPrint Metapack ErrorCode: '+StatusDetail.getChildElement('Code','http://xlogics.eu/blackbox').getText());
                        system.debug('### UpdateImportedDataSendAndPrint '+care.id+' Metapack ErrorMessage: '+StatusDetail.getChildElement('Message','http://xlogics.eu/blackbox').getText());         
                        care.Metapack_Error__c = 'Shipping Label Generation Error : '+ StatusDetail.getChildElement('Message','http://xlogics.eu/blackbox').getText();
                    }
                } else{
                    //Callout Erreur 
                    Dom.XMLNode Fault = body.getChildElement('Fault','http://schemas.xmlsoap.org/soap/envelope/');
                    System.debug('### UpdateImportedDataSendAndPrint Callout Fault: ' + Fault.getChildElement('faultcode',null).getText());
                    System.debug('### UpdateImportedDataSendAndPrint  '+care.id+' Callout Fault: ' + Fault.getChildElement('faultstring',null).getText());
                    care.Metapack_Error__c = 'Shipping Label Generation Error : '+ Fault.getChildElement('faultstring',null).getText();
                }  
                listCareToUpdate.add(care);
            } catch (CalloutException e) {
                throw  new CalloutException(e.getMessage());
            }
            
        }
        update listCareToUpdate; 
        insert listContentVersionToInsert;       
        
    }
}