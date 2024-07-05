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
private class IC_MassCreateClientLists_VFCx_TEST {

    @TestSetup
    public static void setup() {
        String identityProfile = [SELECT Id FROM Profile WHERE Name = 'Identity User'][0].Id;
        insert new IC_Config__c(
            Name = 'Identity User',
            Value__c = identityProfile
        );
    }

    static testMethod void myUnitTest() {
       
        IC_MassCreateClientLists_VFCx mcl;
        Profile p = [select id, name from Profile where name =:'ICON_Corporate'];
        User user = IC_TestFactory.createUser ('Tester@fr.lv.test.com', p.id);
                
        user.MGMT_ZONE_SUB_LEVEL2__c = '22';
        user.MGMT_ZONE_SUB_LEVEL3__c = '78';
        user.DefaultStore__c = 'M11';
        insert user;
        System.runAs(user) {
            mcl = new IC_MassCreateClientLists_VFCx ();
            mcl.selectLevel2();
            mcl.selectLevel3();
            mcl.selectStore();
        }       
        user.MGMT_ZONE_SUB_LEVEL2__c = '22';
        user.MGMT_ZONE_SUB_LEVEL3__c = 'M11';
        System.runAs(user) {
            mcl.selectLevel2();
            mcl.selectLevel3();
            mcl.selectStore();
        }
        mcl.clientListName = '';  
        System.runAs(user) {
            mcl.validate();
        }
        
    }
}