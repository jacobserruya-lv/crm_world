@Istest
public with sharing class ICX_MessengerCountryOptions_Test {
    @isTest static void testMethod1() {
        List<Messenger_Configuration__mdt> messengerConfiguration = [SELECT Label ,ISO3_Code__c , Messaging_Queue_Id__c ,Confirmation_Message__c FROM Messenger_Configuration__mdt WHERE  value__c > 0 ORDER BY value__c limit 4];

        Test.startTest();
        List<ICX_MessengerCountryOptions.optionOutput> botOutputs = ICX_MessengerCountryOptions.countryOptions(null);//index = 0;
        Test.stopTest();
        System.assertequals(botOutputs.get(0).index,1);
        system.assertequals(botOutputs.get(0).options.size(),messengerConfiguration.size()+1);//+1 for the 'Another Country' added option


    }
}