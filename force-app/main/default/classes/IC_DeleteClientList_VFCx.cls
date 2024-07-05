/**
    About
    -----
    Description: Delete Client Lists 
    Created for: SOW: IC001 ICON project (IC0N Release 2014)
    Create date: May 2014

    Details
    -------
    Delete Client List 

    Update History
    --------------
    May 2014 / IC001/ Created by by Pape Babacar DIOUF  - Capgemini (Pape-Babacar.Diouf@capgemini.com)

    --------------
*/


public with sharing class IC_DeleteClientList_VFCx {
	
	public List<cUser> lstcUser{get;set;}
	public String ClientListId;
	public CLI_CliList__c ClientList;
	/* New variable **/
	public Boolean allChecked { get; set; }
	
	public IC_DeleteClientList_VFCx(){
		lstcUser = new List<cUser>();
		ClientListId = ApexPages.currentPage().getParameters().get('Id').escapeHtml4();
        ClientList = [SELECT Id, Name, Description__c, Active__c FROM CLI_CliList__c WHERE Id = :ClientListId limit 1];
		
		List<Id> listUserId = new List<Id>();
		 String reqSOQL;

		String clientListName = String.escapeSingleQuotes(ClientList.Name);
		List<CLI_CliList__c> lstCltLst = [SELECT OwnerId FROM CLI_CliList__c WHERE Name Like :clientListName];

		for(CLI_CliList__c cltLst : lstCltLst){
			listUserId.add(cltLst.OwnerId);
		}
		
		Set<ID> targetedUserRolesIds = IC_Utils.getAllSubRoleIds(new Set<ID>(new List<ID>{ UserInfo.getUserRoleId() }));
		List<User> lstUser;
		if(IC_Utils.isSystemAdmin()) {
			lstUser = [SELECT Id, Name, Title, Email, DefaultStore__c, UserRole.Name, ProfileId, Profile.Name, IsActive
					   FROM User
					   WHERE Id IN :listUserId
						Order By Profile.Name
						limit 1000];
		}

		else {
			Id userId = UserInfo.getUserId();
			lstUser = [SELECT Id, Name, Title, Email, DefaultStore__c, UserRole.Name, ProfileId, Profile.Name, IsActive
					   FROM User
					   WHERE Id IN :listUserId and (UserRoleId IN :targetedUserRolesIds OR Id = :userId)
						Order By Profile.Name
						limit 1000];
		}

		for(User user : lstUser){
			lstcUser.add(new cUser(user));
		}
		
	}
	
	/** EID Mass delete all client list members in one selection **/
	public PageReference CheckAll(){
  
       for(cUser clientListsMembers : lstcUser){
       clientListsMembers.selected = allChecked;
       }
  
        return null;
     } 
	
	public Pagereference deleteCL(){
		List<Id> lstId = getSelectedUserId();
		if(lstId.size()==0){
			PageReference page = New PageReference('/' + ClientListId);
			return page;
		} else {
			String reqSOQL = 'SELECT Id FROM CLI_CliList__c WHERE Name Like \''+String.escapeSingleQuotes(ClientList.Name)+'\' AND OwnerId IN :lstId ';
			List<CLI_CliList__c> lstCltLst = Database.query(reqSOQL);
			database.delete(lstCltLst, true);
			PageReference page = New PageReference(Label.IC_ClientList_TabURL);
			return page;
		}
    }
    
    public Pagereference cancel(){
    	PageReference page = New PageReference('/' + ClientListId);
		return page;
    }
    
  
    public List<Id> getSelectedUserId (){
    	List<Id> lstId = new List<Id>();
    	for(cUser cUserObj : lstcUser){
    		if(cUserObj.selected == true){
    			lstId.add(cUserObj.user.Id);
    		}
    	}
    	return lstId;
    }
    
    
    public String getFieldLabel(String objectName, String fieldName){
    	return Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe().getLabel();
    }
    
    public String getObjectLabel(String objectName){
    	return Schema.getGlobalDescribe().get(objectName).getDescribe().getLabel();
    }
    
    public String getObjectName(String objectName){
    	return Schema.getGlobalDescribe().get(objectName).getDescribe().getName();
    }
    
   
    public String getUserNameLabel(){
    	//return getFieldLabel('User', 'Name');
    	return Label.IC_CloneClientList_UserName;
    }
    
    public String getUserTitleLabel(){
    	return getFieldLabel('User', 'Title');
    }
    
    public String getUserEmailLabel(){
    	return getFieldLabel('User', 'Email');
    }
    
    public String getUserDefaultStoreLabel(){
    	return getFieldLabel('User', 'DefaultStore__c');
    }
    
    public String getUserRoleNameLabel(){
    	return getObjectLabel('UserRole');
    }
    
    public String getProfileNameLabel(){
    	return getObjectLabel('Profile');
    }
    
    public String getUserIsActiveLabel(){
    	return getFieldLabel('User', 'IsActive');
    }
   
    
    public class cUser {
    	public User user{get; set;}
    	public Boolean selected {get; set;}
    	public String ProfileName {get; set;}
    	
    	public cUser(User u){
    		user = u;
    		ProfileName = u.Profile.Name;
    		selected = false;
    	}
    }
    

}