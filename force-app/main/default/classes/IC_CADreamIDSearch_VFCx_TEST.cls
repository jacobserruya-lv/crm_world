/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class IC_CADreamIDSearch_VFCx_TEST {

    static testMethod void myUnitTest() {
       
        
        IC_CADreamIDSearch_VFCx ca = new IC_CADreamIDSearch_VFCx ();
        
        UserDreamId__c c = new UserDreamId__c();        
        c.CA_DREAM_ID__c = 'dreamId1';
        c.CA_Name__c = 'name1';
        c.CA_RMS_ID__c = 'rms1';
        c.CA_Retail_Store_Code__c = 'storeCode1';
        c.CA_Retail_Store_Name__c = 'storeName1';
        insert c;
        
        c = new UserDreamId__c();        
        c.CA_DREAM_ID__c = 'dreamId2';
        c.CA_Name__c = 'name2';
        c.CA_RMS_ID__c = 'rms2';
        c.CA_Retail_Store_Code__c = 'storeCode2';
        c.CA_Retail_Store_Name__c = 'storeName2';
        insert c;
        
        c = new UserDreamId__c();        
        c.CA_DREAM_ID__c = 'dreamId3';
        c.CA_Name__c = 'name3';
        c.CA_RMS_ID__c = 'rms3';
        c.CA_Retail_Store_Code__c = 'storeCode3';
        c.CA_Retail_Store_Name__c = 'storeName3';
        insert c;
        
        
        ca.searchCriterias.CA_RMS_ID__c = null;
        ca.searchCriterias.CA_Retail_Store_Code__c = null;
        ca.searchCADreamIDs ();
        List<UserDreamId__c> resultTest = ca.results;        
        System.assert(resultTest.size() == 0);
        System.assertequals(resultTest.size(), 0);
        
        ca.searchCriterias.CA_RMS_ID__c = 'rms1, rms2';
        ca.searchCriterias.CA_Retail_Store_Code__c = null;
        ca.searchCADreamIDs ();
        resultTest.clear();
        resultTest = ca.results;        
        System.assert(resultTest.size() == 2);
        System.assertequals(resultTest.size(), 2);
        
        ca.searchCriterias.CA_RMS_ID__c = null;
        ca.searchCriterias.CA_Retail_Store_Code__c = 'storeCode3';
        ca.searchCADreamIDs ();
        resultTest.clear();
        resultTest = ca.results;      
        System.assert(resultTest.size() == 1);
        System.assertequals(resultTest.size(), 1);
        
        ca.searchCriterias.CA_RMS_ID__c = 'rms1';
        ca.searchCriterias.CA_Retail_Store_Code__c = 'storeCode3';
        ca.searchCADreamIDs ();
        resultTest.clear();
        resultTest = ca.results;        
        System.assert(resultTest.size() == 0);
        System.assertequals(resultTest.size(), 0);
        
        ca.searchCriterias.CA_RMS_ID__c = 'rms1';
        ca.searchCriterias.CA_Retail_Store_Code__c = 'storeCode1';
        ca.searchCADreamIDs ();
        resultTest.clear();
        resultTest = ca.results;         
        System.assert(resultTest.size() == 1);
        System.assertequals(resultTest.size(), 1);
        
        List <UserDreamId__c> myList = new List<UserDreamId__c>();
        for (Integer i = 0; i<100; i++) {
            c = new UserDreamId__c();        
            c.CA_DREAM_ID__c = 'dreamIds'+String.valueOf(i);
            c.CA_Name__c = 'name';
            c.CA_RMS_ID__c = 'rms';
            c.CA_Retail_Store_Code__c = 'storeCode';
            c.CA_Retail_Store_Name__c = 'storeName';
            myList.add(c);
        }
        insert myList;
        
        ca.searchCriterias.CA_RMS_ID__c = 'rms';
        ca.searchCriterias.CA_Retail_Store_Code__c = 'storeCode';
        ca.searchCADreamIDs ();
        resultTest.clear();
        resultTest = ca.results;         
        System.assert(resultTest.size() == 100);
        System.assertequals(resultTest.size(), 100);
                
    }
}