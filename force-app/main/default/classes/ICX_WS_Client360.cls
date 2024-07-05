/*
CreatedDate: July 2022
Company: Balink
Author: Naomi Baroghel
Description: Callout to Client360 Search and Vision
*/

public with sharing class ICX_WS_Client360 {
    public ICX_WS_Client360() {
    }

    public static HttpResponse httpRequest(String callout, String endpoint, String method,  String body) {
        String countryCodeIso3= getIsoCode3();

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(callout + endPoint);
        request.setMethod(method);
        request.setTimeout(60000);
        request.setHeader('Encoding', 'UTF-8');
        request.setHeader('Accept', 'application/json');
        request.setHeader('Content-Type', 'application/json');

        if(countryCodeIso3!=null){
            request.setHeader('countryCodeIso3',  countryCodeIso3);
        }
        
        request.setHeader('client_id', '{!$Credential.UserName}');
        request.setHeader('client_secret', '{!$Credential.Password}');

        if(body != null) request.setBody(body);

        HttpResponse response = http.send(request);      
        return response;
    }

    public static String requestAndLogs(String callout, String endPoint, String method, String requestBodySearch) {
        String countryCodeIso3= getIsoCode3();

        try { 

            if(countryCodeIso3!=null) {
                HttpResponse response = httpRequest(callout, endpoint, method, requestBodySearch);
                String statusCode = String.valueOf(response.getStatusCode());

                String responseBody = response.getBody();

                if (statusCode == '200' ) {
                    system.debug('ICX_WS_Client360 ws response.getBody() : ' + response.getBody());
                    if(responseBody.length()>3000){
                        responseBody = responseBody.substring(0,3000);
                        ICX_Utils.createIconicsLogsWithInsert('ICONICS - C360', 'ICX_WS_Client360',endpoint,responseBody, requestBodySearch,'INFO',statusCode);
                    } else ICX_Utils.createIconicsLogsWithInsert('ICONICS - C360', 'ICX_WS_Client360',endpoint,responseBody, requestBodySearch,'INFO',statusCode);

                    return response.getBody();                

                } else {

                    ICX_Utils.createIconicsLogsWithInsert('ICONICS - C360', 'ICX_WS_Client360',endPoint, response.getBody(), requestBodySearch,'ERROR',statusCode);
                    ICX_Client360_API_Helper.errorObj errorObj = (ICX_Client360_API_Helper.errorObj)JSON.deserialize(response.getBody(), ICX_Client360_API_Helper.errorObj.class);    
                    throw new ICX_Client360_API_Helper.Client360Exception(HandleError(statusCode,errorObj?.data?.errorType+ ' ' + errorObj?.data?.errorDescription));
                }
    
            } else {
                throw new ICX_Client360_API_Helper.Client360Exception(HandleError('400','Error : Country is not fullfiled on User profile'));    
            }
    
        } catch (Exception e) {
            System.debug('Error message : '+ e.getMessage());
            throw new ICX_Client360_API_Helper.Client360Exception(e.getMessage());
    
        }

    }

    public static String Client360_search(String requestBodySearch) {
        System.debug('requestBodySearch : ' + requestBodySearch);
        String callout = 'callout:MULESOFT_CLIENT_360';
        String endPoint = '/cst-eu/sfdc-client-eapi/v1/clients/search/query';
        String response = requestAndLogs(callout, endpoint, 'POST', requestBodySearch);
        System.debug('Client360_search response ' + response);
        return response;
    }


    public static String Client360_search_form(String requestBodySearch) {
        System.debug('requestBodySearch : ' + requestBodySearch);
        String callout = 'callout:MULESOFT_CLIENT_360';
        String endPoint = '/cst-eu/sfdc-client-eapi/v1/clients/search/advanced-query';
        String response = requestAndLogs(callout, endpoint, 'POST', requestBodySearch);
        System.debug('Client360_search response ' + response);
        return response;
    }

  

    public static String Client360_Profile(String dreamId){
        String callout = 'callout:MULESOFT_CLIENT_360_VISION';
        String endPoint = '/cst-eu/icn-client-vision-eapi/v1/clients/'+ dreamId +'/profile';
        String response = requestAndLogs(callout, endpoint, 'GET', null);
        System.debug('Client360_Profile response ' + response);
        return response;
    }
    
    public static String Client360_OngoingOrders(String dreamId){
        String callout = 'callout:MULESOFT_CLIENT_360_VISION';
        String endPoint = '/cst-eu/icn-client-vision-eapi/v1/clients/'+ dreamId +'/ongoing-orders';
        String response = requestAndLogs(callout, endpoint, 'GET', null);
        System.debug('Client360_OngoingOrders response ' + response);
        return response;
    }



public static String Client360_Aggregates(String dreamId){
    String callout = 'callout:MULESOFT_CLIENT_360_VISION';
    String endPoint = '/cst-eu/icn-client-vision-eapi/v1/clients/'+ dreamId +'/aggregates';
    String response = requestAndLogs(callout, endpoint, 'GET', null);
    System.debug('Client360_Aggregates response ' + response);
    return response;
}

public static HttpResponse Client360_GetPurchases(String endpoint, String dreamId,String newSearch, String scrollType,String refSaleID,String numTrans){

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endPoint);
        request.setMethod('GET');
        request.setTimeout(60000);
        request.setHeader('Encoding','UTF-8');
        request.setHeader('Accept','application/json');
        request.setHeader('newSearch',newSearch);
        request.setHeader('scrollType',scrollType);
        request.setHeader('numTrans',numTrans);
        if(refSaleID!=null){
            request.setHeader('refSaleID',refSaleID);
        }

        request.setHeader('client_id', '{!$Credential.UserName}');
        request.setHeader('client_secret', '{!$Credential.Password}');


        String countryCodeIso3=  getIsoCode3();
          
        if(countryCodeIso3!=null){
            request.setHeader('countryCodeIso3',  countryCodeIso3);
        }else {
            throw new ICX_Client360_API_Helper.Client360Exception(HandleError('400','Error : Country is not fullfiled on User profile'));
        }
        
        HttpResponse response = http.send(request);
        return response;
            
}

