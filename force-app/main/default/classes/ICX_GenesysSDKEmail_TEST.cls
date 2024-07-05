@isTest
class ICX_GenesysSDKEmail_TEST {
    
    @isTest
    static void TestDisconnectEmail(){
        Test.startTest();
        String conversationId = 'conversationId';
        String participantId = 'participantId';
        ICX_GenesysSDKEmail.disconnectEmail(conversationId, participantId);
        Test.stopTest();
    } 

    /*
    @isTest
    static void TestGetConversationDetails(){
        Test.startTest();
        ICX_GenesysSDKEmail.getConversationDetails('conversationId');
        Test.stopTest();
    }*/
    
    /*
    @isTest
    static void TestDisconnectEmailRequest(){
        Test.startTest();
        String conversationId = 'conversationId';
        String participantId = 'participantId';
        String communicationId = 'communicationId';
        ICX_GenesysSDKEmail.disconnectEmailRequest(conversationId, participantId, communicationId);
        Test.stopTest();
    }*/
    
    @isTest
    static void TestGetCommunicationId(){
        Test.startTest();
        String jsonData = '{"participants":[{"participantId": "participantId", "purpose": "external", "sessions": [{"direction": "inbound", "mediaType": "email", "provider": "Salesforce", "sessionId": "communicationId"}]}]}';
        ICX_GenesysSDKEmail dataObj = (ICX_GenesysSDKEmail)JSON.deserialize(jsonData, ICX_GenesysSDKEmail.class);  
        String participantId = 'participantId';
        ICX_GenesysSDKEmail.getCommunicationId(dataObj, participantId);
        Test.stopTest();
    } 
}