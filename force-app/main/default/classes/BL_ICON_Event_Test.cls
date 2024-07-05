@IsTest
public class BL_ICON_Event_Test {
	@testSetup
    static void setup() {
		User u = IC_Test_Common.prepareTestUser('System Administrator');
		u.DefaultStore__c = '1234';
		u.LastName = 'System Administrator';
		u.WWEmployeeNumber__c = 'FREMNS123';
		insert u;
		User u1 = IC_Test_Common.prepareTestUser('Standard User');
		u1.DefaultStore__c = '1234';
		u1.LastName = 'Standard User';
		insert u1;
		Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
		insert store;
		Account acc = new Account(LastName = 'testbliconevent');
		insert acc;
	}
	private static User getUser(String profileName){
		List<User> users = [SELECT Id, DefaultStore__c, WWEmployeeNumber__c FROM User WHERE LastName = :profileName AND isActive = true];
		system.debug('tk users ' + users);
		if(users.size() > 0)
			return users[0];
		return null;
	}
	private static Id getAccountId(){
		List<Account> accs = [SELECT Id FROM Account WHERE LastName = 'testbliconevent'];
		if(accs.size() > 0)
			return accs[0].Id;
		return null;
	}
	@IsTest static void testExecuteGet() {
		try {
			Test.startTest();
			User u = getUser('System Administrator');
			Account acc = IC_TestFactory.createAccount();
			insert acc;
			Event ev = IC_TestFactory.createEvent(acc);
            insert ev;
			System.runAs(u) {
				BL_AppSettings.setAppSettings('WECHAT');
				BL_WS_Router.clientPlatform = 'WECHAT';
				BL_ICON_Event event = new BL_ICON_Event();
				event.me = (BL_UserInfo) Type.forName('BL_ICON_UserInfo').newInstance();
				BL_WS_QueryMergeFields.init(event.me.userMergeFields);
				event.pathParameters = new Map < String, String > {
					'eventId' => null
				};
				event.queryParams = new Map < String, String > ();
				event.executeGET();
				event.resource = 'check';
				event.pathParameters = new Map < String, String > {
					'eventId' => ev.id
				};
				event.queryParams = new Map < String, String > {
					'relatedTickets' => '1234',
					'myTeam' => 'true'
				};
				event.executeGET();
				Test.stopTest();
			}
		} catch (Exception ex) {

		}
	}



	@IsTest static void testExecuteGetById() {
		try {
			Test.startTest();
			User u = getUser('System Administrator');
			User u2 = IC_Test_Common.prepareTestUser('System Administrator');
			u2.DefaultStore__c = '1234';
			insert u2;

			TeamMember__c tm = new TeamMember__c(User__c = u2.id, Manager__c = u.id);
			insert tm;
			System.runAs(u) {
				Account acc = IC_TestFactory.createAccount();
				insert acc;
				Event ev = IC_TestFactory.createEvent(acc);
				ev.recordTypeId = Event.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Golden').getRecordTypeId();
				ev.CA_Ids__c = u.Id + ';' + u2.Id;
				insert ev;
				BL_AppSettings.setAppSettings('Wechat');
				BL_WS_Router.clientPlatform = 'WECHAT';
				BL_ICON_Event event = new BL_ICON_Event();
				event.me = (BL_UserInfo) Type.forName('BL_ICON_UserInfo').newInstance();
				BL_WS_QueryMergeFields.init(event.me.userMergeFields);
				event.pathParameters = new Map < String, String > {
					'eventId' => ev.id
				};
				event.queryParams = new Map < String, String > ();
				event.recordId = ev.Id;
				event.executeGET();
				event.pathParameters = new Map < String, String > {
					'eventId' => null
				};
				event.queryParams = new Map < String, String > {
					'filters' => 'teamMembers;me;myStore;unassigned',
					'caIds' => u2.id
				};
				BL_WS_Router.clientPlatform = null;
				event.executeGET();
				Test.stopTest();
			}
		} catch (Exception ex) {

		}
	}

	@IsTest static void testExecutePOST() {
		try {
			Test.startTest();
			User u = getUser('Standard User');
			Id accId = getAccountId();
			System.runAs(u) {
				BL_AppSettings.setAppSettings('Wechat');
				BL_ICON_Event event = new BL_ICON_Event();
				event.me = (BL_UserInfo) Type.forName('BL_ICON_UserInfo').newInstance();
				BL_WS_QueryMergeFields.init(event.me.userMergeFields);
				List < Map < String, Object >> listRecords = new List < Map < String, Object >> ();
				listRecords.add(new Map < String, Object > {
					'subject' => 'Voice Local Sales - Neutral - Store Action Done',
					'ownerId' => u.id,
					'relatedTo' => accId,
					'startDateTime' => '2020-09-21T08:15:00Z',
      				'endDateTime' => '2020-09-30T08:15:00Z'
				});
				event.requestBody = new Map < String, Object > {
					'records' => listRecords
				};
				event.pathParameters = new Map < String, String > {
					'eventId' => null
				};
				event.queryParams = new Map < String, String >();
				event.executePOST();
				Test.stopTest();
			}
		} catch (Exception ex) {

		}

	}

