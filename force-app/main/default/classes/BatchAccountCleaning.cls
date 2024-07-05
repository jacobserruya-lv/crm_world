/**
Description: Batch used in the developper console in order to empty email adresses and phone numbers for all clients
Created for: SOW: IC007 ICON project
Create date: 27/08/2013

Update History
--------------
27/08/2013 / IC007/ Created by Laurent Loiseau
12/03/2019 : Bernard Wach


*/
global class BatchAccountCleaning  implements Database.Batchable<sObject>{
    
    
    public String query;
    
    /**Bernard's Version*/
    global BatchAccountCleaning(String idmin, String idmax) {       
        query = 'SELECT Id, PersonHomePhone, PersonMobilePhone, Phone, LocalHomePhone__pc, LocalMobilePhone__pc, PersonOtherPhone, PersonEmail, createddate FROM Account '
            + 'where Id >= \'' + idmin.trim() + '\'' + (!String.isBlank(idmax) ? ' and Id < \'' + idmax.trim() + '\'' : '');
    }
    
    /**OLD VERSION
     global BatchAccountCleaning(){
    
     query = 'SELECT Id, PersonHomePhone, PersonMobilePhone, Phone, LocalHomePhone__pc, LocalMobilePhone__pc, PersonOtherPhone, PersonEmail, createddate FROM Account Where PersonHomePhone != null OR PersonMobilePhone != null OR Phone != null OR PersonEmail != null';
   }
 
   
  global database.querylocator start(Database.BatchableContext CD){
    System.debug('#### START - BatchAccountCleanning');
    System.debug('#### query : '+query);
        return Database.getQueryLocator(query);   
  } 
    
  global void execute(Database.BatchableContext CD, List<sObject> scope){
    
    try{
      List<Account> lstAcc = new List<Account>();
            for(sObject o:scope){
              Account myAccount = (Account)o;
              myAccount.PersonHomePhone=System.Label.IC_AnonymousPhone;
              myAccount.PersonMobilePhone=System.Label.IC_AnonymousPhone;
              myAccount.Phone=System.Label.IC_AnonymousPhone;
              myAccount.PersonEmail=System.Label.IC_AnonymousEmail;
              lstAcc.add(myAccount);                
            }               
            update lstAcc;
    
        }catch (DmlException e){
            // Process exception here
            System.debug('#### '+e.getTypeName()+' Exception:'+e.getMessage()+' '+e.getStackTraceString());
        }
    }
    */
    

    global database.querylocator start(Database.BatchableContext CD){
        return Database.getQueryLocator(query);   
    } 
    
    global void execute(Database.BatchableContext CD, List<sObject> scope){

        try{
            List<Account> lstAcc = new List<Account>();
            for(sObject o:scope){
                Account myAccount = (Account)o;

                if (!String.isBlank(myAccount.PersonHomePhone)) myAccount.PersonHomePhone += '11';
                if (!String.isBlank(myAccount.PersonMobilePhone)) myAccount.PersonMobilePhone += '12';
                if (!String.isBlank(myAccount.Phone)) myAccount.Phone += '13';
                if (!String.isBlank(myAccount.LocalHomePhone__pc)) myAccount.LocalHomePhone__pc += '14';
                if (!String.isBlank(myAccount.LocalMobilePhone__pc)) myAccount.LocalMobilePhone__pc += '15';
                if (!String.isBlank(myAccount.PersonOtherPhone)) myAccount.PersonOtherPhone += '16';
                if (!String.isBlank(myAccount.PersonEmail)) myAccount.PersonEmail += '.lv';
                lstAcc.add(myAccount); 
                
                 
            }  

            update lstAcc;

        }catch (DmlException e){
            // Process exception here
            System.debug('#### '+e.getTypeName()+' Exception:'+e.getMessage()+' '+e.getStackTraceString());
        }
    }
    
    
    global void finish(Database.BatchableContext CD){}
    
}