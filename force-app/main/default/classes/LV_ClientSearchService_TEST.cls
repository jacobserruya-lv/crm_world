@isTest
private class LV_ClientSearchService_TEST {
    @testSetup static void setup(){
    Account client1 = IC_TestFactory.createAccount();
    client1.FirstName='FirstName1';
    client1.LastName='LastName1';
    client1.FirstName2__pc='';
    client1.LastName2__pc='';
    client1.DREAMID__c = '00000001'; 
    client1.PersonEmail = 'myemail1@test.com'; 
    client1.Phone = '+0000000001';
    client1.PersonMobilePhone = '+0000000001';
    client1.PersonHomePhone = '+0000000001';
    client1.LocalMobilePhone__pc = '0000000001';
    client1.LocalWorkPhone__pc = '0000000001';
    client1.LocalHomePhone__pc = '0000000001';
    client1.PrimaryCity__pc = 'city1';
    client1.PrimaryZipCode__pc = 'zipcode1';
    client1.PrimaryCountry__pc = 'FRANCE';
    client1.AttachedStoreCountry__pc = '';
    client1.PassportNumber__pc = '0000000001';
    
    Database.saveResult srCli1 = Database.insert(client1);
system.debug('***************client1*********'+ client1) ;

    Account client2 = IC_TestFactory.createAccount();
    client2.FirstName='FirstName2';
    client2.LastName='LastName2';
    client2.FirstName2__pc='';
    client2.LastName2__pc='';
    client2.DREAMID__c = '00000002';
    client2.PersonEmail = 'myemail2@test.com';
    client2.Phone = '+0000000002';
    client2.PersonMobilePhone = '+0000000002';
    client2.PersonHomePhone = '+0000000002';
    client2.LocalMobilePhone__pc = '0000000002';
    client2.LocalWorkPhone__pc = '0000000002';
    client2.LocalHomePhone__pc = '0000000002';
    client2.PrimaryCity__pc = 'city2';
    client2.PrimaryZipCode__pc = 'zipcode2';
    client2.PrimaryCountry__pc = 'USA';
    client2.AttachedStoreCountry__pc = '';
    client2.PassportNumber__pc = '0000000002';
    
    Database.saveResult srCli2 = Database.insert(client2);

    Account client3 = IC_TestFactory.createAccount();
    client3.FirstName='FirstName3';
    client3.LastName='LastName3';
    client3.FirstName2__pc='';
    client3.LastName2__pc='';
    client3.DREAMID__c = '00000003';
    client3.PersonEmail = 'myemail3@test.com';
    client3.Phone = '+0000000003';
    client3.PersonMobilePhone = '+0000000003';
    client3.PersonHomePhone = '+0000000003';
    client3.LocalMobilePhone__pc = '0000000003';
    client3.LocalWorkPhone__pc = '0000000003';
    client3.LocalHomePhone__pc = '0000000003';
    client3.PrimaryCity__pc = 'city3';
    client3.PrimaryZipCode__pc = 'zipcode3';
    client3.PrimaryCountry__pc = 'KOREA';
    client3.AttachedStoreCountry__pc = System.Label.IC_KOREAN_FILTER_CODE;
    client3.PassportNumber__pc = '0000000003';
    
    Database.saveResult srCli3 = Database.insert(client3);
    
    Account client4 = IC_TestFactory.createAccount();
    client4.FirstName='FirstName4';
    client4.LastName='LastName4';
    client4.FirstName2__pc='FirstName4';
    client4.LastName2__pc='LastName4';
    client4.DREAMID__c = '00000004';
    client4.PersonEmail = 'myemail4@test.com';
    client4.Phone = '+0000000004';
    client4.PersonMobilePhone = '+0000000004';
    client4.PersonHomePhone = '+0000000004';
    client4.LocalMobilePhone__pc = '0000000004';
    client4.LocalWorkPhone__pc = '0000000004';
    client4.LocalHomePhone__pc = '0000000004';
    client4.PrimaryCity__pc = 'city4';
    client4.PrimaryZipCode__pc = 'zipcode4';
    client4.PrimaryCountry__pc = 'JAPAN';
    client4.AttachedStoreCountry__pc = '';
    client4.PassportNumber__pc = '0000000004';
    
    Database.saveResult srCli4 = Database.insert(client4);
    
    MergedClients__c clientMerge = new MergedClients__c();
    clientMerge.Name = '00000002';
    clientMerge.Absorbed_DreamId__c = '22222222';
    clientMerge.MasterClient__c = '00000002';
    
    Database.saveResult srMgr = Database.insert(clientMerge);

    createLabelToAccountFieldsCity('FirstName', 'FirstName');
    createLabelToAccountFieldsCity('LastName', 'LastName');
    createLabelToAccountFieldsCity('FirstName2', 'FirstName2__pc');
    createLabelToAccountFieldsCity('LastName2', 'LastName2__pc');
    createLabelToAccountFieldsCity('Email', 'PersonEmail');
    createLabelToAccountFieldsCity('Phone', 'PersonMobilePhone,Phone,PersonHomePhone,LocalMobilePhone__pc,LocalWorkPhone__pc,LocalHomePhone__pc');
    createLabelToAccountFieldsCity('LocalPhone', 'LocalMobilePhone__pc,LocalWorkPhone__pc,LocalHomePhone__pc');
    createLabelToAccountFieldsCity('InternationalPhone', 'PersonMobilePhone,Phone,PersonHomePhone');
    createLabelToAccountFieldsCity('Country', 'PrimaryCountry__pc');
    createLabelToAccountFieldsCity('Passport', 'PassportNumber__pc');
    createLabelToAccountFieldsCity('ZipCode', 'PrimaryZipCode__pc');
    createLabelToAccountFieldsCity('City', 'PrimaryCity__pc');
    createLabelToAccountFieldsCity('DreamId', 'DREAMID__c');
    createLabelToAccountFieldsCity('Owner', 'ownerId');

    createServiceCriteriaForSOQL('Owner');
    
    createSOSLDecisionMatrix('FirstName', 'Name Fields');
    createSOSLDecisionMatrix('LastName', 'Name Fields');
    createSOSLDecisionMatrix('Email', 'Email Fields');
    createSOSLDecisionMatrix('Phone', 'Phone Fields');
    createSOSLDecisionMatrix('LocalPhone', 'Phone Fields');
    createSOSLDecisionMatrix('InternationalPhone', 'Phone Fields');
    createSOSLDecisionMatrix('FirstName2', 'All Fields');
    createSOSLDecisionMatrix('LastName2', 'All Fields');
    createSOSLDecisionMatrix('DreamId', 'All Fields');
    createSOSLDecisionMatrix('Country', 'All Fields');
    createSOSLDecisionMatrix('Owner', 'All Fields');
    createSOSLDecisionMatrix('City', 'All Fields');
    createSOSLDecisionMatrix('Passport', 'All Fields');
    createSOSLDecisionMatrix('ZipCode', 'All Fields');

    //createServiceManualChoice('Service_Query_Settings', true, 2000, false, false);
    createServiceManualChoice('Service_Query_Settings', false, 2000, true, false);
  }
    
