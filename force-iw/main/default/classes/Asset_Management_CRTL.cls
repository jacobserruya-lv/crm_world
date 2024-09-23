public with sharing class Asset_Management_CRTL {

        public String appSettings { 
             get{
                String jsonInput =  [SELECT id ,Custom_Parameters__c  
                         FROM  BL_App_Setting__mdt 
                         WHERE Application__c ='iwa']?.Custom_Parameters__c;  
                Map<String, Object> settings = (Map<String, Object>) JSON.deserializeuntyped(jsonInput);
                 
                String vars = JSON.serialize(settings.get('envVariables'));
                          
                return vars;
             }
             private set;
        }
        public String domainURL {
             get{
                return System.Url.getOrgDomainUrl().toExternalForm() ; 
             }
             private set;
        }
        
        
        public class EnvVariables{
            
            public String clientSecret {get; set;}
            public String clientId {get; set;}
            public String path {get; set;}
            public String env {get; set;}
            public String username {get; set;}
            public String password {get; set;}
        }
}