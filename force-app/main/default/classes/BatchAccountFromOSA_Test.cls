// VB 23/04/2021

@isTest
private class BatchAccountFromOSA_Test {
    @isTest
    static void testBatch() {	
            User testUser = ICX_TestFactory.createUser(ICX_TestFactory.PROFILE_SYSTEM_ADMINNISTRATOR);
        	testUser.BypassWF__c = true;
        	testUser.BypassVR__c = true;
            testUser.Country__c = 'FRANCE';
            insert testUser;
    
            System.runAs(testUser) {
                List<Account> accList = new List<Account>();
                List<event> evList = new List<event>();
                
                for (Integer i=0; i<4; i++) {
                    Account acc = ICX_TestFactory.createAccount();
                    acc.FirstName = 'OSA'+i;
                    acc.ProspectForDream__c = False;
                    acc.PersonMobilePhone = '0667645263';
                    acc.IsProspect__pc = true; 
                    acc.Source__c ='On App'; 
                    acc.Date_Identity__pc = null;
                    acc.Can_Be_Contacted_By_Email__pc = (i ==2) ? true : false;
                   	
                    accList.add(acc);
                }
                insert accList;
                
                Id recordetypeid = Schema.SObjectType.event.getRecordTypeInfosByName().get('Online Appointment').getRecordTypeId();
                Date dt = System.today().addDays(-29); //-29 otherwise upon creation with -30 salesforce puts -31
                for (Account acc: AccList) {
                    event e = new event(Recordtypeid = recordetypeid, activityDate = dt, WhatId = acc.Id, DurationInMinutes = 60, ActivityDateTime = dt);
                    evList.add(e);
                }
                insert evList;
                
                // case 1 -- Account has a linked case
                Case cas = ICX_TestFactory.createCase(accList[0].Id);
                insert cas;
                
                // case 2 -- Account has a linked apt
                event e = new event(Recordtypeid = recordetypeid, WhatId = accList[1].Id, DurationInMinutes = 60, ActivityDateTime = System.today());
                insert e;
                
                // case 3 -- Account can be contacted by email (Can_Be_Contacted_By_Email__pc = true)
                // case 4 -- Account cannot be contacted by email (Can_Be_Contacted_By_Email__pc = false)
                
                               
                BatchAccountFromOSAScheduler myScheduler = new BatchAccountFromOSAScheduler();
                String sch = '0 0 23 L * ?';
                Test.startTest();
                system.schedule('Test check', sch, myScheduler);
                myScheduler.execute(null);
                Test.stopTest();
                
                List<Account> accFinal = [SELECT Id, FirstName, ProspectForDream__c, TECH_CandidateToDeletion__c, PersonMobilePhone FROM Account WHERE Id in :AccList];
                Integer finalAssert = 0;
                String Error = 'Failed cases : ';
                
                for (Account acc: AccFinal) {
                    System.debug(acc);
                    if (acc.FirstName == 'OSA0' || acc.FirstName == 'OSA1') {
                        if (acc.ProspectForDream__c == false) {
                            finalAssert+=1;
                        } else {
                            Error = Error+'case 1 or 2 : Account with case or linked apt updated |';
                        }
                    } else if (acc.FirstName == 'OSA2') {
                        if (acc.ProspectForDream__c == true & acc.PersonMobilePhone == null) {
                            finalAssert+=1;
                        } else {
                            Error = Error+'case 3 : Account to update not updated |';
                        }
                    } else {
                        if (acc.ProspectForDream__c == true & acc.TECH_CandidateToDeletion__c == true) {
                            finalAssert+=1;
                        } else {
                            Error = Error+'case 4 : Account to delete not deleted';
                        }
                    }      
            	}
                System.assertEquals(4, finalAssert , Error);
                    
        }
        
    }
}