    @isTest static void lastNameExactMatchTest() {
        init();

        List<LV_UTILS.SearchCriteria> listSearchCriterias = new List<LV_UTILS.SearchCriteria>();
        listSearchCriterias.add(createSearchCriteria('LastName', 'EQUALS', 'LastName1'));

        List<Account> listClient = new List<Account>();
        listClient = LV_ClientSearchService.searchClient(listSearchFields, listSearchCriterias, clientPerPage, 
                                                            currentPage, orderByField, isDreamIdUsed, attachedFilter, queryType);

        system.assertEquals(1,listClient.size());
    }

  @isTest static void lastNameWildcardTest() {
    init();

    List<LV_UTILS.SearchCriteria> listSearchCriterias = new List<LV_UTILS.SearchCriteria>();
    listSearchCriterias.add(createSearchCriteria('LastName', 'startsWith', 'LastName'));

    List<Account> listClient = new List<Account>();

    LV_ClientSearchService service = new LV_ClientSearchService();
    listClient = LV_ClientSearchService.searchClient(listSearchFields, listSearchCriterias, clientPerPage, 
                                                        currentPage, orderByField, isDreamIdUsed, attachedFilter, queryType);

    system.assertEquals(4,listClient.size());
  }
  
  @isTest static void firstNameExactMatchTest() {
        init();

        List<LV_UTILS.SearchCriteria> listSearchCriterias = new List<LV_UTILS.SearchCriteria>();
        listSearchCriterias.add(createSearchCriteria('FirstName', 'EQUALS', 'FirstName1'));

        List<Account> listClient = new List<Account>();
        listClient = LV_ClientSearchService.searchClient(listSearchFields, listSearchCriterias, clientPerPage, 
                                                            currentPage, orderByField, isDreamIdUsed, attachedFilter, queryType);

        system.assertEquals(1,listClient.size());
    }

