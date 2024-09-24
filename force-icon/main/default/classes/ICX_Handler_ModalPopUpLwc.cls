public with sharing class ICX_Handler_ModalPopUpLwc {
    public ICX_Handler_ModalPopUpLwc() {

    }

    @AuraEnabled
    public static User getUSerValue(Id userId){
        try {
            User usr = [Select id,accountid ,account.personemail,TECH_Email__c ,  username, email from user where id =: userId limit 1 ];

            return usr;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static  void UpdateEmail(String inputEmail, Id userId, Id AccountId){
        User usr = new User (id= userID, Email =inputEmail, TECH_Email__c = inputEmail, Username =inputEmail);
        usr.Username = inputEmail;
        usr.email = inputEmail; 
        usr.TECH_Email__c = inputEmail ; 
        
            //try {
                update usr;
                insertAccountAsync(AccountId, inputEmail);
            /*} catch (Exception e) {
                throw new AuraHandledException(e.getMessage());

            }*/

    }

        
    @future
    public static void insertAccountAsync(String AccountId, String inputEmail) {
        System.debug('AccountId = ' +AccountId);
        // Créer un nouveau compte

        Account acc = [Select id, personEmail from account where id =: Accountid];
        try {
            if (acc.personEmail == null){
            acc.personEmail = inputEmail ; 
            update acc;
            }else {
                TECH_IntegrationManager__c  integM = new TECH_IntegrationManager__c ( AccountId__c =Accountid,
        Error__c =true,	
        StartTime__c = System.today(),	
        Operation__c ='UPDATE', 
        Trigger_Event__c ='UPDATE',	
        Object_Id__c =  Accountid, 	
        Object_Name__c ='ACCOUNT');
        System.debug( integM + ' TEST ' );
        insert integM;            
            }

           
    
           
        } catch (DmlException e) {
            // Gérer les exceptions DML
            System.debug('An error occurred: ' + e.getMessage());
        }
    }


}