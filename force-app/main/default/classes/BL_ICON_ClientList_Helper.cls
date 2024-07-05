public with sharing class BL_ICON_ClientList_Helper {
	public static Object getAll() {
		return new Map < String, Object > {
			'main' => getMainClientLists(),
			'other' => getOtherClientLists(),
            'otherPostions' => new List<String>{'categories', 'services', 'myLists', 'others'}
		};
	}

	private static Object getMainClientLists() {
		return getPermamentsClientListsByType('Main');
	}

	private static Object getServiceClientLists() {
		return getPermamentsClientListsByType('Service');
	}

	private static Object getCategoryClientLists() {
		return getPermamentsClientListsByType('Category');
	}

	private static Object getOtherClientLists() {
		return new Map < String, Object > {
			'services' => getServiceClientLists(),
			'categories' => getCategoryClientLists(),
			'myLists' => getCustomClientListsByMe(),
			'others' => getAllCustomClientLists()
		};
	}

	private static Object getPermamentsClientListsByType(String type) {
		String target = String.isNotBlank(BL_WS_Router.clientPlatform) ? BL_WS_Router.clientPlatform : null;
        Boolean isPilot;
		String pilotCon = '';

		isPilot = IC_UTILS.isInPilotBeta('ICON');
		if(!isPilot) {
			pilotCon = ' AND DeveloperName != \'Engaged_Clients\'';
		}

		return new BL_EasyQuery()
			.useCase(BL_ICON_Constants.USE_CASE_PERMANENT_CLIENTLIST)
			.condition('Is_Active__c = true AND Type__c = \'' + type + '\' AND Target__c IN (\'' + target + '\', \'ALL\', \'\')' + pilotCon)
			.orderBy('Position__c ASC')
			.executeQuery()
			.getMappedObjects();
	}

	private static Object getAllCustomClientLists() {
		List < Map < String, Object >> otherLists = new BL_EasyQuery()
			.useCase(BL_ICON_Constants.USE_CASE_CUSTOM_CLIENTLIST)
			.addCondition('CreatedById != \'' + UserInfo.getUserId() + '\' AND OwnerId = \'' + UserInfo.getUserId() + '\' AND Active__c = TRUE AND ( ExpirationDate__c >= TODAY) AND IsMasterClientList__c = false AND Show_In_Icon__c = true')
			.limitCount(300)
			.executeQuery()
			.getMappedObjects();

		for (Map < String, Object > ml: otherLists) {
			ml.put('type', 'others');
		}

		return otherLists;
	}

	private static Object getCustomClientListsByMe() {
		List < Map < String, Object >> myLists = new BL_EasyQuery()
			.useCase(BL_ICON_Constants.USE_CASE_CUSTOM_CLIENTLIST)
			.addCondition('CreatedById = \'' + UserInfo.getUserId() + '\' AND OwnerId = \'' + UserInfo.getUserId() + '\' AND Active__c = TRUE AND ( ExpirationDate__c > TODAY OR ExpirationDate__c = NULL) AND IsMasterClientList__c = false')
			.orderBy('CreatedDate DESC')
			.limitCount(300)
			.executeQuery()
			.getMappedObjects();

		for (Map < String, Object > ml: myLists) {
			ml.put('type', 'myLists');
		}

		return myLists;
	}

	public static Object getClientListByFeatures(String features) {
		Map < String, Object > result = new Map < String, Object > ();
		List < String > featuresList = features.split(';');
		Integer featuresListSize = featuresList.size();

		for (String f: featuresList) {
			switch on f {
				when 'main' {
					result.put('main', getMainClientLists());
				}
				when 'services' {
					result.put('services', getServiceClientLists());
				}
				when 'categories' {
					result.put('categories', getCategoryClientLists());
				}
				when 'myLists' {
					result.put('myLists', getCustomClientListsByMe());
				}
				when 'others' {
					result.put('others', getAllCustomClientLists());
				}
			}
		}
		return result;
	}

	public static Map < String, Object > getCountOfListClient(String clientListId, Integer pageIndex, Integer pageSize, String caIds, String storeCode, String filterDecode, Integer tab, String sortBy, List < String > employeNumbers, String retentionType) {
		if (clientListId.startsWith('m0')) {
			return new Map < String, Object > {
				'count' => getCountPermanentListClients(clientListId, pageIndex, pageSize, caIds, storeCode, filterDecode, tab, sortBy, employeNumbers, retentionType)
			};
		} else {
			return new Map < String, Object > {
				'count' => getCountCutomListClients(clientListId)
			};
		}
	}

	private static BL_EasyQuery getSpecificClientListQuery(String clientListId) {
		String useCase = clientListId.startsWith('m0') ? BL_ICON_Constants.USE_CASE_PERMANENT_CLIENTLIST : BL_ICON_Constants.USE_CASE_CUSTOM_CLIENTLIST;
		
		return new BL_EasyQuery()
			.useCase(useCase)
			.condition('Id = \'' + clientListId + '\'')
			.executeQuery();
	}

	public static Map < Id, Object > clientListMap;

	public static Object getSpecificClientList(String clientListId) {
		if (clientListMap == null) {
			clientListMap = new Map < Id, BL_ClientList__mdt > ();
		}
		if (clientListMap.get(clientListId) == null) {
			clientListMap.put(clientListId, getSpecificClientListQuery(clientListId).getSObject());
		}
		return clientListMap.get(clientListId);
	}

	public static Object getSpecificClientListMapped(String clientListId) {
		Map < String, Object > res = getSpecificClientListQuery(clientListId).getMappedObject();
		if(res != null ){
			if(res.get('type') != 'Main')
				res.put('type', (String) res.get('createdById') != (String) res.get('OwnerId') ? 'others' : 'myLists');
			return res;
		}
	    return new BL_WS_Response (new List<Map<String,Object>>());
	}

	private static Object getCountPermanentListClients(String clientListId, Integer pageIndex, Integer pageSize, String caIds, String storeCode, String filterDecode, Integer tab, String sortBy, List < String > employeNumbers, String retentionType) {
		
		BL_ClientList__mdt cl = (BL_ClientList__mdt) getSpecificClientList(clientListId);

		if ((cl.DeveloperName == 'New_Client_Voices' || cl.DeveloperName == 'Client_Voices' || cl.DeveloperName == 'Client_Voices_Icon' || cl.DeveloperName == 'Recent_Clients' ) && String.isBlank(storeCode) && employeNumbers.IsEmpty()) {
           
            if(String.isNotBlank(caIds)){
                for(user u :database.query('SELECT Id , WWEmployeeNumber__c FROM User WHERE  Id IN '+ caIds.split(';'))) {
                    employeNumbers.add(u.WWEmployeeNumber__c);
                }
            } else {
                employeNumbers.add(BL_WS_Router.currentClass.me.basicInfos.WWEmployeeNumber__c);
            }
     	}
		
		/*if (cl.DeveloperName == 'Recent_Clients' && employeNumbers.isEmpty() && String.isBlank(storeCode)) { throw new BL_Exceptions.BL_Exception('You must to send param myTeam'); }
		if (cl.DeveloperName == 'Client_Voices' && String.isBlank(storeCode) && employeNumbers.IsEmpty()) { throw new BL_Exceptions.BL_Exception('You must to send employeeNumbers or myTeam'); }*/

		Map < String, Object > res = new Map < String, Object > ();
		if (String.isNotBlank(cl.CountQuery__c)) {
			String queryC = cl.CountQuery__c;
			queryC = queryC.contains('{OWNER_CONDITION}') ? queryC.replace('{OWNER_CONDITION}', getOwnerCondition(cl, caIds, storeCode, employeNumbers)) : queryC;
			system.debug(queryC);
			BL_WS_Log.addLogQuery(queryC, null);
			List < AggregateResult > counts = Database.query(queryC);
			if (counts.size() > 0) {
				res.put('servicesCount', counts);
			} else {
				res.put('servicesCount', new List < AggregateResult > ());
			}
		}

		String condition = (String.isNotBlank(cl.Where_Condition__c) ? cl.Where_Condition__c : ' ');
		condition = condition.contains('{OWNER_CONDITION}') ? condition.replace('{OWNER_CONDITION}', getOwnerCondition(cl, caIds, storeCode, employeNumbers)) : condition;
		condition = condition.contains('{CREATED_BY}') || condition.contains('{LASTMODIFIED_BY}') ? getBYIdCondition(condition, caIds, storeCode, employeNumbers) : condition;

		if (tab != null && String.isNotBlank(cl.Tabs__c)) {
			List < Object > tabs = (List < Object > ) JSON.deserializeUntyped(cl.Tabs__c);
			if (tabs.size() > tab) {
				Map < String, Object > tabDef = (Map < String, Object > ) tabs[tab];
				if (String.isNotBlank(storeCode) && tabDef.get('whereConditionStore') != null) {
					condition = (String) tabDef.get('whereConditionStore');
					condition = condition.contains('{OWNER_CONDITION}') ? condition.replace('{OWNER_CONDITION}', getOwnerCondition(cl, caIds, storeCode, employeNumbers)) : getOwnerCondition(condition, caIds, storeCode, employeNumbers);
				} else if (tabDef.get('whereCondition') != null) {
					condition = (String) tabDef.get('whereCondition');
					condition = condition.contains('{OWNER_CONDITION}') ? condition.replace('{OWNER_CONDITION}', getOwnerCondition(cl, caIds, storeCode, employeNumbers)) : getOwnerCondition(condition, caIds, storeCode, employeNumbers);
					condition = condition.contains('{CREATED_BY}') || condition.contains('{LASTMODIFIED_BY}') ? getBYIdCondition(condition, caIds, storeCode, employeNumbers) : condition;
				}
			}
		}

		Map < String, String > filtersMap = parseFilters(filterDecode, null);
		String addCondition = (filtersMap.get('clientFilters') != null ? filtersMap.get('clientFilters') : '');

		if (retentionType != null) {
			switch on retentionType {
				when  'all'{
					addcondition = addcondition != '' ? addcondition + ' AND VisitNumber12mr__pc >= 1' : 'VisitNumber12mr__pc >= 1';
				}
				when  'potential'{
					addcondition = addcondition != '' ? addcondition + ' AND VisitNumber12mr__pc = 1' : 'VisitNumber12mr__pc = 1';
				}
				when  'retention'{
					addcondition = addcondition != '' ? addcondition + ' AND VisitNumber12mr__pc >= 2' : 'VisitNumber12mr__pc >= 2';
				}
			}
		}

		condition = condition.contains('{FILTERS_SERVICE}') && filtersMap.get('serviceFilters') != null ? condition.replace('{FILTERS_SERVICE}', filtersMap.get('serviceFilters') + ' AND ') : condition.replace('{FILTERS_SERVICE}', ' ');
		BL_EasyQuery easyQuery = new BL_EasyQuery();
		
		if (String.isNotBlank(condition) && String.isNotBlank(addCondition)) {
			easyQuery = easyQuery.objectname('Account').condition(condition).addCondition(addCondition);
		} else if (String.isNotBlank(condition) && String.isBlank(addCondition)) {
			easyQuery = easyQuery.objectname('Account').condition(condition);
		} else if (String.isBlank(condition) && String.isNotBlank(addCondition)) {
			easyQuery = easyQuery.objectname('Account').condition(addCondition);
		} else {
			easyQuery = easyQuery.objectname('Account');
		}
		if (res.get('servicesCount') != null) {
			res.put('clientsCount', easyQuery.executeCount().getTotalSize());
			return res;
		}
		if (cl.limitCount__c != null) {
			easyQuery.limitcount(Integer.ValueOf(cl.limitCount__c));
		}
		return easyQuery.executeCount().getTotalSize();
	}

	private static Object getCountCutomListClients(String clientListId) {
		return new BL_EasyQuery()
			.objectname('Account')
			.condition('PersonContactId In (Select Client__c FRom CLM_CliListMember__c where ClientList__c = \'' + clientListId + '\')')
			.executeCount()
			.getTotalSize();
	}

	public static Object getPermanentListClients(String clientListId, Integer pageIndex, Integer pageSize, String caIds, String storeCode, String filterDecode, Integer tab, String sortBy,
			List < String > employeNumbers, String param10k, String paramRank10k, String queryId, Boolean isStandardRestApiRequired,Integer purchasesYear, String retentionType, String wecomeFriendList) {
		
		BL_ClientList__mdt cl = (BL_ClientList__mdt) getSpecificClientList(clientListId);

		if ((cl.DeveloperName == 'New_Client_Voices' || cl.DeveloperName == 'Client_Voices' || cl.DeveloperName == 'Client_Voices_Icon' || cl.DeveloperName == 'Recent_Clients' ) && String.isBlank(storeCode) && employeNumbers.IsEmpty()) {
            if(String.isNotBlank(caIds)) {
                for(user u :database.query('SELECT Id , WWEmployeeNumber__c FROM User WHERE  Id IN '+ caIds.split(';'))) {
                    employeNumbers.add(u.WWEmployeeNumber__c);
                }
            } else {
                employeNumbers.add(BL_WS_Router.currentClass.me.basicInfos.WWEmployeeNumber__c);
            }
		}
        /*
            if(cl.DeveloperName == 'Prospects' && storeCode == null){
                throw new BL_Exceptions.BL_Exception('You must to send StoreCode');
            }
            Set<String> clientIds = new Set<String>();
            Set<String> serviceIds = new Set<String>();

            if(cl.DeveloperName == 'Client_Voices' && employeNumbers.size() > 0){
                //FIND {LVM096296 OR LVM080140} IN ALL FIELDS  RETURNING VO_Survey__c(Id, CAName__c, type__c, status__c, Store where type__c in ( 'Delighted Client', 'Promoter', 'Neutral', 'Recovery Act') AND AnswerDate__c = LAST_N_DAYS:365 AND (Status__c IN ('New', 'Pending', 'No action') OR (Status__c = 'Closed' AND LastModifieddate= LAST_N_DAYS:7)))
                List<VO_Survey__c> voices = (List<VO_Survey__c>) new BL_EasyQuery()
                                            .objectName('VO_Survey__c')
                                            .fields(new List<String>{'ClientDreamID__c', 'Id'})
                                            .condition('type__c in ( \'Delighted Client\', \'Promoter\', \'Neutral\', \'Recovery Act\') AND AnswerDate__c = LAST_N_DAYS:365 AND (Status__c IN (\'New\', \'Pending\', \'No action\') OR (Status__c = \'Closed\' AND LastModifieddate= LAST_N_DAYS:7))')
                                            .searchText(String.join(employeNumbers, ' OR '))
                                            .executeSearch()
                                            .getSObjects();

                for(VO_Survey__c vv : voices){
                    if(vv.ClientDreamID__c != null)
                    clientIds.add(vv.ClientDreamID__c);
                    serviceIds.add(vv.Id);
                }
                condition = condition.contains('{CLIENT_IDS}') ? condition.replace('{CLIENT_IDS}', '(\'' +String.join(new list<String>(clientIds), '\',\'') + '\')') : condition;
            }
        */

		String useCase = cl.useCase__c != null ? cl.useCase__c : BL_ICON_Constants.USE_CASE_CLIENTMEMBERS;
		String condition = (param10k != null && param10k != '' ? ' Ind_10K__c =\'' + param10k + '\' AND ' : '') + (paramRank10k != null && paramRank10k != '' ? 'indic_10K_rank__c =\'' + paramRank10k + '\' AND ' : '') + (cl.Where_Condition__c != null ? cl.Where_Condition__c : ' ');
		condition = condition.contains('{OWNER_CONDITION}') ? condition.replace('{OWNER_CONDITION}', getOwnerCondition(cl, caIds, storeCode, employeNumbers)) : condition;
		Map < String, String > filtersMap = parseFilters(filterDecode, wecomeFriendList);
		String addCondition = (filtersMap.get('clientFilters') != null ? filtersMap.get('clientFilters') : '');
		Map<String,String> customFieldStringMap = new Map<String,String>{
		 	'{OWNER_CONDITION}' => getOwnerCondition(cl, caIds, storeCode, employeNumbers), 
		 	'{FILTERS_SERVICE}' => (filtersMap.get('serviceFilters') != null ? filtersMap.get('serviceFilters') + ' AND ' : ' ')
		};

		condition = condition.contains('{FILTERS_SERVICE}') && filtersMap.get('serviceFilters') != null ? condition.replace('{FILTERS_SERVICE}', filtersMap.get('serviceFilters') + ' AND ') : condition.replace('{FILTERS_SERVICE}', ' ');
		condition = condition.contains('{CREATED_BY}') || condition.contains('{LASTMODIFIED_BY}') ? getBYIdCondition(condition, caIds, storeCode, employeNumbers) : condition;
		condition = condition.contains('{PURCHASES_YEAR}') ? condition.replace('{PURCHASES_YEAR}', String.ValueOf(purchasesYear) ) : condition;

		if (retentionType != null) {
			switch on retentionType {
				when  'all'{
					addcondition = addcondition != '' ? addcondition + ' AND VisitNumber12mr__pc >= 1' : 'VisitNumber12mr__pc >= 1';
				}
				when  'potential'{
					addcondition = addcondition != '' ? addcondition + ' AND VisitNumber12mr__pc = 1' : 'VisitNumber12mr__pc = 1';
				}
				when  'retention'{
					addcondition = addcondition != '' ? addcondition + ' AND VisitNumber12mr__pc >= 2' : 'VisitNumber12mr__pc >= 2';
				}
			}
		}

		if (tab != null && String.isNotBlank(cl.Tabs__c)) {
			List < Object > tabs = (List < Object > ) JSON.deserializeUntyped(cl.Tabs__c);
			if (tabs.size() > tab) {
				Map < String, Object > tabDef = (Map < String, Object > ) tabs[tab];
				if (String.isNotBlank(storeCode) && tabDef.get('whereConditionStore') != null) {
					condition = (String) tabDef.get('whereConditionStore');
					condition = condition.contains('{OWNER_CONDITION}') ? condition.replace('{OWNER_CONDITION}', getOwnerCondition(cl, caIds, storeCode, employeNumbers)) : getOwnerCondition(condition, caIds, storeCode, employeNumbers);
				} else if (tabDef.get('whereCondition') != null) {
					condition = (String) tabDef.get('whereCondition');
					condition = condition.contains('{OWNER_CONDITION}') ? condition.replace('{OWNER_CONDITION}', getOwnerCondition(cl, caIds, storeCode, employeNumbers)) : getOwnerCondition(condition, caIds, storeCode, employeNumbers);
					condition = condition.contains('{CREATED_BY}') || condition.contains('{LASTMODIFIED_BY}') ? getBYIdCondition(condition, caIds, storeCode, employeNumbers) : condition;
				}
			}
		}

		String orderBy;
		if (sortBy != null && cl.isSortByReplacing__c == true) {
			orderBy = sortBy;
		} else if (sortBy != null && cl.isSortByReplacing__c == false) {
			orderBy = cl.Order_by__c + ',' + sortBy;
		} else {
			orderBy = cl.Order_by__c;
		}

		BL_EasyQuery easyQuery = new BL_EasyQuery();
		
	    if (condition != '' && addCondition != '') {
			easyQuery = easyQuery.useCase(useCase).condition(condition).addCondition(addCondition);
		} else if (condition != '' && addCondition == '') {
			easyQuery = easyQuery.useCase(useCase).condition(condition);
		} else if (condition == '' && addCondition != '') {
			easyQuery = easyQuery.useCase(useCase).condition(addCondition);
		} else {
			easyQuery = easyQuery.useCase(useCase);
		}

		if (cl.limitCount__c != null) {
			easyQuery.limitcount(Integer.ValueOf(cl.limitCount__c));
		}
		easyQuery.orderBy(orderBy)
			.pagination(pageIndex, pageSize);
		if (String.isNotBlank(queryId)) {
			easyQuery.queryId(queryId);
		}
		if(cl.DeveloperName == 'Retention_Clients') {
			String innerSelectPurchases = cl.Inner_Selects__c.replace('{PURCHASES_YEAR}',  '(' + purchasesYear + ')');
			easyQuery.addInnerSelect(innerSelectPurchases);
		}
		easyQuery.setCustomFieldString(customFieldStringMap);
		if (isStandardRestApiRequired) {
			Map<String, Object> members = new Map<String, Object>();			
			members = easyQuery.executeRestQuery().getResponseSObjects();
     
            if(BL_WS_Router.clientPlatform != 'WECHAT') {
				if(members.get('records') instanceof List<SObject> )
					setOwnerDetails(members,null) ;
				else
				 	setOwnerDetailsMapped(members);
            }
			return members;
		} else {
			return easyQuery.executeQuery()
				.GetSObjects();
		}
	}

	public static void setOwnerDetailsMapped(Map<String, Object> members) {
        
        Set<String> ownerIdsList = new Set<String>();
		List<Map<String, Object>> clients = members != null ? ( List<Map<String, Object>>) members.get('records') : null ;
        
		for(Map<String, Object> client : clients){
            ownerIdsList.add((String)client.get('OwnerId'));
        }
        
        if(!ownerIdsList.isEmpty()) {
            Map<String, User> owners = new Map<String, User>();
            for(User u: [SELECT Id, Name, IsTechnicalUser__c FROM User WHERE Id IN:ownerIdsList]) {
                owners.put(u.Id,u);
			}

            for(Map<String, Object> client : clients) {
                String ownerId = (String)client.get('OwnerId');
				client.put('Owner',owners.get(ownerId));
			}
            members.put('records',(Object) clients);
        }        
    }
    
    public static void setOwnerDetails(Map<String, Object> members, List<Object> members2) {
        
        Set<String> ownerIdsList = new Set<String>();
        List<SObject> clients = members != null ? (List<SObject>) members.get('records') :(List<SObject>) members2;
        
        for(SObject client : clients){
            Account c = (Account) client;
            ownerIdsList.add(c.ownerId);
        }

        if(!ownerIdsList.isEmpty()){
            Map<String, User> owners = new Map<String, User>();
            for(User u: [SELECT Id, Name, IsTechnicalUser__c FROM User WHERE Id IN:ownerIdsList]) {
                owners.put(u.Id,u);
            }

            for(SObject client : clients){
            	Account c = (Account) client;
                String ownerId = c.ownerId;
                c.owner = owners.get(ownerId);                
			}

            if(members != null){
                members.put('records',(Object) clients)  ;
            } 
        }        
    }

	public static Object getCutomListClients(String clientListId, Integer pageIndex, Integer pageSize, String queryId, Boolean isStandardRestApiRequired, String storeCode, String myTeamIds) {

		String myStoreCon = '';
		String masterId = [SELECT id, Master_Client_List__c FROM CLI_CliList__c where id = :clientListId].Master_Client_List__c;
		if(String.isNotBlank(masterId)) {
			if(String.isNotBlank(storeCode)) {
				myStoreCon = 'PersonContactId in (Select Client__c FRom CLM_CliListMember__c where ClientList__r.Owner_Default_Store__c = \''+ storeCode +'\' AND ClientList__r.Master_Client_List__c = \'' + masterId + '\')';
			}
			else if(String.isNotEmpty(myTeamIds)) {
				myStoreCon = 'PersonContactId in (Select Client__c FRom CLM_CliListMember__c where ClientList__r.OwnerId IN (' + myTeamIds + ') and ClientList__r.Master_Client_List__c = \'' + masterId + '\')';
			}
		}

		BL_EasyQuery easyQuery = new BL_EasyQuery()
			.useCase(BL_ICON_Constants.USE_CASE_CLIENTMEMBERS)
			.condition(String.isNotBlank(myStoreCon) ? myStoreCon : 'PersonContactId In (Select Client__c FRom CLM_CliListMember__c where ClientList__c = \'' + clientListId + '\')')
			.pagination(pageIndex, pageSize);

		if (String.isNotBlank(queryId)) {
			easyQuery.queryId(queryId);
		}
		if (isStandardRestApiRequired) {
			return easyQuery.executeRestQuery()
				.getResponseSObjects();
		} else {
			return easyQuery.executeQuery()
				.GetSObjects();
		}
	}

	public static Object addClientListMembers(Object wrapperItemMap) {
		List < CLM_CliListMember__c > clientListMembersToInsert = new List < CLM_CliListMember__c > ();
		Map < String, Object > ClientListMap = (Map < String, Object > ) wrapperItemMap;
		Set < String > clientListMembersMapContact = new Set < String > ();

		clientListMembersMapContact = getContactRelatedToAccount(ClientListMap);
		for (String member: clientListMembersMapContact) {
			CLM_CliListMember__c clm = new CLM_CliListMember__c();
			clm.ClientList__c = ClientListMap.get('id').toString();
			clm.Client__c = member;
			clm.TECH_External_Id__c = ClientListMap.get('id').toString() + '_' + member;
			clientListMembersToInsert.add(clm);
		}
		Schema.SObjectField ExternalIdField = CLM_CliListMember__c.Fields.TECH_External_Id__c;
		Database.UpsertResult[] results = Database.upsert(clientListMembersToInsert, ExternalIdField, false);

		//we want to return the new client list id, not the members
		List < Map < String, Object >> returnClientLists = new List < Map < String, Object >> ();
		returnClientLists.add(new Map < String, Object > {
			'id' => ClientListMap.get('id').toString(),
			'success' => true,
			'errors' => new List < Object > ()
		});
		return returnClientLists;
	}

	public static Object createClientList(Object record) {
		List < CLM_CliListMember__c > clientListMembersToInsert = new List < CLM_CliListMember__c > ();
		Map < String, Object > ClientListMap = (Map < String, Object > ) record;

		Set < String > clientListMembersMapContact = getContactRelatedToAccount(ClientListMap);
		CLI_CliList__c cl = new CLI_CliList__c();
		cl.Name = ClientListMap.get('name').toString();
		if(ClientListMap.containsKey('expirationDate') && String.isNotEmpty(ClientListMap.get('expirationDate').toString())){
			cl.ExpirationDate__c = Date.valueOf(ClientListMap.get('expirationDate').toString());
		}	
		if (ClientListMap.get('ownerId') != null) {
			cl.OwnerId = ClientListMap.get('ownerId').toString();
		}
		if (ClientListMap.get('description') != null) {
			cl.Description__c = ClientListMap.get('description').toString();
		}
		insert cl;

		for (String member: clientListMembersMapContact) {
			CLM_CliListMember__c clm = new CLM_CliListMember__c();
			clm.Client__c = member;
			clm.ClientList__c = cl.Id;
			clm.TECH_External_Id__c = cl.Id + '_' + member;
			clientListMembersToInsert.add(clm);
		}

		if (clientListMembersToInsert.size() > 0) {
			Database.SaveResult[] results2 = Database.insert(clientListMembersToInsert);
			if (!results2[0].isSuccess()) {
				//we want to return the new client list id, not the members
				return results2;
			}
		}

		return getSpecificClientListMapped(cl.Id);
	}

	public static Object updateClientList(String ClientListId, Object record) {
		List < CLM_CliListMember__c > clientListMembersToDelete = new List < CLM_CliListMember__c > ();
		List < CLM_CliListMember__c > clientListMembersToInsert = new List < CLM_CliListMember__c > ();
		Map < String, Object > ClientListMap = (Map < String, Object > ) record;
		CLI_CliList__c cl = new CLI_CliList__c();
		cl.Id = ClientListId;
		Set < String > clientListMembersMapContact = new Set < String > ();
		clientListMembersMapContact = getContactRelatedToAccount(ClientListMap);
		if(ClientListMap.containsKey('expirationDate') && String.isNotEmpty(ClientListMap.get('expirationDate').toString())){
			cl.ExpirationDate__c = Date.valueOf(ClientListMap.get('expirationDate').toString());
		}
		if (ClientListMap.get('name') != null) {
			cl.Name = ClientListMap.get('name').toString();
		}
		if (ClientListMap.get('ownerId') != null) {
			cl.OwnerId = ClientListMap.get('ownerId').toString();
		}
		if (ClientListMap.get('description') != null) {
			cl.Description__c = ClientListMap.get('description').toString();
		}
		for (String member: clientListMembersMapContact) {
			CLM_CliListMember__c clm = new CLM_CliListMember__c();
			clm.ClientList__c = ClientListId;
			clm.Client__c = member;
			clm.TECH_External_Id__c = ClientListId + '_' + member;
			clientListMembersToInsert.add(clm);
		}

		clientListMembersToDelete = new BL_EasyQuery()
			.useCase(BL_ICON_Constants.USE_CASE_CLIENTLISTMEMBERS)
			.condition('ClientList__c = \'' + ClientListId + '\'')
			.executeQuery()
			.getSObjects();

		update cl;

		if (clientListMembersToDelete.size() > 0) {
			try {
				Database.DeleteResult[] resultsDelete = Database.delete(clientListMembersToDelete, true);
				if (!resultsDelete[0].isSuccess()) {
					return resultsDelete;
				}
            }
            catch(Exception e){}
		}

		if (clientListMembersToInsert.size() > 0) {
			try {
				Database.SaveResult[] resultsMembers = Database.insert(clientListMembersToInsert, true);
				if (!resultsMembers[0].isSuccess()) {
					return resultsMembers;
				}
            }
            catch(Exception e){}
		}

		//we want to return the new client list id, not the members
		return getSpecificClientListMapped(cl.Id);
	}

	public static Object deleteClientList(String ClientListId) {
		CLI_CliList__c clientListToDelete = new CLI_CliList__c(Id = ClientListId);
		Database.DeleteResult result = Database.delete(clientListToDelete);
		return result;
	}

	private static String getOwnerCondition(BL_ClientList__mdt cl, String caIds, String storeCode, List < String > employeNumbers) {
		String ownerCondition = '';

		if (String.isBlank(storeCode) && String.isBlank(caIds) && cl.Owner_Condition__c.contains('{USER_ID}')) {
			return cl.Owner_Condition__c.replace('{USER_ID}', '\'' + UserInfo.getUserId() + '\'');
		}
		if (String.isNotBlank(storeCode) && cl.Store_Condition__c.contains('{STORE_CODE}')) {
			if (!cl.UseStoreCode__c) {
				String storeId = [select id from Store__c where RetailStoreId__c =:storeCode limit 1].Id;
				ownerCondition = cl.Store_Condition__c.replace('{STORE_CODE}', '\'' + storeId + '\'');
			}
			else {
				ownerCondition = cl.Store_Condition__c.replace('{STORE_CODE}', '\'' + storeCode + '\'');
			}
		} else if (String.isNotBlank(caIds) && cl.Members_Condition__c.contains('{MEMBERS_IDS}')) {
			ownerCondition = cl.Members_Condition__c.replace('{MEMBERS_IDS}', '(' + caIds + ')');
		} else if (employeNumbers.size() == 1) {
			String empNb = employeNumbers[0];
			if (!cl.Members_Condition__c.contains('like \'%{EMPLOYENUMBER}%\'')) {
				empNb = '\'' + empNb + '\'';
			}
			ownerCondition = cl.Owner_Condition__c.replace('{EMPLOYENUMBER}', empNb);
		} else if (employeNumbers.size() > 1 && cl.Members_Condition__c.contains('like \'%{EMPLOYENUMBER}%\'')) {
			String fieldQuery = cl.Members_Condition__c.substringBefore('like');
			ownerCondition = cl.Members_Condition__c.replace(cl.Members_Condition__c, '(' + fieldQuery + ' like \'%' + String.join(employeNumbers, '%\' OR ' + fieldQuery + ' like \'%') + '%\')');
		} else {
			ownerCondition = cl.Members_Condition__c.replace('{EMPLOYENUMBER}', '(\'' + String.join(employeNumbers, '\',\'') + '\')');
		}
		return ownerCondition;
	}

	private static String getOwnerCondition(String condition, String caIds, String storeCode, List < String > employeNumbers) {
		if ((storeCode == null || storeCode == '') && (caIds == null || caIds == '') && condition.contains('{USER_ID}')) {
			return condition.replace('{USER_ID}', '\'' + UserInfo.getUserId() + '\'');
		}
		if (storeCode != null && storeCode != '' && condition.contains('{STORE_CODE}')) {
			condition = condition.replace('{STORE_CODE}', '\'' + storeCode + '\'');
		}
		if (caIds != null && caIds != '' && condition.contains('{MEMBERS_IDS}')) {
			condition = condition.replace('{MEMBERS_IDS}', '(' + caIds + ')');
		}
		if (employeNumbers.size() == 1 && condition.contains('{EMPLOYENUMBER}')) {
			condition = condition.replace('{EMPLOYENUMBER}', '\'' + employeNumbers[0] + '\'');
		}
		if (employeNumbers.size() > 1 && condition.contains('like \'%{EMPLOYENUMBER}%\'')) {
			condition = condition.replace('CAName__c like \'%{EMPLOYENUMBER}%\'', '(CAName__c like \'%' + String.join(employeNumbers, '%\' OR CAName__c like \'%') + '%\')');
		}
		if (employeNumbers.size() > 1 && condition.contains('{EMPLOYENUMBER}')) {
			condition = condition.replace('{EMPLOYENUMBER}', '(\'' + String.join(employeNumbers, '\',\'') + '\')');
		}
		if (condition.contains('{STORE_CODE}') && BL_WS_Router.currentClass != null && BL_WS_Router.currentClass.me != null && BL_WS_Router.currentClass.me.basicInfos != null && String.isNotBlank(BL_WS_Router.currentClass.me.basicInfos.defaultStore__c)) {
			condition = condition.replace('{STORE_CODE}', '\'' + BL_WS_Router.currentClass.me.basicInfos.defaultStore__c + '\'');
		}
		if (condition.contains('{STORE_CODE}') || condition.contains('{MEMBERS_IDS}') || condition.contains('{EMPLOYENUMBER}') || condition.contains('{EMPLOYENUMBER}') || condition.contains('{USER_ID}')) {
			throw new BL_Exceptions.BL_Exception('Missing parameters in query to send : ' + condition);
		}
		return condition;
	}

	private static String getBYIdCondition(String condition, String caIds, String storeCode, List < String > employeNumbers) {
		if ((storeCode == null || storeCode == '') && (caIds == null || caIds == '') && condition.contains('{LASTMODIFIED_BY}')) {
			return condition.replace('{LASTMODIFIED_BY}', 'LastModifiedbyId = \'' + UserInfo.getUserId() + '\'');
		}
		if ((storeCode == null || storeCode == '') && (caIds == null || caIds == '') && condition.contains('{CREATED_BY}')) {
			return condition.replace('{CREATED_BY}', 'CreatedById = \'' + UserInfo.getUserId() + '\'');
		}
		if (caIds != null && caIds != '' && condition.contains('{LASTMODIFIED_BY}')) {
			condition = condition.replace('{LASTMODIFIED_BY}', 'LastModifiedbyId IN (' + caIds + ')');
		}
		if (caIds != null && caIds != '' && condition.contains('{CREATED_BY}')) {
			condition = condition.replace('{CREATED_BY}', 'CreatedbyId IN (' + caIds + ')');
		}
		if (condition.contains('{LASTMODIFIED_BY}') || condition.contains('{CREATED_BY}')) {
			throw new BL_Exceptions.BL_Exception('Missing parameters in query to send : ' + condition);
		}
		return condition;
	}

	private static Set < String > getContactRelatedToAccount(Map < String, Object > ClientListMap) {
		List < String > clientIds = new List < String > ();
		Set < String > clientListMembersMapContact = new Set < String > ();
		if (ClientListMap.get('clientIds') != null) {
			for (Object o: (List < Object > ) ClientListMap.get('clientIds')) {
				clientIds.add((String) o);
			}
			if (clientIds.size() > 0) {
				String clientIdsToString = '\'' + String.join((clientIds), '\',\'') + '\'';
				List < Contact > contacts = new BL_EasyQuery()
					.objectName('Contact')
					.fields(new String[] { 'Id' })
					.condition('AccountId in (' + clientIdsToString + ')')
					.executeQuery()
					.getSObjects();
				for (Contact c: contacts) {
					clientListMembersMapContact.add(c.id);
				}
			}
		}

		return clientListMembersMapContact;
	}

	private static Map < String, String > parseFilters(String filterString, String wecomeFriendList) {
		Map < String, String > results = new Map < String, String > ();
		if (String.isBlank(filterString)) {
			return results;
		}
		List < String > clientFilters = new List < String > ();
		List < String > serviceFilters = new List < String > ();
		List < String > servicesFields = new List < String > {
			'Status__c',
			'In_Store_Status__c',
			'Followup_Status__c',
			'TransactionId__c',
			'MYLV_Care_Status__c',
			'Red_Code__c',
			'Yellow_Code__c',
			'Type__c',
            'ApplicationSource__c',
            'OrderNumber__c',
            'Client_Full_Name_text__c',
            'StageName',
			'CaseNumber',
			'MessageToCA__c',
			'MyRepairStatus__c',
			'nbCancelledShipping__c',
			'nbCompleteShipping__c',
			'nbOpenShipping__c',
			'nbReceivedShipping__c',
            'RespondentProfile__c',
            'GlobalScore__c',
            'Solved__c'
		};
		String wechatBinding, wecomeFriend;

		List < String > filters = filterString.split(';');
		for (String filter: filters) {
			List < String > filterComp = matchFilter(filter);
			String field = filterComp.size() == 3 ? filterComp[0] : filter;
			String operator = filterComp.size() == 3 ? filterComp[1] : null;
			String value = filterComp.size() == 3 ? filterComp[2] : null;

			if (String.isNotBlank(field) && (servicesFields.contains(field))) {
				if (operator == 'INCLUDES' || operator == 'IN' || operator == 'LIKE') {
					serviceFilters.add(field + BL_ICON_Utils.buildMultiChoiceFilterFromList(value.split(',')));
				} else if (operator == 'LIKE') {
					serviceFilters.add(field + ' LIKE \'%' + value + '\'');
				} else {
					serviceFilters.add(filter);
				}
			} else if (String.isNotBlank(field) && String.isNotBlank(value) && !value.contains('(') && (operator == 'INCLUDES' || operator == 'IN' || operator == 'LIKE')) {
				if (operator == 'INCLUDES' || operator == 'IN') {
					clientFilters.add(field + BL_ICON_Utils.buildMultiChoiceFilterFromList(value.split(',')));
				} else if (operator == 'LIKE') {
					clientFilters.add(field + ' LIKE \'%' + value + '%\'');
				}
			} else{
				if(field == 'WechatBinding')
					wechatBinding = value == 'true' ?  'IN' : 'NOT IN';
				else if (field == 'WecomFriend')
					wecomeFriend = value == 'true' ? 'IN' : 'NOT IN';
				else {
					clientFilters.add(filter);
				}
			}
		}

		string SMIcondition;
		if (wechatBinding!=null && wecomeFriend!=null){
			if(wechatBinding == 'IN') {//wechatbinding = true
				SMIcondition = 'ID '+ wechatBinding+' (SELECT client__c FROM Social_Media_Identifier__c where Social_Media_Type__c =\'WECHAT\' and Tech_isBound__c = true and Social_Enterprise_Id__c '+wecomeFriend+' '+wecomeFriendList+')';
			} else {//wechatbinding = false
				if (wecomeFriend == 'IN') {//wecome friend = true
					SMIcondition = 'ID IN (SELECT client__c FROM Social_Media_Identifier__c where Social_Media_Type__c =\'WECHAT\' and Tech_isBound__c = false and Social_Enterprise_Id__c IN '+wecomeFriendList+')';
				} else { //wecome friend = false
					SMIcondition = 'ID NOT IN (SELECT client__c FROM Social_Media_Identifier__c where Social_Media_Type__c =\'WECHAT\' and (Tech_isBound__c = true or Social_Enterprise_Id__c IN '+wecomeFriendList+'))';
				}
			}
		} else if (wechatBinding!=null) {// wecomeFriend undefined
			SMIcondition = 'ID '+ wechatBinding+' (SELECT client__c FROM Social_Media_Identifier__c where Social_Media_Type__c =\'WECHAT\' and Tech_isBound__c = true)';
		} else if(wecomeFriend!=null) {// wechatBinding undefined 
			SMIcondition = 'ID '+wecomeFriend+' (SELECT client__c FROM Social_Media_Identifier__c where Social_Media_Type__c =\'WECHAT\' and Social_Enterprise_Id__c IN '+wecomeFriendList+')';
		} 
		if(SMIcondition != null) clientFilters.add(SMIcondition);

		results.put('clientFilters', clientFilters.size() > 0 ? String.join(clientFilters, ' AND ') : null);
		results.put('serviceFilters', serviceFilters.size() > 0 ? String.join(serviceFilters, ' AND ') : null);
		return results;
	}

	private static List < String > matchFilter(String str) {
		try {
			pattern myPattern = pattern.compile('^([^ ]+)[ ]+([^ ]+)[ ]+(.*)$');
			matcher myMatcher = myPattern.matcher(str);
			myMatcher.find();

			if (myMatcher.groupCount() < 2) {
				return new List < String > {myMatcher.group(0)};
			}
			system.debug(new List < String > {
				myMatcher.group(1),
				myMatcher.group(2),
				myMatcher.group(3)
			});

			return new List < String > {
				myMatcher.group(1),
				myMatcher.group(2),
				myMatcher.group(3)
			};
			
		} catch (Exception e) {return new List < String > {str};}
	}
}