@RestResource(urlMapping='/person-names/*')
global without sharing class PersonNames_WS {
    /*=================================================================================================================*/
    //HTTP Request POST called 

    @HttpPost
    global static void post() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        try{

            
            system.debug(req.requestURI);
            String service = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
        
        
            res.addHeader('Content-Type','application/json');
            res.statusCode = 200;
            string response;

            List<String> body = new List<String>();
            List<String> accountIds = new list<string>();
            List<Account> accounts = new list<Account>();
            List<String> userIds = new list<string>();
            List<User> users = new list<User>();
            Map<String, String> results = new Map<String, String>();
            if (req.requestBody != null) {
                body = (List<String>) JSON.deserialize(req.requestBody.toString(), List<String>.class);
                for(String b: body){
                    if(b.startsWith('001')){
                        accountIds.add(b);
                    } else if(b.startsWith('005')){
                        userIds.add(b);

                    }
                }

                if(accountIds.size() > 0){
                    accounts = [Select Id,Name from Account where id in : accountIds];
                    for(Account acc: accounts){
                        results.put(acc.Id, acc.Name);
                    }
                }
                if(userIds.size() > 0){
                    users = [Select Id,Name from User where id in : userIds];
                    for(User u: users){
                        results.put(u.Id, u.Name);
                    }
                }

            }
            // if(req.requestURI == '/'){
            //     // response = JSON.serialize(OnlineAppointments_Utils.upsertOnlineAppointment(body),true);
            // }
            res.responseBody = Blob.valueOf(JSON.serialize(results));
        }
        catch(Exception ex){
            system.debug(ex.getMessage() + '\n\n' + ex.getLineNumber());
            
                res.responseBody = Blob.valueOf(ex.getMessage() + '\n\n' + ex.getLineNumber());
                res.statusCode = 400;
            
        }
    }

    public class PersonNames_WS_Exception extends Exception {}

}