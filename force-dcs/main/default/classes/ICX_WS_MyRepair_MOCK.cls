/*	 * @author Keman WU
* @date creation 04/11/2021
* @description mock class for ICX_WS_MyRepair
*/@isTest
global class ICX_WS_MyRepair_MOCK implements HttpCalloutMock {
    global HTTPResponse respond(HttpRequest req) {
    
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/xml');
        if(req.getEndpoint().contains('cst-eu/repord-crt-myrep/v1/'))
        res.setBody('<?xml version="1.0" encoding="UTF-8"?> <env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:enc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns0="http://www.atg.com/atg.security" xmlns:ns1="http://www.atg.com/com.vuitton.ecommerce.commerce.store" xmlns:ns2="http://www.atg.com/webservices" xmlns:ns3="http://www.atg.com/com.vuitton.myrepairs.commerce.order.salesforce.adapter" env:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><env:Body><ns2:handleSalesForceOrderResponse><return href="#ID1"/></ns2:handleSalesForceOrderResponse><ns3:SalesForceOrderResultImpl id="ID1" xsi:type="ns3:SalesForceOrderResultImpl"><messageType xsi:type="xsd:string">INFO</messageType><myRepairOrderHeadId xsi:type="xsd:string">97900020</myRepairOrderHeadId><myRepairOrderId xsi:type="xsd:string">o12140290</myRepairOrderId><resultCode xsi:type="xsd:string">000</resultCode><resultMessage xsi:type="xsd:string">SUCCESS</resultMessage> </ns3:SalesForceOrderResultImpl></env:Body></env:Envelope>');
        if(req.getEndpoint().contains('/handleSalesForceOrderStatus'))        
        res.setBody('<?xml version="1.0" encoding="UTF-8"?><env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:enc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns0="http://www.atg.com/atg.commerce" xmlns:ns1="http://www.atg.com/atg.repository" xmlns:ns2="http://www.atg.com/atg.security" xmlns:ns3="http://www.atg.com/atg.userprofiling.address" xmlns:ns4="http://www.atg.com/com.vuitton.ecommerce.commerce.store" xmlns:ns5="http://www.atg.com/webservices" xmlns:ns6="http://www.atg.com/com.vuitton.myrepairs.commerce.order.salesforce.status" env:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><env:Body><ns5:handleSalesForceOrderStatusResponse><return href="#ID1"/></ns5:handleSalesForceOrderStatusResponse><ns6:SalesForceOrderStatusResultImpl id="ID1" xsi:type="ns6:SalesForceOrderStatusResultImpl"><messageType xsi:type="xsd:string">INFO</messageType><myRepairOrderId xsi:type="xsd:string">o12160081</myRepairOrderId><resultCode xsi:type="xsd:string">000</resultCode><resultMessage xsi:type="xsd:string">SUCCESS</resultMessage><salesForceOrderId xsi:type="xsd:string">a1T2f000000t1KKEAY</salesForceOrderId></ns6:SalesForceOrderStatusResultImpl></env:Body></env:Envelope>');
        res.setStatusCode(200);
        return res;
    }

}