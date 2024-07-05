/**
	About
	-----
	Description: Factory class
	Created for: SOW: IC001 ICON project
	Create date: Feb 2013

	Details
	-------
    Factory class to create Task 

	Update History
	--------------
	Feb 2013 / IC001/ Created by Maroun IMAD 
  Sep 2016 / RMO / PIPA Law enhancement
	
	Issues / TODOs
	--------------
*/

public without sharing class IC_Factory {
	
	public static Task createTask(String whatId, String subject, String description, Date dueDate, String ownerId, String status, String priority) {
        return createTask(whatId, subject, description, dueDate, ownerId, status, priority, 'Phone') ;
    } 
 
	public static Task createTask(String whatId, String subject, String description, Date dueDate, String ownerId, String status, String priority, String actionType) {
        Task newTask = new Task(ownerId = (IC_UTILS.empty(ownerId)?UserInfo.getUserId():ownerId), 
        						WhatId = whatId, 
        						Priority = (IC_UTILS.empty(priority)?'Normal':priority),
        						ActivityDate = (IC_UTILS.empty(dueDate)?Date.toDay():dueDate),
        						Status = (IC_UTILS.empty(status)?'Completed':status),
        						Subject = subject,
        						ActionType__c = (IC_UTILS.empty(actionType)?'Other':actionType),
        						Description = description);
        return newTask ;
    } 	
    
    public static String insertTask(Task newTask){
    	insert newTask;
    	system.debug ('*** myTask id = ' + newTask.id);
    	return System.Label.IC_TaskCreated +newTask.Id;
    }
    
    public static User getUser(String userId) {
  		User selectedUser = [select id, FirstName, LastName, defaultStore__c from User where id = :userId];
  		return selectedUser;
  	}
  	
  	public static Account getAccountt(String accountId) {
  		Account selectedAcc = [select id, Salutation, Title__pc, FirstName, LastName, PersonEmail, OwnerId, PersonMobilePhone from Account where id =:accountId];
  		return selectedAcc;
  	}
  	public static Boolean isAdmin()
 	{
 		User currentUser  = [SELECT Id, country__c,ProfileId FROM USER WHERE Id = :UserInfo.getUserId() limit 1];
        return (currentUser.ProfileId == System.Label.IC_System_Admin_Profile_Id || currentUser.ProfileId == System.Label.IC_LVAdministrator_ProfileID);
    	
 	}  	

    public static Boolean isPIPAUser(User user){
      return isPIPACountry (user.Country__c);
    }

    public static Boolean isPIPAUser (){
      return isPIPACountry (IC_UTILS.getUserCountry());
    }

    // Checks for Country name as well as Country Code
    public static Boolean isPIPACountry (String country){
      // Metadata type queries don't support OR Statements
      return [SELECT id FROM PIPA_Law_Settings__mdt WHERE Label = :country].size() > 0 || [SELECT id FROM PIPA_Law_Settings__mdt WHERE Country_Code__c = :country].size() > 0;
    }

    public static Boolean CanPIPACountryEditClient (String country){
      PIPA_Law_Settings__mdt[] pls = [SELECT Can_edit_Clients__c FROM PIPA_Law_Settings__mdt WHERE Label = :country];

      return pls.isEmpty() || pls[0].Can_edit_Clients__c;
    }

    public static String getPIPACountryCode (String country){
      PIPA_Law_Settings__mdt[] pls = [SELECT Country_Code__c FROM PIPA_Law_Settings__mdt WHERE Label = :country];

      if (pls.size() > 0)
        return pls[0].Country_Code__c;
      else
        return '';
    }

    public static List<String> getListPIPACountryCodesToHide (String country){
      List<String> l = new List<String>();
      for (PIPA_Law_Settings__mdt pls : [SELECT Country_Code__c FROM PIPA_Law_Settings__mdt WHERE Label <> :country])
        l.add(pls.Country_Code__c);

      System.debug ('### PIPA Countries to hide : ' + l);
      return l;
    }

    public static List<String> getListPIPACountryNamesToHide (String country){
      List<String> l = new List<String>();
      for (PIPA_Law_Settings__mdt pls : [SELECT Label FROM PIPA_Law_Settings__mdt WHERE Label <> :country])
        l.add(pls.Label);

      System.debug ('### PIPA Countries to hide : ' + l);
      return l;
    }

}