  @isTest static void firstNameWildcardTest() {
    init();

    List<LV_UTILS.SearchCriteria> listSearchCriterias = new List<LV_UTILS.SearchCriteria>();
    listSearchCriterias.add(createSearchCriteria('FirstName', 'startsWith', 'FirstName'));

    List<Account> listClient = new List<Account>();
    listClient = LV_ClientSearchService.searchClient(listSearchFields, listSearchCriterias, clientPerPage, 
                                                        currentPage, orderByField, isDreamIdUsed, attachedFilter, queryType);

    system.assertEquals(4,listClient.size());
  }
  
  @isTest static void lastName2ExactMatchTest() {
        init();

        List<LV_UTILS.SearchCriteria> listSearchCriterias = new List<LV_UTILS.SearchCriteria>();
        listSearchCriterias.add(createSearchCriteria('LastName2', 'EQUALS', 'LastName4'));

        List<Account> listClient = new List<Account>();
        listClient = LV_ClientSearchService.searchClient(listSearchFields, listSearchCriterias, clientPerPage, 
                                                            currentPage, orderByField, isDreamIdUsed, attachedFilter, queryType);

        system.assertEquals(1,listClient.size());
    }

  @isTest static void lastName2WildcardTest() {
    init();

    List<LV_UTILS.SearchCriteria> listSearchCriterias = new List<LV_UTILS.SearchCriteria>();
    listSearchCriterias.add(createSearchCriteria('LastName2', 'startsWith', 'LastName'));

    List<Account> listClient = new List<Account>();
    listClient = LV_ClientSearchService.searchClient(listSearchFields, listSearchCriterias, clientPerPage, 
                                                        currentPage, orderByField, isDreamIdUsed, attachedFilter, queryType);

    system.assertEquals(1,listClient.size());
  }
  
  @isTest static void firstName2ExactMatchTest() {
        init();

        List<LV_UTILS.SearchCriteria> listSearchCriterias = new List<LV_UTILS.SearchCriteria>();
        listSearchCriterias.add(createSearchCriteria('FirstName2', 'EQUALS', 'FirstName4'));

        List<Account> listClient = new List<Account>();
        listClient = LV_ClientSearchService.searchClient(listSearchFields, listSearchCriterias, clientPerPage, 
                                                            currentPage, orderByField, isDreamIdUsed, attachedFilter, queryType);

        system.assertEquals(1,listClient.size());
    }

  @isTest static void firstName2WildcardTest() {
    init();

    List<LV_UTILS.SearchCriteria> listSearchCriterias = new List<LV_UTILS.SearchCriteria>();
    listSearchCriterias.add(createSearchCriteria('FirstName2', 'startsWith', 'FirstName'));

    List<Account> listClient = new List<Account>();
    listClient = LV_ClientSearchService.searchClient(listSearchFields, listSearchCriterias, clientPerPage, 
                                                        currentPage, orderByField, isDreamIdUsed, attachedFilter, queryType);

    system.assertEquals(1,listClient.size());
  }

  @isTest static void emailExactMatchTest() {
    init();

    List<LV_UTILS.SearchCriteria> listSearchCriterias = new List<LV_UTILS.SearchCriteria>();
    listSearchCriterias.add(createSearchCriteria('Email', 'EQUALS', 'myemail1@test.com'));

    List<Account> listClient = new List<Account>();
    listClient = LV_ClientSearchService.searchClient(listSearchFields, listSearchCriterias, clientPerPage, 
                                                        currentPage, orderByField, isDreamIdUsed, attachedFilter, queryType);

    //system.assertEquals(1,listClient.size());
  }

