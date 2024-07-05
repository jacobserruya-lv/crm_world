public with sharing class IDENTITY_jusoAddressSearch_CTRL {
    private static Set<String> SQL_RESERVED_WORDS_AND_SPECIAL_CHARACTERS = new Set<String>{'SELECT', 'INSERT', 'DELETE', 'UPDATE', 'CREATE', 'DROP', 'EXEC', 'UNION', 'FETCH', 'DECLARE', 'TRUNCATE', 'OR', '%', '=', '<', '>', '[', ']'};
    public String addressInputSearch { get; set; }
    public List<juso_wrapper> searchResults { get; set; }
    public String error_message { get; set; }
    public Boolean isItemSelected { get; set; }

    private Integer currentPage = 1; 
    private Integer totalCount; 
    private Integer countPerPage = 20;

    public boolean gethasPrevious()
    {
        return currentPage > 1;
    }
    public boolean gethasNext()
    {
        return totalCount != null ? (currentPage*countPerPage) < totalCount : false;
    }
    public void first(){
        currentPage = 1;
        search();
    }
    public void previous(){
        currentPage = currentPage > 1 ? currentPage - 1 : 1;
        search();
    }
    public void next(){
        
        currentPage += 1; 
        search();
    }
    public void last(){
        if(totalCount != null){
            // currentPage = totalCount / countPerPage;
            currentPage = Math.mod(totalCount, countPerPage) > 0 ? (Integer)Math.ceil(totalCount / countPerPage)+1 : (Integer)Math.ceil(totalCount / countPerPage);
            search();
        }
           
    }

    public void search(){
        try{
           
            if(isInputSafe(addressInputSearch))//check input is safe and not empty
            {
                HttpRequest req = new HttpRequest();
                String juso_path = '/eco-as/address-juso/v1/addrlink/addrLinkApiJsonp.do?resultType=json&confmKey=U01TX0FVVEgyMDE3MTAxNjE4MzQyOTEwNzQwNzk%3D'
                                    +'&countPerPage='+countPerPage
                                    +'&currentPage='+currentPage
                                    +'&keyword='+EncodingUtil.urlEncode(addressInputSearch, 'UTF-8');

                req.setEndpoint('callout:Mulesoft_SFID'+juso_path);
                req.setMethod('POST');
                req.setHeader ('Content-Length','0');
                req.setHeader ('client_id','{!$Credential.Username}');
                req.setHeader ('client_secret', '{!$Credential.Password}');

                Http http = new Http();
                HTTPResponse res = http.send(req);

                if(Integer.valueOf(res.getStatusCode()) == 200){
                    error_message = null;
                    String response = res.getBody();
                    searchResults = getJusoList(response.substring(1, response.length() - 1));
                }else{
                    error_message = Label.IDENTITY_registration_error_message;
                }
            }else{
                searchResults = null;
                error_message = Label.IDENTITY_registration_error_message;

            }
        }catch(Exception e){
            searchResults = null;
            error_message = Label.IDENTITY_registration_error_message;
        }
    }

    public void resetPopup() {
    
        addressInputSearch = '';
        searchResults = null;
        currentPage = 0;
        totalcount = null;
        error_message = null;
        isItemSelected = false;
        
    }
    public void setIsSelectedAccess(){

        isItemSelected = true;
    }
    private static Boolean isInputSafe(String input) {
        if (input == null || input.trim().length() == 0) {
             return false; 
        }
        input = input.toUpperCase();
         
        for (String word : SQL_RESERVED_WORDS_AND_SPECIAL_CHARACTERS) {
            if (input.contains(word)) {
                return false; 
            }
        }
        return true; 
    }
    
    private List<juso_wrapper> getJusoList(String apiResponse) {
        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(apiResponse);

        // Ensure that the "results" field is present
        if (resultMap.containsKey('results')) {
            Map<String, Object> resultsMap = (Map<String, Object>) resultMap.get('results');

            if (resultsMap.containsKey('common')) {//maybe should be static function TO REVIEW
                Map<String, Object> common = (Map<String, Object>)resultsMap.get('common');
                currentPage = Integer.valueOf(common.get('currentPage'));
                totalCount = Integer.valueOf(common.get('totalCount'));
                if(totalCount == 0){
                    error_message = Label.IDENTITY_registration_no_results;
                    return null;
                }
            }

            if (resultsMap.containsKey('juso')) {
                List<Object> jusoList = (List<Object>) resultsMap.get('juso');

                // Convert the list to a list of maps
                List<juso_wrapper> resultJusoList = new List<juso_wrapper>();
                for (Object jusoObject : jusoList) {
                    resultJusoList.add(new juso_wrapper((Map<String, Object>) jusoObject));
                }
                return resultJusoList;
            }
        }

        return null; // or an empty list depending on your use case
    }

    public class juso_wrapper {
        public string postalCode { get; set; }
        public string newAddress { get; set; }
        public string oldAddress { get; set; }
        public string state { get; set; }
        public string address1 { get; set; }
        public string address2 { get; set; }
        public string city { get; set; }


        public juso_wrapper(Map<String, Object> juso){
            this.postalCode = (string)juso.get('zipNo');
            this.newAddress = (string)juso.get('roadAddrPart1');
            this.oldAddress = (string)juso.get('jibunAddr');
            this.state = (string)juso.get('siNm');
            this.address1 = (string)juso.get('emdNm');
            this.address2 = (string)juso.get('rn')+(string)juso.get('buldMnnm')+((string)juso.get('buldSlno')!='0'?(string)juso.get('buldSlno'):'');
            this.city = juso.get('sggNm') != null && juso.get('sggNm') != '' ? (string)juso.get('sggNm') : this.state;

        }
    }
}