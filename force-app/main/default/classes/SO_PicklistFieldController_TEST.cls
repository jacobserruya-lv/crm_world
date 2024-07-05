@isTest
public with sharing class SO_PicklistFieldController_TEST {
    @testSetup
    static void testSetup(){
        SO_PicklistFieldController.PicklistEntryWrapper pew = new SO_PicklistFieldController.PicklistEntryWrapper();
        pew.active = 'active';
        pew.defaultValue = 'defaultValue';
        pew.label = 'label';
        pew.value = 'value';
        pew.validFor = 'validFor';
    }

    @isTest
    static void test_getDependentOptionsImpl(){
        Map<String, List<String>> dependentOptionsImpl1 = SO_PicklistFieldController.getDependentOptionsImpl('objApiName', 'contrfieldApiName', 'depfieldApiName');
        System.assertEquals(null, dependentOptionsImpl1);

        Contact c = new Contact();
        Map<String, List<String>> dependentOptionsImpl2 = SO_PicklistFieldController.getDependentOptionsImpl('Contact', 'AnniversaryDay__c', 'Star_Allergy__c');

        Map<String, List<String>> dependentOptionsImpl3 = SO_PicklistFieldController.getDependentOptionsImpl('Contact', '', '');
    }

    @isTest
    static void test_getDependentOptions(){
        Contact c = new Contact();
        List<String> dependentOptions = SO_PicklistFieldController.getDependentOptions('Contact', 'AnniversaryDay__c', 'Star_Allergy__c', 'Star_Allergy__c');
    }
}