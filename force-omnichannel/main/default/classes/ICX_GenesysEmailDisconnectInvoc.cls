/**
 * Disconnect CTI intercation on qualification complete
 */
public class ICX_GenesysEmailDisconnectInvoc {
    
    @InvocableMethod(label='Genesys Email Disconnect' description='Disconnect email interaction via Genesys SDK' category='Iconics')
    public static List<Result> genesysPickOut(List<Request> requests) {
        String conversationId = requests[0].conversationId;
        String participantId = requests[0].participantId;
        String communicationId;
        Boolean res = false;

        if(String.isNotBlank(conversationId) && String.isNotBlank(participantId)){
            ICX_GenesysSDKEmail.disconnectEmail(conversationId, participantId);
            res = true;
        }

        Result result = new Result();
        result.result = res;
        return new List<Result>{result};
    }
    
    public class Request{  
        @InvocableVariable(label='Genesys Conversation Id' required=true)
        public String conversationId; 

        @InvocableVariable(label='Genesys Participant Id' required=true)
        public String participantId;  
    }
    
    public class Result{
        @InvocableVariable(label='Result')
        public Boolean result;    
    }
}