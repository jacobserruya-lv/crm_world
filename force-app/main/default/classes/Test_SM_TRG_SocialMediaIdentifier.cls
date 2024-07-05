@isTest
public class Test_SM_TRG_SocialMediaIdentifier {
  @isTest
    static void ScialMediaIdentifiers(){
      Account acc =  new Account(LastName = 'test');
      insert acc;
      Social_Media_Identifier__c identifier = new Social_Media_Identifier__c(Client__c = acc.id,Social_Enterprise_Id__c ='55556',Social_Media_Type__c='WeChat',Social_Id__c='WeChat_1235555babeth45');
      insert identifier;
        Social_Media_Identifier_CA__c ca = new Social_Media_Identifier_CA__c(Client_Social_Media_Identifier__c =identifier.id);
        insert ca;
        
    }
}