    	@IsTest static void testExecutePOSTGoldenCA() {
		try {
			Test.startTest();
			User u = getUser('Standard User');
			User u1 = getUser('System Administrator');
			Id accId = getAccountId();
			BL_AppSettings.setAppSettings('Wechat');
			BL_ICON_Event event = new BL_ICON_Event();
			event.me = (BL_UserInfo) Type.forName('BL_ICON_UserInfo').newInstance();
			BL_WS_QueryMergeFields.init(event.me.userMergeFields);
			List < Map < String, Object >> listRecords = new List < Map < String, Object >> ();
			listRecords.add(new Map < String, Object > {
				'subject' => 'Other',
				'manager' => u1.id,
				'relatedToId' => accId,
				'description' => 'blabalbla',
				'startDateTime' => '2020-09-21T08:15:00Z',
      			'endDateTime' => '2020-09-30T08:15:00Z'
			});
			List < Map < String, Object >> listManagers = new List < Map < String, Object >> ();
			listManagers.add(new Map < String, Object > {
				'id' => u1.id,
				'lvMid' => u1.WWEmployeeNumber__c
			});
			event.requestBody = new Map < String, Object > {
				'records' => listRecords,
				'managerDetails' => listManagers
			};
			event.queryParams = new Map < String, String > {
				'golden' => 'true'
			};
			event.executePOST();
			event.requestBody.remove('managerDetails');
			event.executePOST();
			listRecords[0].remove('manager');
			listRecords[0].put('caIds',u.Id + ';' + u1.Id);
			event.requestBody = new Map < String, Object > {
				'records' => listRecords
			};
			event.executePOST();
			Test.stopTest();
		} catch (Exception ex) {}
	}
    
	@IsTest static void testExecuteDELETETask() {
		Test.startTest();
		User u = getUser('System Administrator');
		System.runAs(u) {
			Account acc = IC_TestFactory.createAccount();
			insert acc;
			Event ev = IC_TestFactory.createEvent(acc);
			insert ev;
			BL_AppSettings.setAppSettings('Wechat');
			BL_ICON_Event event = new BL_ICON_Event();
			event.me = (BL_UserInfo) Type.forName('BL_ICON_UserInfo').newInstance();
			BL_WS_QueryMergeFields.init(event.me.userMergeFields);
			event.pathParameters = new Map < String, String > {
				'eventId' => ev.Id
			};
			event.requestBody = new Map < String, Object > ();
			event.executeDELETE();
			Test.stopTest();
		}

	}
	@IsTest static void testExecuteDELETETasks() {
		Test.startTest();
		User u = getUser('System Administrator');
		System.runAs(u) {
			Account acc = IC_TestFactory.createAccount();
			insert acc;
			Event ev = IC_TestFactory.createEvent(acc);
			insert ev;
			BL_AppSettings.setAppSettings('Wechat');
			BL_ICON_Event event = new BL_ICON_Event();
			event.me = (BL_UserInfo) Type.forName('BL_ICON_UserInfo').newInstance();
			BL_WS_QueryMergeFields.init(event.me.userMergeFields);
			string s = '{	"records" :[{	"id": "' + ev.Id + '"}  ]}';
			event.pathParameters = new Map < String, String > {
				'eventId' => null
			};
			event.requestBody = (Map < String, Object > ) JSON.deserializeUntyped(s);
			event.executeDELETE();
			Test.stopTest();
		}

	}

