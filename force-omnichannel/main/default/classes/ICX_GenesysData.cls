public class ICX_GenesysData {
    public CallLog callLog;
    public String eventName;
    public Interaction interaction; 
    
    public class Interaction {  
        public Map<String, String> Attributes;
        public String ani; // Internal On outbound call
        public String calledNumber;
        public List<String> callbackNumbers;
        public String connectedTime;
        public String direction;
        public String displayAddress;
        public String disposition; // wrap up
        public Integer dispositionDurationSeconds; // wrap up       
        public String endTime;
        public String id;
        public Integer interactionDurationSeconds;
        public Boolean isConnected;
        public Boolean isDisconnected;
        public Boolean isDone;
        public Boolean isCallback;
        public Boolean isChat;
        public Boolean isClienteling; // custom property populated in Extension point by callout to Pure Cloud API
    	public Boolean isDialer;
        public Boolean isEmail;
        public Boolean isInternal;
        public Boolean isMessage; // is Chat 
        public Boolean isThirdPartyEmail;
        public Boolean isVoicemail;
        public String name;
        public String phone;
 		public String queueName; 
        public String recordingState;
        public String remoteName;
        public String startTime;
        public String state;
        public Integer totalAcdDurationSeconds;
        public Integer totalIvrDurationSeconds;  
    }    
    
    public class CallLog {
        public String ActivityDate;
        public String CallObject;
        public String CallType;
        public Integer calldurationinseconds;
        public String id;
        public String subject;
        public String status;
        public String rType;
        // public String whoid; // single Match Account
    }
    
    public static String replace(String data){
        return data.replace('"Type":', '"rType":');
    }
}