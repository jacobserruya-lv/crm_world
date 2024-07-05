public without sharing class Google_Analytics_API {
    
    public static Map<String,String> SETTINGS;
    public final static String ENDPOINT;
    public final static String VERSION;
    public final static String TYPE;
    public final static String GA_CLIENT_ID;
    public final static String ENVIRONMENT_ID;
    public final static String ENVIRONMENT_TYPE;

    static {
        SETTINGS = ThirdParty_Utils.getSettings('Google_Analytics');
        ENDPOINT = 'endpoint';
        VERSION = 'v';
        TYPE = 't';
        ENVIRONMENT_ID = 'cd2';
        ENVIRONMENT_TYPE = 'cd4';
    }

    public class CustomException extends Exception {}

    /*
    *** DESCRIPTION Send user login events to Google Analytics
    *** RETURN      a 2xx status code if the HTTP request was received
    */
    public static void sendUserTrackingEvent(Map<String,String> params){

        // GET PARAMS
        String trackingId           = params.get('trackingId');
        String clientId             = params.get('clientId');
        String origin               = params.get('origin'); // only for debug and logs
        String eventCategory        = params.get('eventCategory');
        String eventAction          = params.get('eventAction');
        String eventLabel           = params.get('eventLabel');
        String currentUrl           = params.get('currentUrl');
        String connexionStatus      = params.get('connexionStatus');
        String environmentVersion   = params.get('environmentVersion');
        String environmentLanguage  = params.get('environmentLanguage');
        String pageName             = params.get('pageName');
        String pageType             = params.get('pageType');
        String pageTitle            = params.get('pageTitle');
        String screenOrientation    = params.get('screenOrientation');
        
        Integer randomInt           = getRandomNumber(1000000000);
        String  randomZ             = String.valueOf(randomInt);
        
        try{

      String payLoad =  'tid='    + trackingId 
                            + '&cid='   + clientId 
                            + '&v='     + SETTINGS.get(VERSION)
                            + '&t='     + SETTINGS.get(TYPE)
                            + '&cd53='  + clientId            // GG Analytics Id
                            + '&cd2='   + SETTINGS.get(ENVIRONMENT_ID)      // Domain
                            + '&cd4='   + SETTINGS.get(ENVIRONMENT_TYPE)    // App type [site]

                            + '&ec='    + eventCategory 
                            + '&ea='    + eventAction
                            + '&el='    + eventLabel

                            + '&cd9='   + connexionStatus       // Connection status (session) [logged_user]
                            + '&cd10='  + connexionStatus       // Connection status (hit) [logged_user]
                            + '&cd5='   + environmentVersion    // environmentVersion [e1]
                            + '&cd3='   + environmentLanguage   // environmentLanguage [eng-e1]
                            + '&cd85='  + currentUrl            // absolute URL
                            + '&dp='    + pageName              // pageName [mylv/account_creation]
                            + '&cd84='  + pageType              // pageType [account_creation]
                            //+ '&dt='    + pageTitle             // pageTitle [create a MyLV account | LOUIS VUITTON]
                            //+ '&cd8='   + screenOrientation     // screenOrientation [portrait/landscape]
                            + '&z='     + randomZ
                            ;

      // API CALL
            HTTP_Utils response = new HTTP_Utils()
              .post(SETTINGS.get(ENDPOINT))
              .body(payLoad)
              .call();

          if(isSuccessResponse(response)){
              System.debug('GOOGLE ANALYTICS API');
                System.debug('SUCCESS: ' + response.responseBody());
              System.debug('PAYLOAD: ' + payLoad);
          }
          else {
              new Logs(new Map<String,Object> {
                    'level' => 'ERROR', 
                    'apexClass' => 'Google_Analytics_API', 
                    'category' => 'CALLOUT',
                    'endpoint' => SETTINGS.get(ENDPOINT),
                    'request' => payLoad,
                    'response' => response.responseBody(),
                    'application' => origin
                });
            throw new CustomException('Google_Analytics_API failed to send login event (1)');
          }
      }
    catch(Exception ex){
      new Logs(new Map<String,Object> {
                'level' => 'ERROR', 
                'apexClass' => 'Google_Analytics_API', 
                'category' => 'CALLOUT',
                'exception_case' => ex,
                'application' => origin
            });
      throw new CustomException('Google_Analytics_API failed to send login event (2)');
    }
       
    }

    private static Boolean isSuccessResponse(HTTP_Utils response) {
        return (!Test.isRunningTest() ? response.statusCode() == 200 : true);
    }

    public static Integer getRandomNumber(Integer size){
    Double d = math.random() * size;
    return d.intValue();
  }
}