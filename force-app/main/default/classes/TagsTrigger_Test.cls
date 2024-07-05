@isTest
public with sharing class TagsTrigger_Test {
    @isTest
    static void insertTag(){
      insert new Tag__c(
          Type__c = 'key_dates'
      );
    }
}