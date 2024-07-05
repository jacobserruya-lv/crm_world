@isTest
public class BL_ICON_ClientList_Helper_TEST {


	@isTest
	static void testMethodGetMembersOfPermanentClientListWithParams() {
		try {
			Account acc = new Account(LastName = 'test');
			insert acc;
			BL_AppSettings.setAppSettings('Icon');
			BL_ICON_ClientList blClient = new BL_ICON_ClientList();
			User u = IC_Test_Common.prepareTestUser('System Administrator');
			u.DefaultStore__c = '1234';
			insert u;
			Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
			insert store;
			BL_ClientList__mdt clientList = [SELECT DeveloperName, Id FROM BL_ClientList__mdt WHERE DeveloperName = 'Reassigned'];
			blClient.me = (BL_UserInfo) Type.forName('BL_ICON_UserInfo').newInstance();
			blClient.pathParameters = new Map < String, String > {
				'id' => clientList.Id
			};

			blClient.queryParams = new Map < String, String > {
				'tab' => '1',
				'' => 'A06'
			};

			Test.startTest();
			blClient.resource = 'members';
			blClient.executeGET();
			blClient.isStandardRestApiRequired = true;
			blClient.PageSize = 200;
			blClient.pageIndex = 0;
			blClient.executeGET();
			Test.stopTest();
		} catch (Exception e) {}
	}


	@isTest
	static void testMethodGetMembersOfPermanentClientListWithParams2() {
		try {
			Account acc = new Account(LastName = 'test');
			insert acc;
			BL_AppSettings.setAppSettings('Icon');
			BL_ICON_ClientList blClient = new BL_ICON_ClientList();
			User u = IC_Test_Common.prepareTestUser('System Administrator');
			u.DefaultStore__c = '1234';
			insert u;
			Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
			insert store;
			BL_ClientList__mdt clientList = [SELECT DeveloperName, Id FROM BL_ClientList__mdt WHERE DeveloperName = 'Reassigned'];
			blClient.me = (BL_UserInfo) Type.forName('BL_ICON_UserInfo').newInstance();
			blClient.pathParameters = new Map < String, String > {
				'id' => clientList.Id
			};


			blClient.queryParams = new Map < String, String > {
				'tab' => '1',
				'storeCode' => 'A06'
			};

			Test.startTest();
			blClient.resource = 'members';
			blClient.executeGET();
			blClient.isStandardRestApiRequired = true;
			blClient.PageSize = 200;
			blClient.pageIndex = 0;
			blClient.executeGET();
			Test.stopTest();
		} catch (Exception e) {}
	}

	@isTest
	static void testMethodGetMembersOfPermanentClientListWithParams3() {
		try {
			Account acc = new Account(LastName = 'test');
			insert acc;
			BL_AppSettings.setAppSettings('Icon');
			BL_ICON_ClientList blClient = new BL_ICON_ClientList();
			User u = IC_Test_Common.prepareTestUser('System Administrator');
			u.DefaultStore__c = '1234';
			insert u;
			Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
			insert store;
			BL_ClientList__mdt clientList = [SELECT DeveloperName, Id FROM BL_ClientList__mdt WHERE DeveloperName = 'Reassigned'];
			blClient.me = (BL_UserInfo) Type.forName('BL_ICON_UserInfo').newInstance();
			blClient.pathParameters = new Map < String, String > {
				'id' => clientList.Id
			};


			blClient.queryParams = new Map < String, String > {
				'tab' => '1',
				'caIds' => clientList.Id
			};

			Test.startTest();
			blClient.resource = 'members';
			blClient.executeGET();
			blClient.isStandardRestApiRequired = true;
			blClient.PageSize = 200;
			blClient.pageIndex = 0;
			blClient.executeGET();
			Test.stopTest();
		} catch (Exception e) {}
	}


