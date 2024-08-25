/*	 * @author Keman WU
* @date creation 04/11/2021
* @description Mock class for ICX_WS_Metapack
*/
@isTest
global class ICX_WS_Metapack_MOCK implements HttpCalloutMock {
    global HTTPResponse respond(HttpRequest req) {
     
        // Create a fake response
        HttpResponse res = new HttpResponse();
        if(req.getBody().contains('ImportDataMultiRequest'))  
        res.setHeader('Content-Type', 'text/xml');      
        res.setBody('<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" xmlns:u="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd"><s:Header><o:Security s:mustUnderstand="1" xmlns:o="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd"><u:Timestamp u:Id="_0"><u:Created>2021-11-04T16:01:33.009Z</u:Created><u:Expires>2021-11-04T16:06:33.009Z</u:Expires></u:Timestamp></o:Security></s:Header><s:Body><ImportDataMultiResponse xmlns="http://xlogics.eu/blackbox"><ExitStatus xmlns:i="http://www.w3.org/2001/XMLSchema-instance"><Status>Success</Status><StatusDetails><StatusDetail><Status>Success</Status><Code>0</Code><Message>Succeed</Message><Details/></StatusDetail></StatusDetails></ExitStatus><OutputParameters xmlns:i="http://www.w3.org/2001/XMLSchema-instance"><ImportItem><Parameters><ShippingParameter><Name>ImportData.Id</Name><Value>103248</Value></ShippingParameter></Parameters></ImportItem></OutputParameters></ImportDataMultiResponse></s:Body></s:Envelope>');
        if(req.getBody().contains('UpdateImportedDataSendAndPrintRequest'))        
        res.setBody('<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" xmlns:u="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd"><s:Header><o:Security s:mustUnderstand="1" xmlns:o="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd"><u:Timestamp u:Id="_0"><u:Created>2021-11-04T16:00:49.217Z</u:Created><u:Expires>2021-11-04T16:05:49.217Z</u:Expires></u:Timestamp></o:Security></s:Header><s:Body><UpdateImportedDataSendAndPrintResponse xmlns="http://xlogics.eu/blackbox"><ExitStatus xmlns:i="http://www.w3.org/2001/XMLSchema-instance"><Status>Success</Status><StatusDetails><StatusDetail><Status>Success</Status><Code>0</Code><Message>Succeed</Message><Details/></StatusDetail></StatusDetails></ExitStatus><OutputParameters xmlns:i="http://www.w3.org/2001/XMLSchema-instance"><ShippingParameter><Name>LABEL.1Z0961579000000980.PDF.PDF|Unicode.Label_1Z0961579000000980_NOPRINT_~pdf</Name><Value>JVBERi0xLjQKJdP</Value></ShippingParameter><ShippingParameter><Name>Shipment.Status</Name><Value>Created|Printed|NotUpdated</Value></ShippingParameter></OutputParameters></UpdateImportedDataSendAndPrintResponse></s:Body></s:Envelope>');
        res.setStatusCode(200);
        return res;
    }

}