public static String Client360_Purchases(String dreamId,String newSearch, String scrollType,String refSaleID,String numTrans) {
    try {

        String endPoint = 'callout:MULESOFT_CLIENT_360_VISION/cst-eu/icn-client-vision-eapi/v1/clients/'+ dreamId +'/purchases';

        HttpResponse response  = Client360_GetPurchases(endpoint, dreamId, newSearch, scrollType, refSaleID, numTrans);

            String statusCode = String.valueOf(response.getStatusCode());


            if (response.getStatusCode() == 200 ) {
                ICX_Utils.createIconicsLogsWithInsert('ICONICS - C360', 'ICX_WS_Client360',endPoint,response.getBody(), null,'INFO',statusCode);
                System.debug('The purchases response'+response.getBody());
                return response.getBody();
            }

            else{
                ICX_Utils.createIconicsLogsWithInsert('ICONICS - C360', 'ICX_WS_Client360',endPoint,response.getBody(), null,'ERROR',statusCode);
                ICX_Client360_API_Helper.errorObj errorObj = (ICX_Client360_API_Helper.errorObj)JSON.deserialize(response.getBody(), ICX_Client360_API_Helper.errorObj.class);
                throw new ICX_Client360_API_Helper.Client360Exception(HandleError(statusCode,errorObj?.data?.errorType+ ' ' + errorObj?.data?.errorDescription));
            }
         

    } catch (Exception e) {
        System.debug('Error message : '+ e.getMessage());
        throw new ICX_Client360_API_Helper.Client360Exception(e.getMessage());

    }
}

    
    public static String getIsoCode3(){
        String countryIso3User;

        //check corporate
        String idCorporate = [SELECT Id,DeveloperName FROM UserRole WHERE DeveloperName ='Corporate_Digital' LIMIT 1]?.Id;
        if(UserInfo.getUserRoleId()==idCorporate){
            countryIso3User='ALL';
        }        
          //check ISR groupe (CSC Spain)
        else if([SELECT Id, Group.DeveloperName FROM GroupMember WHERE UserOrGroupId =:UserInfo.getUserId() AND Group.DeveloperName =: 'ISR_Clients_Visibility'].size()>0){
                countryIso3User='ISR';
            
        }
        //else take country of the user
        else{
            String countryUser = [SELECT Id, Country__c FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1]?.Country__c;
            //if country is not in the metadata, we need to map it
            Map<String,String> countryMap = new Map<String,String> {
                'USA' => 'UNITED STATES',
                'MACAU' => 'MACAO'
            };
            
            if(countryMap.get(countryUser) != null) {
                countryUser = countryMap.get(countryUser);
            }

            
            if(countryUser!=null){
                countryIso3User = [SELECT Id,Iso3Code__c FROM CountryMapping__mdt WHERE Picklist__c=:countryUser LIMIT 1]?.Iso3Code__c;
            }
        }

        system.debug(' countryIso3User : '+countryIso3User);
        return countryIso3User;
    }


    public static String HandleError(String statusCode, String errorMessage){
        return '{"statusCode":"'+statusCode+'","errorMessage":"'+ errorMessage+'"}' ;
    }

}