	@isTest
	static void testMethodGetMembersOfPermanentClientListWithParams4() {
		try{
			Account acc = new Account(LastName = 'test');
			insert acc;
			BL_AppSettings.setAppSettings('Icon');
			BL_ICON_ClientList blClient = new BL_ICON_ClientList();
			User u = IC_Test_Common.prepareTestUser('System Administrator');
			u.DefaultStore__c = '1234';
			insert u;
			Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
			insert store;
			BL_ClientList__mdt clientList = [SELECT DeveloperName, Id FROM BL_ClientList__mdt WHERE DeveloperName = 'Reassigned'];
			blClient.me = (BL_UserInfo) Type.forName('BL_ICON_UserInfo').newInstance();
			blClient.pathParameters = new Map < String, String > {
				'id' => clientList.Id
			};


			blClient.queryParams = new Map < String, String > {
				'caIds' => '',
				'storeCode' => ''
			};

			

			Test.startTest();
			blClient.resource = 'members';
			blClient.executeGET();
			blClient.isStandardRestApiRequired = true;
			blClient.PageSize = 200;
			blClient.pageIndex = 0;
			blClient.executeGET();
			Test.stopTest();
		}
		catch(Exception e ) {}
	
	}

	@isTest
	static void test22222() {

		User u = IC_Test_Common.prepareTestUser('System Administrator');
		u.DefaultStore__c = '1234';
        insert u;

		User u2 = IC_Test_Common.prepareTestUser('System Administrator');
		u2.DefaultStore__c = '1234';
        u2.WWEmployeeNumber__c = 'FR1235';

		CLI_CliList__c clientList = new CLI_CliList__c( Name = '#May Client Birthdays#', OwnerId = u.id);
		insert clientList;

        Account c = new Account(LastName = 'test', FirstName = 'test');
		insert c;

        CLM_CliListMember__c Clm = new CLM_CliListMember__c(Client__c= [Select Id From Contact WHERE AccountId = :c.id].id,ClientList__c = clientList.id);

		BL_ICON_ClientList blClient = new BL_ICON_ClientList();

		BL_ClientList__mdt clientList2 = [SELECT DeveloperName, Id FROM BL_ClientList__mdt WHERE DeveloperName = 'Men_RTW'];
 		BL_ClientList__mdt clientList3 = [SELECT DeveloperName, Id FROM BL_ClientList__mdt WHERE DeveloperName = 'Care_Services'];
        BL_ClientList__mdt clientList4 = [SELECT DeveloperName, Id FROM BL_ClientList__mdt WHERE DeveloperName = 'Recent_Clients'];
		BL_ClientList__mdt clientList5 = [SELECT DeveloperName, Id FROM BL_ClientList__mdt WHERE DeveloperName = 'Retention'];


        User u3 = IC_Test_Common.prepareTestUser('System Administrator');
		u3.DefaultStore__c = '1234';
        u3.WWEmployeeNumber__c = 'FR5682';
        insert new List < User > {u2,u3 };

		List < String > employeNumbers = new List < String > {'5'};

		List < String > employeNumbers2 = new List < String > {'1'};

		BL_ICON_ClientList_Helper.getAll();

		BL_ICON_ClientList_Helper.getClientListByFeatures('main;services;categories;myLists;others');

		try{
		BL_ICON_ClientList_Helper.getCountOfListClient('m0005f0000004xJiE', 5, 5, 'ewv654we6v4', 'NA7', 'NA7', 5, 'DESC', employeNumbers,null);
		}
		catch(Exception e){}

		try{
		BL_ICON_ClientList_Helper.getCountOfListClient('m0005f0000004xJiE', 5, 5, 'ewv654we6v4', 'NA7', 'NA7', 5, 'DESC', employeNumbers2,null);
		}
		catch(Exception e){}

		try{
		BL_ICON_ClientList_Helper.getCountOfListClient('m0005f0000004xJiE', 5, 5, '', '', 'NA7', 5, 'DESC', employeNumbers,null);
		}
		catch(Exception e){}

		try{
			BL_ICON_ClientList_Helper.getPermanentListClients('m0005f0000004xJiE', 5, 5, 'ewv654we6v4', 'NA7', 'NA7', 5, 'DESC', employeNumbers, '10500', '10500', 'm0005f0000004xJiE', true, null, null,null);
			}
			catch(Exception e){}
		try{
			BL_ICON_ClientList_Helper.getPermanentListClients(clientList5.id, 0, 50, 'ewv654we6v4', '', '', null, 'DESC', employeNumbers, '', '', '', true, null, 'all', null);
			}
			catch(Exception e){}
		try{
			BL_ICON_ClientList_Helper.getPermanentListClients(clientList5.id, 0, 50, 'ewv654we6v4', '', '', null, 'DESC', employeNumbers, '', '', '', true, null, 'potential',null);
			}
			catch(Exception e){}
		try{
			BL_ICON_ClientList_Helper.getPermanentListClients(clientList5.id, 0, 50, 'ewv654we6v4', '', '', null, 'DESC', employeNumbers, '', '', '', true, null, 'retention',null);
			}
			catch(Exception e){}
				
		try{
			BL_ICON_ClientList_Helper.getPermanentListClients(u.id, 5, 5, 'ewv654we6v4', 'NA7', 'NA7', 5, 'DESC', employeNumbers, '10500', '10500', 'm0005f0000004xJiE', true, null, null,null);
			}
			catch(Exception e){}	

		try{
			BL_ICON_ClientList_Helper.getPermanentListClients(u.id, 5, 5, null, 'NA7', 'NA7', 5, 'DESC', employeNumbers, '10500', '10500', 'm0005f0000004xJiE', true, null, null,null);
			}
			catch(Exception e){}	

		BL_ICON_ClientList_Helper.getCountOfListClient(u.id, 5, 5, 'ewv654we6v4', 'NA7', 'NA7', 5, 'DESC', employeNumbers,null);

		try{
		BL_ICON_ClientList_Helper.getSpecificClientList(null);
		}
		catch(Exception e){}	
		
		try{
		BL_ICON_ClientList_Helper.getCutomListClients(u.id, 5, 5, 'ewv654we6v4', true, 'A06', '');
		}
		catch(Exception e){}

		try{
		BL_ICON_ClientList_Helper.getCutomListClients(u.id, 5, 5, 'ewv654we6v4', false, 'A06', '');
		}
		catch(Exception e){}

		try{
		BL_ICON_ClientList_Helper.getCutomListClients(u.id, 5, 5, '', true, 'A06', '');
		}
		catch(Exception e){}

		try{
		blClient.me = (BL_UserInfo) Type.forName('BL_ICON_UserInfo').newInstance();
		}
		catch(Exception e){}


		try{
		BL_ICON_ClientList_Helper.addClientListMembers(u);
		}
		catch(Exception e){}

		try{
		BL_ICON_ClientList_Helper.createClientList(u);
		}
		catch(Exception e){}

		try{
		BL_ICON_ClientList_Helper.updateClientList(u.id, Clm);
		}
		catch(Exception e){}


		try{
			BL_ICON_ClientList_Helper.deleteClientList(u2.id);
		}
		catch(Exception e){}




		Test.startTest();
        
        blClient.queryParams = new Map < String, String > {
			'features' => 'others',
            'filter' =>  'Ind_10K__c = \'10K\'' ,
            'tab' => '1',
            'caIds' => u2.id+';'+u3.id 

		};
        blClient.pathParameters = new Map < String, String > {
			'id' => clientList2.Id
		};   
        blClient.resource = 'members';
        
		blClient.executeGET();

        blClient.queryParams = new Map < String, String > {
			'features' => 'others',
            'filter' =>  'Ind_10K__c = \'10K\'' ,
            'caIds' => u2.id+';'+u3.id 
		};
        blClient.pathParameters = new Map < String, String > {
			'id' => clientList4.Id
		};   
        blClient.resource = 'members';
        
		blClient.executeGET();
        
        blClient.queryParams = new Map < String, String > {
			'features' => 'others',
            'filter' =>  'Ind_10K__c = \'10K\'' ,
            'tab' => '1'
		};
        blClient.pathParameters = new Map < String, String > {
			'id' => clientList2.Id
		};   
        blClient.resource = 'count';
        
		blClient.executeGET();
        
         blClient.queryParams = new Map < String, String > {
			'features' => 'others',
            'filter' =>  'Ind_10K__c = \'10K\'' ,
            'tab' => '1',
             'caIds' => u2.id+';'+u3.id 

		};
        blClient.pathParameters = new Map < String, String > {
			'id' => clientList4.Id
		};   
        blClient.resource = 'count';
        
		blClient.executeGET();
        
        blClient.queryParams = new Map < String, String > {
			'features' => 'others',
            'filter' =>  'Ind_10K__c = \'10K\'' ,
            'tab' => '1'
		};
        blClient.pathParameters = new Map < String, String > {
			'id' => clientList3.Id
		};   
        blClient.resource = 'count';
        
		blClient.executeGET();

    
		Test.stopTest();
    	
	
	}
    