  @isTest static void emailWildcardTest() {
    init();

    List<LV_UTILS.SearchCriteria> listSearchCriterias = new List<LV_UTILS.SearchCriteria>();
    listSearchCriterias.add(createSearchCriteria('Email', 'startsWith', 'myemail'));

    List<Account> listClient = new List<Account>();
    listClient = LV_ClientSearchService.searchClient(listSearchFields, listSearchCriterias, clientPerPage, 
                                                        currentPage, orderByField, isDreamIdUsed, attachedFilter, queryType);

    //system.assertEquals(4,listClient.size());
  }
    
    @isTest static void phoneExactMatchTest() {
    init();

    List<LV_UTILS.SearchCriteria> listSearchCriterias = new List<LV_UTILS.SearchCriteria>();
    listSearchCriterias.add(createSearchCriteria('Phone', 'EQUALS', '+0000000001'));

    List<Account> listClient = new List<Account>();
    listClient = LV_ClientSearchService.searchClient(listSearchFields, listSearchCriterias, clientPerPage, 
                                                        currentPage, orderByField, isDreamIdUsed, attachedFilter, queryType);

    system.assertEquals(1,listClient.size());
  }
  
  @isTest static void phoneWildcardTest() {
    init();

    List<LV_UTILS.SearchCriteria> listSearchCriterias = new List<LV_UTILS.SearchCriteria>();
    listSearchCriterias.add(createSearchCriteria('Phone', 'startsWith', '00000'));

    List<Account> listClient = new List<Account>();
    listClient = LV_ClientSearchService.searchClient(listSearchFields, listSearchCriterias, clientPerPage, 
                                                        currentPage, orderByField, isDreamIdUsed, attachedFilter, queryType);

    system.assertEquals(4,listClient.size());
  }
  
  @isTest static void localPhoneExactMatchTest() {
    init();

    List<LV_UTILS.SearchCriteria> listSearchCriterias = new List<LV_UTILS.SearchCriteria>();
    listSearchCriterias.add(createSearchCriteria('LocalPhone', 'EQUALS', '0000000001'));

    List<Account> listClient = new List<Account>();
    listClient = LV_ClientSearchService.searchClient(listSearchFields, listSearchCriterias, clientPerPage, 
                                                        currentPage, orderByField, isDreamIdUsed, attachedFilter, queryType);

    system.assertEquals(1,listClient.size());
  }
  
  @isTest static void localPhoneWildcardTest() {
    init();

    List<LV_UTILS.SearchCriteria> listSearchCriterias = new List<LV_UTILS.SearchCriteria>();
    listSearchCriterias.add(createSearchCriteria('LocalPhone', 'startsWith', '00000'));

    List<Account> listClient = new List<Account>();
    listClient = LV_ClientSearchService.searchClient(listSearchFields, listSearchCriterias, clientPerPage, 
                                                        currentPage, orderByField, isDreamIdUsed, attachedFilter, queryType);

    system.assertEquals(4,listClient.size());
  }
  
  @isTest static void internationalPhoneExactMatchTest() {
    init();

    List<LV_UTILS.SearchCriteria> listSearchCriterias = new List<LV_UTILS.SearchCriteria>();
    listSearchCriterias.add(createSearchCriteria('InternationalPhone', 'EQUALS', '+0000000001'));
    
    List<Account> listClient = new List<Account>();
    listClient = LV_ClientSearchService.searchClient(listSearchFields, listSearchCriterias, clientPerPage, 
                                                        currentPage, orderByField, isDreamIdUsed, attachedFilter, queryType);

    system.assertEquals(1,listClient.size());
  }
  
  @isTest static void internationalPhoneWildcardTest() {
    init();

    List<LV_UTILS.SearchCriteria> listSearchCriterias = new List<LV_UTILS.SearchCriteria>();
    listSearchCriterias.add(createSearchCriteria('InternationalPhone', 'startsWith', '+00000'));

    List<Account> listClient = new List<Account>();
    listClient = LV_ClientSearchService.searchClient(listSearchFields, listSearchCriterias, clientPerPage, 
                                                        currentPage, orderByField, isDreamIdUsed, attachedFilter, queryType);

    system.assertEquals(4,listClient.size());
  }
  
