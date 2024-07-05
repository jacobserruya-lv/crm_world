@isTest
public class SO_ClientController_TEST {
    
    @isTest static void Test_findById() {
        
        Account acc 			= IC_TestFactory.createAccount();
		insert acc;
        
        Account a 				= [Select Id From Account Where Id =:acc.Id Limit 1];
        System.debug('$$$$$'+a.Id);
        System.debug('$$$$$'+acc.Id);
        
        Test.startTest();
        SO_ClientController.findById(a.Id);
       	Test.stopTest();
        
        System.assertEquals(acc.Id, a.Id);
           
    } 
  
    @isTest static void Test_getCountryMap() {
        
		Account acc = new Account();
        acc.LastName = 'Europe' + String.valueOf(System.now());
        acc.FirstName='Louis';
        acc.Salutation = 'Ms';
        acc.Segmentation__pc='VIC';
        acc.PrimaryAddressLine1__pc='Adresse ligne 1';
        acc.PrimaryAddressLine2__pc='Adresse ligne 2';
        acc.PrimaryAddressLine3__pc ='Adresse ligne 3';
        acc.PrimaryCity__pc='Paris';
        acc.PersonEmail='sylvie@lv.com';
        acc.PrimaryZipCode__pc='75000';
        acc.PrimaryCountry__pc='France';
        acc.PassportNumber__pc='ABC12345';
        acc.SPO_Country_code__pc = 'AFG';
        insert acc;

		Map<String, String> m = new Map<String, String>(); 
        m.put('AFGANISTAN', 'AFG');
        
        String s = m.get('AFGANISTAN');
        
        Account a 				= [Select Id, SPO_Country_code__pc From Account Where Id =:acc.Id Limit 1];
        
        System.debug('$$$$$'+ a.SPO_Country_code__pc);
        System.debug('$$$$$'+s);
        
        Test.startTest();
        SO_ClientController.getCountryMap();
       	Test.stopTest();
        
        
        System.assertEquals(acc.SPO_Country_code__pc, s);
    
        
    }

    @isTest
    public static void testFindAll1(){

        SO_Util.SearchClientData search = new SO_Util.SearchClientData();
        search.firstName = 'virginie';
        search.lastName = 'legrand';
        search.storeCode = 'A06';
        SO_Settings__c setting = new SO_Settings__c(Name='now-yours_mulesoft-active', Value__c='true');
		insert setting;

        String searchJSON = JSON.serialize(search);
        SO_ProductPagedResult ppr = SO_ClientController.findAll(searchJSON, 20, 1, false);

        // RMS call not done during tests
        System.assertEquals(0, ppr.total);
        system.assertEquals('null', ppr.clientRmsList);
    }
    @isTest
    public static void testFindAll2(){

        SO_Util.SearchClientData search = new SO_Util.SearchClientData();
        search.firstName = 'virginie';
        search.lastName = 'legrand';
        
        SO_Settings__c setting = new SO_Settings__c(Name='now-yours_mulesoft-active', Value__c='false');
		insert setting;

        String searchJSON = JSON.serialize(search);
        SO_ProductPagedResult ppr = SO_ClientController.findAll(searchJSON, 20, 1, false);

        // RMS call not done during tests
        System.assertEquals(0, ppr.total);
        system.assertEquals('null', ppr.clientRmsList);
    }

    @isTest
    public static void findAllInSalesforce_TEST(){

        // Init
        Account acc = new Account();
        acc.Firstname = 'Peter';
        acc.Lastname = 'Parker';
        acc.PersonEmail = 'peter.parker@test.com';
        acc.Phone = '+33999999999';
        acc.SPO_Country__pc = 'FRA';//SPO_Country_code__pc = 'FRA';
        acc.PrimaryZipCode__pc = '75001';
        
        Account acc2 = ICX_TestFactory.createAccount();
        insert new List<Account> {acc, acc2};

        SO_Util.SearchClientData search = new SO_Util.SearchClientData();
        search.firstName = 'Peter';
        search.lastName = 'Parker';
        search.email = 'peter.parker@test.com';
        search.phoneNumber = '+33999999999';
        search.zipCode = '75001';
        search.country = 'FRA';

        String searchJSON = JSON.serialize(search);
        
        // Search
        SO_ProductPagedResult ppr = SO_ClientController.findAllInSalesforce(searchJSON, 20, 1);

        // RMS call not done during tests
        System.assertEquals(1, ppr.total);
        system.assertEquals(null, ppr.clientRmsList);
        system.assert(ppr.sobjects != null && ppr.sobjects.size() == 1);
        Account result = (Account) ppr.sobjects[0];
        system.assertEquals('Parker', result.Lastname);
    }

    /* @isTest static void getUser() {
         
         User usr  				= IC_TestFactory.createUser('utest');
         insert usr;
         
         User u 				=[Select Id, MANAGEMENT_ZONE_LEVEL__c From User Where Id =:usr.Id Limit 1];
        
         System.debug('$$$$$'+u.MANAGEMENT_ZONE_LEVEL__c);
         System.debug('$$$$$'+usr.MANAGEMENT_ZONE_LEVEL__c);
        
       	 Test.startTest();
        SO_ClientController.getUser();
       	 Test.stopTest();
        
        System.assertEquals(usr.MANAGEMENT_ZONE_LEVEL__c, u.MANAGEMENT_ZONE_LEVEL__c);
        

     }*/
        
    }