    @isTest
	static void testMethodGet2() {
		Account acc = new Account(LastName = 'test');
		insert acc;
		BL_AppSettings.setAppSettings('Icon');
		BL_ICON_ClientList blClient = new BL_ICON_ClientList();
		User u = IC_Test_Common.prepareTestUser('System Administrator');
		u.DefaultStore__c = '1234';
        
        User u2 = IC_Test_Common.prepareTestUser('System Administrator');
		u2.DefaultStore__c = '1234';
        u2.WWEmployeeNumber__c = 'FR1235';

        User u3 = IC_Test_Common.prepareTestUser('System Administrator');
		u3.DefaultStore__c = '1234';
        u3.WWEmployeeNumber__c = 'FR5682';
        insert new List < User > {u,u2,u3 };
        
        TeamMember__c tm = new TeamMember__c(User__c = u2.id, Manager__c = u.id);
		TeamMember__c tm1 = new TeamMember__c(User__c = u2.id, Manager__c = u.id);
        
		insert new List < TeamMember__c > {tm,tm1 };
        
		Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
		insert store;
		CLI_CliList__c clientList = new CLI_CliList__c( /*ExpirationDate__c = Date.newInstance(2020,10,01),*/ Name = '#May Client Birthdays#', OwnerId = u.id);
		insert clientList;
        
        BL_ClientList__mdt clientList2 = [SELECT DeveloperName, Id FROM BL_ClientList__mdt WHERE DeveloperName = 'Men_RTW'];
 		BL_ClientList__mdt clientList3 = [SELECT DeveloperName, Id FROM BL_ClientList__mdt WHERE DeveloperName = 'Care_Services'];
        BL_ClientList__mdt clientList4 = [SELECT DeveloperName, Id FROM BL_ClientList__mdt WHERE DeveloperName = 'Recent_Clients'];

		blClient.me = (BL_UserInfo) Type.forName('BL_ICON_UserInfo').newInstance();
		
		Test.startTest();
        
        blClient.queryParams = new Map < String, String > {
			'features' => 'others',
            'filter' =>  'Ind_10K__c = \'10K\'' ,
            'tab' => '1',
            'caIds' => u2.id+';'+u3.id 

		};
        blClient.pathParameters = new Map < String, String > {
			'id' => clientList2.Id
		};   
        blClient.resource = 'members';
        
		blClient.executeGET();

        blClient.queryParams = new Map < String, String > {
			'features' => 'others',
            'filter' =>  'Ind_10K__c = \'10K\'' ,
            'caIds' => u2.id+';'+u3.id 
		};
        blClient.pathParameters = new Map < String, String > {
			'id' => clientList4.Id
		};   
        blClient.resource = 'members';
        
		blClient.executeGET();
        
        blClient.queryParams = new Map < String, String > {
			'features' => 'others',
            'filter' =>  'Ind_10K__c = \'10K\'' ,
            'tab' => '1'
		};
        blClient.pathParameters = new Map < String, String > {
			'id' => clientList2.Id
		};   
        blClient.resource = 'count';
        
		blClient.executeGET();
        
         blClient.queryParams = new Map < String, String > {
			'features' => 'others',
            'filter' =>  'Ind_10K__c = \'10K\'' ,
            'tab' => '1',
             'caIds' => u2.id+';'+u3.id 

		};
        blClient.pathParameters = new Map < String, String > {
			'id' => clientList4.Id
		};   
        blClient.resource = 'count';
        
		blClient.executeGET();
        
        blClient.queryParams = new Map < String, String > {
			'features' => 'others',
            'filter' =>  'Ind_10K__c = \'10K\'' ,
            'tab' => '1'
		};
        blClient.pathParameters = new Map < String, String > {
			'id' => clientList3.Id
		};   
        blClient.resource = 'count';
        
		blClient.executeGET();

    
		Test.stopTest();
	}
    
