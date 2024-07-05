@isTest
private class IC_TargetedClientsLists_VFCx_TEST{

    static testMethod void myTargetedClientsListsTest() {
        // Recover info of the current user
        User thisUser = [select Id from User where Id = :UserInfo.getUserId()];
        
        // Data Model       
        list<Account> lAccount = new list<Account>();
        
        Account oAcc1 = new Account(
            LastName = 'TCLTest',
            FirstName='TCLTest',
            DREAMID__c = '1515',
            Salutation = 'Mr',
            LastTrans__pc = System.Today(),
            Segmentation__pc = 'VIC',
            PersonDoNotCall = true,
            PersonHasOptedOutOfEmail = true,
            DoNotSMS__pc = true,
            DoNotContactbyPost__pc = true,
            BirthdateMonth__pc = '1',
            Gender__pc = 'Male',
            HistoricalSpendEUR__pc = 250000
        );
        lAccount.add(oAcc1);
        
        Account oAcc2 = new Account(
            LastName = 'TCLTest2',
            FirstName='TCLTest2',
            DREAMID__c = '1616',
            Salutation = 'Mr',
            LastTrans__pc = System.Today(),
            Segmentation__pc = 'VIC',
            PersonDoNotCall = true,
            PersonHasOptedOutOfEmail = true,
            DoNotSMS__pc = true,
            DoNotContactbyPost__pc = true,
            BirthdateMonth__pc = '1',
            Gender__pc = 'Male',
            HistoricalSpendEUR__pc = 250000
        );
        lAccount.add(oAcc2);    
        
        insert lAccount;
        
        // Change the owner from 'DREAM' to the current user
        lAccount.clear();
        
        oAcc1.OwnerId = thisUser.Id;
        lAccount.add(oAcc1);
        
        oAcc2.OwnerId = thisUser.Id;
        lAccount.add(oAcc2);
        
        update lAccount;
        
        list<PPR_PurchProduct__c> lPP = new list<PPR_PurchProduct__c>();
        
        ICONSettings__c iconSet = new ICONSettings__c();
		iconSet.ExcepPurchaseUSD__c=2000;
		iconSet.Exceptional_Purchase_Currency__c='USD';
		iconSet.ShowWeChat__c = 'JAPAN';
		insert iconSet; 
        
        PPR_PurchProduct__c oPP1 = new PPR_PurchProduct__c(
            Client__c = oAcc1.Id,
            PurchasedDate__c = System.Today(),
            ProductLine__c = 'Shoes',
            SKU__c = '1515',
            TicketNumber__c = '789'
            
        );
        lPP.add(oPP1);
        
        PPR_PurchProduct__c oPP2 = new PPR_PurchProduct__c(
            Client__c = oAcc2.Id,
            PurchasedDate__c = System.Today(),
            ProductLine__c = 'Shoes',
            SKU__c = '1515',
            TicketNumber__c = '788'
        );
        lPP.add(oPP2);

        insert lPP;     
        
        // ICONSettings__c
        ICONSettings__c userIS = new ICONSettings__c(setupownerid=UserInfo.getUserId(), Targeted_Clients_Lists_PaginationSize__c=1);
        Database.UpsertResult oUpsertResult = Database.upsert(userIS);      
                
        // Start test
        test.starttest();
        
        IC_TargetedClientsLists_VFCx oTCLCont = new IC_TargetedClientsLists_VFCx();
        oTCLCont.oSearchAccount.TECH_OutreachFrom__pc = Date.today().addMonths(-1);
        oTCLCont.oSearchAccount.TECH_OutreachTo__pc = Date.today();
        //oTCLCont.setOutreachScope(new String[]{System.Label.IC_Last_Store_Outreach});
        oTCLCont.getOutreachScopeItems();
        oTCLCont.getOutreachScope();
        oTCLCont.getLogicOperators();
        oTCLCont.getBirthdateMonth();
        oTCLCont.getGender();
        oTCLCont.getOperator3();
        oTCLCont.getOperator4();
        oTCLCont.getProductGender();
        oTCLCont.getlSMS();
        oTCLCont.getlEmail();
        oTCLCont.getlCall();
        oTCLCont.getlPost();
        
        // Execute all methods of the controller
        oTCLCont.getProductCategory();
        oTCLCont.getActionType();
        oTCLCont.getCurrency();
        oTCLCont.getSpendField();
        oTCLCont.getOperator();
        oTCLCont.getSpendField2();
        oTCLCont.getOperator2();
        oTCLCont.getSegmentation();
    
        oTCLCont.oSearchAccount.TECH_LastPurchasedDateFrom__pc = System.today().toStartOfMonth().addMonths(-1);
        oTCLCont.oSearchAccount.TECH_LastPurchasedDateTo__pc = System.today().toStartOfMonth().addMonths(1);
        //oTCLCont.oSearchAccount.Segmentation__pc = 'VIC';
        oTCLCont.oSearchAccount.DREAMID__c = '1515,1616';
        oTCLCont.oSearchAccount.PersonDoNotCall = true;
        oTCLCont.oSearchAccount.PersonHasOptedOutOfEmail = true;
        oTCLCont.oSearchAccount.DoNotSMS__pc = true;
        oTCLCont.oSearchAccount.DoNotContactbyPost__pc = true;
        oTCLCont.oSearchAccount.BirthdateMonth__pc = '1';
        oTCLCont.oSearchAccount.Gender__pc = 'Male';
        oTCLCont.oSearchAccount.OwnerId = thisUser.Id;
        oTCLCont.sCurrency = 'EUR';
        oTCLCont.sSpendField = 'HistoricalSpend';
        oTCLCont.iSpendAmount = 200000;
        oTCLCont.sOperator = 'greater or equal';
        oTCLCont.sSpendField2 = 'HistoricalSpend';
        oTCLCont.iSpendAmount2 = 300000;
        oTCLCont.sOperator2 = 'less or equal';      

        oTCLCont.oSearchPurchasedProduct.TECH_PurchasedDateFrom__c = System.today().toStartOfMonth().addMonths(-1);
        oTCLCont.oSearchPurchasedProduct.TECH_PurchasedDateTo__c = System.today().toStartOfMonth().addMonths(1);
        oTCLCont.lProductCategory.add('Shoes');
        oTCLCont.lProductCategory.add('Watches');
        oTCLCont.oSearchPurchasedProduct.SKU__c = '1616';
        oTCLCont.lSegmentation.add('VIC');

        // Search will return no result as SKU is not OK
        oTCLCont.searchClients();
        //system.assertEquals(oTCLCont.lClientsList.size(), 0);
        
        // Search will return two rows 
        oTCLCont.oSearchPurchasedProduct.SKU__c = '1515,1616';
        oTCLCont.searchClients();
        //system.assertEquals(oTCLCont.lClientsList.size(), 2);
        
        // Execute all pagination methods
        oTCLCont.nextList();
        oTCLCont.previousList();
        oTCLCont.firstList();
        oTCLCont.lastList();        
        
        // Execute sort method
        oTCLCont.SortField = 'Name';
        oTCLCont.doSort(); // ASC
        oTCLCont.doSort(); // DESC
        oTCLCont.SortField = 'Segmentation';
        oTCLCont.doSort(); // ASC
        oTCLCont.doSort(); // DESC
        oTCLCont.SortField = 'LastTrans';
        oTCLCont.doSort(); // ASC
        oTCLCont.doSort(); // DESC
        oTCLCont.SortField = 'OwnerName';
        oTCLCont.doSort(); // ASC
        oTCLCont.doSort(); // DESC
        oTCLCont.SortField = 'CVER'; // this shouldn't be the case
        oTCLCont.doSort();
        
        // Save will fail as client list name is not provided
        oTCLCont.saveClientsLists();
        
        // Save will fail as no client is selected
        oTCLCont.oClientsList.Name = 'TEST Client List';
        for(integer i=0; i< oTCLCont.lClientsList.size(); i++){
            oTCLCont.lClientsList[i].TECH_Selected__pc= false;
        }       
        oTCLCont.saveClientsLists();

        // Save will be OK
        for(integer i=0; i< oTCLCont.lClientsList.size(); i++){
            oTCLCont.lClientsList[i].TECH_Selected__pc= true;
        }
        oTCLCont.saveClientsLists();
        
        // P.B.D
        oTCLCont.setOutreachScope(new String[]{System.Label.IC_Last_Store_Outreach});
        oTCLCont.searchClients();
        
        // Stop test
        test.stoptest();
    }
}