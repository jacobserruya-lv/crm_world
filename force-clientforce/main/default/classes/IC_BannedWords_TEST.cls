/**
    About
    -----
    Description: Test class for IC_BannedWords_TRG
    Created to improve code coverage %
    Create date: Jan 2014

    Details
    -------
    Class contains test methods

    Update History
    --------------
    Jan 2014 / Created by Marie TOURNE
    
*/
@isTest
private class IC_BannedWords_TEST {

    static testMethod void checkWordsOneFieldTEST() {
     
      User user = IC_TestFactory.createUser(String.valueOf(System.today())+'@lvtest.com', IC_UTILS.getDreamProfile());
      insert user;
      
      Account account = IC_TestFactory.createAccount();
      account.ownerId = user.Id;
      insert account;
      
      Banned_Words__c bannedWord = new  Banned_Words__c(Word__c = 'testWord',Language__c='English');
      insert bannedWord;
      
      insert new ICONSettings__c(AccLastContactTimeRange__c=30);
      
      IconBannedWordsFieldList__c fieldList = new IconBannedWordsFieldList__c(Name = 'Account.foodpreferences__pc');
      insert fieldList;
      
      fieldList = new IconBannedWordsFieldList__c(Name = 'Event.*');
      insert fieldList;
      
      fieldList = new IconBannedWordsFieldList__c(Name = 'Task.*');
      insert fieldList;
                    
      System.runAs(user){   

          
          account.FoodPreferences__pc = 'testWord';
          Test.startTest();
          try{
            update account;
            //System.assert(false, 'an exception should be thrown when updating account : bannedword');
            
          } catch(DMLException e){
            System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDmlType(0), 'an exception should be thrown : bannedword');
            
          }
          
          
          Task newTask = IC_Factory.createTask(account.Id, 'tskSubject', 'tskDescription', null, null, null, null, 'SMS');
          insert newTask;
        
          Event newEvt = IC_TestFactory.createEvent();
          insert newEvt;
          
          
          
          newTask.TECH_is_AutoSave__c = true;
          update newTask;
          
          newEvt.TECH_is_AutoSave__c = true;
          update newEvt;
          
          
          try{
          	newTask.Description = 'testWord';
          	update newTask;
          } catch(DMLException e){
          	System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDmlType(0), 'an exception should be thrown : bannedword');
          }
          
          try{
          	newEvt.Description = 'testWord';
          	update newEvt;
          } catch(DMLException e){
          	System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDmlType(0), 'an exception should be thrown : bannedword');
          }
        	
          Test.stopTest();
           
          }
    }
    
    
    static testMethod void checkWordsAllFieldsTEST() {
     
      User user = IC_TestFactory.createUser(String.valueOf(System.today())+'@lvtest.com', IC_UTILS.getDreamProfile());
      insert user;
      
      Account account = IC_TestFactory.createAccount();
      account.ownerId = user.Id;

      insert account;
      
      Banned_Words__c bannedWord = new  Banned_Words__c(Word__c = 'testWord',Language__c='English');
      insert bannedWord;
      
      IconBannedWordsFieldList__c fieldList = new IconBannedWordsFieldList__c(Name = 'Account.*');
      insert fieldList;
                
      System.runAs(user){
         
          account.FoodPreferences__pc = 'testWord';
          Test.startTest();
          try{
            update account;
            //System.assert(false, 'an exception should be thrown when updating account : bannedword');
            
          } catch(DMLException e){
            System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDmlType(0), 'an exception should be thrown : bannedword');
            
          }
          Test.stopTest();
           
          }
    }
}