	@isTest
	static void testMethodPost() {
		BL_AppSettings.setAppSettings('Icon');
		BL_ICON_ClientList blClient = new BL_ICON_ClientList();
		User u = IC_Test_Common.prepareTestUser('System Administrator');
		u.DefaultStore__c = '1234';
		insert u;
		Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
		insert store;
		CLI_CliList__c clientList = new CLI_CliList__c( /*ExpirationDate__c = Date.newInstance(2020,10,01),*/ Name = '#May Client Birthdays#', OwnerId = u.id);
		insert clientList;
		Account c = new Account(LastName = 'test');
		insert c;
		Account c2 = new Account(LastName = 'test2');
		insert c2;
		blClient.me = (BL_UserInfo) Type.forName('BL_ICON_UserInfo').newInstance();
		blClient.pathParameters = new Map < String, String > {
			'id' => null
		};
		List < String > clientsIds = new List < String > {
			c.id
		};
		List < String > clientsIds2 = new List < String > {
			c2.id
		};
		blClient.requestBody = new Map < String, Object > {
			'clientIds' => clientsIds,
			'ownerId' => u.id,
			'name' => 'test'
		};
		Test.startTest();
		blClient.executePOST();
		blClient.pathParameters = new Map < String, String > {
			'id' => clientList.Id
		};
		blClient.requestBody = new Map < String, Object > {
			'clientIds' => clientsIds2,
			'ownerId' => u.id,
			'name' => 'test'
		};
		blClient.executePOST();
		Test.stopTest();
	}
	@isTest
	static void testMethodPUT() {
		BL_AppSettings.setAppSettings('Icon');
		BL_ICON_ClientList blClient = new BL_ICON_ClientList();
		User u = IC_Test_Common.prepareTestUser('System Administrator');
		u.DefaultStore__c = '1234';
		insert u;
		Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
		insert store;
		CLI_CliList__c clientList = new CLI_CliList__c( /*ExpirationDate__c = Date.newInstance(2020,10,01),*/ Name = '#May Client Birthdays#', OwnerId = u.id);
		insert clientList;
		Account c2 = new Account(LastName = 'test', FirstName = 'test');
		insert c2;
        Account c = new Account(LastName = 'test', FirstName = 'test');
		insert c;
        CLM_CliListMember__c Clm = new CLM_CliListMember__c(Client__c= [Select Id From Contact WHERE AccountId = :c.id].id,ClientList__c = clientList.id);
        CLM_CliListMember__c Clm2 = new CLM_CliListMember__c(Client__c= [Select Id From Contact WHERE AccountId = :c2.id].id,ClientList__c = clientList.id);

        insert new list<CLM_CliListMember__c>{Clm,clm2}; 
		blClient.me = (BL_UserInfo) Type.forName('BL_ICON_UserInfo').newInstance();
		List < String > clientsIds = new List < String > {
			c.id,c2.id
		};
		Test.startTest();
		blClient.pathParameters = new Map < String, String > {
			'id' => clientList.Id
		};
		blClient.requestBody = new Map < String, Object > {
			'clientIds' => clientsIds,
			'ownerId' => u.id,
			'name' => 'test',
			'description' => 'test'
		};
		blClient.executePUT();
		Test.stopTest();
	}
	@isTest
	static void testMethodDELETE() {
		BL_AppSettings.setAppSettings('Icon');
		BL_ICON_ClientList blClient = new BL_ICON_ClientList();
		User u = IC_Test_Common.prepareTestUser('System Administrator');
		u.DefaultStore__c = '1234';
		insert u;
		Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
		insert store;
		CLI_CliList__c clientList = new CLI_CliList__c( /*ExpirationDate__c = Date.newInstance(2020,10,01),*/ Name = '#May Client Birthdays#', OwnerId = u.id);
		insert clientList;
		blClient.me = (BL_UserInfo) Type.forName('BL_ICON_UserInfo').newInstance();
		Test.startTest();
		blClient.pathParameters = new Map < String, String > {
			'id' => clientList.Id
		};
		blClient.executeDELETE();
		Test.stopTest();
	}
	@isTest
	static void testMethodGetWithQueryId() {
		try {
			Account acc = new Account(LastName = 'test');
			insert acc;
			BL_AppSettings.setAppSettings('Icon');
			BL_ICON_ClientList blClient = new BL_ICON_ClientList();
			User u = IC_Test_Common.prepareTestUser('System Administrator');
			u.DefaultStore__c = '1234';
			insert u;
			Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
			insert store;
			CLI_CliList__c clientList = new CLI_CliList__c( /*ExpirationDate__c = Date.newInstance(2020,10,01),*/ Name = '#May Client Birthdays#', OwnerId = u.id);
			insert clientList;
			blClient.me = (BL_UserInfo) Type.forName('BL_ICON_UserInfo').newInstance();
			blClient.pathParameters = new Map < String, String > {
				'id' => clientList.Id
			};
			blClient.queryParams = new Map < String, String > ();
			blClient.resource = 'members';
			blClient.isStandardRestApiRequired = true;
			blClient.PageSize = 200;
			blClient.pageIndex = 0;
			Test.startTest();
			blClient.executeGET();
			Test.stopTest();
		} catch (Exception e) {}
	}
	@isTest
	static void testMethodGetCount() {
		Account acc = new Account(LastName = 'test');
		insert acc;
		BL_AppSettings.setAppSettings('Icon');
		BL_ICON_ClientList blClient = new BL_ICON_ClientList();
		User u = IC_Test_Common.prepareTestUser('System Administrator');
		u.DefaultStore__c = '1234';
		insert u;
		Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
		insert store;
		CLI_CliList__c clientList = new CLI_CliList__c( /*ExpirationDate__c = Date.newInstance(2020,10,01),*/ Name = '#May Client Birthdays#', OwnerId = u.id);
		insert clientList;
		blClient.me = (BL_UserInfo) Type.forName('BL_ICON_UserInfo').newInstance();
		blClient.pathParameters = new Map < String, String > {
			'id' => clientList.Id
		};
		blClient.queryParams = new Map < String, String > ();
		Test.startTest();
		blClient.resource = 'count';
		blClient.executeGET();
		BL_ClientList__mdt clientList2 = [SELECT DeveloperName, Id FROM BL_ClientList__mdt WHERE DeveloperName = 'Birthday_Wedding_Anniversary'];
		blClient.pathParameters = new Map < String, String > {
			'id' => clientList2.Id
		};
		blClient.executeGET();
		Test.stopTest();
	}