  @isTest static void countryExactMatchTest() {
    init();

    List<LV_UTILS.SearchCriteria> listSearchCriterias = new List<LV_UTILS.SearchCriteria>();
    listSearchCriterias.add(createSearchCriteria('Country', 'EQUALS', 'FRANCE'));
      
    List<Account> listClient = new List<Account>();
    listClient = LV_ClientSearchService.searchClient(listSearchFields, listSearchCriterias, clientPerPage, 
                                                        currentPage, orderByField, isDreamIdUsed, attachedFilter, queryType);

    system.assertEquals(1,listClient.size());
  }
  
  @isTest static void countryWildcardTest() {
    init();

    List<LV_UTILS.SearchCriteria> listSearchCriterias = new List<LV_UTILS.SearchCriteria>();

    listSearchCriterias.add(createSearchCriteria('Country', 'startsWith', 'JAP'));
    List<Account> listClient = new List<Account>();
    listClient = LV_ClientSearchService.searchClient(listSearchFields, listSearchCriterias, clientPerPage, 
                                                        currentPage, orderByField, isDreamIdUsed, attachedFilter, queryType);

    system.assertEquals(1,listClient.size());
  }
  
  @isTest static void passportExactMatchTest() {
    init();

    List<LV_UTILS.SearchCriteria> listSearchCriterias = new List<LV_UTILS.SearchCriteria>();
    listSearchCriterias.add(createSearchCriteria('Passport', 'EQUALS', '0000000001'));

    List<Account> listClient = new List<Account>();
    listClient = LV_ClientSearchService.searchClient(listSearchFields, listSearchCriterias, clientPerPage, 
                                                        currentPage, orderByField, isDreamIdUsed, attachedFilter, queryType);

    system.assertEquals(1,listClient.size());
  }
  
  @isTest static void passportWildcardTest() {
    init();

    List<LV_UTILS.SearchCriteria> listSearchCriterias = new List<LV_UTILS.SearchCriteria>();
    listSearchCriterias.add(createSearchCriteria('Passport', 'startsWith', '00000'));

    List<Account> listClient = new List<Account>();
    listClient = LV_ClientSearchService.searchClient(listSearchFields, listSearchCriterias, clientPerPage, 
                                                        currentPage, orderByField, isDreamIdUsed, attachedFilter, queryType);

    system.assertEquals(4,listClient.size());
  }
  
  @isTest static void zipcodeExactMatchTest() {
    init();

    List<LV_UTILS.SearchCriteria> listSearchCriterias = new List<LV_UTILS.SearchCriteria>();
    listSearchCriterias.add(createSearchCriteria('ZipCode', 'EQUALS', 'zipcode1'));

    List<Account> listClient = new List<Account>();
    listClient = LV_ClientSearchService.searchClient(listSearchFields, listSearchCriterias, clientPerPage, 
                                                        currentPage, orderByField, isDreamIdUsed, attachedFilter, queryType);

    system.assertEquals(1,listClient.size());
  }
  
  @isTest static void zipcodeWildcardTest() {
    init();

    List<LV_UTILS.SearchCriteria> listSearchCriterias = new List<LV_UTILS.SearchCriteria>();
    listSearchCriterias.add(createSearchCriteria('ZipCode', 'startsWith', 'zipcode'));

    List<Account> listClient = new List<Account>();
    listClient = LV_ClientSearchService.searchClient(listSearchFields, listSearchCriterias, clientPerPage, 
                                                        currentPage, orderByField, isDreamIdUsed, attachedFilter, queryType);

    system.assertEquals(4,listClient.size());
  }
  
  
  @isTest static void cityExactMatchTest() {
    init();

    List<LV_UTILS.SearchCriteria> listSearchCriterias = new List<LV_UTILS.SearchCriteria>();
    listSearchCriterias.add(createSearchCriteria('City', 'EQUALS', 'City1'));
    
    List<Account> listClient = new List<Account>();
    listClient = LV_ClientSearchService.searchClient(listSearchFields, listSearchCriterias, clientPerPage, 
                                                        currentPage, orderByField, isDreamIdUsed, attachedFilter, queryType);

    system.assertEquals(1,listClient.size());
  }
  
