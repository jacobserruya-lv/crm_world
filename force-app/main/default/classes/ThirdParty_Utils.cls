/*
    About
    -----
    Description: Get settings
    Created for: Identity & Wordrobing project
    Create date: Jan 2019
	CreatedBy : Lirone GALLETTO

    Details
    -------
    Class get Third_Party_Settings MetaData for WS

    Update History
    --------------
    Sep 2021 / IDentity / Imad ALSID / ------ The class has been modified to meet the need for security. we created an internal class with the without sharing annotation to give the right access 
	                                          to customs settings in the code. The request on Third_Party_Settings__mdt has been transferred from the ThirdParty_Utils class to the inner class
											   getSettingWithoutSharing ---------
    
    Issues / TODOs
    --------------
*/
public with sharing class ThirdParty_Utils {
        
	/*
*** DESCRIPTION Get settings
*** RETURN     
*/
	public static Map<String,String> getSettings(String developerName){
		Map<String,String> SETTINGS = new Map<String,String>();
		try{
			
			// Get third party
			//Commented By Imad AL 20/09/2021
			/*	Third_Party_Settings__mdt metadata = [
				 SELECT EndPoint__c, Username__c, Password__c, Custom_Settings__c, Paths__c
				 FROM Third_Party_Settings__mdt 
				 WHERE DeveloperName =: developerName LIMIT 1
				 ];*/
			String queryThid = 'SELECT EndPoint__c, Username__c, Password__c, Custom_Settings__c, Paths__c '+
							   'FROM Third_Party_Settings__mdt WHERE DeveloperName = \''+ developerName +'\' LIMIT 1';
			Third_Party_Settings__mdt metadata = (Third_Party_Settings__mdt) new getSettingWithoutSharing().executeQuery(queryThid);
				// ADD Standard Fields
				SETTINGS.putAll(new Map<String,String>{
					'endpoint' => metadata.EndPoint__c,
						'username' => metadata.Username__c,
						'password' => metadata.Password__c
						});
			// Add Custom Paths
			if(!String.isEmpty(metadata.Paths__c)){
				
				Map<String,Object> fields = (Map<String,Object>)JSON.deserializeUntyped(metadata.Paths__c);
				
				for(String key : fields.keySet()){
					SETTINGS.put(key, (String)fields.get(key));
				}
			}
			
			// Add Custom Fields
			if(!String.isEmpty(metadata.Custom_Settings__c)){
				
				Map<String,Object> fields = (Map<String,Object>)JSON.deserializeUntyped(metadata.Custom_Settings__c);
				
				for(String key : fields.keySet()){
					SETTINGS.put(key, (String)fields.get(key));
				}
			}
		}
		catch(Exception ex){
			SETTINGS = new Map<String,String>();
			System.debug(ex.getMessage());
		}
		
		return SETTINGS;
	}
	public without sharing class getSettingWithoutSharing{
		
		private sObject executeQuery(string query){
			return Database.query(query);
		}
	}
	
}