	@isTest
	static void testMethodGetMembersOfPermanentClientList() {
		try {
			Account acc = new Account(LastName = 'test');
			insert acc;
			BL_AppSettings.setAppSettings('Icon');
			BL_ICON_ClientList blClient = new BL_ICON_ClientList();
			User u = IC_Test_Common.prepareTestUser('System Administrator');
			u.DefaultStore__c = '1234';
			insert u;
			Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
			insert store;
			BL_ClientList__mdt clientList = [SELECT DeveloperName, Id FROM BL_ClientList__mdt WHERE DeveloperName = 'Birthday_Wedding_Anniversary'];
			blClient.me = (BL_UserInfo) Type.forName('BL_ICON_UserInfo').newInstance();
			blClient.pathParameters = new Map < String, String > {
				'id' => clientList.Id
			};
			blClient.queryParams = new Map < String, String > ();
			Test.startTest();
			blClient.resource = 'members';
			blClient.executeGET();
			blClient.isStandardRestApiRequired = true;
			blClient.PageSize = 200;
			blClient.pageIndex = 0;
			blClient.executeGET();
			Test.stopTest();
		} catch (Exception e) {}
	}


	@isTest
	static void testMethodSetOwnerDetailsMapped() {
		try{
    	Account acc = new Account(LastName = 'test');
		insert acc;
		BL_AppSettings.setAppSettings('Icon');
		BL_ICON_ClientList blClient = new BL_ICON_ClientList();
		blClient.isStandardRestApiRequired=true;
		User u = IC_Test_Common.prepareTestUser('System Administrator');
		u.DefaultStore__c = '1234';
        
        User u2 = IC_Test_Common.prepareTestUser('System Administrator');
		u2.DefaultStore__c = '1234';
        u2.WWEmployeeNumber__c = 'FR1235';

        User u3 = IC_Test_Common.prepareTestUser('System Administrator');
		u3.DefaultStore__c = '1234';
        u3.WWEmployeeNumber__c = 'FR5682';
        insert new List < User > {u,u2,u3 };
        
        TeamMember__c tm = new TeamMember__c(User__c = u2.id, Manager__c = u.id);
		TeamMember__c tm1 = new TeamMember__c(User__c = u2.id, Manager__c = u.id);
        
		insert new List < TeamMember__c > {tm,tm1 };
        
		Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
		insert store;
		CLI_CliList__c clientList = new CLI_CliList__c( /*ExpirationDate__c = Date.newInstance(2020,10,01),*/ Name = '#May Client Birthdays#', OwnerId = u.id);
		insert clientList;
        
        BL_ClientList__mdt clientList2 = [SELECT DeveloperName, Id FROM BL_ClientList__mdt WHERE DeveloperName = 'Men_RTW'];
 		BL_ClientList__mdt clientList3 = [SELECT DeveloperName, Id FROM BL_ClientList__mdt WHERE DeveloperName = 'Care_Services'];
        BL_ClientList__mdt clientList4 = [SELECT DeveloperName, Id FROM BL_ClientList__mdt WHERE DeveloperName = 'Recent_Clients'];

		blClient.me = (BL_UserInfo) Type.forName('BL_ICON_UserInfo').newInstance();

		Test.startTest();

        blClient.queryParams = new Map < String, String > {
			'features' => 'others',
            'filter' =>  'Ind_10K__c = \'10K\'' ,
            'tab' => '1',
			's'=>'True',

            'caIds' => u2.id+';'+u3.id 

		};
        blClient.pathParameters = new Map < String, String > {
			'id' => clientList2.Id
		};   
        blClient.resource = 'members';
        
		blClient.executeGET();

        blClient.queryParams = new Map < String, String > {
			'features' => 'others',
            'filter' =>  'Ind_10K__c = \'10K\'' ,
			's'=>'True',

            'caIds' => u2.id+';'+u3.id 
		};
        blClient.pathParameters = new Map < String, String > {
			'id' => clientList4.Id
		};   
        blClient.resource = 'members';
        
		blClient.executeGET();
        
        blClient.queryParams = new Map < String, String > {
			'features' => 'others',
            'filter' =>  'Ind_10K__c = \'10K\'' ,
			's'=>'True',

            'tab' => '1'
		};
        blClient.pathParameters = new Map < String, String > {
			'id' => clientList2.Id
		};   
        blClient.resource = 'count';
        
		blClient.executeGET();
        
         blClient.queryParams = new Map < String, String > {
			'features' => 'others',
            'filter' =>  'Ind_10K__c = \'10K\'' ,
            'tab' => '1',
			's'=>'True',
             'caIds' => u2.id+';'+u3.id 

		};
        blClient.pathParameters = new Map < String, String > {
			'id' => clientList4.Id
		};   
        blClient.resource = 'count';
        
		blClient.executeGET();
        
        blClient.queryParams = new Map < String, String > {
			'features' => 'others',
            'filter' =>  'Ind_10K__c = \'10K\'' ,
            'tab' => '1',
			's'=>'True'
		};
        blClient.pathParameters = new Map < String, String > {
			'id' => clientList3.Id
		};   
        blClient.resource = 'count';
        
		blClient.executeGET();
		BL_ICON_ClientList_Helper.getPermanentListClients( 'm0ff000000002WfAAI', null,null, '005f0000004ylGcAAI', null, 'Ind_10K__c = \'10K\'', 1, null, null,null ,null , null,true,null, null, null);

		BL_ICON_ClientList_Helper.getPermanentListClients( clientList4.id, null,null, '', '', 'Ind_10K__c = \'10K\'', 1, null, null,null ,null , null,true, null, null, null);
    
		

		Test.stopTest();
	}

catch(Exception e ) {}
	
	}



}