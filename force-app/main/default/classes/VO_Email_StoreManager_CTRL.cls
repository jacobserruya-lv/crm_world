/*
VO_Email_StoreManager_CTRL
Bernard Wach - 07/11/2015
Modify by Menash Yamin in 17.02.16 to support VOICE 2 CR No. 12:
add isAfterSalesUser and isSalesUser that 
*/

public without sharing class VO_Email_StoreManager_CTRL {
   	private String d;		// Date for query
    public String srv {get;set;}
	public String storeCode {get;set;}
	private final static String PS_AFTERSALES_NAME = VO_Utils.VOICE_AFTER_SALES;
	private final static String PS_SALES_NAME = VO_Utils.VOICE_SALES;
	private String storeName;
	public Boolean isAfterSalesUser {get;set;}
	public Boolean isSalesUser {get;set;}
	public String userId {get;
		set
		{
			userId = value;
			List<PermissionSetAssignment> lis =  [SELECT Id, PermissionSet.Name,PermissionSet.label,AssigneeId
		             FROM PermissionSetAssignment
		             WHERE AssigneeId = :value];
		    initBooleanIfSalesOrAfterSalesUser(lis);
		}
	   }
	//public List<PermissionSetAssignment> lis {get;set;}

	public VO_Email_StoreManager_CTRL() {
		VO_Config__c cfgSrv = VO_Config__c.getInstance('server');
		srv = cfgSrv.Value__c;
		Date dte = Date.today().addDays(-1);
		d = dte.year() + (dte.month() < 10 ? '-0' : '-') + dte.month() + (dte.day() < 10 ? '-0' : '-') + dte.day();		
	}

	public void initBooleanIfSalesOrAfterSalesUser(List<PermissionSetAssignment> lis)
	{
		for(PermissionSetAssignment ps :lis)
		{
			if(ps.PermissionSet.label == PS_AFTERSALES_NAME)
			{
				this.isAfterSalesUser = true;
			}
			if(ps.PermissionSet.label == PS_SALES_NAME)
			{
				this.isSalesUser = true;
			}
		}
	}

 	public String getStoreName() {
		Store__c st = [select Id, Name from Store__c where RetailStoreId__c = :storeCode limit 1];
		return st.Name;
 	} 
  
    public String getNbRecoveryActs() {
		Store__c st = [select Id, Name from Store__c where RetailStoreId__c = :storeCode limit 1];
		String query = 'select id from VO_Survey__c where Scoring__c = \'Recovery act\' and Status__c = \'New\' and AnswerDate__c>=' + d + ' and Store__c = \'' + st.Id + '\'';
    	List<VO_Survey__c> surveys = Database.query(query);
    	return String.valueOf(surveys.size()); 
    }

    public String getNbDelighteds() {
		Store__c st = [select Id, Name from Store__c where RetailStoreId__c = :storeCode limit 1];
		String query = 'select id from VO_Survey__c where Scoring__c = \'Delighted client\' and Status__c = \'New\' and AnswerDate__c>=' + d + ' and Store__c = \'' + st.Id + '\'';
    	List<VO_Survey__c> surveys = Database.query(query);
    	return String.valueOf(surveys.size()); 
    }
    public String getNbPromoters() {
		Store__c st = [select Id, Name from Store__c where RetailStoreId__c = :storeCode limit 1];
		String query = 'select id from VO_Survey__c where Scoring__c = \'Promoter\' and Status__c = \'New\' and AnswerDate__c>=' + d + ' and Store__c = \'' + st.Id + '\'';
    	List<VO_Survey__c> surveys = Database.query(query);
    	return String.valueOf(surveys.size()); 
    }


}