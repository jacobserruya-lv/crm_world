@isTest
private class IM_BatchCareServiceStatusFlow_TEST {
	
	@isTest static void test_method_one() {       
        Id StoreCareRTId = Schema.SObjectType.CareService__c.getRecordTypeInfosByDeveloperName().get('StoreCareService').getRecordTypeId();	
		
		ID batchprocessid;
        Store__c store1= new Store__c(RetailStoreId__c = 'A06');
		insert store1;
        Account acc = ICX_TestFactory.createAccount();
        insert acc;
        CareService__c cs = new CareService__c(recordTypeId = StoreCareRTId, Client__c =acc.Id, StoreRetailCode__c = 'A06', Store__c = store1.Id, MyRepairStatus__c = 'Draft');
        CareService__c cs1 = new CareService__c(recordTypeId = StoreCareRTId,Client__c =acc.Id, StoreRetailCode__c = 'A06',Store__c = store1.Id, MyRepairStatus__c = 'createdInStore');
        CareService__c cs2 = new CareService__c(recordTypeId = StoreCareRTId,Client__c =acc.Id, StoreRetailCode__c = 'A06',Store__c = store1.Id, MyRepairStatus__c = 'orderPendingValidation');
        CareService__c cs3 = new CareService__c(recordTypeId = StoreCareRTId,Client__c =acc.Id, StoreRetailCode__c = 'A06',Store__c = store1.Id, MyRepairStatus__c = 'waitingForSpareParts');
        CareService__c cs4 = new CareService__c(recordTypeId = StoreCareRTId,Client__c =acc.Id, StoreRetailCode__c = 'A06',Store__c = store1.Id, MyRepairStatus__c = 'waitingForSpareParts');
        CareService__c cs5 = new CareService__c(recordTypeId = StoreCareRTId,Client__c =acc.Id, StoreRetailCode__c = 'A06',Store__c = store1.Id, MyRepairStatus__c = 'shippedToStore');
        CareService__c cs6 = new CareService__c(recordTypeId = StoreCareRTId,Client__c =acc.Id, StoreRetailCode__c = 'A06',Store__c = store1.Id, MyRepairStatus__c = 'clientContacted');
        CareService__c cs7 = new CareService__c(recordTypeId = StoreCareRTId,Client__c =acc.Id, StoreRetailCode__c = 'A06',Store__c = store1.Id, MyRepairStatus__c = 'sentToRMS');

        List<CareService__c> careList = new List<CareService__c>{cs, cs1, cs2,cs3, cs4, cs5, cs6, cs7};
        try{
            insert careList;
        }catch(DMLException dmlexp){
            system.debug('DMLException while inserting careList  ====> '+dmlexp.getMessage());
        }
        cs.Last_MyRepair_Status_Changed_Date__c = Date.today().addDays(-7);
        cs1.Last_MyRepair_Status_Changed_Date__c = Date.today().addDays(-7);
        cs2.Last_MyRepair_Status_Changed_Date__c = Date.today().addDays(-30);
        cs3.Last_MyRepair_Status_Changed_Date__c = Date.today().addDays(-14);
        cs4.Last_MyRepair_Status_Changed_Date__c = Date.today().addDays(-28);
        cs5.Last_MyRepair_Status_Changed_Date__c = Date.today().addDays(-14);
        cs6.Last_MyRepair_Status_Changed_Date__c = Date.today().addDays(-7);
        cs7.Last_MyRepair_Status_Changed_Date__c = Date.today().addDays(-90);
        cs7.IsToDo__c = true;
        cs7.Followup_Status__c = 'Closed';
      
        update cs7;
        System.debug('#### cs7 : ' + cs7);
        System.debug('#### cs7.Last_MyRepair_Status_Changed_Date__c : ' + cs7.Last_MyRepair_Status_Changed_Date__c);
        System.debug('#### cs7.MyRepair_CreatedDate__c : ' + cs7.MyRepair_CreatedDate__c);
       // System.debug('#### cs7.MyRepair_CreatedDate__c : ' + cs7.MyRepair_CreatedDate__c);

        List<CareService__c> careListUPDATE = new List<CareService__c>{cs, cs1, cs2,cs3, cs4, cs5, cs6, cs7};
        try{
           update careListUPDATE;     
        }catch(DMLException dmle){
            system.debug('BNG 29/10/2021  <==>  DMLException while updating careListUPDATE  ====> '+dmle.getMessage()); 
        }
        //update careListUPDATE;
        cs.Followup_Status__c = 'Closed';
        update cs;

        cs.Last_MyRepair_Status_Changed_Date__c = Date.today().addDays(-8);
        cs.Last_FollowUpStatus_Changed_Date__c = Date.today().addDays(-7);
        update cs;
        
		test.startTest();
		IM_BatchCareServiceStatusFlow bat = new IM_BatchCareServiceStatusFlow();	
        batchprocessid=Database.executeBatch(bat);     
        bat.execute(null,careListUPDATE);

        test.stopTest();

	}

	
	
	
}