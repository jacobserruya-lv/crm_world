/** Class Name   : POC_RegionTreeController 
*  Description  : This class is used make google api callouts and get the response 
*  Created By   : Veera k  
*  Created On   : 31/10/2017
*
*  Modification Log:  
*  --------------------------------------------------------------------------------------------------------------------------------------
*   Developer                Date                   Modification ID      Description 
*  --------------------------------------------------------------------------------------------------------------------------------------                                                                                   
*  
**/
public with sharing class ICX_AddressSearchControllerLC {  

    /*public String lightningDomain {get; set;}

    public ICX_AddressSearchControllerLC() {
        Map<String, String> params = System.currentPageReference().getParameters();
        this.lightningDomain = (params != null && String.isNotBlank(params.get('lightningDomain')) ? params.get('lightningDomain') : '' );
    }*/

    @AuraEnabled(cacheable=true)
    public static String getVisualforceHost() {
        return IconicsSettings__c.getInstance().VisualforceHost__c;
    }

    @AuraEnabled(cacheable=true)
    public static String getCurrentUserLoginCountry() {
        // Note:  last login >= YESTERDAY because we had some issues during deployment where the last login of the current user was yesteday (maybe because of the Session Time)
        List<LoginHistory> historyList = [SELECT CountryIso, Status, UserId FROM LoginHistory WHERE UserId = :UserInfo.getUserId() AND LoginTime >= YESTERDAY order by LoginTime desc LIMIT 1];
        return (historyList.isEmpty() ? null : historyList.get(0).CountryIso);
    }

/*
    // @description : Auto suggestion Web Service 
    // @param : input: SearchAddress , types: Results Types , langug : language for getting the results
    @AuraEnabled(cacheable=true)
    public static string getAddressAutoComplete(String input, String types,String langug) {
        String url = '/autocomplete/json?input='
            + EncodingUtil.urlEncode(input, 'UTF-8')
            + '&language=' + langug
            + '&key=' + ICX_AddressSearchControllerLC.getGoogleMapsAPIKey();
           // + '&amp;channel_id=' + ICX_AddressSearchControllerLC.getGoogleMapsAPIKey();
        return ICX_AddressSearchControllerLC.getHttp(url);
    }

    // @description : Place Details Web Service 
    // @param : PlaceId: Unique Place Id , langug : language for getting the results
    @AuraEnabled
    public static string getAddressDetails(String placeId,String lang) {
        String url = '/details/json?placeid='
            +placeId+'&language='+lang+'&key='+ ICX_AddressSearchControllerLC.getGoogleMapsAPIKey();
        return ICX_AddressSearchControllerLC.getHttp(url);
    }
    
    // @description : To get the google Api key from custom label
    private static String getGoogleMapsAPIKey(){
        String gMapkey = IconicsSettings__c.getInstance().GooglePlaceKey__c;//'AIzaSyAWZMtd-kmcFpYneyyIPM2WbwegjkIp3fQ';//Label.TXP_Google_Key;
        return gMapkey;
    }

    // @description : Common Utility method for making call out
    private static string getHttp(String url){
        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(url);
            request.setEndpoint('callout:Google_Place' + url); // Setup > Named credentials > Open Street Map
            request.setMethod('GET');
            HttpResponse response = http.send(request);
            System.debug('response.getBody()=' + response.getBody());
            
            // {"address_components":['
                //   +'{"address_components":[{"long_name":"Rue Bretonneau","short_name":"Rue Bretonneau","types":["route"]},{"long_name":"Saint-Cyr-sur-Loire","short_name":"Saint-Cyr-sur-Loire","types":["locality","political"]},{"long_name":"Indre-et-Loire","short_name":"37","types":["administrative_area_level_2","political"]},{"long_name":"Centre","short_name":"Centre","types":["administrative_area_level_1","political"]},{"long_name":"France","short_name":"FR","types":["country","political"]},{"long_name":"37540","short_name":"37540","types":["postal_code"]}],"formatted_address":"Rue Bretonneau, 37540 Saint-Cyr-sur-Loire, France","geometry":{"bounds":{"northeast":{"lat":47.40127070,"lng":0.65740570},"southwest":{"lat":47.3954730,"lng":0.65596190}},"location":{"lat":47.39822119999999,"lng":0.65601820},"location_type":"GEOMETRIC_CENTER","viewport":{"northeast":{"lat":47.40151947068016,"lng":0.6598314206801714},"southwest":{"lat":47.39522422931982,"lng":0.6535361793198285}}},"partial_match":true,"types":["route"]}'
               // 				+'
            String fakeResult = '{"result":'
                +'{"address_components" : [{"long_name":"Rue du Docteur Bretonneau","short_name":"Rue du Docteur Bretonneau","types":["route"]},{"long_name":"Tours","short_name":"Tours","types":["locality","political"]},{"long_name":"Indre-et-Loire","short_name":"37","types":["administrative_area_level_2","political"]},{"long_name":"Centre","short_name":"Centre","types":["administrative_area_level_1","political"]},{"long_name":"France","short_name":"FR","types":["country","political"]},{"long_name":"37000","short_name":"37000","types":["postal_code"]}]'
                +',"formatted_address":"Rue du Docteur Bretonneau, 37000 Tours, France"'
            	+',"geometry":{"bounds":{"northeast":{"lat":47.3958540,"lng":0.68046010},"southwest":{"lat":47.39427310,"lng":0.6802389999999999}},"location":{"lat":47.39503870,"lng":0.6803620},"location_type":"GEOMETRIC_CENTER","viewport":{"northeast":{"lat":47.39821117068017,"lng":0.6834971706801714},"southwest":{"lat":47.39191592931983,"lng":0.6772019293198285}}}'
                +',"partial_match":true,"types":["route"]'
                +'}'
                //+'{"address_components":[{"long_name":"Rue Bretonneau","short_name":"Rue Bretonneau","types":["route"]}'
                //+',{"long_name":"Saint-Cyr-sur-Loire","short_name":"Saint-Cyr-sur-Loire","types":["locality","political"]},{"long_name":"Indre-et-Loire","short_name":"37","types":["administrative_area_level_2","political"]},{"long_name":"Centre","short_name":"Centre","types":["administrative_area_level_1","political"]},{"long_name":"France","short_name":"FR","types":["country","political"]},{"long_name":"37540","short_name":"37540","types":["postal_code"]}'
                //+']'
                //+',"formatted_address":"Rue Bretonneau, 37540 Saint-Cyr-sur-Loire, France"'
                //+',"geometry":{"bounds":{"northeast":{"lat":47.40127070,"lng":0.65740570},"southwest":{"lat":47.3954730,"lng":0.65596190}},"location":{"lat":47.39822119999999,"lng":0.65601820},"location_type":"GEOMETRIC_CENTER","viewport":{"northeast":{"lat":47.40151947068016,"lng":0.6598314206801714},"southwest":{"lat":47.39522422931982,"lng":0.6535361793198285}}}'
                //+',"partial_match":true,"types":["route"]}'
                +',"status":"OK"}';
            Address_JSON2Apex parseJson = parse2(fakeResult);
            System.debug('parseJson=' + parseJson);
            
            // Address
            // convert Webservice to Address object
            Address address = new Address();
            if (parseJson != null && 'OK'.equals(parseJson.status) && parseJson.Result != null) {
                address.formatted_address = parseJson.Result.formatted_address;
                for (Address_components comp : parseJson.Result.address_components) {
                    for (String type : comp.types) {
                        switch on type {
                            when 'street_number' {
                                address.street_number = comp;
                            }
                            when 'route' { // "long_name":"Rue Bretonneau","short_name":"Rue Bretonneau"
                                address.route = comp;
                            }
                            when 'locality' { // "long_name":"Saint-Cyr-sur-Loire","short_name":"Saint-Cyr-sur-Loire"
                                address.locality = comp;
                            }
                            when 'postal_code' {
                                address.postal_code = comp;
                            }
                            when 'administrative_area_level_1' { // "long_name":"Centre","short_name":"Centre"
                                address.administrative_area_level_1 = comp;
                            }
                            when 'administrative_area_level_2' { // "long_name":"Indre-et-Loire","short_name":"37"
                                address.administrative_area_level_2 = comp;
                            }
                            when 'country' { // "long_name":"France","short_name":"FR"
                                address.country = comp;
                            }
                        }
                    }
                }
                if (parseJson.Result.geometry != null) {
                    address.location = parseJson.Result.geometry.location;
                }
            }
            return JSON.serialize(parseJson.result);
            //return parseJson;
            //return response.getBody();
            
        } catch(Exception e){    
            return null;
        }
    } 
  
    // @description : Parsing Json Response for Auto Suggestion (1st Web Service)
    // @return : List<AddressJsonInfo>
    private static List<AddressJsonInfo> parse(String json) {
        return (List<AddressJsonInfo>) System.JSON.deserialize(json, List<AddressJsonInfo>.class);
    }
    
    // @description : Parsing Json Response for Place Details (3rd and 4th Web Service)
    // @return : TXP_JSON2Apex
    private static Address_JSON2Apex parse2(String json) {
        return (Address_JSON2Apex) System.JSON.deserialize(json, Address_JSON2Apex.class);
    }
    
    // @description : Parsing Json Response for Place Details (2nd Web Service)
    private static GeoLoca parse1(String json) {
        return (GeoLoca) System.JSON.deserialize(json, GeoLoca.class);
    }
    
    // @description : Wrapper class for getting latitude and longtitude (Second Web Service)
    public class GeoLoca{
        public Double lat;  //6.9121796
        public Double lng;  //79.8828828
    }
    
    // @description : Wrapper class for getting Address (First Web Service)
    public class AddressJsonInfo {
        public String long_name;
        public String short_name;
        public List<String> types;
    }
    // @description : Wrapper class for getting latitude and longtitude (Second Web Service)
    public class Geometry {
        public Location location;
        public Viewport viewport;
    }
    
    public class Viewport {
        public Location northeast;
        public Location southwest;
    }
    
    public class Location {
        public Double lat;
        public Double lng;
    }
    
    
    // @description : Wrapper class for Place Details  (Third and fourth Web Service)
    public class Address_JSON2Apex {
        public List<Html_attributions> html_attributions;
        public Result result;
        public String status;
    }
    public class Html_attributions {
    }
    
    // Exact field name from Google result
    public class Result {
        public List<Address_components> address_components;
        public String adr_address;
        public String formatted_address;
        public Geometry geometry;
        public String icon;
        public String id;
        public String name;
        public String place_id;
        public String reference;
        public String scope;
        public List<String> types;
        public String url;
        public Integer utc_offset;
        public String vicinity;
    }
    public class Address_components {
        public String long_name;
        public String short_name;
        public List<String> types;
    }
    */
    
}