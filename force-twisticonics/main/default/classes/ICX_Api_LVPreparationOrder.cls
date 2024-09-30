public with sharing class ICX_Api_LVPreparationOrder {
    
    @AuraEnabled(cacheable=true)
    public static String getProductPerso(String shippingGroupRequestId, String countryIso2Code) {
        try {
            system.debug('ICX_Api_LVPreparationOrder - getProductPerso():' + shippingGroupRequestId);
            Http http = new Http();    
            HttpRequest request = new HttpRequest();

            CountryLanguage__c countryLang= ICX_TWIST_OOB.getCountryLanguage(countryIso2Code);
            String mulesoftLocal = countryLang?.Mulesoft_Local__c!=null ? countryLang.Mulesoft_Local__c : 'eco-eu';
            String local = countryLang?.OOB_Local__c!= null ? countryLang.OOB_Local__c : countryLang.ATG_Locale__c;
            
            string endPoint = '/' + mulesoftLocal + '/lvcom-ordr-prp-eapi/v1/products/' + local + '/shipping-group-ids/'+ shippingGroupRequestId;
            request.setEndpoint('callout:MULESOFT_KBRW' + endPoint);
            request.setMethod('GET');
            request.setTimeout(120000);
            request.setHeader('Encoding', 'UTF-8');
            request.setHeader('Accept', 'application/json');
            request.setHeader('Content-Type', 'application/json');            
            request.setHeader('client_id', '{!$Credential.UserName}');
            request.setHeader('client_secret', '{!$Credential.Password}');

            HttpResponse response = http.send(request);

            
            // This is another way to parse the response
            //WS_ProductPersoJson js = (WS_ProductPersoJson) JSON.deserialize(response.getBody(), WS_ProductPersoJson.class));
            
            if (response.getStatusCode() == 200 ) {               
                JSONParser parser = JSON.createParser(response.getBody());
                WS_ProductPersoJson js = (WS_ProductPersoJson) parser.readValueAs(WS_ProductPersoJson.class);

                String color = (js?.personalization?.color==null?'':js?.personalization?.color);

                String dateLib = js?.personalization?.dateLib;
                // if (dateLib != null) {
                //     List<String> subStringList = new List<String>();
                //     for(Integer i=0; i<dateLib.length(); i+=2) {
                //         subStringList.add(dateLib.substring(i, i+2));
                //     }
                //     dateLib = String.join( subStringList, '.' );
                // }
                // else {
                //     dateLib = '';
                // }

                Boolean isDot = js?.personalization?.dot == 'DOT';
                Boolean isFinishGold = js?.personalization?.finishGold == 'GOLD';                
                String fontSize = (js?.personalization?.fontSize==null?'':js?.personalization?.fontSize);
                String initials = (js?.personalization?.initials==null?'':js?.personalization?.initials);
                String vertical = (js?.personalization?.vertical==null?'':js?.personalization?.vertical);
                
                String finalUrl = js.url+'?isPerso='+true;
                finalUrl = finalUrl + (String.isNotEmpty(color)?'&color='+color:'');
                finalUrl = finalUrl + (String.isNotEmpty(dateLib)?'&dateLib='+dateLib:'');
                finalUrl = finalUrl + '&dot='+isDot;
                finalUrl = finalUrl + '&finishGold='+isFinishGold;
                finalUrl = finalUrl + (String.isNotEmpty(fontSize)?'&fontSize='+fontSize:'');
                finalUrl = finalUrl + (String.isNotEmpty(initials)?'&initials='+initials:'');
                finalUrl = finalUrl + (String.isNotEmpty(vertical)?'&vertical='+vertical:'');

                return finalUrl;
                //return js.url+'?color='+color+'&dateLib='+dateLib+'&dot='+isDot+'&finishGold='+isFinishGold+'&fontSize='+fontSize+'&initials='+initials+'&vertical='+vertical+'&isPerso='+true;
            }
            else{
                throw new AuraHandledException(response.getStatus());   
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());  
        } 
    }

    public class WS_ProductPersoJson{
        @AuraEnabled public String skuID {get;set;} 
		@AuraEnabled public String url {get;set;} 
		@AuraEnabled public Perzonalization personalization {get;set;} 
    }

    private class Perzonalization{
        @AuraEnabled public String color {get;set;}
        @AuraEnabled public String dateLib {get;set;}
        @AuraEnabled public String dot {get;set;}
        @AuraEnabled public String finishGold {get;set;}
        @AuraEnabled public String fontSize {get;set;}
        @AuraEnabled public String initials {get;set;}
        @AuraEnabled public String typePerso {get;set;}
        @AuraEnabled public String vertical {get;set;}
    }
}