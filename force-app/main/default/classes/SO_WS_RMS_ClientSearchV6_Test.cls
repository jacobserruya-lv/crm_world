@IsTest
private class SO_WS_RMS_ClientSearchV6_Test {
    
    @IsTest
    static void testClientSearch() {
        String mockResponseBody = '...';
        
        SO_WS_RMS_ClientSearchV6 clientSearch = new SO_WS_RMS_ClientSearchV6();
        
        SO_WS_RMS_ClientSearchV6.mainService_cs request = new SO_WS_RMS_ClientSearchV6.mainService_cs();
        request.clientSearch = new SO_WS_RMS_ClientSearchV6.clientSearch();
        request.clientSearch.ClientSearch = new SO_WS_RMS_ClientSearchV6.ClientSearchType();
        
        SO_WS_RMS_ClientSearchV6.docTypeRef_ClientSearchDataResponse request2 = new SO_WS_RMS_ClientSearchV6.docTypeRef_ClientSearchDataResponse();
        SO_WS_RMS_ClientSearchV6.docTypeRef_ClientSearchData request3 = new SO_WS_RMS_ClientSearchV6.docTypeRef_ClientSearchData();
        SO_WS_RMS_ClientSearchV6.clientSearchResponse request4 = new SO_WS_RMS_ClientSearchV6.clientSearchResponse();
        SO_WS_RMS_ClientSearchV6.docTypeRef_clientData request5 = new SO_WS_RMS_ClientSearchV6.docTypeRef_clientData();
        SO_WS_RMS_ClientSearchV6.docTypeRef_searchCriteria request6 = new SO_WS_RMS_ClientSearchV6.docTypeRef_searchCriteria();
        SO_WS_RMS_ClientSearchV6.ClientSearchResponseType request7 = new SO_WS_RMS_ClientSearchV6.ClientSearchResponseType();
        SO_WS_RMS_ClientSearchV6.mainServiceResponse_cs request8 = new SO_WS_RMS_ClientSearchV6.mainServiceResponse_cs();
        SO_WS_RMS_ClientSearchV6.WSLV013_webService_v6_0_clientSearch_Port clientSearchPort = new SO_WS_RMS_ClientSearchV6.WSLV013_webService_v6_0_clientSearch_Port();
        SO_WS_RMS_ClientSearchV6.mainService_cs request10 = new SO_WS_RMS_ClientSearchV6.mainService_cs();
        
        request10.clientSearch = new SO_WS_RMS_ClientSearchV6.clientSearch();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse('successOrderPdf', 'OrderPdf'));
        
        Test.startTest();
        try{
            SO_WS_RMS_ClientSearchV6.WSLV013_webService_v6_0_clientSearch_Port request9 = new SO_WS_RMS_ClientSearchV6.WSLV013_webService_v6_0_clientSearch_Port();
            request9.mainService_cs(request.clientSearch);
        }
        catch(Exception ex){
            system.debug(ex);
        }
        Test.stopTest();
        
    }
}