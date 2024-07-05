/**
    About
    -----
    Description: Clone Client Lists 
    Created for: SOW: IC001 ICON project (IC0N Release 2014)
    Create date: May 2014

    Details
    -------
    Clone Client List 

    Update History
    --------------
    May 2014 / IC001/ Created by by Pape Babacar DIOUF  - Capgemini (Pape-Babacar.Diouf@capgemini.com)

    --------------
*/

public with sharing class IC_CloneClientList_VFCx {

	public List<CLI_CliList__c> lstCliList{get;set;}
	public String ClientListId;
	public CLI_CliList__c ClientList;
	
	public IC_CloneClientList_VFCx(){
		
        ClientListId = ApexPages.currentPage().getParameters().get('Id').escapeHtml4();
        ClientList = [SELECT Id, Name, Description__c, Active__c, TECH_UserId__c, ExpirationDate__c FROM CLI_CliList__c WHERE Id = :ClientListId limit 1];

		lstCliList = new List<CLI_CliList__c>();
		for(integer i=0;i<10;i++){
			lstCliList.add(new CLI_CliList__c(Name=ClientList.Name));
		}
        
	}
	
	
	
	public Pagereference save(){
		
		if(lstCliList.size()== 0){
			PageReference page = New PageReference('/' + ClientListId);
			return page;
		} else {
			List<CLI_CliList__c> lstClientListToCreate = new List<CLI_CliList__c>();
			Set<String> setUserId = new Set<String>();
			for(CLI_CliList__c lkpUser : lstCliList){
				setUserId.add(lkpUser.TECH_UserId__c);
			}
			
			for(String u:setUserId){
				if(u!= null && u!=''){
					CLI_CliList__c cli = new CLI_CliList__c();
					cli.Name = ClientList.Name;
					cli.Description__c = ClientList.Description__c;
					cli.Active__c = ClientList.Active__c;
					cli.ExpirationDate__c = ClientList.ExpirationDate__c;
					cli.OwnerId = u;
					
					lstClientListToCreate.add(cli);
				}
			}
			/*** Insertion des Clients List ***/	
			Database.insert(lstClientListToCreate, true);
			PageReference page = New PageReference(Label.IC_ClientList_TabURL);
			return page;
		}
    }
    
    public Pagereference cancel(){
    	PageReference page = New PageReference('/' + ClientListId);
		return page;
    }

}