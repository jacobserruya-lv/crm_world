@isTest
private class AccountBeforeUpdateTriggerTest {
    @isTest
    static void testTrigger() {
                // Run the trigger logic as the current user
                User usTest = [select id from user where id = '0050H00000BVfjyQAD'];

                System.runAs(usTest) {
                    Id personAccountRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ACC_PersonAccount').getRecordTypeId();
                    List<Account> accounts = new List<Account>();
                    for (Integer i = 0; i < 5; i++) {
                        Account acc = new Account(
                                                  Source__c = 'WeChat',
                                                  LastName ='Test Client',
                                                  RecordTypeId = personAccountRTId
                                                );
                                                accounts.add(acc);
                    }
                    insert accounts;
                }
    }
}