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
private class IC_Administration_VFCx_TEST {

    @TestSetup
    public static void setup() {
        String identityProfile = [SELECT Id FROM Profile WHERE Name = 'Identity User'][0].Id;
        insert new IC_Config__c(
            Name = 'Identity User',
            Value__c = identityProfile
        );
    }

    static testMethod void myUnitTest() {
        Account acc = IC_TestFactory.createAccount();
        ID id = [Select Id from Profile][0].Id;
        User user = IC_TestFactory.createUser('john@acme.com', id);
        user.DREAMId__c = '331133';
        acc.TECH_DreamIdSA__pc = '331133';
        insert user;
        insert acc;
        
        ICON_Default_ClientList__c cll1 = new ICON_Default_ClientList__c();
        cll1.Name = 'US';
        cll1.DefautClientList__c = 'Maman, va, a , dakar';
        insert cll1;
        
        ICON_Default_ClientList__c cll2 = new ICON_Default_ClientList__c();
        cll2.Name = 'China';
        cll2.DefautClientList__c = 'Maman, va, a , dakar';
        insert cll2;
        
        IC_Administration_VFCx ctrl = new IC_Administration_VFCx();
        ctrl.initializeDefaultClienList();
        
        ctrl.dreamIds = null;
        ctrl.form_ReaffectSA_IsValid();
        ctrl.form_ClientListCreation_IsValid();
        ctrl.launchSriptBatchClientUpdate();
        ctrl.param = 'US';
        ctrl.updateClientList();
        //ctrl.launchSriptBatchClientListsCreation();
        
        ctrl.dreamIds = '313, 212, 198, 114, 92, 70, 66, 25, 14, 7, 331133';
        ctrl.clientList = 'MAMAN, jai, encore, rate, lavion';
        ctrl.form_ReaffectSA_IsValid();
        ctrl.form_ClientListCreation_IsValid();
        ctrl.getMyListOfDreamsIDs();
        ctrl.getMyListOfClientList();
        
        ctrl.dreamIds = '331133';
        ctrl.getMyListOfDreamsIDs();
        ctrl.getMyListOfClientList();
        ctrl.launchSriptBatchClientUpdate();
        ctrl.launchSriptBatchClientListsCreation();
        
        
    }
}