	@IsTest static void testExecutePATCH() {
		try {
			Test.startTest();
			User u = getUser('System Administrator');
			BL_AppSettings.setAppSettings('Wechat');
			BL_ICON_Event event = new BL_ICON_Event();
			event.me = (BL_UserInfo) Type.forName('BL_ICON_UserInfo').newInstance();
			BL_WS_QueryMergeFields.init(event.me.userMergeFields);
			Account acc = IC_TestFactory.createAccount();
			insert acc;
			Event ev = IC_TestFactory.createEvent(acc);
			insert ev;
			string s = ' "records": [{"subject": "Voice Local Sales - Neutral - Store Action Done","relatedTo" : "' + acc.id + '","activityDate" : "2020-07-10"}]';
			List < Map < String, Object >> listRecords = new List < Map < String, Object >> ();
			listRecords.add(new Map < String, Object > {
				'subject' => 'Voice Local Sales - Neutral - Store Action Done',
				'ownerId' => u.id,
				'relatedTo' => acc.id,
				'activityDate' => '2020-07-10'
			});
			event.requestBody = new Map < String, Object > {
				'records' => listRecords
			};
			event.pathParameters = new Map < String, String > {
				'eventId' => ev.Id
			};
			event.queryParams = new Map < String, String > {
				'userId' => null
			};
			event.executePATCH();
			Test.stopTest();
		} catch (Exception ex) {

		}

	}
	@IsTest static void testExecuteHelper() {
		try {
			Test.startTest();
			User u = getUser('System Administrator');
			BL_AppSettings.setAppSettings('Wechat');
			Account acc = IC_TestFactory.createAccount();
			insert acc;
			Event ev = IC_TestFactory.createEvent(acc);
			ev.RecordTypeId = Event.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Online_Appointment').getRecordTypeId();
			insert ev;
			BL_ICON_Event_Helper.assignAppointments(null, ev.id, false);
			Test.stopTest();
		} catch (Exception ex) {}


	}
	@IsTest static void testExecuteHelper2() {
		try {
			Test.startTest();
			User u = getUser('System Administrator');
			BL_AppSettings.setAppSettings('Wechat');
			Account acc = IC_TestFactory.createAccount();
			insert acc;
			Event ev = IC_TestFactory.createEvent(acc);
			ev.RecordTypeId = Event.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Online_Appointment').getRecordTypeId();
			insert ev;
			BL_ICON_Event_Helper.attendanceAppointments(ev.id);
			Test.stopTest();
		} catch (Exception ex) {}
	}
	@IsTest static void testExecuteUT() {
		try {
			Test.startTest();
			User u = getUser('System Administrator');
			BL_AppSettings.setAppSettings('Wechat');
			BL_ICON_Event event = new BL_ICON_Event();
			event.me = (BL_UserInfo) Type.forName('BL_ICON_UserInfo').newInstance();
			BL_WS_QueryMergeFields.init(event.me.userMergeFields);
			Account acc = IC_TestFactory.createAccount();
			insert acc;
			string s = ' "records": [{"subject": "Voice Local Sales - Neutral - Store Action Done","relatedTo" : "' + acc.id + '","activityDate" : "2020-07-10"}]';
			List < Map < String, Object >> listRecords = new List < Map < String, Object >> ();
			listRecords.add(new Map < String, Object > {
				'subject' => 'Voice Local Sales - Neutral - Store Action Done',
				'ownerId' => u.id,
				'relatedTo' => acc.id,
				'activityDate' => '2020-07-10'
			});
			event.requestBody = new Map < String, Object > {
				'records' => listRecords
			};
			event.pathParameters = new Map < String, String > {
				'eventId' => null
			};
			event.queryParams = new Map < String, String > {
				'userId' => null
			};
			event.executePUT();
			event.path = '/activities/events/' + null + '/assign';
			event.executePUT();
			event.path = '/activities/events/' + null + '/attendance';
			event.executePUT();
			Test.stopTest();
		} catch (Exception ex) {

		}

	}
	@IsTest static void testExecutepUT() {
		try {
			Test.startTest();
			User u = getUser('System Administrator');
			Id onlineRT = Event.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Online_Appointment').getRecordTypeId();
            Id goldenRT = Event.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Golden').getRecordTypeId();
			Account acc = IC_TestFactory.createAccount();
			insert acc;
			Event ev = IC_TestFactory.createEvent(acc);
            ev.RecordTypeId = onlineRT;
            ev.Status__c = 'Not Assigned';
			insert ev;

			BL_AppSettings.setAppSettings('Icon');
			BL_ICON_Event event = new BL_ICON_Event();
			event.me = (BL_UserInfo) Type.forName('BL_ICON_UserInfo').newInstance();
			BL_WS_QueryMergeFields.init(event.me.userMergeFields);

			List < Map < String, Object >> listRecords = new List < Map < String, Object >> ();
			listRecords.add(new Map < String, Object > {
				'subject' => 'Voice Local Sales - Neutral - Store Action Done',
				'ownerId' => u.id,
				'relatedTo' => acc.id,
				'activityDate' => '2020-07-10'
			});
			event.requestBody = new Map < String, Object > {
				'records' => listRecords
			};
			event.pathParameters = new Map < String, String > {
				'eventId' => ev.Id
			};
			event.queryParams = new Map < String, String > {
				'userId' => u.id
			};
			event.path = '/activities/events/{eventId}/assign';
			event.executePUT();
			event.path = '/activities/events/{eventId}/attendance';
            event.executePUT();
            event.requestBody = new Map < String, Object > {
				'rejectReason' => 'Stam'
			};
            event.path = '/activities/events/{eventId}/reject';
			event.executePUT();
            event.pathParameters.put('eventId',null);
			event.executePUT();
            event.pathParameters.put('eventId',ev.Id);
            event.path = '/activities/events/{eventId}/assign';
            ev.RecordTypeId = goldenRT;
            update ev;
            event.executePUT();
			event.path = '/activities/events/{eventId}';
			event.pathParameters = new Map < String, String > {
				'eventId' => ev.Id
			};
            event.executePUT();

			BL_ICON_Event_Helper.attendanceAppointments(ev.Id);
			Test.stopTest();
		} catch (Exception ex) {

		}
        
    }   
}