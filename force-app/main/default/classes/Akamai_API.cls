public without sharing class Akamai_API {
    
    public static String getShortUrl(String longUrl, String application){
        Map<String,String> settings = ThirdParty_Utils.getSettings('AKAMAI_Shortner_' + application);

        String endpoint = longUrl.contains('louisvuitton.cn') ? settings.get('endpoint_china') : settings.get('endpoint');
        Map<String, Object> body = new Map<String, Object>{'url' => longUrl , 'base' => endpoint};
        
        HTTP_Utils request = new HTTP_Utils()
               .post(endpoint)
               .header('Authorization', 'Basic ' + HTTP_Utils.getBasicAuthentication(settings.get('username'), settings.get('password')))
               .header('Content-Type', 'application/json')
               .body(JSON.serialize(body))
               .call();

        if(request.statusCode() == 200){
            logResponse( request, 'INFO');

            Map<String,String> response = request.getParameters();
            return response.get('short');
        }
        else{
            logResponse( request, 'ERROR');
        }

        return null;
    }

    private static void logResponse( HTTP_Utils request, String level) {
        new Logs( new Map<String,Object> {
                'level' => level, 
                'apexClass' => 'Akamai_API', 
                'category' => 'CALLOUT',
                'http' => request
            });
    }
}