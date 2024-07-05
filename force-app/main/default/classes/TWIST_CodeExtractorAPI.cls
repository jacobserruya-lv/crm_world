@RestResource(urlMapping='/code/extraction')
global class TWIST_CodeExtractorAPI {
  
   @HttpGet
    global static CodeResponseWrapper doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        try {
            if(req!=null && req.params!=null && !req.params.isEmpty() && req.params.get('code')!=null){
                res.statusCode = 200;
                return  new CodeResponseWrapper(req.params.get('code'), req.params.get('sfdc_community_url'), req.params.get('sfdc_community_id'), req.params.get('state'));
            }
            else {
                res.statusCode = 400;
                return new CodeResponseWrapper('Missing parameters');
            }
       } catch (Exception e) {
           res.statusCode = 500;
           return new CodeResponseWrapper('Could not parse auth code redirect URI');
            
       }
           
      
   }
  @TestVisible
   global class CodeResponseWrapper {
      public String code;
      public String sfdcCommunityUrl;
      public String sfdcCommunityId;
      public String state;
      public Boolean success;
      public String errMsg;
       
       public CodeResponseWrapper(){
           this.code = null;
           this.sfdcCommunityUrl = null;
           this.sfdcCommunityId = null;
           this.state = null;
       }
      
       public CodeResponseWrapper(String code, String sfdcCommunityUrl, String sfdcCommunityId, String state) {
           this.code = code;
           this.sfdcCommunityUrl = sfdcCommunityUrl;
           this.sfdcCommunityId = sfdcCommunityId;
           this.state = state;
           this.success = true;
       }
      
        public CodeResponseWrapper(String errMsg) {
           this.code = null;
           this.sfdcCommunityUrl = null;
           this.sfdcCommunityId = null;
           this.state = null;
           this.success = false;
           this.errMsg = errMsg;
       }  
       
       
   }
}