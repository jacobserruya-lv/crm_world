@isTest
private class PPR_PurchProductTrigger_TEST {
  @testSetup
  static void setup() {
    Account acc = new Account(
      FirstName = 'Calev',
      LastName = 'Machiah',
      DREAMID__c = 'asdfghj145',
      AttachedStore__pc = 'UEC',
      AttachedStoreCode__pc = 'UEC',
      PersonEmail = 'test@test.com',
      SPO_Country_code__pc = 'USA'
    );
    insert acc;

    Club_and_Seasons__c clubSneakers = new Club_and_Seasons__c(
      Name = 'Sneakers'
    );
    insert clubSneakers;

    Club_MemberShip__c clubM = new Club_MemberShip__c(
      clientId__c = acc.Id,
      dreamId__c = 'asdfghj145',
      Club_and_Seasons__c = clubSneakers.id,
      clubStatus__c = 'Pearl',
      lastStatusUpdated__c = system.now(),
      Unique_Key__c = acc.DREAMID__c + '_' + clubSneakers.Name
    );
    insert clubM;

    /*LV_Club_Setting__mdt setting = new LV_Club_Setting__mdt();
    setting.label
    setting.DeveloperName = 'Sneakers';
    setting.skusProductCatalogueFiltered__c = 'BOQU2PMI%,BPQU1PSC%,BPQU1PTX%,BPQU1PMI%,BL9U1PSR%,BH9U1PSR%,BJ9U1PSR%,BM9U1PSR%,BN9U1PSR%,BJ9U4PSR%,BM9U3PSR%,BM9U2PSR%,BJ9U3PSR%';
    setting.skusProductReferentialsFiltered__c = '%LV TRAINER%,%LV SKATE%,%NIKE%';
    setting.statusClubFilteredList__c = 'Client Advisor,Influencer,Not Eligible	';
    setting.clubNameFilter__c = 'Sneakers';
    insert setting;*/
  }

  @isTest
  static void testHandleAfterInsert() {
    Account user1 = [
      SELECT Id
      FROM Account
      WHERE DREAMID__c = 'asdfghj145'
      LIMIT 1
    ];

    List<PPR_PurchProduct__c> pprlList = new List<PPR_PurchProduct__c>();

    PPR_PurchProduct__c pprp1 = new PPR_PurchProduct__c();
    pprp1.Client__c = user1.Id;
    pprp1.TicketNumber__c = '195141ge65';
    pprp1.RMSSKUCode__c = '1AARQT';
    pprp1.quantity__c = 1;
    pprlList.add(pprp1);

    PPR_PurchProduct__c pprp2 = new PPR_PurchProduct__c();
    pprp2.Client__c = user1.Id;
    pprp2.TicketNumber__c = '195141ge65';
    pprp2.RMSSKUCode__c = '1AB8SR';
    pprp2.quantity__c = 1;
    pprlList.add(pprp2);

    PPR_PurchProduct__c pprp3 = new PPR_PurchProduct__c();
    pprp3.Client__c = user1.Id;
    pprp3.TicketNumber__c = '195141ge65';
    pprp3.RMSSKUCode__c = '1AB8RU';
    pprp3.quantity__c = -1;
    pprlList.add(pprp3);

    Test.startTest();
    insert pprlList;
    Test.stopTest();
  }

  @isTest 
  static void scheduleTest() {
    Account user1 = [
      SELECT Id
      FROM Account
      WHERE DREAMID__c = 'asdfghj145'
      LIMIT 1
    ];

    Test.startTest();
		ProductReferential__c pr1 = new ProductReferential__c(Name = 'LV TRAINER', SKUCode__c = '1ABM2L', Activity__c = 'SHOES', Family__c = 'SNEAKER');
		insert pr1;

    ProductCatalogue__c product1 = new ProductCatalogue__c(SKU__c='TST123', longSkuId__c = 'BN9U1PSR', Workshop__c = '1798');
    insert product1;

    List<PPR_PurchProduct__c> pprlList = new List<PPR_PurchProduct__c>();

    PPR_PurchProduct__c pprp1 = new PPR_PurchProduct__c();
    pprp1.Client__c = user1.Id;
    pprp1.TicketNumber__c = '195141ge65';
    pprp1.RMSSKUCode__c = '1ABM2L';
    pprp1.quantity__c = 1;
    pprlList.add(pprp1);

    PPR_PurchProduct__c pprp2 = new PPR_PurchProduct__c();
    pprp2.Client__c = user1.Id;
    pprp2.TicketNumber__c = '195141ge65';
    pprp2.RMSSKUCode__c = 'TST123';
    pprp2.quantity__c = 1;
    pprlList.add(pprp2);

    PPR_PurchProduct__c pprp3 = new PPR_PurchProduct__c();
    pprp3.Client__c = user1.Id;
    pprp3.TicketNumber__c = '195141ge65';
    pprp3.RMSSKUCode__c = 'TST123';
    pprp3.quantity__c = -1;
    pprlList.add(pprp3);

    insert pprlList;

    String cron = '0 0 23 * * ?';
    BatchCWForClubMembersScheduler schd = new BatchCWForClubMembersScheduler();
    String jobId = System.schedule('test BatchCWForClubMembersScheduler', cron, schd);

    BatchCollectionWallForClubMembers cwMembers = new BatchCollectionWallForClubMembers(false, 1);
    Database.executeBatch(cwMembers);  
    Test.stopTest();
  }
}