@isTest
public with sharing class BL_ICON_Client_Helper_TEST {
    @testSetup
    static void setup() {
        Account acc = new Account(LastName = 'test', DREAMID__c = '345673');
		insert acc;
		Social_Media_Identifier__c smi = new Social_Media_Identifier__c();
		smi.Client__c = acc.Id;
		smi.Social_Media_Type__c = 'WeChat';
		smi.Opt_In__c = true;
		smi.Social_Id__c = '345673';
		smi.Social_SF_External_Id__c = '345673';
		insert smi;
        User u = IC_Test_Common.prepareTestUser('System Administrator');
		u.DefaultStore__c = '1234';
		insert u;
        
    }
	@isTest
	static void testMethodGet() {
		Account acc = new Account(LastName = 'test');
		insert acc;
		BL_AppSettings.setAppSettings('Icon');
		BL_ICON_Client blClient = new BL_ICON_Client();
		User u = IC_Test_Common.prepareTestUser('System Administrator');
		u.DefaultStore__c = '1234';
		insert u;
		system.runAs(u) {
			Test.startTest();
			Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
			insert store;
			blClient.me = (BL_UserInfo) Type.forName('BL_ICON_UserInfo').newInstance();
			blClient.pathParameters = new Map < String, String > {
				'clientId' => acc.Id
			};
			blClient.queryParams = new Map < String, String > {
				'features' => 'personal-infos'
			};
			
			blClient.executeGET();
			Test.stopTest();

		
			try {
				BL_UserInfo b = new BL_UserInfo(); 
				b.userMergeFields();
			} catch (Exception ex) {
				System.AssertEquals(ex.getMessage(),'Argument 1 cannot be null');
			}
		
		}

	}

	@isTest
	static void testMethodGetSmi() {
		BL_AppSettings.setAppSettings('Icon');
		BL_ICON_Client blClient = new BL_ICON_Client();
		User u = [SELECT id,DefaultStore__c FROM User Limit 1];
		system.runAs(u) {
			Test.startTest();
            Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
			insert store;
			blClient.me = (BL_UserInfo) Type.forName('BL_ICON_UserInfo').newInstance();
			blClient.pathParameters = new Map < String, String > {
				'clientId' => '345673'
			};
			blClient.queryParams = new Map < String, String > {
				'wcwid' => 'BL_234',
                'features' => 'surveys'
			};
			blClient.executeGET();
			Account acc = [SELECT Id FROM Account LIMIT 1];
            Social_Media_Identifier__c smi = [SELECT Id FROM Social_Media_Identifier__c LIMIT 1];
			blClient.queryParams = new Map < String, String > ();
			blClient.pathParameters = new Map < String, String > {
				'clientId' => acc.id,
				'feature' => 'social-media-identifiers',
				'featureId' => smi.id
			};
			blClient.executeGET();
            Test.stopTest();
		}
	}

	@isTest
	static void testPostClientSocialMedia() {
		Account acc = IC_Test_Common.createAccount('2938742');
		BL_AppSettings.setAppSettings('Icon');
		BL_ICON_Client blClient = new BL_ICON_Client();
		User u = IC_Test_Common.prepareTestUser('System Administrator');
		u.DefaultStore__c = '1234';
		insert u;
		system.runAs(u) {
			Test.startTest();
			Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
			insert store;
			blClient.me = (BL_UserInfo) Type.forName('BL_ICON_UserInfo').newInstance();

			blClient.requestBody = new Map < String, Object > {
				'client' => acc.id,
				'socialEnterpriseId' => '55556',
				'socialMediaType' => 'WeChat',
				'socialId' => '1235555babeth45',
				'socialSFExternalId' => 'WeChat_1235555babeth45'
			};

			blClient.pathParameters = new Map < String, String > {
				'clientId' => acc.Id,
				'feature' => 'social-media-identifiers'
			};
			blClient.executePOST();

			Test.stopTest();



		}
	}

	@isTest
	static void testPostClientAssign() {
		Account acc = IC_Test_Common.createAccount('2938742');
		BL_AppSettings.setAppSettings('Icon');
		BL_ICON_Client blClient = new BL_ICON_Client();
		User u = IC_Test_Common.prepareTestUser('System Administrator');
		u.DefaultStore__c = '1234';
		insert u;
		system.runAs(u) {
			Test.startTest();
			Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
			insert store;
			blClient.me = (BL_UserInfo) Type.forName('BL_ICON_UserInfo').newInstance();

			blClient.requestBody = new Map < String, Object > {
				'ownerId' => u.id
			};

			blClient.pathParameters = new Map < String, String > {
				'clientId' => acc.Id,
				'feature' => 'assign'
			};
			blClient.executePOST();

			Test.stopTest();

		}
	}
	@isTest
	static void testPostMultipleClientAssign() {
		Account acc = IC_Test_Common.createAccount('2938742');
		Account acc2 = IC_Test_Common.createAccount('111111');
		BL_AppSettings.setAppSettings('Icon');
		BL_ICON_Client blClient = new BL_ICON_Client();
		User u = IC_Test_Common.prepareTestUser('System Administrator');
		u.DefaultStore__c = '1234';
		insert u;
		system.runAs(u) {
			Test.startTest();
			Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
			insert store;
			blClient.me = (BL_UserInfo) Type.forName('BL_ICON_UserInfo').newInstance();

			blClient.path = '/assign-clients';
			blClient.pathParameters = new Map < String, String > {
			
			};
			blClient.requestBody = new Map < String, Object > {
				'ownerId' => u.id, 
				'clientIds' => new List<String> {acc.Id, acc2.Id}
			};
			blClient.executePOST();

			Test.stopTest();

		}
	}

	@isTest
	static void testPostClientInterest() {

		BL_AppSettings.setAppSettings('Icon');
		BL_ICON_Client blClient = new BL_ICON_Client();


		Account acc = IC_Test_Common.createAccount('2938742');


		User u = IC_Test_Common.prepareTestUser('System Administrator');
		u.DefaultStore__c = '1234';
		insert u;

		Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
		insert store;

		system.runAs(u) {
			Test.startTest();
			blClient.me = (BL_UserInfo) Type.forName('BL_ICON_UserInfo').newInstance();

			Map < String, Object > interset = new Map < String, Object > {
				'isActive' => true,
				'categories' => 'Women Shoes'
			};
			

			blClient.requestBody = new Map < String, Object > {
				'records' => new List < Object > {
					interset
				}
			};
			blClient.pathParameters = new Map < String, String > {
				'clientId' => acc.Id,
				'feature' => 'interests'
			};
			blClient.executePOST();

			Test.stopTest();

		}
	}

	@isTest
	static void testClientVoice() {
		Test.loadData(VO_Config__c.sobjectType, 'VO_Config_TestCLS');

		BL_AppSettings.setAppSettings('Icon');
		BL_ICON_Client blClient = new BL_ICON_Client();


		Account acc = IC_Test_Common.createAccount('2938742');


		User u = IC_Test_Common.prepareTestUser('System Administrator');
		u.DefaultStore__c = '1234';
		insert u;

		Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
		insert store;

		VO_Survey__c srv = new VO_Survey__c(SurveyType__c = VO_Utils.VOICE_WEB_SALES, StoreID__c = '1234', ClientDreamID__c = acc.id, IDTransaction__c = '123');
		insert srv;

		Event ev = IC_TestFactory.createEvent(acc);
		insert ev;


		system.runAs(u) {
			Test.startTest();
			blClient.me = (BL_UserInfo) Type.forName('BL_ICON_UserInfo').newInstance();

			Map < String, Object > voice = new Map < String, Object > {
				'answerDate' => date.today(),
				'channel' => 'call'
			};
			
			blClient.queryParams = new Map < String, String > ();
			blClient.pathParameters = new Map < String, String > {
				'clientId' => acc.Id,
				'feature' => 'surveys',
				'featureId' => srv.id
			};
			blClient.executeGET();

			blClient.requestBody = new Map < String, Object > {
				'records' => new List < Object > {
					voice
				}
			};
			blClient.pathParameters = new Map < String, String > {
				'clientId' => acc.Id,
				'feature' => 'surveys'
			};
			blClient.executePOST();

			blClient.requestBody = new Map < String, Object > ();
			blClient.requestBody = voice;
			blClient.pathParameters = new Map < String, String > {
				'clientId' => acc.Id,
				'featureId' => srv.Id,
				'feature' => 'surveys'
			};
			blClient.executePUT();

			BL_ICON_Client_Helper.getClientEventById(acc.Id, ev.id);




			Test.stopTest();

		}
	}

	@isTest
	static void testPutClientbyFeatureRepairs() {
		Account acc = new Account(LastName = 'test');
		insert acc;
		BL_AppSettings.setAppSettings('Icon');
		BL_ICON_Client blClient = new BL_ICON_Client();
		User u = IC_Test_Common.prepareTestUser('System Administrator');
		u.DefaultStore__c = '1234';
		insert u;
		system.runAs(u) {
			Test.startTest();
			Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
			insert store;
			blClient.me = (BL_UserInfo) Type.forName('BL_ICON_UserInfo').newInstance();
			blClient.queryParams = new Map < String, String > ();
			CareService__c c = new CareService__c(Client__c = acc.id, store__c = store.id, StoreRetailCode__c = store.RetailStoreId__c);
			insert c;

			blClient.requestBody = new Map < String, Object > {
				'client' => acc.id,
				'ICON_Comments__c' => 'test',
				'In_Store_Action__c' => 'No action',
				'Followup_Comments__c' => 'test',
				'id' => c.id
			};
			blClient.pathParameters = new Map < String, String > {
				'clientId' => acc.Id,
				'feature' => 'repairs',
				'featureId' => c.id
			};
			blClient.executePUT();
			Test.stopTest();
		}

	}

	@isTest
	static void testClientbyFeatureRequest() {
		Account acc = new Account(LastName = 'test');
		insert acc;
		BL_AppSettings.setAppSettings('Icon');
		BL_ICON_Client blClient = new BL_ICON_Client();
		User u = IC_Test_Common.prepareTestUser('System Administrator');
		u.DefaultStore__c = '1234';
		insert u;
		system.runAs(u) {
			Test.startTest();
			Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
			insert store;
			blClient.me = (BL_UserInfo) Type.forName('BL_ICON_UserInfo').newInstance();
			blClient.queryParams = new Map < String, String > ();
			Case ca = IC_TestFactory.createCase(acc);
			insert ca;

			Map < String, Object > requests = new Map < String, Object > {
				'oldStatus' => 'new',
				'status' => 'pending',
				'caId' => u.id
			};

			

			blClient.requestBody = new Map < String, Object > {
				'records' => new List < Object > {
					requests
				}
			};
			blClient.pathParameters = new Map < String, String > {
				'clientId' => acc.Id,
				'feature' => 'requests'
			};
			blClient.executePOST();

			blClient.requestBody = new Map < String, Object > ();
			blClient.requestBody = requests;
			blClient.pathParameters = new Map < String, String > {
				'clientId' => acc.Id,
				'feature' => 'requests',
				'featureId' => ca.id
			};
			blClient.executePUT();


			blClient.requestBody = new Map < String, Object > ();
			blClient.pathParameters = new Map < String, String > {
				'clientId' => acc.Id,
				'feature' => 'requests',
				'featureId' => ca.id
			};
			blClient.executeGET();

			BL_ICON_Client_Helper.activityfieldMap();
			Test.stopTest();
		}

	}

	@isTest
	static void testGetinterests() {
		Account acc = new Account(LastName = 'test');
		insert acc;

		BL_AppSettings.setAppSettings('Icon');
		BL_ICON_Client blClient = new BL_ICON_Client();
		User u = IC_Test_Common.prepareTestUser('System Administrator');
		u.DefaultStore__c = '1234';
		insert u;
		system.runAs(u) {
			Test.startTest();
			Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
			insert store;
			blClient.me = (BL_UserInfo) Type.forName('BL_ICON_UserInfo').newInstance();
			
			blClient.queryParams = new Map < String, String > {
				'featuresSampleLimit' => '10'
			};
			blClient.pathParameters = new Map < String, String > {
				'clientId' => acc.Id,
				'feature' => 'interests'
			};
			blClient.executeGET();
			Test.stopTest();
		}
	}

	@isTest
	static void testGetsurveys() {
		Account acc = new Account(LastName = 'test');
		insert acc;
		BL_AppSettings.setAppSettings('Icon');
		BL_ICON_Client blClient = new BL_ICON_Client();
		User u = IC_Test_Common.prepareTestUser('System Administrator');
		u.DefaultStore__c = '1234';
		insert u;
		system.runAs(u) {
			Test.startTest();
			Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
			insert store;
			blClient.me = (BL_UserInfo) Type.forName('BL_ICON_UserInfo').newInstance();
			blClient.queryParams = new Map < String, String > ();
			
			blClient.pathParameters = new Map < String, String > {
				'clientId' => acc.Id,
				'feature' => 'surveys'
			};
			blClient.executeGET();
			Test.stopTest();
		}
	}
    
	@isTest
	static void testGetsurveysById() {
		Account acc = new Account(LastName = 'test');
		insert acc;
		BL_AppSettings.setAppSettings('Icon');
		BL_ICON_Client blClient = new BL_ICON_Client();
		User u = IC_Test_Common.prepareTestUser('System Administrator');
		u.DefaultStore__c = '1234';
		insert u;
		system.runAs(u) {
			Test.startTest();
			Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
			insert store;
			blClient.me = (BL_UserInfo) Type.forName('BL_ICON_UserInfo').newInstance();
			blClient.queryParams = new Map < String, String > ();
			Test.loadData(VO_Config__c.sobjectType, 'VO_Config_TestCLS');
			VO_Survey__c srv = new VO_Survey__c( ClientDreamID__c = acc.id ,SurveyType__c = VO_Utils.VOICE_WEB_SALES, StoreID__c = 'P3', DreamIDText__c = '14712', IDTransaction__c = '123');
			insert srv;
			
			blClient.pathParameters = new Map < String, String > {
				'clientId' => acc.Id,
				'feature' => 'surveys',
				'featureId' => srv.id
			};
			blClient.executeGET();
			Test.stopTest();
		}
	}
    
	@isTest
	static void testGettimelines() {
	

		Store__c store1 = new Store__c(RetailStoreId__c = 'A06' ,StoreType__c = 'Store' );
        insert store1;
        Account acc = new Account (LastName='Test', FirstName='Test',PersonEmail='test@Test.com');
        insert acc;
        Order__c order = new Order__c(Name ='Test',OrderNumber__c='2501002000228',Store__c=store1.id,Account__c=acc.id ,Source__c='KBRW',OrderDate__c=System.now());
        insert order;
        OrderShipping__c ordershipping= new OrderShipping__c(Name='Test' ,Order__c=order.id,ShippingNumber__c='a123456789',DeliveryType__c='shipforpickup',Status__c='Fulfilled',StatusDate__c=DateTime.now().addDays(-7));
        insert ordershipping ;

        OrderLine__c orderLine = new OrderLine__c(Name= 'Test',Order__c=order.id,Quantity__c=1,SKU__c='M14141',OrderShipping__c=ordershipping.id );
        insert orderLine;  


        Opportunity order2 = new Opportunity(   Name = 'Test SP Order',StageName = 'Brief in progress',CloseDate = Date.today(),Received_in_Store_Date__c = Date.today(),
                                                SPO_EstimatedProductionTimeMonths__c = 1,SPO_EstimatedDistributionTime__c = 12,SPO_UnitRetailPriceQuotation__c = 1000,
                                                SPO_ExportPrice__c = 111,SPO_Numberofproductivehours__c = 231,SPO_ProductCategory__c = 'Belts',SPO_Store__c = store1.Id,
                                                Amount = 1000,SPO_DepositAmount__c = 500, SPO_CACode__c='SIM', SPO_SkuQuantity__c=1,AccountId=acc.id , ApplicationSource__c = 'SPO' );
        insert order2;
        DateTime dT = DateTime.now().addMonths(-9);
        SPO_FirmOrder__c firmOrder = new SPO_FirmOrder__c(SPO_BriefName__c = order2.Id,LineNumber__c = 1,SPO_TechETLStatus__c = 'V',SPO_FirmOrderStatus__c = 'Distribution in progress', ProductionInProgressDate__c = date.newinstance(dT.year(), dT.month(), dT.day()));
        insert firmOrder; 
		BL_AppSettings.setAppSettings('Icon');
		BL_ICON_Client blClient = new BL_ICON_Client();
		User u = IC_Test_Common.prepareTestUser('System Administrator');
		u.DefaultStore__c = '1234';
		insert u;
		system.runAs(u) {
			Test.startTest();
			Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
			insert store;
			blClient.me = (BL_UserInfo) Type.forName('BL_ICON_UserInfo').newInstance();
			blClient.queryParams = new Map < String, String > ();
			blClient.pathParameters = new Map < String, String > {
				'clientId' => acc.Id,
				'feature' => 'timelines;xstoreOrders;nyorders'
			};
			blClient.executeGET();
			
			blClient.requestBody = new Map < String, Object > {
				'ICON_Comments__c' => 'test',
				'id' => order2.id
			};
			blClient.pathParameters = new Map < String, String > {
				'clientId' => acc.Id,
				'feature' => 'nyorders',
				'featureId' => order2.id
			};
			blClient.executePUT();
			
			blClient.requestBody = new Map < String, Object > {
				'ICON_Comments__c' => 'test',
				'id' => order.id
			};
			blClient.pathParameters = new Map < String, String > {
				'clientId' => acc.Id,
				'feature' => 'xstoreOrders',
				'featureId' => order.id
			};
			blClient.executePUT();
            blClient.pathParameters.put('feature','timelines');
            blClient.executeGET();
            blClient.pathParameters.put('featureId',order2.id);
            blClient.executeGET();
            blClient.pathParameters.put('feature','ongoings');
            blClient.executeGET();
            blClient.pathParameters.put('featureId',order.id);
            blClient.executeGET();
			Test.stopTest();

		}
	}
    
	@isTest
	static void testGetpurchaseKPI() {
		Account acc = new Account(LastName = 'test');
		insert acc;
		BL_AppSettings.setAppSettings('Icon');
		BL_ICON_Client blClient = new BL_ICON_Client();
		User u = IC_Test_Common.prepareTestUser('System Administrator');
		u.DefaultStore__c = '1234';
		insert u;
		system.runAs(u) {
			Test.startTest();
			Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
			insert store;
			blClient.me = (BL_UserInfo) Type.forName('BL_ICON_UserInfo').newInstance();
			blClient.queryParams = new Map < String, String > ();
			
			blClient.pathParameters = new Map < String, String > {
				'clientId' => acc.Id,
				'feature' => 'purchaseKPI'
			};
			blClient.executeGET();
			Test.stopTest();
		}
	}
    
	@isTest
	static void testGetpurchases() {
		Account acc = new Account(LastName = 'test');
		insert acc;
		BL_AppSettings.setAppSettings('Icon');
		BL_ICON_Client blClient = new BL_ICON_Client();
		User u = IC_Test_Common.prepareTestUser('System Administrator');
		u.DefaultStore__c = '1234';
		insert u;
		system.runAs(u) {
			Test.startTest();
			Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
			insert store;
			blClient.me = (BL_UserInfo) Type.forName('BL_ICON_UserInfo').newInstance();
			blClient.queryParams = new Map < String, String > ();
			
			blClient.pathParameters = new Map < String, String > {
				'clientId' => acc.Id,
				'feature' => 'purchases'
			};
			blClient.executeGET();
            blClient.queryParams.put('pageIndex','1');
            blClient.queryParams.put('pageSize','1');
            blClient.executeGET();
			Test.stopTest();
		}
	}
    
	@isTest
	static void testGetpurchasesById() {
		Account acc = new Account(LastName = 'test');
		insert acc;
		BL_AppSettings.setAppSettings('Icon');
		BL_ICON_Client blClient = new BL_ICON_Client();
		User u = IC_Test_Common.prepareTestUser('System Administrator');
		u.DefaultStore__c = '1234';
		insert u;
		system.runAs(u) {
			Test.startTest();
			Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
			insert store;
			blClient.me = (BL_UserInfo) Type.forName('BL_ICON_UserInfo').newInstance();
			PPR_PurchProduct__c p = new PPR_PurchProduct__c(Client__c = acc.id, Name = 'PF.SARAH RETIRO MNG CERI.', TicketNumber__c = '210728876');
			insert p;
			blClient.queryParams = new Map < String, String > ();
			
			blClient.pathParameters = new Map < String, String > {
				'clientId' => acc.Id,
				'feature' => 'purchases',
				'featureId' => p.Id
			};
			blClient.executeGET();
			Test.stopTest();
		}
	}
    
	@isTest
	static void testGetInterestById() {
		Account acc = new Account(LastName = 'test');
		insert acc;
		BL_AppSettings.setAppSettings('Icon');
		BL_ICON_Client blClient = new BL_ICON_Client();
		User u = IC_Test_Common.prepareTestUser('System Administrator');
		u.DefaultStore__c = '1234';
		insert u;
		system.runAs(u) {
			Test.startTest();
			blClient.me = (BL_UserInfo) Type.forName('BL_ICON_UserInfo').newInstance();
			Interests__c i = new Interests__c(Client__c = acc.id, Categories__c = 'Perfume');
			insert i;
			blClient.queryParams = new Map < String, String > ();
			
			blClient.pathParameters = new Map < String, String > {
				'clientId' => acc.Id,
				'feature' => 'interests',
				'featureId' => i.id
			};
			blClient.executeGET();
			Test.stopTest();
		}
	}
    
	@isTest
	static void testGetInterest() {
		Account acc = new Account(LastName = 'test');
		insert acc;
		BL_AppSettings.setAppSettings('Icon');
		BL_ICON_Client blClient = new BL_ICON_Client();
		User u = IC_Test_Common.prepareTestUser('System Administrator');
		u.DefaultStore__c = '1234';
		insert u;
		system.runAs(u) {
			Test.startTest();
			Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
			insert store;
			blClient.me = (BL_UserInfo) Type.forName('BL_ICON_UserInfo').newInstance();
			blClient.queryParams = new Map < String, String > ();
			
			blClient.pathParameters = new Map < String, String > {
				'clientId' => acc.Id,
				'feature' => 'interests'
			};
			blClient.executeGET();
			Test.stopTest();
		}
	}
    
	@isTest
	static void testGetpersonalinfos() {
		Account acc = new Account(LastName = 'test');
		insert acc;
		BL_AppSettings.setAppSettings('Icon');
		BL_ICON_Client blClient = new BL_ICON_Client();
		User u = IC_Test_Common.prepareTestUser('System Administrator');
		u.DefaultStore__c = '1234';
		insert u;
		system.runAs(u) {
			Test.startTest();
			Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
			insert store;
			blClient.me = (BL_UserInfo) Type.forName('BL_ICON_UserInfo').newInstance();
			blClient.queryParams = new Map < String, String > ();
			
			blClient.pathParameters = new Map < String, String > {
				'clientId' => acc.Id,
				'feature' => 'personal-infos'
			};
			blClient.executeGET();
			Test.stopTest();
		}
	}
    
	@isTest
	static void testGetupcomingActivities() {
		Account acc = new Account(LastName = 'test');
		insert acc;
		BL_AppSettings.setAppSettings('Icon');
		BL_ICON_Client blClient = new BL_ICON_Client();
		User u = IC_Test_Common.prepareTestUser('System Administrator');
		u.DefaultStore__c = '1234';
		insert u;
		system.runAs(u) {
			Test.startTest();
			Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
			insert store;
			Task task = new Task(Subject = 'Other', Priority = 'Normal', OwnerId = u.id, ActivityDate = Date.newInstance(2020, 07, 29));
			insert task;
			blClient.me = (BL_UserInfo) Type.forName('BL_ICON_UserInfo').newInstance();
			blClient.queryParams = new Map < String, String > ();
			
			blClient.pathParameters = new Map < String, String > {
				'clientId' => acc.Id,
				'feature' => 'upcoming-activities',
				'featureId' => task.Id
			};
			blClient.executeGET();
			Test.stopTest();
		}
	}
    
	@isTest
	static void testGetupcomingActivitiesById() {
		Account acc = new Account(LastName = 'test');
		insert acc;
		BL_AppSettings.setAppSettings('Icon');
		BL_ICON_Client blClient = new BL_ICON_Client();
		User u = IC_Test_Common.prepareTestUser('System Administrator');
		u.DefaultStore__c = '1234';
		insert u;
		system.runAs(u) {
			Test.startTest();
			Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
			insert store;
			blClient.me = (BL_UserInfo) Type.forName('BL_ICON_UserInfo').newInstance();
			blClient.queryParams = new Map < String, String > ();
			
			blClient.pathParameters = new Map < String, String > {
				'clientId' => acc.Id,
				'feature' => 'upcoming-activities'
			};
			blClient.executeGET();
			Test.stopTest();
		}
	}
    
	@isTest
	static void testGetRepairs() {
		Account acc = new Account(LastName = 'test');
		insert acc;
		BL_AppSettings.setAppSettings('Icon');
		BL_ICON_Client blClient = new BL_ICON_Client();
		User u = IC_Test_Common.prepareTestUser('System Administrator');
		u.DefaultStore__c = '1234';
		insert u;
		system.runAs(u) {
			Test.startTest();
			Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
			insert store;
			blClient.me = (BL_UserInfo) Type.forName('BL_ICON_UserInfo').newInstance();
			blClient.queryParams = new Map < String, String > ();
			
			blClient.pathParameters = new Map < String, String > {
				'clientId' => acc.Id,
				'feature' => 'repairs'
			};
			blClient.executeGET();
			Test.stopTest();
		}
	}
    
	@isTest
	static void testGetRepairsById() {
		Account acc = new Account(LastName = 'test');
		insert acc;
		BL_AppSettings.setAppSettings('Icon');
		BL_ICON_Client blClient = new BL_ICON_Client();
		User u = IC_Test_Common.prepareTestUser('System Administrator');
		u.DefaultStore__c = '1234';
		insert u;
		system.runAs(u) {
			Test.startTest();
			Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
			insert store;
			blClient.me = (BL_UserInfo) Type.forName('BL_ICON_UserInfo').newInstance();
			CareService__c c = new CareService__c(Client__c = acc.id, store__c = store.id, StoreRetailCode__c = store.RetailStoreId__c);
			insert c;
			blClient.queryParams = new Map < String, String > ();
			
			blClient.pathParameters = new Map < String, String > {
				'clientId' => acc.Id,
				'feature' => 'repairs',
				'featureId' => c.id
			};
			blClient.executeGET();
			Test.stopTest();
		}
	}
    
	@isTest
	static void testGetRequests() {
		Account acc = new Account(LastName = 'test');
		insert acc;
		BL_AppSettings.setAppSettings('Icon');
		BL_ICON_Client blClient = new BL_ICON_Client();
		User u = IC_Test_Common.prepareTestUser('System Administrator');
		u.DefaultStore__c = '1234';
		insert u;
		system.runAs(u) {
			Test.startTest();
			Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
			insert store;
			blClient.me = (BL_UserInfo) Type.forName('BL_ICON_UserInfo').newInstance();
			blClient.queryParams = new Map < String, String > ();
			
			blClient.pathParameters = new Map < String, String > {
				'clientId' => acc.Id,
				'feature' => 'requests'
			};
			blClient.executeGET();
			Test.stopTest();
		}
	}
    
	@isTest
	static void testGetLook() {
		Account acc = new Account(LastName = 'test');
		insert acc;
		BL_AppSettings.setAppSettings('Icon');
		BL_ICON_Client blClient = new BL_ICON_Client();
		User u = IC_Test_Common.prepareTestUser('System Administrator');
		u.DefaultStore__c = '1234';
		insert u;
		system.runAs(u) {
			Test.startTest();
			Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
			insert store;
			blClient.me = (BL_UserInfo) Type.forName('BL_ICON_UserInfo').newInstance();
			blClient.queryParams = new Map < String, String > ();
			
			blClient.pathParameters = new Map < String, String > {
				'clientId' => acc.Id,
				'feature' => 'looks'
			};
			blClient.executeGET();
			Test.stopTest();
		}
	}
    
    @isTest
	static void testGetLook2() {
		Account acc = new Account(LastName = 'test');
		insert acc;
		BL_AppSettings.setAppSettings('Icon');
		BL_ICON_Client blClient = new BL_ICON_Client();
		User u = IC_Test_Common.prepareTestUser('System Administrator');
		u.DefaultStore__c = '1234';
		insert u;
		system.runAs(u) {
			Test.startTest();
			Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
			insert store;
			blClient.me = (BL_UserInfo) Type.forName('BL_ICON_UserInfo').newInstance();
			blClient.queryParams = new Map < String, String > ();
			
			blClient.pathParameters = new Map < String, String > {
				'clientId' => acc.Id,
				'feature' => 'looks;interactiveWardrobings'
			};
			blClient.executeGET();
            blClient.pathParameters.put('featureId',acc.Id);
            blClient.executeGET();
			Test.stopTest();
		}
	}
    
	@isTest
	static void testGetLookById() {
		Account acc = new Account(LastName = 'test');
		insert acc;
		BL_AppSettings.setAppSettings('Icon');
		BL_ICON_Client blClient = new BL_ICON_Client();
		User u = IC_Test_Common.prepareTestUser('System Administrator');
		u.DefaultStore__c = '1234';
		insert u;
		system.runAs(u) {
			Test.startTest();
			Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
			insert store;
			blClient.me = (BL_UserInfo) Type.forName('BL_ICON_UserInfo').newInstance();
			blClient.queryParams = new Map < String, String > ();
			Look__c l = new Look__c(Name = 'MY COFFRET 8 MONTRES MONOGRAM ECLIPSE  Look', store__c = store.id, ownerId = u.id, SKUs__c = 'P00957;');
			insert l;
			
			blClient.pathParameters = new Map < String, String > {
				'clientId' => acc.Id,
				'feature' => 'looks',
				'featureId' => l.id
			};
			blClient.executeGET();
			Test.stopTest();
		}
	}
    
	@isTest
	static void testGetScialMediaIdentifiers() {
		Account acc = new Account(LastName = 'test');
		insert acc;
		BL_AppSettings.setAppSettings('Icon');
		BL_ICON_Client blClient = new BL_ICON_Client();
		User u = IC_Test_Common.prepareTestUser('System Administrator');
		u.DefaultStore__c = '1234';
		insert u;
		system.runAs(u) {
			Test.startTest();
			Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
			insert store;
			blClient.me = (BL_UserInfo) Type.forName('BL_ICON_UserInfo').newInstance();
			blClient.queryParams = new Map < String, String > ();
			
			blClient.pathParameters = new Map < String, String > {
				'clientId' => acc.Id,
				'feature' => 'social-media-identifiers'
			};
			blClient.executeGET();
			Test.stopTest();
		}
	}

	@isTest
	static void testGetOngoingRequests() {
		Account acc = new Account(LastName = 'test');
		insert acc;
		BL_AppSettings.setAppSettings('Icon');
		BL_ICON_Client blClient = new BL_ICON_Client();
		User u = IC_Test_Common.prepareTestUser('System Administrator');
		u.DefaultStore__c = '1234';
		insert u;
		system.runAs(u) {
			Test.startTest();
			Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
			insert store;
			blClient.me = (BL_UserInfo) Type.forName('BL_ICON_UserInfo').newInstance();
			blClient.queryParams = new Map < String, String > ();
			
			blClient.pathParameters = new Map < String, String > {
				'clientId' => acc.Id,
				'feature' => 'ongoings'
			};
			blClient.executeGET();
			Test.stopTest();
		}
	}
    
	@isTest
	static void testGetInterestsHistoryRequests() {
		Account acc = new Account(LastName = 'test');
		insert acc;
		BL_AppSettings.setAppSettings('Icon');
		BL_ICON_Client blClient = new BL_ICON_Client();
		User u = IC_Test_Common.prepareTestUser('System Administrator');
		u.DefaultStore__c = '1234';
		insert u;
		system.runAs(u) {
			Test.startTest();
			Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
			insert store;
			blClient.me = (BL_UserInfo) Type.forName('BL_ICON_UserInfo').newInstance();
			blClient.queryParams = new Map < String, String > ();
			
			blClient.pathParameters = new Map < String, String > {
				'clientId' => acc.Id,
				'feature' => 'interestsHistory'
			};
			blClient.executeGET();
			Test.stopTest();
		}
	}
	@isTest
	static void testGetProductRecommendation() {
		Account acc = new Account(LastName = 'test', DREAMID__c='DREAM111');
		insert acc;
		BL_AppSettings.setAppSettings('Icon');
		BL_ICON_Client blClient = new BL_ICON_Client();
		User u = IC_Test_Common.prepareTestUser('System Administrator');
		u.DefaultStore__c = '1234';
		u.WWEmployeeNumber__c='ABC123';
		insert u;
		Product_Recommendation__c rec = new Product_Recommendation__c( LVM_Id__c = u.WWEmployeeNumber__c, Dream_Id__c = acc.DREAMID__c, ProductRecommendation__c = 'M45321,M78656,M44580,M44391,M44936,M44875');
		insert rec;

		system.runAs(u) {
			Test.startTest();
			Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
			insert store;
			blClient.me = (BL_UserInfo) Type.forName('BL_ICON_UserInfo').newInstance();
			blClient.queryParams = new Map < String, String > ();
			
			blClient.pathParameters = new Map < String, String > {
				'clientId' => acc.Id,
				'feature' => 'product-recommandation'
			};
			blClient.executeGET();
		}
	}
    	
}