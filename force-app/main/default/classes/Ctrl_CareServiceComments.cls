public with sharing class Ctrl_CareServiceComments {
    @AuraEnabled
    public static CareService__c getCareServiceFromId(Id sID) {
        CareService__c item = new CareService__c();
        System.debug('**** in controller getCareServiceFromId '+sID);
        if(sID != null) {                 
        	List<CareService__c> services = [ SELECT Id, CA_Name__c, Followup_Comments__c, ICON_Comments__c
                                             from CareService__c 
                                             where Id = :sID ];        
        	if(services.size() != 0) {
            	item =  services[0];
            }
        }   
       return item;        
    }
    
    @AuraEnabled
      public static String getUserName() {
        //return userinfo.getName();
        return (userinfo.getLastName()+' '+userinfo.getFirstName());
      }
    
    @AuraEnabled
    public static Boolean addICONComment(Id sID, String comment) {       
        CareService__c item = new CareService__c();
        System.debug('**** in controller addICONComment '+sID);        
        if(sID == null) {
            return false;
        }                     
        List<CareService__c> services = [ SELECT Id, ICON_Comments__c
                                         from CareService__c 
                                         where Id = :sID ];        
        if(services.size() != 0) {
            item =  services[0];
        } else {
            return false;
        }
        
        System.debug('**** old comment is '+item.ICON_Comments__c);
        System.debug('**** comment is '+comment);		
		item.ICON_Comments__c = comment;
        System.debug('**** new comment is '+item.ICON_Comments__c);
        
        try {
            upsert item;            
        } catch (DmlException e){
            return false;
        }
       return true;        
    }

}