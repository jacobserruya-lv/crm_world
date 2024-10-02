public with sharing class ICX_CampaignListViewController {
    
    @AuraEnabled (cacheable=true)
    public static List<Map<String, String>> getCampaignsList(Integer pageSize,Integer pageIndex, String nameSearchekey, Map<String, String> filters){
        List<Campaign__c> campaignList = new List<Campaign__c>();
        List<Map<String, String>> myCampaignsMap = new List<Map<String,String>>();
        Id UserId = System.UserInfo.getUserId();
        String UserProfileName = [Select Id, Name FROM Profile WHERE Id =: System.UserInfo.getProfileId()].Name;
        String nameFilter = '%' + nameSearchekey + '%';
        
        String query = 'Select Id, Name, Status__c, StartDate__c, EndDate__c, Priority__c,TargetedClients__c,ContactedClients__c, InterestedClients__c, NotInterestedClients__c FROM Campaign__c ';
        
        if(UserProfileName == 'ICONiCS_SA_Manager' || UserProfileName.contains('Admin')){
            query += 'WHERE CreatedById =: UserId ';
            
        }else if(UserProfileName == 'ICONiCS_SA'){
            query += 'WHERE Id IN (SELECT Campaign__c FROM CampaignMember__c WHERE AssignedCA__c =: UserId) ';
        }
        
        if(nameSearchekey != null && nameSearchekey != '' ) {
            query += 'AND NAME LIKE:nameFilter ';
        }
        
        if(filters != null && !filters.isEmpty()){
            for(String filter: filters.keySet()){
                if(filters.get(filter)!= null){
                    query += ' AND '+ filter +' =\'' + filters.get(filter) + '\' ';
                }
            }
        }
        
        query += 'ORDER BY Status_Order__c, Name ASC LIMIT :pageSize OFFSET :pageIndex';
        campaignList = Database.query(query);

        if(campaignList.size()>0){
            myCampaignsMap = processCampaignData(campaignList);
        }
        
        return myCampaignsMap;
    }
    
    @AuraEnabled (cacheable=true)
    public static List<Map<String, String>> getCampaignMembersList(Integer pageSize,Integer pageIndex, String nameSearchekey, Map<String, String> filters, String campaignId){
        List<CampaignMember__c> campaignMembersList = new List<CampaignMember__c>();
        List<Map<String, String>> myCampaignMembersMap = new List<Map<String,String>>();
        
        Id UserId = System.UserInfo.getUserId();
        String UserProfileName = [Select Id, Name FROM Profile WHERE Id =: System.UserInfo.getProfileId()].Name;
        String nameFilter = '%' + nameSearchekey + '%';
        
        String query = 'SELECT Id, Campaign__c, Campaign__r.Name, Campaign__r.Status__c,Campaign__r.CreatedById,'
            + 'Campaign__r.StartDate__c, Campaign__r.EndDate__c, Campaign__r.Priority__c, Status__c, '
            + 'Member__c, Member__r.Name, AssignedCA__c,AssignedCA__r.Name, Contacted__c, Contacted_Channel__c,Interested__c,'
            + 'Member__r.Sub_Segment__c, Member__r.Can_Be_Contacted_By_Email__pc,'
            + 'ClientContactability__c FROM CampaignMember__c WHERE ';
        
        if(campaignId != null){
            query += 'Campaign__c =:campaignId ';
        }
        
        if(UserProfileName == 'ICONiCS_SA_Manager' || UserProfileName.contains('Administrator')){
            query += (campaignId != null)? '' : 'Campaign__r.CreatedById =: UserId ';   
        }else if(UserProfileName == 'ICONiCS_SA'){
            query += (campaignId != null)? 'AND AssignedCA__c =: UserId ' :  'AssignedCA__c =: UserId ';
        }
        
        if(nameSearchekey != null && nameSearchekey != '' ) {
            query += 'AND Member__r.Name LIKE: nameFilter ';
        }
        
        if(filters != null && !filters.isEmpty()){
            for(String filter: filters.keySet()){
                if(filters.get(filter) != null){
                    if(filter == 'campaignName'){
                        String campaignNameFilter = '%' + filters.get(filter) + '%';
                        query += ' AND Campaign__r.Name LIKE:campaignNameFilter ';
                    }else{
                        query += ' AND '+ filter +' =\'' + filters.get(filter) + '\' ';
                    }
                }
            }
        }
        
        try{
            query += 'ORDER BY Member__r.Name ASC LIMIT :pageSize OFFSET :pageIndex';
            campaignMembersList = Database.query(query);
            
        }catch(Exception e){
            System.debug(e);
        }
        
        if(campaignMembersList.size() > 0){
            myCampaignMembersMap = processCampaignMemberData(campaignMembersList);
        }
        
        return myCampaignMembersMap;
    }
    
    @AuraEnabled (cacheable=true)
    public static Boolean isManagerUser(){
        String UserProfileName = [Select Id, Name FROM Profile WHERE Id =: System.UserInfo.getProfileId()].Name;
        if(UserProfileName == 'ICONiCS_SA_Manager' || UserProfileName.contains('Administrator')){
            return true;
        }else if(UserProfileName == 'ICONiCS_SA'){
            return false;
        }
        
        return false;
    }
    
    
    private static List<Map<String, String>> processCampaignData(List<Campaign__c> campaignList){
        List<Map<String, String>> myCampaignsMap = new List<Map<String,String>>();
        
        for(Campaign__c cam: campaignList){
            Map<String, String> campaignMap = new Map<String, String>{
                'Id' => cam.Id,
                    'Name' => cam.Name,
                    'Status' => cam.Status__c,
                    'StartDate' => cam.StartDate__c?.format(),
                    'EndDate' => cam.EndDate__c?.format(),
                    'Priority' => cam.Priority__c,
                    'TargetClients' => String.valueOf(cam.TargetedClients__c),
                    'ContactedClients' => String.valueOf(cam.ContactedClients__c),
                    'Interested' => String.valueOf(cam.InterestedClients__c),
                    'NotInterested' => String.valueOf(cam.NotInterestedClients__c)
                    };
                        myCampaignsMap.add(campaignMap);
        }
        
        return myCampaignsMap;
    }
    
    private static List<Map<String, String>> processCampaignMemberData(List<CampaignMember__c> campaignMembersList){
        List<Map<String, String>> myCampaignMembersMap = new List<Map<String,String>>();
        
        for(CampaignMember__c camMemeber : campaignMembersList){
            
            Map<String, String> campaignMemberMap = new Map<String, String>{
                'Id' => camMemeber.Id,
                    'Name' => camMemeber.Campaign__r.Name,
                    'Status' => camMemeber.Status__c,
                    'StartDate'=> camMemeber.Campaign__r.StartDate__c.format(),
                    'EndDate' => camMemeber.Campaign__r.EndDate__c.format(),
                    'Priority' => camMemeber.Campaign__r.Priority__c,
                    'ClientName' => camMemeber.Member__r.Name,
                    'CA' => camMemeber.AssignedCA__r.Name,
                    'Contacted' => camMemeber.Contacted__c,
                    'ClientSegmentation' => camMemeber.Member__r.Sub_Segment__c,
                    'ContactChannel' => camMemeber.Contacted_Channel__c,
                    'ClientInterest' => camMemeber.Interested__c,
                    'ClientContactability' => camMemeber.ClientContactability__c
                    };
                        
                        myCampaignMembersMap.add(campaignMemberMap);
        }
        
        return myCampaignMembersMap;
    }
}