  @isTest static void cityWildcardTest() {
    init();

    List<LV_UTILS.SearchCriteria> listSearchCriterias = new List<LV_UTILS.SearchCriteria>();

    listSearchCriterias.add(createSearchCriteria('City', 'startsWith', 'City'));

    List<Account> listClient = new List<Account>();
    listClient = LV_ClientSearchService.searchClient(listSearchFields, listSearchCriterias, clientPerPage, 
                                                        currentPage, orderByField, isDreamIdUsed, attachedFilter, queryType);

    system.assertEquals(4,listClient.size());
  }
  
  @isTest static void dreamidExactMatchTest() {
    init();

    List<LV_UTILS.SearchCriteria> listSearchCriterias = new List<LV_UTILS.SearchCriteria>();
    listSearchCriterias.add(createSearchCriteria('DreamId', 'EQUALS', '00000001'));

    List<Account> listClient = new List<Account>();
    listClient = LV_ClientSearchService.searchClient(listSearchFields, listSearchCriterias, clientPerPage, 
                                                        currentPage, orderByField, isDreamIdUsed, attachedFilter, queryType);

    system.assertEquals(1,listClient.size());
  }
  
  @isTest static void dreamidWildcardTest() {
    init();

    List<LV_UTILS.SearchCriteria> listSearchCriterias = new List<LV_UTILS.SearchCriteria>();
    listSearchCriterias.add(createSearchCriteria('DreamId', 'startsWith', '00000'));

    List<Account> listClient = new List<Account>();
    listClient = LV_ClientSearchService.searchClient(listSearchFields, listSearchCriterias, clientPerPage, 
                                                        currentPage, orderByField, isDreamIdUsed, attachedFilter, queryType);

    system.assertEquals(4,listClient.size());
  }
  
  @isTest static void multiCriteriaExactMatchTest() {
    init();

    List<LV_UTILS.SearchCriteria> listSearchCriterias = new List<LV_UTILS.SearchCriteria>();

    listSearchCriterias.add(createSearchCriteria('LastName', 'EQUALS', 'LastName4'));
    listSearchCriterias.add(createSearchCriteria('FirstName', 'EQUALS', 'FirstName4'));
    listSearchCriterias.add(createSearchCriteria('LastName2', 'EQUALS', 'LastName4'));
    listSearchCriterias.add(createSearchCriteria('FirstName2', 'EQUALS', 'FirstName4'));
    listSearchCriterias.add(createSearchCriteria('Email', 'EQUALS', 'myemail4@test.com'));
    listSearchCriterias.add(createSearchCriteria('Phone', 'EQUALS', '+0000000004'));
    listSearchCriterias.add(createSearchCriteria('LocalPhone', 'EQUALS', '0000000004'));
    listSearchCriterias.add(createSearchCriteria('InternationalPhone', 'EQUALS', '+0000000004'));
    listSearchCriterias.add(createSearchCriteria('Country', 'EQUALS', 'JAPAN'));
    listSearchCriterias.add(createSearchCriteria('Passport', 'EQUALS', '0000000004'));
    listSearchCriterias.add(createSearchCriteria('ZipCode', 'EQUALS', 'zipcode4'));
    listSearchCriterias.add(createSearchCriteria('City', 'EQUALS', 'City4'));
    listSearchCriterias.add(createSearchCriteria('DreamId', 'EQUALS', '00000004'));

    List<Account> listClient = new List<Account>();
    listClient = LV_ClientSearchService.searchClient(listSearchFields, listSearchCriterias, clientPerPage, 
                                                        currentPage, orderByField, isDreamIdUsed, attachedFilter, queryType);

    //system.assertEquals(1,listClient.size());
}
  
  

@isTest static void pipaAdminTest() {
    init();

    List<LV_UTILS.SearchCriteria> listSearchCriterias = new List<LV_UTILS.SearchCriteria>();

    listSearchCriterias.add(createSearchCriteria('LastName', 'EQUALS', 'LastName3'));

    List<Account> listClient = new List<Account>();
    listClient = LV_ClientSearchService.searchClient(listSearchFields, listSearchCriterias, clientPerPage, 
                                                        currentPage, orderByField, isDreamIdUsed, attachedFilter, queryType);

    system.assertEquals(1,listClient.size());
}

