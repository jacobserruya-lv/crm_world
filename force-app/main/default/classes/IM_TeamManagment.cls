/*
CreatedDate: March 2018
Company: Balink
Author: Jeremy Martiano
Description: Interface Web Sevice to Manage ICON teams
*/

@RestResource(urlMapping='/TeamManagment/*')
global with sharing class IM_TeamManagment {
    
 // global  class customException extends Exception {}

    /*=================================================================================================================*/ 
    @HttpGet
    global static void get() {

        RestRequest req = RestContext.request;
        String service = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);

        RestResponse res = RestContext.response;
        res.addHeader('Content-Type','application/json');
        res.statusCode = 200;
        string response;

        try {
            if(service == '') {
                response = JSON.serialize(getStoreUsers());
            }

            res.responseBody = Blob.valueOf(response);
            string logResponse='Success1';
           // UtilsLogs.addLog('ICON', 'IM_TeamManagment', JSON.serialize(req.params), JSON.serialize(req), response, '');
             new Logs.DEBUG('IM_TeamManagment','API',logResponse);
        }
        catch(Exception ex) {
            string error = ex.getMessage() + '\n\n' + ex.getLineNumber();
            res.responseBody = Blob.valueOf(JSON.serialize(error));
            res.statusCode = 400;
           // UtilsLogs.addLog('ICON', 'IM_TeamManagment', JSON.serialize(req.params), JSON.serialize(req),'', error);  
            new Logs.ERROR('IM_TeamManagment','CALLOUT',ex);

        }
    }


    /*=================================================================================================================*/ 
    @HttpPost
    global static void post() {

        RestRequest req = RestContext.request;
        String service = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
        
        Map<String,Object> body = new Map<String,Object>();
        if (req.requestBody != null) {
            body = (Map<String,Object>)JSON.deserializeUntyped(req.requestBody.toString());
        }

        RestResponse res = RestContext.response;
        res.addHeader('Content-Type','application/json');
        res.statusCode = 200;
        string response;

        try {
            if(service == '') {
                setTeamMembers(body);
            }
           // UtilsLogs.addLog('ICON','IM_TeamManagment', JSON.serialize(body), JSON.serialize(req), '', '');
            new Logs.DEBUG('IM_TeamManagment','API',response);
        }
        catch(Exception ex) {
            string error = ex.getMessage() + '\n\n' + ex.getLineNumber();
            res.responseBody = Blob.valueOf(JSON.serialize(error));
            res.statusCode = 400;
            //UtilsLogs.addLog('ICON','IM_TeamManagment', JSON.serialize(body), JSON.serialize(req),'', error);  
             new Logs.ERROR('IM_TeamManagment','API',ex);
        }
    }

    /*=================================================================================================================*/ 
    global static List<User> getStoreUsers() {
        List<UserWrapper> result = new List<UserWrapper>();
        User currentUser = getCurrentUser(false);

        List<User> users = [
            SELECT Id, FirstName, LastName, WWEmployeeNumber__c, RMS_ID__c,Email, FullPhotoUrl,
                (SELECT Id,TECH_UniqueKey__c From TeamMembers__r WHERE Manager__c = :currentUser.Id) 
            FROM User
            WHERE DefaultStore__c = :currentUser.DefaultStore__c AND
                DefaultStore__c != null AND DefaultStore__c != '' AND
                IsActive = true AND
                IsTechnicalUser__c = false AND
                (NOT Email LIKE 'store_%')
            LIMIT 500
        ];
        //for(User user : users){
        //    result.add(new UserWrapper(user));  
        //}
        return users;
    }

    /*=================================================================================================================*/ 
    global static Void setTeamMembers(Map<String, Object> body) {
      
        
     List<TeamMember__c> tmToUpsert = new List<TeamMember__c>();
        
        List<String> teamIds = ((String)body.get('teamIds')).split(';');
        List<User> teamUsers = [SELECT Id FROM User WHERE Id IN : teamIds];

        List<TeamMember__c> tmToDelete = [SELECT ID FROM TeamMember__c WHERE Manager__c = :UserInfo.getUserId() AND User__c NOT IN : teamIds];
        if (tmToDelete.size() > 0) {
            delete tmToDelete;
        }

        for(User user : teamUsers) {
            TeamMember__c tm = new TeamMember__c(User__c = user.Id, Manager__c = UserInfo.getUserId(), TECH_UniqueKey__c = UserInfo.getUserId()+user.Id);
            tmToUpsert.add(tm);
        } 

        if (tmToUpsert.size()>0) {
           upsert tmToUpsert TECH_UniqueKey__c;
        }

    }

    /*=================================================================================================================*/ 
    global static User getCurrentUser(Boolean needsTeamMembers) {
        return [SELECT Id, DefaultStore__c  FROM User WHERE Id =: UserInfo.getUserId()];
    }

    /*=================================================================================================================*/ 
    public static Integer indexOf(List<String> inList, String searchedString) {
        for(Integer i = 0; i<inList.size(); i++) {
            if(inList[i] == searchedString) {
                return i;
            }
        }
        return -1;
      }

    /*=================================================================================================================*/ 
    global class UserWrapper{
        public User User {get;set;}
        public Boolean InMyTeam {get;set;}

        public UserWrapper(User u) {
            User = u;
            if(u.TeamMembers__r.size() > 0) {
                InMyTeam = true;
            }
        } 
    }
}