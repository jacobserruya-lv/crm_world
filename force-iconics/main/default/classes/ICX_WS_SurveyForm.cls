public with sharing class ICX_WS_SurveyForm {

    public static String getSurveyForm(String feedbackId) {
    // public static HttpResponse getSurveyForm(String feedbackId) {
        System.debug('getSurveyForm recordId : '+feedbackId);

        String callout = 'callout:MULESOFT_VOICE';
        String endPoint = '/api/v1/answer_sets/' + feedbackId; 

        Http http = new Http();


        HttpRequest request = new HttpRequest();
        request.setEndpoint(callout + endPoint);
        request.setMethod('GET');
        request.setTimeout(120000);
        request.setHeader('Encoding', 'UTF-8');
        request.setHeader('Accept', 'application/json');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('client_id', '{!$Credential.UserName}');
        request.setHeader('client_secret', '{!$Credential.Password}');
    

        HttpResponse response = http.send(request);

        System.debug('getSurveyForm response: '+response);    
        
        return response.getBody();

    }
}