  @isTest static void soslTest() {
    init();

    List<LV_UTILS.SearchCriteria> listSearchCriterias = new List<LV_UTILS.SearchCriteria>();

    listSearchCriterias.add(createSearchCriteria('LastName', 'EQUALS', 'LastName1'));

    LV_CS002_SearchParameters__c serviceManualChoice = [Select Id, Name, SOQL__c, SOSL__c From LV_CS002_SearchParameters__c];
    serviceManualChoice.SOQL__c = false;
    serviceManualChoice.SOSL__c = true;
    serviceManualChoice.Automatic__c = false;
    Database.update(serviceManualChoice);

    List<Account> listClient = new List<Account>();

    LV_ClientSearchService service = new LV_ClientSearchService();
    listClient = LV_ClientSearchService.searchClient(listSearchFields, listSearchCriterias, clientPerPage, 
                                                        currentPage, orderByField, isDreamIdUsed, attachedFilter, queryType);

    system.assertEquals(1,listClient.size());
  }

    @isTest static void soslAutomaticDecisionTest() {
        init();

        List<LV_UTILS.SearchCriteria> listSearchCriterias = new List<LV_UTILS.SearchCriteria>();

        listSearchCriterias.add(createSearchCriteria('LastName', 'startsWith', 'LastName'));

        LV_CS002_SearchParameters__c serviceManualChoice = [Select Id, Name, SOQL__c, SOSL__c From LV_CS002_SearchParameters__c];
        serviceManualChoice.SOQL__c = false;
        serviceManualChoice.SOSL__c = false;
        serviceManualChoice.Automatic__c = true;
        Database.update(serviceManualChoice);

        List<Account> listClient = new List<Account>();

        LV_ClientSearchService service = new LV_ClientSearchService();
        listClient = LV_ClientSearchService.searchClient(listSearchFields, listSearchCriterias, clientPerPage, 
                                                            currentPage, orderByField, isDreamIdUsed, attachedFilter, queryType);
        system.assertEquals(4,listClient.size());
    }
    
    @isTest static void mergedClientTest() {
        init();

        List<LV_UTILS.SearchCriteria> listSearchCriterias = new List<LV_UTILS.SearchCriteria>();
        listSearchCriterias.add(createSearchCriteria('DreamId', 'EQUALS', '22222222'));

        isDreamIdUsed = true;

        List<Account> listClient = new List<Account>();
        listClient = LV_ClientSearchService.searchClient(listSearchFields, listSearchCriterias, clientPerPage, 
                                                            currentPage, orderByField, isDreamIdUsed, attachedFilter, queryType);
        
        system.assertEquals(1,listClient.size());
    }

    @isTest static void mergedClientByPassTest() {
        init();

        List<LV_UTILS.SearchCriteria> listSearchCriterias = new List<LV_UTILS.SearchCriteria>();
        listSearchCriterias.add(createSearchCriteria('DreamId', 'EQUALS', '22222222'));

        isDreamIdUsed = false;

        List<Account> listClient = new List<Account>();
        listClient = LV_ClientSearchService.searchClient(listSearchFields, listSearchCriterias, clientPerPage, 
                                                            currentPage, orderByField, isDreamIdUsed, attachedFilter, queryType);
        
        system.assertEquals(0,listClient.size());
    }
    
    @isTest static void additionalFilter() {
        init();

        List<LV_UTILS.SearchCriteria> listSearchCriterias = new List<LV_UTILS.SearchCriteria>();
        listSearchCriterias.add(createSearchCriteria('LastName', 'startsWith', 'LastName'));

        attachedFilter = '(PersonEmail =\'myemail1@test.com\' OR PrimaryCountry__pc = \'JAPAN\' )';        

        List<Account> listClient = new List<Account>();
        listClient = LV_ClientSearchService.searchClient(listSearchFields, listSearchCriterias, clientPerPage, 
                                                            currentPage, orderByField, isDreamIdUsed, attachedFilter, queryType);
        
        system.assertEquals(2,listClient.size());
    }
    
