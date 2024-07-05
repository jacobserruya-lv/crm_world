@isTest

public class Tr_ExclusiveCampaignOrder_Handler_Test {
  @istest
    static void Test_ExclusiveCampaignOrder_Test() {
        Store__c store1 = new Store__c(RetailStoreId__c = 'A06');
        insert store1;
        Account acc = createAccount('test', 'test', null, null);
        //insert acc;
       // insert acc;
       
        Order__c order = new Order__c(Name ='Test',OrderNumber__c='2501002000228',Store__c=store1.id ,Account__c = acc.id,Source__c='KBRW',OrderDate__c=System.now());
       // insert order;

        Exclusive_Campaign_Order__c exclusivecampaign= new Exclusive_Campaign_Order__c(Store__c=store1.id,TECH_Serial_Number_Product__c='TESTlv' );
      //  insert exclusivecampaign;
        List<Exclusive_Campaign_Order__c> campaignList= new  List<Exclusive_Campaign_Order__c>();
        campaignList.Add(exclusivecampaign);

    //    Tr_ExclusiveCampaignOrder_Handler.checkSerialNumberExists(exclusivecampaign);
                Tr_ExclusiveCampaignOrder_Handler.getArtyStats();
                        Tr_ExclusiveCampaignOrder_Handler.getproductsAvailable();

                        Tr_ExclusiveCampaignOrder_Handler.getproductsAll();
                                Tr_ExclusiveCampaignOrder_Handler.handleTrigger(campaignList,null,null);

        



    }

    @istest
    static void Test_ExclusiveCampaignOrder2_Test() {
      Identity_TestFactory.createSettings();

      Store__c store1 = new Store__c(RetailStoreId__c = 'A06',StoreCountry__c='Americas', name='Americas');
        insert store1;
        Account acc = new Account();
        acc.Dreamid__c = 'TEST892S0';
        acc.DreamIdMasterClient__c = 'hhTEST894M0';
        acc.lastName = 'SlaveClient #1';
        acc.PersonEmail = 'master@master.com';
        acc.Unsubscribe__pc = true;
        acc.Date_Identity__pc = Date.today();
        acc.Can_Be_Contacted_By_Email__pc = true;
        acc.Can_Be_Contacted_By_SMS__pc	 = true;
        acc.Can_Be_Contacted_By_Mail__pc = true;

        insert acc;
        //insert acc;
       // insert acc;
       
        Order__c order = new Order__c(Name ='Test',OrderNumber__c='2501002000228',Store__c=store1.id ,Account__c = acc.id,Source__c='KBRW',OrderDate__c=System.now());
       // insert order;

        Exclusive_Campaign_Order__c exclusivecampaign= new Exclusive_Campaign_Order__c(Store__c=store1.id,TECH_Serial_Number_Product__c='TESTlv' );
      //  insert exclusivecampaign;
        List<Exclusive_Campaign_Order__c> campaignList= new  List<Exclusive_Campaign_Order__c>();
        campaignList.Add(exclusivecampaign);
        Quota__c quotas= new Quota__c(Status__c='Available',Store__c=store1.id);
        insert quotas;
         Quota__c quotas2= new Quota__c(Status__c='Available',Store__c=store1.id,MANAGEMENT_ZONE_LEVEL__c='13');
        insert quotas2;
      User  user2 = IDENTITY_TestFactory.createSimpleUser('firstName', 'lastName',  'ezrrzer@yaah.fr',  '909008089098'); 
      user2.country__c='CHINA';
      update user2;
      
      System.runas(user2){
        Test.startTest();
    //    Tr_ExclusiveCampaignOrder_Handler.checkSerialNumberExists(exclusivecampaign);
                Tr_ExclusiveCampaignOrder_Handler.getArtyStats();
                        Tr_ExclusiveCampaignOrder_Handler.getproductsAvailable();

                        Tr_ExclusiveCampaignOrder_Handler.getproductsAll();
                                Tr_ExclusiveCampaignOrder_Handler.handleTrigger(campaignList,null,null);

        

                                Test.stopTest();

                              }
    }
    
