public with sharing class Threekit_API {
    public class CustomException extends Exception {}
    
    public static Map<String,String> SETTINGS;
    public static Map<String,String> SETTINGS_ALPHA;
    public final static String ENDPOINT;
    public final static String PASSWORD;
    public final static String USERNAME;
    public final static String GET_CONFIGURATION_URL;
    
    static {
        SETTINGS = ThirdParty_Utils.getSettings('Threekit');
        SETTINGS_ALPHA = ThirdParty_Utils.getSettings('Alpha_mulesoft');
        ENDPOINT = 'endpoint';
        PASSWORD = 'password';
        USERNAME = 'username';
        GET_CONFIGURATION_URL = 'configuration_url';
    }
    
    /*
*** DESCRIPTION Create account in ATG. Mapping in Identity_Utils class
*** RETURN
*/
    public static List<ProductConfigurationDetail__c> getRecipeDetails(String shortId){ //MIY-1967
        Boolean isAlpha = IsThreekitAlpha(shortId) ;
        String end_point;
        if (isAlpha) {
            end_point = SETTINGS_ALPHA.get(ENDPOINT)
                + SETTINGS_ALPHA.get(GET_CONFIGURATION_URL).replace('{shortId}', shortId);
                System.debug(end_point);
        }  
        else {   
            end_point = SETTINGS.get(ENDPOINT)
                + SETTINGS.get(GET_CONFIGURATION_URL).replace('{shortId}', shortId)
                + ('?bearer_token=' + SETTINGS.get(PASSWORD));
            // end_point = 'https://admin-fts.threekit.com/api/configurations/3HunEJ-tu?bearer_token=785a18c9-da66-4484-a071-6cd7a7854f74';
            System.debug(end_point);
        }
        try{
            HttpRequest req = new HttpRequest();
            req.setEndpoint(end_point);
            req.setTimeout(60000); //sets maximum timeout
            req.setMethod('GET');
            // Send the request, and return a response
            if (isAlpha) {
                System.debug('oooooooooooooooi'+end_point);
                System.debug(SETTINGS_ALPHA.get(USERNAME));
                System.debug(SETTINGS_ALPHA.get(PASSWORD));
                req.setHeader('client_id', SETTINGS_ALPHA.get(USERNAME));
                req.setHeader('client_secret', SETTINGS_ALPHA.get(PASSWORD));
            }
            Http h = new Http();
            HttpResponse res = h.send(req);
            String str = (String)res.getBody();
            if(str.contains('"error"')&& ( str.contains('"Bad request"') || str.contains('"conflict"'))){
                throw new CustomException('THREEKIT: Retrieving recipe detail failed (MIY-1967): ' + shortId);
            }
            
            Map<String,Object> resp1 = (Map < String, Object > ) JSON.deserializeUntyped(res.getBody());
            
            return parseBody(resp1,isAlpha); 
            
        }
        catch(Exception ex){
            // ADD EXCEPTION TO LOG
            if(!ex.getTypeName().contains('CustomException')){
                new Logs(new Map<String,Object> {
                    'level' => 'ERROR',
                        'apexClass' => 'Threekit_API',
                        'category' => 'CALLOUT',
                        'exception_case' => ex
                        });
            }
        }
        
        return new List<ProductConfigurationDetail__c>();
    } 
    
    public static List<ProductConfigurationDetail__c> parseBody(Map<String,Object> resp ,Boolean isAlpha){
        List<ProductConfigurationDetail__c> result = new List<ProductConfigurationDetail__c>();
        Map<String,Object> metadata = (Map<String,Object>)resp.get('metadata');
        List<Object> skusObj ;
        if (isAlpha) {
            skusObj = (List<Object>)metadata.get('skus');
        }
        else {
            skusObj = (List<Object>)metadata.get('sku');
        }
        
        List<String> skus = new List<String> ();
        for(Object a: skusObj){
            skus.add(String.valueOf(a));
        }
        String sku = skus.isEmpty() ? 'empty' : '(' + String.join(skus, ',') + ')';
        Map<String,Object> readableConfiguration = (Map<String,Object>)metadata.get('readableConfiguration');
        Map<String,Object> threekitConfiguration = (Map<String,Object>)metadata.get('threekitConfiguration');
        for(String name : readableConfiguration.keySet()){
            
            String type;
            String valueText;
            String value;
            Boolean isVisible=false;
            Map<String,Object> attribute  = (Map<String,Object>)readableConfiguration.get(name);
            
            if (isAlpha) {
                isVisible = attribute?.get('uiVisible') == true;
            }  
            
            if(((!name.contains('_') && name != 'CameraAngle') && !isAlpha) || (isVisible && isAlpha)) {   
                valueText = (String)attribute.get('value');
                value = (String)attribute.get('thumbnail');    
                
                if(threekitConfiguration.get(name) != null && (threekitConfiguration.get(name) instanceof Map<String,Object> || !isAlpha))
                {
                    Map<String,Object> threekitDetails = (Map<String,Object>)threekitConfiguration.get(name);
                    type = (String)threekitDetails.get('type');     
                } 
                
                result.add(new ProductConfigurationDetail__c(
                    Sku__c = sku,
                    Value__c = value,
                    Value_Text__c = valueText,
                    Name = name,
                    Type__c = type,
                    hasDoesNotExist__c = false,
                    Key__c = name
                ));
            }                          
        }
        System.debug('result'+result);
        return result;
    }
    
    public static Boolean IsThreekitAlpha(String inputString) {
        if (String.isNotBlank(inputString) && inputString.length() == 8 && inputString == inputString.toUpperCase()) {
            String firstCharacter = inputString.substring(0, 1);
            return firstCharacter == 'T';
        }
        return false;
    } 
}