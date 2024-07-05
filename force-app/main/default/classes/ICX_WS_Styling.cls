public with sharing class ICX_WS_Styling {

    public static Map<String, Object>  getStylingLink(String wardrobingId, String accountId) {

        String endpoint = '/cst-eu/wardrobing-icon/v1/wardrobings/' + wardrobingId + '/shares/' +accountId ;
        String accessToken = Page.BL_ApiSessionId.getContent().toString().trim();

        HTTP_Utils request = new HTTP_Utils()
        .get('callout:MULESOFT_ICONICS'+endpoint)
        .header('Content-Type', 'application/json')
        .header('Encoding', 'UTF-8')
        .header('Accept', 'application/json')
        .header('Authorization', 'Bearer '+accessToken)
        .header('client_id', '{!$Credential.UserName}')
        .header('client_secret', '{!$Credential.Password}')
        .timeout(120000)
        .call();

      Map<String, Object> response = request.getBodyResponse();

      system.debug('ICX_WS_Styling response : '+ response);
      return response;
    }
}