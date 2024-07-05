/**
    About
    -----
    Description: Search clients with filter and create Client lists
    Create date: July 2016

    Details
    -------
    Test class for IC_TargetedClientsLists_VFCx_New

    Update History
    --------------
    July 2016 / Created by Balink
    
    Issues / TODOs
    --------------
*/




@isTest
public class IC_TargetedClients_VFCx_New_Test {
    @TestSetup
    public static void setup() {
        String identityProfile = [SELECT Id FROM Profile WHERE Name = 'Identity User'][0].Id;
        insert new IC_Config__c(
            Name = 'Identity User',
            Value__c = identityProfile
        );
    }
    static testMethod void deactivatePageTest(){
        User u = IC_Test_Common.createTestUser();
        System.runAs(u){
        Account acc1 = IC_Test_Common.createPersonAccount('83866129');
        IC_TargetedClientsLists_VFCx_New.HierarchyLevel level1 = new IC_TargetedClientsLists_VFCx_New.HierarchyLevel();
            level1.label = 'A06';
            level1.value = 'A06';
            IC_TargetedClientsLists_VFCx_New.HierarchyLevel level2 = new IC_TargetedClientsLists_VFCx_New.HierarchyLevel();
            level1.label = 'EMEA';
            level1.value = '15';
            IC_TargetedClientsLists_VFCx_New.HierarchyLevel level3 = new IC_TargetedClientsLists_VFCx_New.HierarchyLevel();
            level1.label = 'DANMARK';
            level1.value = '187';
            Map<String,IC_TargetedClientsLists_VFCx_New.HierarchyLevel> sFilter = new Map<String,IC_TargetedClientsLists_VFCx_New.HierarchyLevel> ();
            IC_TargetedClientsLists_VFCx_New.GetClientLists('xmas',sfilter,'');
            sFilter.put('2',level3);
            sFilter.put('1',level2);
            sFilter.put('3',level2);
            sFilter.put('4',level1);
            sFilter.put('5',level2);

            IC_TargetedClientsLists_VFCx_New.GetClientLists('xmas',sfilter,'');

        }
    }
    static testMethod void testLaunchSearch() {
        User u = IC_Test_Common.createTestUser();
        CLI_CliList__c cli= IC_Test_Common.createClientList();
        List<String> cli_list = new List<String>();
        cli_list.add(cli.Id);
        Account acc1 = IC_Test_Common.createPersonAccount('83866129');
        Account acc2 = IC_Test_Common.createPersonAccount('83630074');
        //insert lAccount;
        System.runAs(u){         
            acc1.ownerId = u.id; 
            update acc1;
            acc2.ownerId = u.id; 
            update acc2;  
            IC_TargetedClientsLists_VFCx_New.InterestFilter iFilter= new IC_TargetedClientsLists_VFCx_New.InterestFilter();
            
            IC_TargetedClientsLists_VFCx_New.ProductFilter pFilter =  new IC_TargetedClientsLists_VFCx_New.ProductFilter(); 
            pFilter.purchaseDateFrom = '2016-08-02';
            pFilter.purchaseDateTo = '2016-08-03';
            pFilter.Categories = new List<String> {'Shoes', 'Watches', 'Ready To Wear', 'Leather Goods', 'Jewelry', 'Accessories'}; 
            pFilter.ProductGenders = new List<String> {'Female', 'Male', 'Other', 'Unknown'};
            pFilter.uploadedSKUIds = new List<String> {'16565461', '52649172', '52867119', '18522140', '53252525', '53600010', '83630074', '83866129'};

            IC_TargetedClientsLists_VFCx_New.ClientFilter cFilter =  new IC_TargetedClientsLists_VFCx_New.ClientFilter(); 
            cFilter.lastCorporateOutreachFrom = '2016-08-02';
            cFilter.lastCorporateOutreachTo = '2016-08-03';
            cFilter.lastStoreOutreachFrom = '2016-08-02';
            cFilter.lastStoreOutreachTo = '2016-08-03';
            cFilter.segmentations = new List<String> {'Sleepers', 'Adventurers', 'Core clients', 'Novices', 'VIC', 'The Family', 'Emerging'};
            cFilter.PersonDoNotCall = true;
            cFilter.PersonHasOptedOutOfEmail = false;
            cFilter.DoNotSMS = false;
            cFilter.DoNotContactbyPost = true;
            //cFilter.preferredCA = u.id;
            cFilter.Gender = new List<String> {'Male','Female'}; //{'M','T'};
            cFilter.birthdateMonths = new List<String> {'1','2'};

            IC_TargetedClientsLists_VFCx_New.ClientFilter cFilter1 =  new IC_TargetedClientsLists_VFCx_New.ClientFilter(); 
            cFilter1.Indic10K = new List<String>{'10K This Year', '10K'};

            IC_TargetedClientsLists_VFCx_New.HierarchyLevel level1 = new IC_TargetedClientsLists_VFCx_New.HierarchyLevel();
            /*
            Map<String ,Object> m1 = new Map<String, Object>();
            List<Account> accts = [SELECT Id, Name FROM Account LIMIT 2];
            m1.put('one', accts.get(0));
            m1.put('two', accts.get(1));
            level1.children = m1;
            */
            level1.label = 'A06';
            level1.value = 'A06';

            IC_TargetedClientsLists_VFCx_New.HierarchyLevel level2 = new IC_TargetedClientsLists_VFCx_New.HierarchyLevel();
            level1.label = 'EMEA';
            level1.value = '15';

            IC_TargetedClientsLists_VFCx_New.HierarchyLevel level3 = new IC_TargetedClientsLists_VFCx_New.HierarchyLevel();
            level1.label = 'DANMARK';
            level1.value = '187';
            system.debug('\n\n HERE \n\n');

            IC_TargetedClientsLists_VFCx_New.TransactionField tField = new IC_TargetedClientsLists_VFCx_New.TransactionField('234', '234','fieldValue');
            //tField.fromValue = 'str';
            //tField.toValue = 'str';

            IC_TargetedClientsLists_VFCx_New.TransactionFilter transactionParams =  new IC_TargetedClientsLists_VFCx_New.TransactionFilter();
            transactionParams.FirstTransactionDateFrom = '2016-08-02';
            transactionParams.FirstTransactionDateTo = '2016-08-03';
            transactionParams.LastTransactionDateFrom = '2016-08-02';
            transactionParams.LastTransactionDateTo = '2016-08-03';
            // transactionParams.spent = // type: Map<String, TransactionField>

            Map<String, IC_TargetedClientsLists_VFCx_New.TransactionField> spentObj = new Map<String, IC_TargetedClientsLists_VFCx_New.TransactionField>();
            /* spentObj.put('Last36MSpend',tField);
            spentObj.put('Last36MAccessoriesSpend',tField);
            spentObj.put('Last36MJewelrySpend',tField);
            spentObj.put('Last36MLeatherGoodSpend',tField);
            spentObj.put('Last36MReadyToWearSpend',tField);
            spentObj.put('Last36MShoesSpend',tField);
            spentObj.put('Last36MSpend',tField);
            spentObj.put('Last36MWatchSpend',tField);*/
            transactionParams.spent = spentObj;

            transactionParams.userCurrency = 'EUR'; //Userinfo.userCurrency;
            
            IC_TargetedClientsLists_VFCx_New.AcountResponse aFilter1 =  new IC_TargetedClientsLists_VFCx_New.AcountResponse();
            IC_TargetedClientsLists_VFCx_New.AcountResponse aFilter2 =  new IC_TargetedClientsLists_VFCx_New.AcountResponse('11', '22', '33');
      
            IC_TargetedClientsLists_VFCx_New.ClientListResponse clFilter =  new IC_TargetedClientsLists_VFCx_New.ClientListResponse();
            clFilter.numberOfListsCreated = 1;
            clFilter.numberOfMembersCreated = 1;
            clFilter.numberOfListFailures = 1;
            clFilter.numberOfMembersFailures = 1;
            clFilter.errorMessage = 'str';
                    
            Test.startTest();
            
            IC_TargetedClientsLists_VFCx_New.nullOrEmpty('string');
            IC_TargetedClientsLists_VFCx_New.nullOrEmpty(3);
            IC_TargetedClientsLists_VFCx_New.nullOrEmpty(new List<String> {});
            IC_TargetedClientsLists_VFCx_New.nullOrEmpty(new Map<String,object>());
            Map<String ,Object> map2 = new Map<String, Object>();
            List<Account> accts = [SELECT Id, Name FROM Account LIMIT 2];
            map2.put('one', accts.get(0));
            map2.put('two', accts.get(1));
            IC_TargetedClientsLists_VFCx_New.nullOrEmpty(map2);

            IC_TargetedClientsLists_VFCx_New.StringToDate('2016-08-10');

            IC_TargetedClientsLists_VFCx_New.findUserLike('someText');
            IC_TargetedClientsLists_VFCx_New.findAdvisorLike('someText');
            User user1 = IC_TargetedClientsLists_VFCx_New.getCurrentUser();

            Map<String,IC_TargetedClientsLists_VFCx_New.HierarchyLevel> sFilter = new Map<String,IC_TargetedClientsLists_VFCx_New.HierarchyLevel> ();
            sFilter.put('2',level3);
            sFilter.put('1',level2);
            sFilter.put('3',level2);
            sFilter.put('4',level1);
            sFilter.put('5',level2);

            List<String> dreamIds = new List<String> {'83866129','83630074','16565461','52649172', '55061268', '55030035', '19084605', '55275803', '18522140', '53600010'};
            List<Account> acctsList1 = IC_TargetedClientsLists_VFCx_New.targetClientSearch(acc1.Id, sFilter, cFilter, pFilter,iFilter, dreamIds, transactionParams);
            
            List<Account> acctsList2 = IC_TargetedClientsLists_VFCx_New.transferClientSearch(acc1.Id, sFilter, cFilter, pFilter,iFilter, dreamIds, transactionParams);
            Object obj1 = IC_TargetedClientsLists_VFCx_New.AassignClients(new List<String> {acc1.Id,acc2.Id},Userinfo.getUserId());
            List<Account> acctsList3 = IC_TargetedClientsLists_VFCx_New.PerformClientSearch('SELECT Id, Name, PersonContactId,ownerId, owner.Name FROM Account ', acc1.Id, sFilter, cFilter, pFilter,iFilter, dreamIds, transactionParams,true);
            List<String> strLIst1 = IC_TargetedClientsLists_VFCx_New.getPickListVal('Contact', 'Segmentation__c', 'New Client');
            // List<IC_TargetedClientsLists_VFCx_New.AcountResponse> acountResponseLIst1 = IC_TargetedClientsLists_VFCx_New.launchSearchIds(sFilter, cFilter, pFilter,iFilter, dreamIds, transactionParams,true,'');
            
            List<IC_TargetedClientsLists_VFCx_New.AcountResponse> acountResponseLIst1 = IC_TargetedClientsLists_VFCx_New.launchSearchIds(
                new Map<String, IC_TargetedClientsLists_VFCx_New.HierarchyLevel>(), 
                new IC_TargetedClientsLists_VFCx_New.ClientFilter(),
                new IC_TargetedClientsLists_VFCx_New.ProductFilter(),
                new IC_TargetedClientsLists_VFCx_New.InterestFilter(), 
                dreamIds,
                new IC_TargetedClientsLists_VFCx_New.TransactionFilter(), 
                true,
                ''
            );
                 
            System.debug('My debug statement' + acountResponseLIst1);

            //String str = IC_TargetedClientsLists_VFCx_New.buildTransactionFilter(transactionParams);
            String str1 = IC_TargetedClientsLists_VFCx_New.addStringsToQuery('SELECT Id, Name, PersonContactId,ownerId, owner.Name FROM Account ', dreamIds, '', '', ''); // FROM Account LIMIT 2 ', dreamIds, 'conjunction', 'condition', 'field');
            

            List<User> userList1 =  IC_TargetedClientsLists_VFCx_New.GetAdvisorsByStore(sFilter, 'e', true);
            List<User> userList11 =  IC_TargetedClientsLists_VFCx_New.GetAdvisorsByStore(sFilter, 't', true);
            List<User> userList12 =  IC_TargetedClientsLists_VFCx_New.GetAdvisorsByStore(sFilter, '1', true);
            List<User> userList13 =  IC_TargetedClientsLists_VFCx_New.GetAdvisorsByStore(sFilter, '2', true);
            List<User> userList14 =  IC_TargetedClientsLists_VFCx_New.GetAdvisorsByStore(sFilter, '3', true);
            List<User> userList15 =  IC_TargetedClientsLists_VFCx_New.GetAdvisorsByStore(sFilter, '4', true);
            List<User> userList16 =  IC_TargetedClientsLists_VFCx_New.GetAdvisorsByStore(sFilter, '5', true);

            IC_TargetedClientsLists_VFCx_New.ClientListResponse clientListResponse1 = IC_TargetedClientsLists_VFCx_New.createClientList(acountResponseLIst1, 'listName', 'listDescription', String.valueOf(System.Today()), '', '');
           
            //List<CLI_CliList__c> listCLI_CliList1 = IC_TargetedClientsLists_VFCx_New.getClientLists('listName', sFilter);
            //List<CLI_CliList__c> listCLI_CliList2 = IC_TargetedClientsLists_VFCx_New.getClientLists('listName',sFilter);
            //List<CLI_CliList__c> listCLI_CliList3 = IC_TargetedClientsLists_VFCx_New.getClientLists('u', sFilter);

            String str2 = IC_TargetedClientsLists_VFCx_New.getUserNameFromId(Userinfo.getUserId());


            // MORE         
            Map<String,IC_TargetedClientsLists_VFCx_New.HierarchyLevel> sFilter2 = new Map<String,IC_TargetedClientsLists_VFCx_New.HierarchyLevel> ();
            sFilter2.put('0',level2);
            List<User> userList34 =  IC_TargetedClientsLists_VFCx_New.GetAdvisorsByStore(sFilter2, 'h', true);

            Map<String,IC_TargetedClientsLists_VFCx_New.HierarchyLevel> sFilter3 = new Map<String,IC_TargetedClientsLists_VFCx_New.HierarchyLevel> ();
            sFilter3.put('4',level3);
            List<User> userList35 =  IC_TargetedClientsLists_VFCx_New.GetAdvisorsByStore(sFilter3, 'y', true);


            Map<String,IC_TargetedClientsLists_VFCx_New.HierarchyLevel> sFilter4 = new Map<String,IC_TargetedClientsLists_VFCx_New.HierarchyLevel> ();
            sFilter4.put('3',level3);
            List<User> userList36 =  IC_TargetedClientsLists_VFCx_New.GetAdvisorsByStore(sFilter4, 'u', true);


            Map<String,IC_TargetedClientsLists_VFCx_New.HierarchyLevel> sFilter5 = new Map<String,IC_TargetedClientsLists_VFCx_New.HierarchyLevel> ();
            sFilter5.put('2',level3);
            List<User> userList37 =  IC_TargetedClientsLists_VFCx_New.GetAdvisorsByStore(sFilter5, 'l', true);


            Map<String,IC_TargetedClientsLists_VFCx_New.HierarchyLevel> sFilter6 = new Map<String,IC_TargetedClientsLists_VFCx_New.HierarchyLevel> ();
            sFilter6.put('1',level3);
            List<User> userList38 =  IC_TargetedClientsLists_VFCx_New.GetAdvisorsByStore(sFilter6, 'o', true);

            /*
            Map<String,IC_TargetedClientsLists_VFCx_New.HierarchyLevel> sFilter7 = new Map<String,IC_TargetedClientsLists_VFCx_New.HierarchyLevel> ();
            sFilter7.put('5',level3);
            List<User> userList39 =  IC_TargetedClientsLists_VFCx_New.GetAdvisorsByStore(sFilter7, 's');
            */


            // MORE
            List<IC_TargetedClientsLists_VFCx_New.AcountResponse> acountResponseLIst2 = IC_TargetedClientsLists_VFCx_New.launchSearchIds(sFilter2, cFilter1, pFilter,iFilter, dreamIds, NULL, true,'');
            List<IC_TargetedClientsLists_VFCx_New.AcountResponse> acountResponseLIst3 = IC_TargetedClientsLists_VFCx_New.launchSearchIds(sFilter3, cFilter, pFilter,iFilter, dreamIds, NULL, true,'');
            List<IC_TargetedClientsLists_VFCx_New.AcountResponse> acountResponseLIst4 = IC_TargetedClientsLists_VFCx_New.launchSearchIds(sFilter4, cFilter, pFilter,iFilter, dreamIds, NULL, true,'');
            List<IC_TargetedClientsLists_VFCx_New.AcountResponse> acountResponseLIst5 = IC_TargetedClientsLists_VFCx_New.launchSearchIds(sFilter5, cFilter, pFilter,iFilter, dreamIds, NULL, true,'');
            List<IC_TargetedClientsLists_VFCx_New.AcountResponse> acountResponseLIst6 = IC_TargetedClientsLists_VFCx_New.launchSearchIds(sFilter6, cFilter, pFilter,iFilter, dreamIds, NULL, true,'');

            IC_TargetedClientsLists_VFCx_New.PerformClientSearch('SELECT Id, Name, PersonContactId,ownerId, owner.Name FROM Account ', acc1.Id, sFilter2, cFilter, pFilter,iFilter, dreamIds, transactionParams,true);
            IC_TargetedClientsLists_VFCx_New.PerformClientSearch('SELECT Id, Name, PersonContactId,ownerId, owner.Name FROM Account ', acc1.Id, sFilter3, cFilter, pFilter,iFilter, dreamIds, transactionParams,true);
            IC_TargetedClientsLists_VFCx_New.PerformClientSearch('SELECT Id, Name, PersonContactId,ownerId, owner.Name FROM Account ', acc1.Id, sFilter4, cFilter, pFilter,iFilter, dreamIds, transactionParams,true);
            IC_TargetedClientsLists_VFCx_New.PerformClientSearch('SELECT Id, Name, PersonContactId,ownerId, owner.Name FROM Account ', acc1.Id, sFilter5, cFilter, pFilter,iFilter, dreamIds, transactionParams,true);
            IC_TargetedClientsLists_VFCx_New.PerformClientSearch('SELECT Id, Name, PersonContactId,ownerId, owner.Name FROM Account ', acc1.Id, sFilter6, cFilter, pFilter, iFilter,dreamIds, transactionParams,true);

            IC_TargetedClientsLists_VFCx_New.wideSearch(sFilter, cFilter, pFilter, iFilter, dreamIds, transactionParams, false);
            IC_TargetedClientsLists_VFCx_New.DeactivateClientLists(cli_list);

            Test.stopTest();
            
        }
    }

    static testMethod void testDeactivateExpiredClientLists() {
        Database.executeBatch(new IM_DeactivateExpiredClientListsBatch(), 1000);
    }
}