    @isTest static void orderBy() {
        init();

        List<LV_UTILS.SearchCriteria> listSearchCriterias = new List<LV_UTILS.SearchCriteria>();
        listSearchCriterias.add(createSearchCriteria('LastName', 'startsWith', 'LastName'));

        orderByField = 'PrimaryCountry__pc';        

        List<Account> listClient = new List<Account>();
        listClient = LV_ClientSearchService.searchClient(listSearchFields, listSearchCriterias, clientPerPage, 
                                                            currentPage, orderByField, isDreamIdUsed, attachedFilter, queryType);
        
        system.assertEquals(4,listClient.size());
    }

    private static List<String> listSearchFields;
    private static Integer clientPerPage;
    private static Integer currentPage;
    private static String orderByField;
    private static boolean isDreamIdUsed;
    private static String attachedFilter;
    private static String queryType;

    private static void init(){
        listSearchFields = new List<String>{'OwnerId', 'Typology__pc', 
                                                'Name', 'Segmentation__pc', 
                                                'DREAMID__c', 'PassportNumber__pc',
                                                'PersonMobilePhone', 'PersonHomePhone',
                                                'Phone', 'PersonEmail', 'LastName',
                                                'FirstName', 'Lastname2__pc',
                                                'Firstname2__pc', 'AttachedStore__pc',
                                                'PrimaryCountry__pc', 'PrimaryZipCode__pc',
                                                'IsProspect__pc', 'CreatedDate'
                                            };
        
        clientPerPage = 15;
        currentPage = 0;

        orderByField = 'LastName';
        isDreamIdUsed = true;

        queryType = 'SOQL';

        // For SOSL test ------------------------------------
        List<Account> listClients = [Select Id From Account];
        List<Id> fixedSearchResults= new List<Id>();
        for(Account client : listClients){
            fixedSearchResults.add(client.Id);
        }

        fixedSearchResults.add(listClients[0].Id);
        Test.setFixedSearchResults(fixedSearchResults);
        // --------------------------------------------------
    }


  private static LV_UTILS.SearchCriteria createSearchCriteria(String label, String operator, String value){
      LV_UTILS.SearchCriteria searchCriteria = new LV_UTILS.SearchCriteria();
      searchCriteria.Label = label;
      searchCriteria.Operator = operator;
      searchCriteria.Value = value;

      return searchCriteria;
  }

  // --------------------------------------------------- //
  // Methods that creates custom settings for data tests //
  // --------------------------------------------------- //
  private static void createLabelToAccountFieldsCity(String name, String fields){
    LV_CS001_SearchLabelToFields__c labelToAccountFields = new LV_CS001_SearchLabelToFields__c();
    labelToAccountFields.Name = name;
    labelToAccountFields.fields__c = fields;
    Database.saveResult srCs = Database.insert(labelToAccountFields);
  }

  private static void createServiceCriteriaForSOQL(String name){
    LV_CS004_SearchSOQLQueryMatrix__c serviceCriteriaForSOQL = new LV_CS004_SearchSOQLQueryMatrix__c();
    serviceCriteriaForSOQL.Name = name;
    Database.saveResult srCs = Database.insert(serviceCriteriaForSOQL);
  }

  private static void createSOSLDecisionMatrix(String name, String sOSLScope){
    LV_CS003_SearchSOSLScopeMatrix__c sOSLDecisionMatrix = new LV_CS003_SearchSOSLScopeMatrix__c();
    sOSLDecisionMatrix.Name = name;
    sOSLDecisionMatrix.SOSLScope__c = sOSLScope;
    Database.saveResult srCs = Database.insert(sOSLDecisionMatrix);
  }

  private static void createServiceManualChoice(String name, boolean automatic, Integer recordsLimit, boolean soql, boolean sosl){
    LV_CS002_SearchParameters__c serviceManualChoice = new LV_CS002_SearchParameters__c();
    serviceManualChoice.Name = name;
    serviceManualChoice.Automatic__c = automatic;
    serviceManualChoice.Limit__c = recordsLimit;
    serviceManualChoice.SOQL__c = soql;
    serviceManualChoice.SOSL__c = sosl;
    Database.saveResult srCs = Database.insert(serviceManualChoice);
  }
}