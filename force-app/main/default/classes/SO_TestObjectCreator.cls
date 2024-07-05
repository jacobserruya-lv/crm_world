@isTest
public with sharing class SO_TestObjectCreator 
{
	public Account client  					{ get; set; }
	public Opportunity opp1 				{ get; set; }
    public Opportunity opp2             	{ get; set; }
	public Store__c retailStore				{ get; set; }
	public ProductReferential__c prodRef 	{ get; set; }

	public void initialization_one(Boolean addStore, Boolean addProdRef) 
	{

        System.debug('SO_TestObjectCreator - initialization_one - START:');

		SObject[] insertList = new List<SObject>();

		List<SO_Settings__c> settigList = Test.loadData(SO_Settings__c.sObjectType, 'SO_LV_Settings_For_Test_CSV');

        Map<String, RecordType> recordTypeByDevMap = SO_UTIL.retRecordTypeByDevMap(new Set<String>{'ACC_PersonAccount'});
        client = new Account(FirstName = 'testAccount'
                            ,LastName = 'Data Model Tester 001'
        					,BirthdateYear__pc 	= '1970'
        					,BirthdateMonth__pc = '05'
        					,BirthdateDay__pc	= '10'
                            ,Salutation = 'Mr'
        					,RecordTypeId = recordTypeByDevMap.get('ACC_PersonAccount').Id
                            ,IsProspect__pc = true);

        Database.insert(client);
        //insertList.add(client);

        opp1 = new Opportunity(
            					Name = 'Test Class Opp'
                			   ,SPO_CACode__c = '770X'
                			   ,StageName = SO_Settings__c.getValues(SO_UTIL.NEW_OPPORTUNITY_STAGENAME_SETTINGS_NAME).Value__c
							   ,CloseDate = Date.today().addDays(Integer.valueOf(SO_Settings__c.getValues(SO_UTIL.NEW_OPPORTUNITY_CLODEDATE_SETTINGS_NAME).Value__c))
							   ,AccountId = client.Id
        );
        opp2 = new Opportunity(
                                Name = 'Test Class Opp2'
                               ,SPO_CACode__c = '770X'
                               ,StageName = SO_Settings__c.getValues(SO_UTIL.NEW_OPPORTUNITY_STAGENAME_SETTINGS_NAME).Value__c
                               ,CloseDate = Date.today().addDays(Integer.valueOf(SO_Settings__c.getValues(SO_UTIL.NEW_OPPORTUNITY_CLODEDATE_SETTINGS_NAME).Value__c))
                               ,AccountId = client.Id
        );

        
        if(addStore) {
         	retailStore = new Store__c(Name = 'Test_' + SO_Constant_For_Test.LV_TOKYO_ROPPONGI
                                      ,RetailStoreId__c = SO_Constant_For_Test.LV_TOKYO_ROPPONGI);

         	insertList.add(retailStore);
        }
        
        
        if(addProdRef) {
        	prodRef = new ProductReferential__c(Name = 'PR-001'
        						               ,SKUCode__c = '12W');

        	insertList.add(prodRef);
        }

        Database.insert(insertList);

        if(null != retailStore) {
        	opp1.SPO_Store__c = retailStore.Id;
        }

        if(null != prodRef) {
        	opp1.SPO_BaseSKURefmodelSKU__c = prodRef.Id;
        }

        Database.insert(opp1);
        Database.insert(opp2);

        List<Picklist_Dependency__c> dependencyList = new List<Picklist_Dependency__c>();
        Picklist_Dependency__c newDependency = new Picklist_Dependency__c();
        newDependency.Opportunity_Category__c = 'Accessories';
        newDependency.Opportunity_Record_Type__c = 'Special Order Accessory';
        newDependency.Referential_Category__c = 'Accessories';
        newDependency.Name = 'Accessory';
        dependencyList.add(newDependency);

        Picklist_Dependency__c newDependency2 = new Picklist_Dependency__c();
        newDependency2.Opportunity_Category__c = 'Leather goods';
        newDependency2.Opportunity_Record_Type__c = 'Special Order Leather Good';
        newDependency2.Referential_Category__c = 'Leather Goods';
        newDependency2.Name = 'Leather good';
        dependencyList.add(newDependency2);

        Picklist_Dependency__c newDependency3 = new Picklist_Dependency__c();
        newDependency3.Opportunity_Category__c = 'Watches';
        newDependency3.Opportunity_Record_Type__c = 'Special Order Watch';
        newDependency3.Referential_Category__c = 'Watches';
        newDependency3.Name = 'Watch';
        dependencyList.add(newDependency3);

        insert dependencyList;

        System.debug('SO_TestObjectCreator - initialization_one - END:');
	}

    public void createAccount()
    {
        Account acc = new Account(Name ='Test_Account');
        Database.insert(acc);
    }

    public void customSettingForClientSearchInit() 
    {
		List<LV_CS001_SearchLabelToFields__c> settigList1 = Test.loadData(LV_CS001_SearchLabelToFields__c.sObjectType
																	   ,'LV_CS001_SearchLabelToFields_CSV');
		List<LV_CS002_SearchParameters__c> settigList2 = Test.loadData(LV_CS002_SearchParameters__c.sObjectType
			 														   ,'LV_CS002_SearchParameters_CSV');

        List<LV_CS003_SearchSOSLScopeMatrix__c> settigList3 = Test.loadData(LV_CS003_SearchSOSLScopeMatrix__c.sObjectType
                                                                       ,'LV_CS003_SearchSOSLScopeMatrix_for_Test_CSV');
	}
}