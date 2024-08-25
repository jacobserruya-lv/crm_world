public class ICX_GenesysSDKEmail {

    private String conversationId;
    private String conversationStart;
    private String conversationEnd;
    private List<Participant> participants;

    /**
     * Request to Genesys SDK to get conversation details object
     * @param conversationId
     */
    @TestVisible
    private static HttpResponse getConversationDetails(String conversationId){  
        if(String.IsNotBlank(conversationId)){
            String conversDetails = '/api/v2/analytics/conversations/'+conversationId+'/details';
            HttpResponse response = purecloud.SDK.Rest.get(conversDetails);
            return response;
        }
        return null;
    }

    /**
     * Request to retrieve Genesys CommunicationId from @see getconversationDetails method
     * 
     * @param dataObj
     * @param participantId
     */
    @TestVisible
    private static String getCommunicationId(ICX_GenesysSDKEmail dataObj, String participantId){  
        if(String.IsNotBlank(participantId)){
            List<Participant> participants = dataObj.participants;
            for(Participant part : participants){
                if(part.participantId == participantId){
                    Integer objNum = part.sessions.size() -1;
                    return part.sessions[objNum].sessionId; 
                }
            }
        }
        return null;
    }

    /**
     * Send Request via Genesys SDK to disconnect Interaction from the CTI
     * 
     * @param conversationId
     * @param participantId
     * @param communicationId
     */
    @TestVisible
    public static Boolean disconnectEmailRequest(String conversationId, String participantId, String communicationId){
        if(String.IsNotBlank(conversationId) && String.IsNotBlank(participantId) && String.IsNotBlank(communicationId)){
            String emailUpdateStatus = '/api/v2/conversations/emails/'+conversationId+'/participants/'+participantId+'/communications/'+communicationId;
            Map<String, String> payload = new Map<String, String>{'state'=>'disconnected'};   
            HttpResponse response = purecloud.SDK.Rest.patch(emailUpdateStatus, JSON.serialize(payload));
   
            if(response.getStatusCode() != 200){
                throw new ICXGenesysException(response.getBody());
            }
            return true;
        }
        return false;
    }

    /**
     * Future method that disconnect email interaction
     * 
     * @param conversationId
     * @param participantId
     */
    @future(callout=true)
    public static void disconnectEmail(String conversationId, String participantId){
        if(String.IsBlank(conversationId) || String.IsBlank(participantId)){ return; }
        String communicationId = null;
        try{
            HttpResponse response = getConversationDetails(conversationId);
            
            if(response.getStatusCode() == 200){
                String body = response.getBody();
                System.debug(body);
                ICX_GenesysSDKEmail dataObj = (ICX_GenesysSDKEmail)JSON.deserialize(body, ICX_GenesysSDKEmail.class);  
                if(dataObj.conversationEnd == null){
                    // Get the communicationId (=sessionId) from response Obj
                    communicationId = getCommunicationId(dataObj, participantId);
                    disconnectEmailRequest(conversationId, participantId, communicationId);
                }
            }else{
                throw new ICXGenesysException('Error on Genesys request analytics/conversations/details');
            }     
        }catch(Exception e){
            System.debug(e.getMessage());
            new Logs.ERROR('ICX_GenesysExtensionPoint', 'APEX Code', e);
        } 
    }

    public class Participant {
        public String participantId;
        public String connectedTime;
        public List<Session> sessions;
    }   
    
    public class Session {
        public String sessionId;
        public String direction;
        public String mediaType;
        public String peerId;
    }    
    
    public class ICXGenesysException extends Exception {}
}