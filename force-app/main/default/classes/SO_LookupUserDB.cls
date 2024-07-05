public with sharing class SO_LookupUserDB {
	/*@AuraEnabled
	   public static List < sObject > LookupUserDB(String userName, String ObjName) {

	    system.debug('ObjectName-->' + ObjName);
	    system.debug('userName search -->' + userName);
	    String searchKey = userName + '%';

	    List < sObject > returnList = new List < sObject > ();

	    // Create a Dynamic SOQL Query For Fetch Record List
	    //The below profile Id is hardcoding, will need to replace by custom setting or util class
	    String sQuery =  'Select Id, Name, Email From ' + ObjName + ' Where Name LIKE: searchKey limit 100';
	    List < sObject > lstOfRecords = Database.query(sQuery);

	    for (sObject obj: lstOfRecords) {
	        returnList.add(obj);
	    }
	    for(sObject s: lstOfRecords){
	        System.debug('return list of user found in SO_LookupUserDB' + s);
	    }

	    return returnList;
	   }*/

	@AuraEnabled
	public static String searchDB(String objectName, String fld_API_Text, String fld_API_Val,
	                              Integer lim,String fld_API_Search,String searchText, String filter ){

		searchText='\'%' + String.escapeSingleQuotes(searchText.trim()) + '%\'';


		String query = 'SELECT ' + String.escapeSingleQuotes(fld_API_Text) + ' ,' + String.escapeSingleQuotes(fld_API_Val) +
		               ' FROM ' + String.escapeSingleQuotes(objectName) +
		               ' WHERE ' + String.escapeSingleQuotes(fld_API_Search) + ' LIKE ' + searchText +
		               (String.isNotBlank(filter) ? filter : '') +
		               ' LIMIT ' + lim;

		List<sObject> sobjList = Database.query(query);
		List<ResultWrapper> lstRet = new List<ResultWrapper>();

		for(SObject s : sobjList) {
			ResultWrapper obj = new ResultWrapper();
			obj.obj = s;
			obj.objName = objectName;
			obj.text = String.valueOf(s.get(fld_API_Text));
			obj.val = String.valueOf(s.get(fld_API_Val));
			lstRet.add(obj);
		}
		return JSON.serialize(lstRet);
	}

	public class ResultWrapper {
		public sObject obj {get; set;}
		public String objName {get; set;}
		public String text {get; set;}
		public String val {get; set;}
	}
}