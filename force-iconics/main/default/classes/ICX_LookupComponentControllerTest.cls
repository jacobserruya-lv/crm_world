@isTest
public class ICX_LookupComponentControllerTest {
    @isTest
    static void search_should_return_Account() {
        Id [] fixedResults = new Id[1];
        Account account = createTestAccount('Account', 'test@test.com');
        fixedResults[0]=account.Id;
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();

        List<LookupSearchResult> results = ICX_LookupComponentController.search('test@test.com', selectedIds, null);
      


        System.assertEquals(1, results.size());
        System.assertEquals(account.Id, results.get(0).getId());
        System.assertEquals('Account', results.get(0).getSObjectType());
        System.assertEquals(account.LastName, results.get(0).getTitle());
        System.assertEquals(account.PersonEmail, results.get(0).getSubtitle());

    }

    @isTest
    static void search_should_not_return_selected_item() {
        Id [] fixedResults = new Id[1];
        Account account1 = createTestAccount('Account1','test1@test.com');
        fixedResults.add(account1.Id);
        Account account2 = createTestAccount('Account2','test2@test.com');
        fixedResults.add(account2.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();
        selectedIds.add(account2.Id);

        List<LookupSearchResult> results = ICX_LookupComponentController.search('test1@test.com', selectedIds, null);

        System.assertEquals(1, results.size());
        System.assertEquals(account1.Id, results.get(0).getId());
    }

    private static Account createTestAccount(String name,string email) {
        Account account = new Account(LastName = name,PersonEmail = email );
        insert account;
        return account;
    }
}