        @istest
    static void Test_ExclusiveCampaignOrder3_Test() {
      Identity_TestFactory.createSettings();

      Store__c store1 = new Store__c(RetailStoreId__c = 'A06',StoreCountry__c='Americas', name='Americas');
        insert store1;
        Account acc = new Account();
        acc.Dreamid__c = 'TEST892S0';
        acc.DreamIdMasterClient__c = 'hhTEST894M0';
        acc.lastName = 'SlaveClient #1';
        acc.PersonEmail = 'master@master.com';
        acc.Unsubscribe__pc = true;
        acc.Date_Identity__pc = Date.today();
        acc.Can_Be_Contacted_By_Email__pc = true;
        acc.Can_Be_Contacted_By_SMS__pc	 = true;
        acc.Can_Be_Contacted_By_Mail__pc = true;

        insert acc;
        //insert acc;
       // insert acc;
       
        Order__c order = new Order__c(Name ='Test',OrderNumber__c='2501002000228',Store__c=store1.id ,Account__c = acc.id,Source__c='KBRW',OrderDate__c=System.now());
       // insert order;

        Exclusive_Campaign_Order__c exclusivecampaign= new Exclusive_Campaign_Order__c(Store__c=store1.id,TECH_Serial_Number_Product__c='TESTlv' );
      //  insert exclusivecampaign;
        List<Exclusive_Campaign_Order__c> campaignList= new  List<Exclusive_Campaign_Order__c>();
        campaignList.Add(exclusivecampaign);
        Quota__c quotas= new Quota__c(Status__c='Available',Store__c=store1.id);
        insert quotas;
         Quota__c quotas2= new Quota__c(Status__c='Available',Store__c=store1.id,MANAGEMENT_ZONE_LEVEL__c='13');
        insert quotas2;
      User  user2 = IDENTITY_TestFactory.createSimpleUser('firstName', 'lastName',  'ezrrzer@yaah.fr',  '909008089098'); 
      user2.country__c='FRANCE';
      //  user2.MANAGEMENT_ZONE_LEVEL__c='ASIA NORTH';
      update user2;
      System.runas(user2){
        Test.startTest();
    //    Tr_ExclusiveCampaignOrder_Handler.checkSerialNumberExists(exclusivecampaign);
                Tr_ExclusiveCampaignOrder_Handler.getArtyStats();
                        Tr_ExclusiveCampaignOrder_Handler.getproductsAvailable();

                        Tr_ExclusiveCampaignOrder_Handler.getproductsAll();
                                Tr_ExclusiveCampaignOrder_Handler.handleTrigger(campaignList,null,null);

        

                                Test.stopTest();

                              }
    }
     @istest
      static void Test_ExclusiveCampaignOrder4_Test() {
      Identity_TestFactory.createSettings();

      Store__c store1 = new Store__c(RetailStoreId__c = 'A06',StoreCountry__c='Americas', name='Americas');
        insert store1;
        Account acc = new Account();
        acc.Dreamid__c = 'TEST892S0';
        acc.DreamIdMasterClient__c = 'hhTEST894M0';
        acc.lastName = 'SlaveClient #1';
        acc.PersonEmail = 'master@master.com';
        acc.Unsubscribe__pc = true;
        acc.Date_Identity__pc = Date.today();
        acc.Can_Be_Contacted_By_Email__pc = true;
        acc.Can_Be_Contacted_By_SMS__pc	 = true;
        acc.Can_Be_Contacted_By_Mail__pc = true;

        insert acc;
        //insert acc;
       // insert acc;
       
        Order__c order = new Order__c(Name ='Test',OrderNumber__c='2501002000228',Store__c=store1.id ,Account__c = acc.id,Source__c='KBRW',OrderDate__c=System.now());
       // insert order;

        Exclusive_Campaign_Order__c exclusivecampaign= new Exclusive_Campaign_Order__c(Store__c=store1.id,TECH_Serial_Number_Product__c='TESTlv' );
      //  insert exclusivecampaign;
        List<Exclusive_Campaign_Order__c> campaignList= new  List<Exclusive_Campaign_Order__c>();
        campaignList.Add(exclusivecampaign);
        Quota__c quotas= new Quota__c(Status__c='Available',Store__c=store1.id);
        insert quotas;
         Quota__c quotas2= new Quota__c(Status__c='Available',Store__c=store1.id,MANAGEMENT_ZONE_LEVEL__c='13');
        insert quotas2;
      User  user2 = IDENTITY_TestFactory.createSimpleUser('firstName', 'lastName',  'ezrrzer@yaah.fr',  '909008089098'); 
      user2.country__c='FRANCE';
       user2.MANAGEMENT_ZONE_LEVEL__c='ASIA NORTH';
      update user2;
        
      System.runas(user2){
                   PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'ArtyCappucines_Corporate'];

insert new PermissionSetAssignment(AssigneeId = user2.id, PermissionSetId = ps.Id);
        Test.startTest();
    //    Tr_ExclusiveCampaignOrder_Handler.checkSerialNumberExists(exclusivecampaign);
                Tr_ExclusiveCampaignOrder_Handler.getArtyStats();
                        Tr_ExclusiveCampaignOrder_Handler.getproductsAvailable();

                        Tr_ExclusiveCampaignOrder_Handler.getproductsAll();
                                Tr_ExclusiveCampaignOrder_Handler.handleTrigger(campaignList,null,null);

        

                                Test.stopTest();

                              }
    }
    
     private static Account createAccount(String firstname, String lastname, String phone, String email) {
        Account acc = new Account();
        acc.Firstname = firstname;
        acc.LastName = lastname;
        acc.PersonMobilePhone = phone;
        acc.PersonEmail = email;
        return acc;
    }
}